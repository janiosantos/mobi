import 'package:equatable/equatable.dart';

/// Scheduled ride model
class ScheduledRide extends Equatable {
  final int id;
  final String rideNumber;
  final int passengerId;
  final int? driverId;
  final int vehicleCategoryId;
  final String status;
  final bool isScheduled;
  final DateTime? scheduledAt;
  final DateTime? scheduledPickupWindowStart;
  final DateTime? scheduledPickupWindowEnd;
  final String? scheduledStatus;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final double estimatedPrice;
  final String? passengerNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduledRide({
    required this.id,
    required this.rideNumber,
    required this.passengerId,
    this.driverId,
    required this.vehicleCategoryId,
    required this.status,
    required this.isScheduled,
    this.scheduledAt,
    this.scheduledPickupWindowStart,
    this.scheduledPickupWindowEnd,
    this.scheduledStatus,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.estimatedPrice,
    this.passengerNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduledRide.fromJson(Map<String, dynamic> json) {
    return ScheduledRide(
      id: json['id'] as int,
      rideNumber: json['ride_number'] as String,
      passengerId: json['passenger_id'] as int,
      driverId: json['driver_id'] as int?,
      vehicleCategoryId: json['vehicle_category_id'] as int,
      status: json['status'] as String,
      isScheduled: json['is_scheduled'] as bool? ?? false,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      scheduledPickupWindowStart: json['scheduled_pickup_window_start'] != null
          ? DateTime.parse(json['scheduled_pickup_window_start'] as String)
          : null,
      scheduledPickupWindowEnd: json['scheduled_pickup_window_end'] != null
          ? DateTime.parse(json['scheduled_pickup_window_end'] as String)
          : null,
      scheduledStatus: json['scheduled_status'] as String?,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      passengerNotes: json['passenger_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_number': rideNumber,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'vehicle_category_id': vehicleCategoryId,
      'status': status,
      'is_scheduled': isScheduled,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'scheduled_pickup_window_start': scheduledPickupWindowStart?.toIso8601String(),
      'scheduled_pickup_window_end': scheduledPickupWindowEnd?.toIso8601String(),
      'scheduled_status': scheduledStatus,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_address': pickupAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'dropoff_address': dropoffAddress,
      'estimated_price': estimatedPrice,
      'passenger_notes': passengerNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if ride is a scheduled ride
  bool get isScheduledRide => isScheduled;

  /// Check if within pickup window
  bool get isWithinPickupWindow {
    if (!isScheduled || scheduledPickupWindowStart == null || scheduledPickupWindowEnd == null) {
      return false;
    }

    final now = DateTime.now();
    return now.isAfter(scheduledPickupWindowStart!) && now.isBefore(scheduledPickupWindowEnd!);
  }

  /// Check if ride can be updated
  bool get canBeUpdated {
    if (!isScheduled || scheduledStatus != 'pending') {
      return false;
    }

    if (scheduledAt == null) return false;

    // Cannot update rides scheduled within 30 minutes
    final minutesUntilScheduled = scheduledAt!.difference(DateTime.now()).inMinutes;
    return minutesUntilScheduled >= 30;
  }

  /// Check if ride can be cancelled
  bool get canBeCancelled {
    return isScheduled && (scheduledStatus == 'pending' || scheduledStatus == 'confirmed');
  }

  /// Get time until scheduled pickup
  Duration? get timeUntilPickup {
    if (scheduledAt == null) return null;
    return scheduledAt!.difference(DateTime.now());
  }

  /// Get formatted scheduled time
  String get formattedScheduledTime {
    if (scheduledAt == null) return 'N/A';

    // Format: "25 Jan, 14:30"
    final day = scheduledAt!.day;
    final month = _getMonthName(scheduledAt!.month);
    final hour = scheduledAt!.hour.toString().padLeft(2, '0');
    final minute = scheduledAt!.minute.toString().padLeft(2, '0');

    return '$day $month, $hour:$minute';
  }

  /// Get status display text
  String get statusDisplay {
    switch (scheduledStatus) {
      case 'pending':
        return 'Pendente';
      case 'confirmed':
        return 'Confirmada';
      case 'driver_assigned':
        return 'Motorista Atribuído';
      case 'cancelled':
        return 'Cancelada';
      default:
        return scheduledStatus ?? 'Desconhecido';
    }
  }

  /// Get status icon
  String get statusIcon {
    switch (scheduledStatus) {
      case 'pending':
        return '⏰';
      case 'confirmed':
        return '✅';
      case 'driver_assigned':
        return '🚗';
      case 'cancelled':
        return '❌';
      default:
        return '❓';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  ScheduledRide copyWith({
    int? id,
    String? rideNumber,
    int? passengerId,
    int? driverId,
    int? vehicleCategoryId,
    String? status,
    bool? isScheduled,
    DateTime? scheduledAt,
    DateTime? scheduledPickupWindowStart,
    DateTime? scheduledPickupWindowEnd,
    String? scheduledStatus,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? dropoffAddress,
    double? estimatedPrice,
    String? passengerNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduledRide(
      id: id ?? this.id,
      rideNumber: rideNumber ?? this.rideNumber,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      vehicleCategoryId: vehicleCategoryId ?? this.vehicleCategoryId,
      status: status ?? this.status,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      scheduledPickupWindowStart: scheduledPickupWindowStart ?? this.scheduledPickupWindowStart,
      scheduledPickupWindowEnd: scheduledPickupWindowEnd ?? this.scheduledPickupWindowEnd,
      scheduledStatus: scheduledStatus ?? this.scheduledStatus,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      passengerNotes: passengerNotes ?? this.passengerNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rideNumber,
        passengerId,
        driverId,
        vehicleCategoryId,
        status,
        isScheduled,
        scheduledAt,
        scheduledPickupWindowStart,
        scheduledPickupWindowEnd,
        scheduledStatus,
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffAddress,
        estimatedPrice,
        passengerNotes,
        createdAt,
        updatedAt,
      ];
}
