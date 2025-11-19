import 'package:equatable/equatable.dart';

/// Category breakdown for spending
class CategoryBreakdown extends Equatable {
  final String categoryName;
  final int ridesCount;
  final double totalSpent;

  const CategoryBreakdown({
    required this.categoryName,
    required this.ridesCount,
    required this.totalSpent,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryName: json['category_name'] as String,
      ridesCount: json['rides_count'] as int,
      totalSpent: (json['total_spent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'rides_count': ridesCount,
      'total_spent': totalSpent,
    };
  }

  /// Get formatted amount
  String get formattedAmount => 'R\$ ${totalSpent.toStringAsFixed(2)}';

  /// Get average per ride
  double get averagePerRide => ridesCount > 0 ? totalSpent / ridesCount : 0;

  @override
  List<Object?> get props => [categoryName, ridesCount, totalSpent];
}

/// Monthly trend data
class MonthlyTrend extends Equatable {
  final int year;
  final int month;
  final int ridesCount;
  final double totalSpent;

  const MonthlyTrend({
    required this.year,
    required this.month,
    required this.ridesCount,
    required this.totalSpent,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> json) {
    return MonthlyTrend(
      year: json['year'] as int,
      month: json['month'] as int,
      ridesCount: json['rides_count'] as int,
      totalSpent: (json['total_spent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'rides_count': ridesCount,
      'total_spent': totalSpent,
    };
  }

  /// Get month name
  String get monthName {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  /// Get formatted month/year
  String get formattedPeriod => '$monthName/$year';

  /// Get formatted amount
  String get formattedAmount => 'R\$ ${totalSpent.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [year, month, ridesCount, totalSpent];
}

/// Spending summary for passengers
class SpendingSummary extends Equatable {
  final int totalRides;
  final double totalSpent;
  final double averagePrice;
  final double totalDiscounts;
  final double totalTips;
  final double cheapestRide;
  final double mostExpensiveRide;
  final List<CategoryBreakdown> byCategory;
  final List<MonthlyTrend> monthlyTrend;
  final String period;

  const SpendingSummary({
    required this.totalRides,
    required this.totalSpent,
    required this.averagePrice,
    required this.totalDiscounts,
    required this.totalTips,
    required this.cheapestRide,
    required this.mostExpensiveRide,
    required this.byCategory,
    required this.monthlyTrend,
    required this.period,
  });

  factory SpendingSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final summary = data['summary'] as Map<String, dynamic>;

    return SpendingSummary(
      totalRides: summary['total_rides'] as int? ?? 0,
      totalSpent: (summary['total_spent'] as num?)?.toDouble() ?? 0,
      averagePrice: (summary['average_price'] as num?)?.toDouble() ?? 0,
      totalDiscounts: (summary['total_discounts'] as num?)?.toDouble() ?? 0,
      totalTips: (summary['total_tips'] as num?)?.toDouble() ?? 0,
      cheapestRide: (summary['cheapest_ride'] as num?)?.toDouble() ?? 0,
      mostExpensiveRide: (summary['most_expensive_ride'] as num?)?.toDouble() ?? 0,
      byCategory: (data['by_category'] as List<dynamic>?)
              ?.map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyTrend: (data['monthly_trend'] as List<dynamic>?)
              ?.map((e) => MonthlyTrend.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      period: data['period'] as String? ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'summary': {
          'total_rides': totalRides,
          'total_spent': totalSpent,
          'average_price': averagePrice,
          'total_discounts': totalDiscounts,
          'total_tips': totalTips,
          'cheapest_ride': cheapestRide,
          'most_expensive_ride': mostExpensiveRide,
        },
        'by_category': byCategory.map((e) => e.toJson()).toList(),
        'monthly_trend': monthlyTrend.map((e) => e.toJson()).toList(),
        'period': period,
      }
    };
  }

  /// Get formatted total spent
  String get formattedTotalSpent => 'R\$ ${totalSpent.toStringAsFixed(2)}';

  /// Get formatted average price
  String get formattedAveragePrice => 'R\$ ${averagePrice.toStringAsFixed(2)}';

  /// Get formatted total discounts
  String get formattedTotalDiscounts => 'R\$ ${totalDiscounts.toStringAsFixed(2)}';

  /// Get formatted total tips
  String get formattedTotalTips => 'R\$ ${totalTips.toStringAsFixed(2)}';

  /// Get savings from discounts
  double get savingsPercentage {
    if (totalSpent == 0) return 0;
    return (totalDiscounts / (totalSpent + totalDiscounts)) * 100;
  }

  @override
  List<Object?> get props => [
        totalRides,
        totalSpent,
        averagePrice,
        totalDiscounts,
        totalTips,
        cheapestRide,
        mostExpensiveRide,
        byCategory,
        monthlyTrend,
        period,
      ];
}

/// Daily earnings for drivers
class DailyEarning extends Equatable {
  final DateTime date;
  final int ridesCount;
  final double totalEarnings;
  final double totalTips;

  const DailyEarning({
    required this.date,
    required this.ridesCount,
    required this.totalEarnings,
    required this.totalTips,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: DateTime.parse(json['date'] as String),
      ridesCount: json['rides_count'] as int,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      totalTips: (json['total_tips'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'rides_count': ridesCount,
      'total_earnings': totalEarnings,
      'total_tips': totalTips,
    };
  }

  /// Get formatted date
  String get formattedDate {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return '${weekdays[date.weekday % 7]} ${date.day}/${date.month}';
  }

  /// Get formatted earnings
  String get formattedEarnings => 'R\$ ${totalEarnings.toStringAsFixed(2)}';

  /// Get total with tips
  double get totalWithTips => totalEarnings + totalTips;

  @override
  List<Object?> get props => [date, ridesCount, totalEarnings, totalTips];
}

/// Hourly performance for drivers
class HourlyPerformance extends Equatable {
  final int hour;
  final int ridesCount;
  final double avgEarnings;

  const HourlyPerformance({
    required this.hour,
    required this.ridesCount,
    required this.avgEarnings,
  });

  factory HourlyPerformance.fromJson(Map<String, dynamic> json) {
    return HourlyPerformance(
      hour: json['hour'] as int,
      ridesCount: json['rides_count'] as int,
      avgEarnings: (json['avg_earnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'rides_count': ridesCount,
      'avg_earnings': avgEarnings,
    };
  }

  /// Get formatted hour
  String get formattedHour => '${hour.toString().padLeft(2, '0')}:00';

  /// Get formatted average earnings
  String get formattedAvgEarnings => 'R\$ ${avgEarnings.toStringAsFixed(2)}';

  /// Get time period name
  String get periodName {
    if (hour >= 6 && hour < 12) return 'Manhã';
    if (hour >= 12 && hour < 18) return 'Tarde';
    if (hour >= 18 && hour < 24) return 'Noite';
    return 'Madrugada';
  }

  @override
  List<Object?> get props => [hour, ridesCount, avgEarnings];
}

/// Earnings summary for drivers
class EarningsSummary extends Equatable {
  final int totalRides;
  final double totalEarnings;
  final double averageEarnings;
  final double totalTips;
  final double totalDistanceKm;
  final double totalDurationMinutes;
  final double acceptanceRate;
  final double cancellationRate;
  final List<DailyEarning> dailyEarnings;
  final List<HourlyPerformance> hourlyPerformance;
  final String period;

  const EarningsSummary({
    required this.totalRides,
    required this.totalEarnings,
    required this.averageEarnings,
    required this.totalTips,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.acceptanceRate,
    required this.cancellationRate,
    required this.dailyEarnings,
    required this.hourlyPerformance,
    required this.period,
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final summary = data['summary'] as Map<String, dynamic>;

    return EarningsSummary(
      totalRides: summary['total_rides'] as int? ?? 0,
      totalEarnings: (summary['total_earnings'] as num?)?.toDouble() ?? 0,
      averageEarnings: (summary['average_earnings'] as num?)?.toDouble() ?? 0,
      totalTips: (summary['total_tips'] as num?)?.toDouble() ?? 0,
      totalDistanceKm: (summary['total_distance_km'] as num?)?.toDouble() ?? 0,
      totalDurationMinutes: (summary['total_duration_minutes'] as num?)?.toDouble() ?? 0,
      acceptanceRate: (data['acceptance_rate'] as num?)?.toDouble() ?? 0,
      cancellationRate: (data['cancellation_rate'] as num?)?.toDouble() ?? 0,
      dailyEarnings: (data['daily_earnings'] as List<dynamic>?)
              ?.map((e) => DailyEarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hourlyPerformance: (data['hourly_performance'] as List<dynamic>?)
              ?.map((e) => HourlyPerformance.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      period: data['period'] as String? ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'summary': {
          'total_rides': totalRides,
          'total_earnings': totalEarnings,
          'average_earnings': averageEarnings,
          'total_tips': totalTips,
          'total_distance_km': totalDistanceKm,
          'total_duration_minutes': totalDurationMinutes,
        },
        'acceptance_rate': acceptanceRate,
        'cancellation_rate': cancellationRate,
        'daily_earnings': dailyEarnings.map((e) => e.toJson()).toList(),
        'hourly_performance': hourlyPerformance.map((e) => e.toJson()).toList(),
        'period': period,
      }
    };
  }

  /// Get formatted total earnings
  String get formattedTotalEarnings => 'R\$ ${totalEarnings.toStringAsFixed(2)}';

  /// Get formatted average earnings
  String get formattedAverageEarnings => 'R\$ ${averageEarnings.toStringAsFixed(2)}';

  /// Get formatted total tips
  String get formattedTotalTips => 'R\$ ${totalTips.toStringAsFixed(2)}';

  /// Get formatted acceptance rate
  String get formattedAcceptanceRate => '${acceptanceRate.toStringAsFixed(1)}%';

  /// Get formatted cancellation rate
  String get formattedCancellationRate => '${cancellationRate.toStringAsFixed(1)}%';

  /// Get formatted distance
  String get formattedDistance => '${totalDistanceKm.toStringAsFixed(1)} km';

  /// Get formatted duration
  String get formattedDuration {
    final hours = (totalDurationMinutes / 60).floor();
    final minutes = (totalDurationMinutes % 60).round();
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Get earnings per km
  double get earningsPerKm {
    if (totalDistanceKm == 0) return 0;
    return totalEarnings / totalDistanceKm;
  }

  /// Get earnings per hour
  double get earningsPerHour {
    if (totalDurationMinutes == 0) return 0;
    return (totalEarnings / totalDurationMinutes) * 60;
  }

  @override
  List<Object?> get props => [
        totalRides,
        totalEarnings,
        averageEarnings,
        totalTips,
        totalDistanceKm,
        totalDurationMinutes,
        acceptanceRate,
        cancellationRate,
        dailyEarnings,
        hourlyPerformance,
        period,
      ];
}

/// Favorite category
class FavoriteCategory extends Equatable {
  final int id;
  final String name;
  final int ridesCount;

  const FavoriteCategory({
    required this.id,
    required this.name,
    required this.ridesCount,
  });

  factory FavoriteCategory.fromJson(Map<String, dynamic> json) {
    return FavoriteCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      ridesCount: json['rides_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rides_count': ridesCount,
    };
  }

  @override
  List<Object?> get props => [id, name, ridesCount];
}

/// User statistics
class UserStats extends Equatable {
  final int totalRides;
  final double averageRating;
  final int totalRatings;
  final DateTime memberSince;
  final double walletBalance;
  final double? totalSpent;
  final double? totalDiscounts;
  final FavoriteCategory? favoriteCategory;
  final double? totalEarnings;
  final double? totalTips;
  final double? totalDistanceKm;

  const UserStats({
    required this.totalRides,
    required this.averageRating,
    required this.totalRatings,
    required this.memberSince,
    required this.walletBalance,
    this.totalSpent,
    this.totalDiscounts,
    this.favoriteCategory,
    this.totalEarnings,
    this.totalTips,
    this.totalDistanceKm,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return UserStats(
      totalRides: data['total_rides'] as int? ?? 0,
      averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0,
      totalRatings: data['total_ratings'] as int? ?? 0,
      memberSince: DateTime.parse(data['member_since'] as String),
      walletBalance: (data['wallet_balance'] as num?)?.toDouble() ?? 0,
      totalSpent: (data['total_spent'] as num?)?.toDouble(),
      totalDiscounts: (data['total_discounts'] as num?)?.toDouble(),
      favoriteCategory: data['favorite_category'] != null
          ? FavoriteCategory.fromJson(data['favorite_category'] as Map<String, dynamic>)
          : null,
      totalEarnings: (data['total_earnings'] as num?)?.toDouble(),
      totalTips: (data['total_tips'] as num?)?.toDouble(),
      totalDistanceKm: (data['total_distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'total_rides': totalRides,
        'average_rating': averageRating,
        'total_ratings': totalRatings,
        'member_since': memberSince.toIso8601String(),
        'wallet_balance': walletBalance,
        if (totalSpent != null) 'total_spent': totalSpent,
        if (totalDiscounts != null) 'total_discounts': totalDiscounts,
        if (favoriteCategory != null) 'favorite_category': favoriteCategory!.toJson(),
        if (totalEarnings != null) 'total_earnings': totalEarnings,
        if (totalTips != null) 'total_tips': totalTips,
        if (totalDistanceKm != null) 'total_distance_km': totalDistanceKm,
      }
    };
  }

  /// Get formatted rating
  String get formattedRating => averageRating.toStringAsFixed(1);

  /// Get formatted wallet balance
  String get formattedWalletBalance => 'R\$ ${walletBalance.toStringAsFixed(2)}';

  /// Get member duration
  Duration get memberDuration => DateTime.now().difference(memberSince);

  /// Get formatted member duration
  String get formattedMemberDuration {
    final days = memberDuration.inDays;
    if (days < 30) return '$days dias';
    if (days < 365) return '${(days / 30).floor()} meses';
    return '${(days / 365).floor()} anos';
  }

  /// Check if is passenger
  bool get isPassenger => totalSpent != null;

  /// Check if is driver
  bool get isDriver => totalEarnings != null;

  @override
  List<Object?> get props => [
        totalRides,
        averageRating,
        totalRatings,
        memberSince,
        walletBalance,
        totalSpent,
        totalDiscounts,
        favoriteCategory,
        totalEarnings,
        totalTips,
        totalDistanceKm,
      ];
}

/// Report period enum
enum ReportPeriod {
  all,
  week,
  month,
  year,
}

extension ReportPeriodExtension on ReportPeriod {
  String get value {
    switch (this) {
      case ReportPeriod.all:
        return 'all';
      case ReportPeriod.week:
        return 'week';
      case ReportPeriod.month:
        return 'month';
      case ReportPeriod.year:
        return 'year';
    }
  }

  String get displayName {
    switch (this) {
      case ReportPeriod.all:
        return 'Tudo';
      case ReportPeriod.week:
        return 'Última Semana';
      case ReportPeriod.month:
        return 'Último Mês';
      case ReportPeriod.year:
        return 'Último Ano';
    }
  }
}
