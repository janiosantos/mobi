import 'package:equatable/equatable.dart';

/// Vehicle category model with pricing information
class VehicleCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;
  final double minimumFare;
  final int capacity;
  final List<String> features;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VehicleCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    required this.minimumFare,
    required this.capacity,
    required this.features,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      baseFare: (json['base_fare'] as num).toDouble(),
      perKmRate: (json['per_km_rate'] as num).toDouble(),
      perMinuteRate: (json['per_minute_rate'] as num).toDouble(),
      minimumFare: (json['minimum_fare'] as num).toDouble(),
      capacity: json['capacity'] as int,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : [],
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'per_minute_rate': perMinuteRate,
      'minimum_fare': minimumFare,
      'capacity': capacity,
      'features': features,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Calculate estimated price for a ride
  double calculatePrice(double distanceKm, int durationMinutes) {
    final distanceFare = distanceKm * perKmRate;
    final timeFare = durationMinutes * perMinuteRate;
    final totalFare = baseFare + distanceFare + timeFare;

    // Apply minimum fare
    return totalFare > minimumFare ? totalFare : minimumFare;
  }

  /// Get formatted price range
  String get priceRange => 'A partir de R\$ ${minimumFare.toStringAsFixed(2)}';

  /// Get features as comma-separated string
  String get featuresString => features.join(', ');

  /// Get capacity display text
  String get capacityDisplay => capacity == 1 ? '1 pessoa' : '$capacity pessoas';

  VehicleCategory copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
    String? description,
    double? baseFare,
    double? perKmRate,
    double? perMinuteRate,
    double? minimumFare,
    int? capacity,
    List<String>? features,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      perMinuteRate: perMinuteRate ?? this.perMinuteRate,
      minimumFare: minimumFare ?? this.minimumFare,
      capacity: capacity ?? this.capacity,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        icon,
        description,
        baseFare,
        perKmRate,
        perMinuteRate,
        minimumFare,
        capacity,
        features,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}

/// Price estimate for a vehicle category
class CategoryPriceEstimate extends Equatable {
  final VehicleCategory category;
  final double distanceKm;
  final int durationMinutes;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double estimatedPrice;
  final double minimumFare;

  const CategoryPriceEstimate({
    required this.category,
    required this.distanceKm,
    required this.durationMinutes,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.estimatedPrice,
    required this.minimumFare,
  });

  factory CategoryPriceEstimate.fromJson(Map<String, dynamic> json) {
    return CategoryPriceEstimate(
      category: VehicleCategory.fromJson(json['category'] as Map<String, dynamic>),
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num).toDouble(),
      timeFare: (json['time_fare'] as num).toDouble(),
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      minimumFare: (json['minimum_fare'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'distance_km': distanceKm,
      'duration_minutes': durationMinutes,
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'time_fare': timeFare,
      'estimated_price': estimatedPrice,
      'minimum_fare': minimumFare,
    };
  }

  @override
  List<Object?> get props => [
        category,
        distanceKm,
        durationMinutes,
        baseFare,
        distanceFare,
        timeFare,
        estimatedPrice,
        minimumFare,
      ];
}
