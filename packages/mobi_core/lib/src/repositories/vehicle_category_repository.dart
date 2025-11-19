import '../models/vehicle_category.dart';
import '../services/api_service.dart';

/// Repository for managing vehicle categories
class VehicleCategoryRepository {
  final ApiService _apiService;

  VehicleCategoryRepository(this._apiService);

  /// Get all active vehicle categories
  Future<List<VehicleCategory>> getCategories() async {
    try {
      final response = await _apiService.get('/vehicle-categories');
      final List<dynamic> data = response.data['data'];
      return data.map((json) => VehicleCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get vehicle categories: $e');
    }
  }

  /// Get a specific category by slug
  Future<VehicleCategory> getCategory(String slug) async {
    try {
      final response = await _apiService.get('/vehicle-categories/$slug');
      return VehicleCategory.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to get vehicle category: $e');
    }
  }

  /// Estimate price for a specific category
  Future<CategoryPriceEstimate> estimatePrice({
    required String slug,
    required double distanceKm,
    required int durationMinutes,
  }) async {
    try {
      final response = await _apiService.post(
        '/vehicle-categories/$slug/estimate',
        data: {
          'distance_km': distanceKm,
          'duration_minutes': durationMinutes,
        },
      );

      return CategoryPriceEstimate.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to estimate price: $e');
    }
  }

  /// Compare prices across all categories
  Future<List<CategoryComparison>> comparePrice({
    required double distanceKm,
    required int durationMinutes,
  }) async {
    try {
      final response = await _apiService.post(
        '/vehicle-categories/compare-price',
        data: {
          'distance_km': distanceKm,
          'duration_minutes': durationMinutes,
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => CategoryComparison.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to compare prices: $e');
    }
  }
}

/// Category price comparison model
class CategoryComparison {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final int capacity;
  final List<String> features;
  final double estimatedPrice;
  final PriceBreakdown priceBreakdown;

  CategoryComparison({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    required this.capacity,
    required this.features,
    required this.estimatedPrice,
    required this.priceBreakdown,
  });

  factory CategoryComparison.fromJson(Map<String, dynamic> json) {
    return CategoryComparison(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      capacity: json['capacity'] as int,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : [],
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      priceBreakdown: PriceBreakdown.fromJson(json['price_breakdown'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'capacity': capacity,
      'features': features,
      'estimated_price': estimatedPrice,
      'price_breakdown': priceBreakdown.toJson(),
    };
  }
}

/// Price breakdown model
class PriceBreakdown {
  final double baseFare;
  final double distanceFare;
  final double timeFare;

  PriceBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num).toDouble(),
      timeFare: (json['time_fare'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'time_fare': timeFare,
    };
  }

  double get total => baseFare + distanceFare + timeFare;
}
