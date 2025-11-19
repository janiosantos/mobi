import '../models/referral.dart';
import '../services/api_service.dart';

/// Repository for managing referrals
class ReferralRepository {
  final ApiService _apiService;

  ReferralRepository(this._apiService);

  /// Get my referral statistics and code
  Future<ReferralStats> getMyReferralStats() async {
    try {
      final response = await _apiService.get('/referrals/me');
      return ReferralStats.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get referral stats: $e');
    }
  }

  /// Send a referral invitation
  Future<Referral> sendInvitation({
    String? email,
    String? phone,
  }) async {
    try {
      if (email == null && phone == null) {
        throw Exception('Either email or phone is required');
      }

      final response = await _apiService.post(
        '/referrals/invite',
        data: {
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );

      return Referral.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to send invitation: $e');
    }
  }

  /// Apply a referral code (during or after registration)
  Future<Referral> applyReferralCode(String code) async {
    try {
      final response = await _apiService.post(
        '/referrals/apply',
        data: {
          'referral_code': code.toUpperCase(),
        },
      );

      return Referral.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to apply referral code: $e');
    }
  }

  /// Get referral details by code (public)
  Future<Map<String, dynamic>> getReferralByCode(String code) async {
    try {
      final response = await _apiService.get('/referrals/${code.toUpperCase()}');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to get referral: $e');
    }
  }

  /// Get my referrals (sent and received)
  Future<Map<String, dynamic>> getMyReferrals() async {
    try {
      final response = await _apiService.get('/referrals');

      final List<dynamic> madeData = response.data['data']['made'] ?? [];
      final made = madeData.map((r) => Referral.fromJson(r)).toList();

      final receivedData = response.data['data']['received'];
      final received = receivedData != null ? Referral.fromJson(receivedData) : null;

      return {
        'made': made,
        'received': received,
      };
    } catch (e) {
      throw Exception('Failed to get referrals: $e');
    }
  }

  /// Get referral leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      final response = await _apiService.get('/referrals/leaderboard');
      final List<dynamic> data = response.data['data'];
      return data.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  /// Share referral code via system share
  String generateShareMessage({
    required String referralCode,
    required String userName,
    required double referredReward,
  }) {
    return '''
🎁 ${userName} está te convidando para o MOBI!

Use o código: $referralCode

Ganhe R\$ ${referredReward.toStringAsFixed(2)} de crédito na sua primeira corrida!

Baixe o app e comece a economizar agora! 🚗
''';
  }

  /// Validate referral code format
  bool isValidReferralCodeFormat(String code) {
    // Must be 8 characters, alphanumeric
    return RegExp(r'^[A-Z0-9]{8}$').hasMatch(code.toUpperCase());
  }

  /// Generate shareable referral link
  String generateReferralLink(String referralCode) {
    // TODO: Replace with actual deep link domain
    return 'https://mobi.app/referral/$referralCode';
  }
}
