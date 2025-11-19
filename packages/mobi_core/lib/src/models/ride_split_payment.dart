import 'package:equatable/equatable.dart';

/// Ride split payment model
class RideSplitPayment extends Equatable {
  final int id;
  final int rideId;
  final int? userId;
  final int? invitedBy;
  final String inviteCode;
  final double amount;
  final double? percentage;
  final String status;
  final DateTime? acceptedAt;
  final DateTime? paidAt;
  final DateTime? declinedAt;
  final DateTime? expiresAt;
  final String? declineReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RideSplitPayment({
    required this.id,
    required this.rideId,
    this.userId,
    this.invitedBy,
    required this.inviteCode,
    required this.amount,
    this.percentage,
    required this.status,
    this.acceptedAt,
    this.paidAt,
    this.declinedAt,
    this.expiresAt,
    this.declineReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RideSplitPayment.fromJson(Map<String, dynamic> json) {
    return RideSplitPayment(
      id: json['id'] as int,
      rideId: json['ride_id'] as int,
      userId: json['user_id'] as int?,
      invitedBy: json['invited_by'] as int?,
      inviteCode: json['invite_code'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: json['percentage'] != null
          ? (json['percentage'] as num).toDouble()
          : null,
      status: json['status'] as String,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      declinedAt: json['declined_at'] != null
          ? DateTime.parse(json['declined_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      declineReason: json['decline_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'user_id': userId,
      'invited_by': invitedBy,
      'invite_code': inviteCode,
      'amount': amount,
      'percentage': percentage,
      'status': status,
      'accepted_at': acceptedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'declined_at': declinedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'decline_reason': declineReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if split payment is pending
  bool get isPending => status == 'pending';

  /// Check if split payment was accepted
  bool get isAccepted => status == 'accepted';

  /// Check if split payment was paid
  bool get isPaid => status == 'paid';

  /// Check if split payment was declined
  bool get isDeclined => status == 'declined';

  /// Check if split payment is expired
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
      case 'accepted':
        return 'Aceito';
      case 'paid':
        return 'Pago';
      case 'declined':
        return 'Recusado';
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
      case 'accepted':
        return '✅';
      case 'paid':
        return '💰';
      case 'declined':
        return '❌';
      case 'expired':
        return '⌛';
      default:
        return '❓';
    }
  }

  /// Get formatted amount
  String get formattedAmount => 'R\$ ${amount.toStringAsFixed(2)}';

  /// Get time until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now());
  }

  /// Check if can be accepted
  bool get canBeAccepted => isPending && !isExpired;

  /// Check if can be declined
  bool get canBeDeclined => isPending && !isExpired;

  /// Check if can be paid
  bool get canBePaid => (isPending || isAccepted) && !isExpired;

  RideSplitPayment copyWith({
    int? id,
    int? rideId,
    int? userId,
    int? invitedBy,
    String? inviteCode,
    double? amount,
    double? percentage,
    String? status,
    DateTime? acceptedAt,
    DateTime? paidAt,
    DateTime? declinedAt,
    DateTime? expiresAt,
    String? declineReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideSplitPayment(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      userId: userId ?? this.userId,
      invitedBy: invitedBy ?? this.invitedBy,
      inviteCode: inviteCode ?? this.inviteCode,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      paidAt: paidAt ?? this.paidAt,
      declinedAt: declinedAt ?? this.declinedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      declineReason: declineReason ?? this.declineReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rideId,
        userId,
        invitedBy,
        inviteCode,
        amount,
        percentage,
        status,
        acceptedAt,
        paidAt,
        declinedAt,
        expiresAt,
        declineReason,
        createdAt,
        updatedAt,
      ];
}

/// Split fare participant for creating split payments
class SplitFareParticipant {
  final int? userId;
  final String? email;
  final String? phone;
  final double? amount;
  final double? percentage;

  SplitFareParticipant({
    this.userId,
    this.email,
    this.phone,
    this.amount,
    this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (amount != null) 'amount': amount,
      if (percentage != null) 'percentage': percentage,
    };
  }
}

/// Split method enum
enum SplitMethod {
  equal,
  custom,
  percentage,
}

extension SplitMethodExtension on SplitMethod {
  String get value {
    switch (this) {
      case SplitMethod.equal:
        return 'equal';
      case SplitMethod.custom:
        return 'custom';
      case SplitMethod.percentage:
        return 'percentage';
    }
  }

  String get displayName {
    switch (this) {
      case SplitMethod.equal:
        return 'Dividir Igualmente';
      case SplitMethod.custom:
        return 'Valores Personalizados';
      case SplitMethod.percentage:
        return 'Porcentagem';
    }
  }
}
