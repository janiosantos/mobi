import 'package:equatable/equatable.dart';

/// Referral model
class Referral extends Equatable {
  final int id;
  final int referrerId;
  final int? referredId;
  final String referralCode;
  final String? referredEmail;
  final String? referredPhone;
  final String status;
  final double referrerCredit;
  final double referredCredit;
  final bool referrerCreditApplied;
  final bool referredCreditApplied;
  final DateTime? registeredAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Referral({
    required this.id,
    required this.referrerId,
    this.referredId,
    required this.referralCode,
    this.referredEmail,
    this.referredPhone,
    required this.status,
    required this.referrerCredit,
    required this.referredCredit,
    required this.referrerCreditApplied,
    required this.referredCreditApplied,
    this.registeredAt,
    this.completedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as int,
      referrerId: json['referrer_id'] as int,
      referredId: json['referred_id'] as int?,
      referralCode: json['referral_code'] as String,
      referredEmail: json['referred_email'] as String?,
      referredPhone: json['referred_phone'] as String?,
      status: json['status'] as String,
      referrerCredit: (json['referrer_credit'] as num).toDouble(),
      referredCredit: (json['referred_credit'] as num).toDouble(),
      referrerCreditApplied: json['referrer_credit_applied'] as bool? ?? false,
      referredCreditApplied: json['referred_credit_applied'] as bool? ?? false,
      registeredAt: json['registered_at'] != null
          ? DateTime.parse(json['registered_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_id': referredId,
      'referral_code': referralCode,
      'referred_email': referredEmail,
      'referred_phone': referredPhone,
      'status': status,
      'referrer_credit': referrerCredit,
      'referred_credit': referredCredit,
      'referrer_credit_applied': referrerCreditApplied,
      'referred_credit_applied': referredCreditApplied,
      'registered_at': registeredAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if referral is pending
  bool get isPending => status == 'pending';

  /// Check if referred user has registered
  bool get isRegistered => status == 'registered';

  /// Check if referral is completed
  bool get isCompleted => status == 'completed';

  /// Check if referral is expired
  bool get isExpired {
    if (status == 'expired') return true;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'registered':
        return 'Registrado';
      case 'completed':
        return 'Concluído';
      case 'expired':
        return 'Expirado';
      default:
        return status;
    }
  }

  /// Get status icon
  String get statusIcon {
    switch (status) {
      case 'pending':
        return '⏳';
      case 'registered':
        return '✅';
      case 'completed':
        return '💰';
      case 'expired':
        return '❌';
      default:
        return '❓';
    }
  }

  /// Get formatted referrer credit
  String get formattedReferrerCredit => 'R\$ ${referrerCredit.toStringAsFixed(2)}';

  /// Get formatted referred credit
  String get formattedReferredCredit => 'R\$ ${referredCredit.toStringAsFixed(2)}';

  /// Get time until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }

  /// Get days until expiration
  int? get daysUntilExpiration {
    final duration = timeUntilExpiration;
    if (duration == null) return null;
    return duration.inDays;
  }

  Referral copyWith({
    int? id,
    int? referrerId,
    int? referredId,
    String? referralCode,
    String? referredEmail,
    String? referredPhone,
    String? status,
    double? referrerCredit,
    double? referredCredit,
    bool? referrerCreditApplied,
    bool? referredCreditApplied,
    DateTime? registeredAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Referral(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referredId: referredId ?? this.referredId,
      referralCode: referralCode ?? this.referralCode,
      referredEmail: referredEmail ?? this.referredEmail,
      referredPhone: referredPhone ?? this.referredPhone,
      status: status ?? this.status,
      referrerCredit: referrerCredit ?? this.referrerCredit,
      referredCredit: referredCredit ?? this.referredCredit,
      referrerCreditApplied: referrerCreditApplied ?? this.referrerCreditApplied,
      referredCreditApplied: referredCreditApplied ?? this.referredCreditApplied,
      registeredAt: registeredAt ?? this.registeredAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        referrerId,
        referredId,
        referralCode,
        referredEmail,
        referredPhone,
        status,
        referrerCredit,
        referredCredit,
        referrerCreditApplied,
        referredCreditApplied,
        registeredAt,
        completedAt,
        expiresAt,
        createdAt,
        updatedAt,
      ];
}

/// Referral statistics model
class ReferralStats extends Equatable {
  final String referralCode;
  final double referralCredits;
  final int referralsCount;
  final int successfulReferralsCount;
  final List<Referral> referrals;
  final double referrerReward;
  final double referredReward;

  const ReferralStats({
    required this.referralCode,
    required this.referralCredits,
    required this.referralsCount,
    required this.successfulReferralsCount,
    required this.referrals,
    required this.referrerReward,
    required this.referredReward,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    final List<dynamic> referralsData = json['referrals'] ?? [];
    final referrals = referralsData.map((r) => Referral.fromJson(r)).toList();

    return ReferralStats(
      referralCode: json['referral_code'] as String,
      referralCredits: (json['referral_credits'] as num).toDouble(),
      referralsCount: json['referrals_count'] as int,
      successfulReferralsCount: json['successful_referrals_count'] as int,
      referrals: referrals,
      referrerReward: (json['referrer_reward'] as num).toDouble(),
      referredReward: (json['referred_reward'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referral_code': referralCode,
      'referral_credits': referralCredits,
      'referrals_count': referralsCount,
      'successful_referrals_count': successfulReferralsCount,
      'referrals': referrals.map((r) => r.toJson()).toList(),
      'referrer_reward': referrerReward,
      'referred_reward': referredReward,
    };
  }

  /// Get formatted total credits
  String get formattedCredits => 'R\$ ${referralCredits.toStringAsFixed(2)}';

  /// Get conversion rate (successful / total)
  double get conversionRate {
    if (referralsCount == 0) return 0;
    return (successfulReferralsCount / referralsCount) * 100;
  }

  /// Get formatted conversion rate
  String get formattedConversionRate => '${conversionRate.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        referralCode,
        referralCredits,
        referralsCount,
        successfulReferralsCount,
        referrals,
        referrerReward,
        referredReward,
      ];
}

/// Leaderboard entry model
class LeaderboardEntry extends Equatable {
  final int id;
  final String name;
  final int successfulReferralsCount;
  final double referralCredits;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.successfulReferralsCount,
    required this.referralCredits,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      successfulReferralsCount: json['successful_referrals_count'] as int,
      referralCredits: (json['referral_credits'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'successful_referrals_count': successfulReferralsCount,
      'referral_credits': referralCredits,
    };
  }

  String get formattedCredits => 'R\$ ${referralCredits.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        name,
        successfulReferralsCount,
        referralCredits,
      ];
}
