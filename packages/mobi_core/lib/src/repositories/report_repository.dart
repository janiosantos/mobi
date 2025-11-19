import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/ride.dart';
import '../models/report.dart';

/// Repository for report and insights data
class ReportRepository {
  final ApiService _apiService;

  ReportRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get ride history with filters
  ///
  /// [status] - Filter by ride status
  /// [startDate] - Filter by start date (YYYY-MM-DD)
  /// [endDate] - Filter by end date (YYYY-MM-DD)
  /// [page] - Page number for pagination
  Future<Map<String, dynamic>> getRideHistory({
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final response = await _apiService.get(
        '/reports/rides',
        queryParameters: queryParams,
      );

      // Parse pagination response
      return {
        'data': (response['data'] as List<dynamic>)
            .map((e) => Ride.fromJson(e as Map<String, dynamic>))
            .toList(),
        'current_page': response['current_page'] as int,
        'last_page': response['last_page'] as int,
        'per_page': response['per_page'] as int,
        'total': response['total'] as int,
      };
    } catch (e) {
      throw Exception('Failed to fetch ride history: $e');
    }
  }

  /// Get spending summary for passengers
  ///
  /// [period] - Report period (all, week, month, year)
  Future<SpendingSummary> getSpendingSummary({
    ReportPeriod period = ReportPeriod.all,
  }) async {
    try {
      final response = await _apiService.get(
        '/reports/spending',
        queryParameters: {'period': period.value},
      );

      return SpendingSummary.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch spending summary: $e');
    }
  }

  /// Get earnings summary for drivers
  ///
  /// [period] - Report period (all, week, month, year)
  Future<EarningsSummary> getEarningsSummary({
    ReportPeriod period = ReportPeriod.all,
  }) async {
    try {
      final response = await _apiService.get(
        '/reports/earnings',
        queryParameters: {'period': period.value},
      );

      return EarningsSummary.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch earnings summary: $e');
    }
  }

  /// Get user statistics
  Future<UserStats> getUserStats() async {
    try {
      final response = await _apiService.get('/reports/stats');

      return UserStats.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  /// Export ride history to CSV
  ///
  /// [startDate] - Filter by start date (YYYY-MM-DD)
  /// [endDate] - Filter by end date (YYYY-MM-DD)
  /// Returns CSV data as list of rows
  Future<List<List<String>>> exportRideHistory({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final response = await _apiService.get(
        '/reports/export',
        queryParameters: queryParams,
      );

      final data = response['data'] as List<dynamic>;
      return data.map((row) {
        return (row as List<dynamic>).map((cell) => cell.toString()).toList();
      }).toList();
    } catch (e) {
      throw Exception('Failed to export ride history: $e');
    }
  }

  /// Convert CSV data to downloadable format
  ///
  /// [csvData] - CSV data as list of rows
  /// Returns CSV string ready for download
  String convertToCSV(List<List<String>> csvData) {
    return csvData.map((row) {
      return row.map((cell) {
        // Escape quotes and wrap in quotes if needed
        if (cell.contains(',') || cell.contains('"') || cell.contains('\n')) {
          return '"${cell.replaceAll('"', '""')}"';
        }
        return cell;
      }).join(',');
    }).join('\n');
  }

  /// Format date for API (YYYY-MM-DD)
  String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get spending comparison between periods
  ///
  /// Useful for showing growth/decline trends
  Future<Map<String, dynamic>> getSpendingComparison() async {
    try {
      final currentMonth = await getSpendingSummary(period: ReportPeriod.month);
      final currentWeek = await getSpendingSummary(period: ReportPeriod.week);
      final allTime = await getSpendingSummary(period: ReportPeriod.all);

      return {
        'current_month': currentMonth,
        'current_week': currentWeek,
        'all_time': allTime,
      };
    } catch (e) {
      throw Exception('Failed to fetch spending comparison: $e');
    }
  }

  /// Get earnings comparison between periods
  ///
  /// Useful for showing performance trends for drivers
  Future<Map<String, dynamic>> getEarningsComparison() async {
    try {
      final currentMonth = await getEarningsSummary(period: ReportPeriod.month);
      final currentWeek = await getEarningsSummary(period: ReportPeriod.week);
      final allTime = await getEarningsSummary(period: ReportPeriod.all);

      return {
        'current_month': currentMonth,
        'current_week': currentWeek,
        'all_time': allTime,
      };
    } catch (e) {
      throw Exception('Failed to fetch earnings comparison: $e');
    }
  }

  /// Get best performing hours for a driver
  ///
  /// Returns top 5 hours by average earnings
  List<HourlyPerformance> getBestPerformingHours(EarningsSummary summary) {
    final sorted = List<HourlyPerformance>.from(summary.hourlyPerformance)
      ..sort((a, b) => b.avgEarnings.compareTo(a.avgEarnings));

    return sorted.take(5).toList();
  }

  /// Get most used categories for a passenger
  ///
  /// Returns top 3 categories by ride count
  List<CategoryBreakdown> getMostUsedCategories(SpendingSummary summary) {
    final sorted = List<CategoryBreakdown>.from(summary.byCategory)
      ..sort((a, b) => b.ridesCount.compareTo(a.ridesCount));

    return sorted.take(3).toList();
  }

  /// Calculate spending trend (increasing/decreasing)
  ///
  /// Returns percentage change from previous period
  double calculateSpendingTrend(SpendingSummary summary) {
    if (summary.monthlyTrend.length < 2) return 0;

    final current = summary.monthlyTrend.first.totalSpent;
    final previous = summary.monthlyTrend[1].totalSpent;

    if (previous == 0) return 0;

    return ((current - previous) / previous) * 100;
  }

  /// Calculate earnings trend (increasing/decreasing)
  ///
  /// Returns percentage change from previous period
  double calculateEarningsTrend(EarningsSummary summary) {
    if (summary.dailyEarnings.length < 2) return 0;

    final current = summary.dailyEarnings.first.totalEarnings;
    final previous = summary.dailyEarnings[1].totalEarnings;

    if (previous == 0) return 0;

    return ((current - previous) / previous) * 100;
  }

  /// Get performance rating based on acceptance and cancellation rates
  ///
  /// Returns: 'excellent', 'good', 'average', 'poor'
  String getDriverPerformanceRating(EarningsSummary summary) {
    if (summary.acceptanceRate >= 90 && summary.cancellationRate <= 5) {
      return 'excellent';
    } else if (summary.acceptanceRate >= 75 && summary.cancellationRate <= 10) {
      return 'good';
    } else if (summary.acceptanceRate >= 60 && summary.cancellationRate <= 20) {
      return 'average';
    } else {
      return 'poor';
    }
  }

  /// Get performance rating display text
  String getPerformanceRatingDisplay(String rating) {
    switch (rating) {
      case 'excellent':
        return 'Excelente';
      case 'good':
        return 'Bom';
      case 'average':
        return 'Médio';
      case 'poor':
        return 'Ruim';
      default:
        return 'N/A';
    }
  }

  /// Get performance rating icon
  String getPerformanceRatingIcon(String rating) {
    switch (rating) {
      case 'excellent':
        return '⭐';
      case 'good':
        return '👍';
      case 'average':
        return '👌';
      case 'poor':
        return '👎';
      default:
        return '❓';
    }
  }

  /// Calculate total earnings with tips
  double getTotalEarningsWithTips(EarningsSummary summary) {
    return summary.totalEarnings + summary.totalTips;
  }

  /// Calculate total spent with tips
  double getTotalSpentWithTips(SpendingSummary summary) {
    return summary.totalSpent + summary.totalTips;
  }

  /// Get date range for period
  Map<String, String> getDateRangeForPeriod(ReportPeriod period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case ReportPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case ReportPeriod.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case ReportPeriod.all:
        return {};
    }

    return {
      'start_date': formatDateForApi(startDate),
      'end_date': formatDateForApi(now),
    };
  }

  /// Validate date range
  bool isValidDateRange(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return true;

    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      return end.isAfter(start) || end.isAtSameMomentAs(start);
    } catch (e) {
      return false;
    }
  }

  /// Get suggested export filename
  String getExportFilename({String? startDate, String? endDate}) {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    if (startDate != null && endDate != null) {
      return 'rides_${startDate}_to_${endDate}_$timestamp.csv';
    }

    return 'rides_export_$timestamp.csv';
  }
}
