import 'package:equatable/equatable.dart';

/// Shared ride model for carpooling functionality
class SharedRide extends Equatable {
  final int id;
  final int driverId;
  final int? vehicleId;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final DateTime departureTime;
  final int maxPassengers;
  final int currentPassengers;
  final double pricePerSeat;
  final String status; // 'scheduled', 'in_progress', 'completed', 'cancelled'
  final List<SharedRidePassenger> passengers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SharedRide({
    required this.id,
    required this.driverId,
    this.vehicleId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.departureTime,
    required this.maxPassengers,
    required this.currentPassengers,
    required this.pricePerSeat,
    required this.status,
    required this.passengers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SharedRide.fromJson(Map<String, dynamic> json) {
    return SharedRide(
      id: json['id'] as int,
      driverId: json['driver_id'] as int,
      vehicleId: json['vehicle_id'] as int?,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      maxPassengers: json['max_passengers'] as int,
      currentPassengers: json['current_passengers'] as int,
      pricePerSeat: (json['price_per_seat'] as num).toDouble(),
      status: json['status'] as String,
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((p) => SharedRidePassenger.fromJson(p))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'vehicle_id': vehicleId,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_address': pickupAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'dropoff_address': dropoffAddress,
      'departure_time': departureTime.toIso8601String(),
      'max_passengers': maxPassengers,
      'current_passengers': currentPassengers,
      'price_per_seat': pricePerSeat,
      'status': status,
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasAvailableSeats => currentPassengers < maxPassengers;
  bool get isFull => currentPassengers >= maxPassengers;

  @override
  List<Object?> get props => [
        id,
        driverId,
        vehicleId,
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffAddress,
        departureTime,
        maxPassengers,
        currentPassengers,
        pricePerSeat,
        status,
        passengers,
        createdAt,
        updatedAt,
      ];
}

/// Passenger in a shared ride
class SharedRidePassenger extends Equatable {
  final int id;
  final int passengerId;
  final String passengerName;
  final String? passengerPhotoUrl;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final String status; // 'pending', 'confirmed', 'picked_up', 'dropped_off', 'cancelled'
  final double price;
  final DateTime joinedAt;

  const SharedRidePassenger({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    this.passengerPhotoUrl,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    required this.status,
    required this.price,
    required this.joinedAt,
  });

  factory SharedRidePassenger.fromJson(Map<String, dynamic> json) {
    return SharedRidePassenger(
      id: json['id'] as int,
      passengerId: json['passenger_id'] as int,
      passengerName: json['passenger_name'] as String,
      passengerPhotoUrl: json['passenger_photo_url'] as String?,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      dropoffLatitude: (json['dropoff_latitude'] as num).toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num).toDouble(),
      dropoffAddress: json['dropoff_address'] as String,
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passenger_id': passengerId,
      'passenger_name': passengerName,
      'passenger_photo_url': passengerPhotoUrl,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'pickup_address': pickupAddress,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'dropoff_address': dropoffAddress,
      'status': status,
      'price': price,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        passengerId,
        passengerName,
        passengerPhotoUrl,
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffAddress,
        status,
        price,
        joinedAt,
      ];
}
