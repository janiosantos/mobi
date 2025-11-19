import '../models/ride_split_payment.dart';
import '../services/api_service.dart';

/// Repository for managing split fare/split payments
class SplitFareRepository {
  final ApiService _apiService;

  SplitFareRepository(this._apiService);

  /// Create a split payment for a ride
  Future<Map<String, dynamic>> createSplitPayment({
    required int rideId,
    required SplitMethod method,
    required List<SplitFareParticipant> participants,
  }) async {
    try {
      final response = await _apiService.post(
        '/split-fare/rides/$rideId',
        data: {
          'method': method.value,
          'participants': participants.map((p) => p.toJson()).toList(),
        },
      );

      final data = response.data['data'];
      final List<dynamic> splitPaymentsData = data['split_payments'];
      final splitPayments = splitPaymentsData
          .map((json) => RideSplitPayment.fromJson(json))
          .toList();

      return {
        'ride': data['ride'],
        'split_payments': splitPayments,
      };
    } catch (e) {
      throw Exception('Failed to create split payment: $e');
    }
  }

  /// Get split payments for a ride
  Future<List<RideSplitPayment>> getSplitPaymentsForRide(int rideId) async {
    try {
      final response = await _apiService.get('/split-fare/rides/$rideId');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => RideSplitPayment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get split payments: $e');
    }
  }

  /// Get a specific split payment by invite code
  Future<RideSplitPayment> getSplitPayment(String inviteCode) async {
    try {
      final response = await _apiService.get('/split-fare/$inviteCode');
      return RideSplitPayment.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get split payment: $e');
    }
  }

  /// Accept a split payment invitation
  Future<RideSplitPayment> acceptSplitPayment(String inviteCode) async {
    try {
      final response = await _apiService.post('/split-fare/$inviteCode/accept');
      return RideSplitPayment.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to accept split payment: $e');
    }
  }

  /// Decline a split payment invitation
  Future<RideSplitPayment> declineSplitPayment({
    required String inviteCode,
    String? reason,
  }) async {
    try {
      final response = await _apiService.post(
        '/split-fare/$inviteCode/decline',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      return RideSplitPayment.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to decline split payment: $e');
    }
  }

  /// Pay a split payment
  Future<RideSplitPayment> paySplitPayment(String inviteCode) async {
    try {
      final response = await _apiService.post('/split-fare/$inviteCode/pay');
      return RideSplitPayment.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to pay split payment: $e');
    }
  }

  /// Get my split payment invitations (sent and received)
  Future<Map<String, dynamic>> getMyInvitations({int page = 1}) async {
    try {
      final response = await _apiService.get(
        '/split-fare/invitations',
        queryParameters: {'page': page.toString()},
      );

      final List<dynamic> splitPaymentsData = response.data['data'];
      final splitPayments = splitPaymentsData
          .map((json) => RideSplitPayment.fromJson(json))
          .toList();

      return {
        'split_payments': splitPayments,
        'current_page': response.data['current_page'],
        'last_page': response.data['last_page'],
        'total': response.data['total'],
      };
    } catch (e) {
      throw Exception('Failed to get invitations: $e');
    }
  }

  /// Calculate equal split amount
  double calculateEqualSplit(double totalAmount, int participantsCount) {
    if (participantsCount == 0) return 0;
    return totalAmount / participantsCount;
  }

  /// Calculate percentage split amount
  double calculatePercentageSplit(double totalAmount, double percentage) {
    return (totalAmount * percentage) / 100;
  }

  /// Validate split participants for custom method
  bool validateCustomSplit(
    List<SplitFareParticipant> participants,
    double totalAmount,
  ) {
    final totalSplitAmount = participants.fold<double>(
      0,
      (sum, p) => sum + (p.amount ?? 0),
    );

    // Allow small floating point differences
    return (totalSplitAmount - totalAmount).abs() < 0.01;
  }

  /// Validate split participants for percentage method
  bool validatePercentageSplit(List<SplitFareParticipant> participants) {
    final totalPercentage = participants.fold<double>(
      0,
      (sum, p) => sum + (p.percentage ?? 0),
    );

    // Allow small floating point differences
    return (totalPercentage - 100).abs() < 0.01;
  }

  /// Create equal split participants
  List<SplitFareParticipant> createEqualSplit({
    required double totalAmount,
    required List<int> userIds,
  }) {
    final amount = calculateEqualSplit(totalAmount, userIds.length);
    return userIds
        .map((userId) => SplitFareParticipant(
              userId: userId,
              amount: amount,
            ))
        .toList();
  }

  /// Create percentage split participants
  List<SplitFareParticipant> createPercentageSplit({
    required Map<int, double> userPercentages,
  }) {
    return userPercentages.entries
        .map((entry) => SplitFareParticipant(
              userId: entry.key,
              percentage: entry.value,
            ))
        .toList();
  }
}
