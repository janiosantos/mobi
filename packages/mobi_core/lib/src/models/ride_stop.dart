import 'package:equatable/equatable.dart';

/// Ride stop model for multiple stops feature
class RideStop extends Equatable {
  final int id;
  final int rideId;
  final int stopNumber;
  final String address;
  final double latitude;
  final double longitude;
  final int waitTimeMinutes;
  final DateTime? arrivedAt;
  final DateTime? departedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RideStop({
    required this.id,
    required this.rideId,
    required this.stopNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.waitTimeMinutes,
    this.arrivedAt,
    this.departedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RideStop.fromJson(Map<String, dynamic> json) {
    return RideStop(
      id: json['id'] as int,
      rideId: json['ride_id'] as int,
      stopNumber: json['stop_number'] as int,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      waitTimeMinutes: json['wait_time_minutes'] as int,
      arrivedAt: json['arrived_at'] != null
          ? DateTime.parse(json['arrived_at'] as String)
          : null,
      departedAt: json['departed_at'] != null
          ? DateTime.parse(json['departed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'stop_number': stopNumber,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'wait_time_minutes': waitTimeMinutes,
      'arrived_at': arrivedAt?.toIso8601String(),
      'departed_at': departedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if driver has arrived at this stop
  bool get hasArrived => arrivedAt != null;

  /// Check if driver has departed from this stop
  bool get hasDeparted => departedAt != null;

  /// Check if stop is completed (arrived and departed)
  bool get isCompleted => hasArrived && hasDeparted;

  /// Check if currently at this stop (arrived but not departed)
  bool get isCurrentStop => hasArrived && !hasDeparted;

  /// Check if stop is pending (not arrived yet)
  bool get isPending => !hasArrived;

  /// Get wait time remaining in minutes
  int? get waitTimeRemaining {
    if (!hasArrived || hasDeparted) {
      return null;
    }

    final elapsedMinutes = DateTime.now().difference(arrivedAt!).inMinutes;
    final remaining = waitTimeMinutes - elapsedMinutes;

    return remaining > 0 ? remaining : 0;
  }

  /// Get status display text
  String get statusDisplay {
    if (isCompleted) return 'Concluída';
    if (isCurrentStop) return 'Aguardando';
    if (isPending) return 'Pendente';
    return 'Desconhecido';
  }

  /// Get icon for stop status
  String get statusIcon {
    if (isCompleted) return '✅';
    if (isCurrentStop) return '⏱️';
    if (isPending) return '⏳';
    return '❓';
  }

  RideStop copyWith({
    int? id,
    int? rideId,
    int? stopNumber,
    String? address,
    double? latitude,
    double? longitude,
    int? waitTimeMinutes,
    DateTime? arrivedAt,
    DateTime? departedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideStop(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      stopNumber: stopNumber ?? this.stopNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      waitTimeMinutes: waitTimeMinutes ?? this.waitTimeMinutes,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      departedAt: departedAt ?? this.departedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rideId,
        stopNumber,
        address,
        latitude,
        longitude,
        waitTimeMinutes,
        arrivedAt,
        departedAt,
        createdAt,
        updatedAt,
      ];
}
