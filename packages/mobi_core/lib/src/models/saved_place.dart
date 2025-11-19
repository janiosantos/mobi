import 'package:equatable/equatable.dart';

/// Saved place model for favorites, home, work locations
class SavedPlace extends Equatable {
  final int id;
  final int userId;
  final SavedPlaceType type;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedPlace({
    required this.id,
    required this.userId,
    required this.type,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: _typeFromString(json['type'] as String),
      label: json['label'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static SavedPlaceType _typeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return SavedPlaceType.home;
      case 'work':
        return SavedPlaceType.work;
      case 'favorite':
        return SavedPlaceType.favorite;
      default:
        return SavedPlaceType.favorite;
    }
  }

  /// Get icon for place type
  String get icon {
    switch (type) {
      case SavedPlaceType.home:
        return '🏠';
      case SavedPlaceType.work:
        return '💼';
      case SavedPlaceType.favorite:
        return '⭐';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        label,
        address,
        latitude,
        longitude,
        isDefault,
        createdAt,
        updatedAt,
      ];
}

/// Types of saved places
enum SavedPlaceType {
  home,
  work,
  favorite,
}

extension SavedPlaceTypeExtension on SavedPlaceType {
  String get displayName {
    switch (this) {
      case SavedPlaceType.home:
        return 'Casa';
      case SavedPlaceType.work:
        return 'Trabalho';
      case SavedPlaceType.favorite:
        return 'Favorito';
    }
  }
}
