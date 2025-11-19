import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'badge.g.dart';

enum BadgeCategory {
  rides,
  earnings,
  ratings,
  streak,
  special,
}

enum BadgeRarity {
  common,
  rare,
  epic,
  legendary,
}

@JsonSerializable()
class Badge extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final int points;
  final Map<String, dynamic>? criteria;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_earned')
  final bool? isEarned;
  @JsonKey(name: 'earned_at')
  final DateTime? earnedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.points,
    this.criteria,
    this.isActive = true,
    this.isEarned,
    this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        icon,
        category,
        rarity,
        points,
        criteria,
        isActive,
        isEarned,
        earnedAt,
      ];

  Badge copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? icon,
    BadgeCategory? category,
    BadgeRarity? rarity,
    int? points,
    Map<String, dynamic>? criteria,
    bool? isActive,
    bool? isEarned,
    DateTime? earnedAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      points: points ?? this.points,
      criteria: criteria ?? this.criteria,
      isActive: isActive ?? this.isActive,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  String get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return '#94A3B8';
      case BadgeRarity.rare:
        return '#3B82F6';
      case BadgeRarity.epic:
        return '#8B5CF6';
      case BadgeRarity.legendary:
        return '#F59E0B';
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Comum';
      case BadgeRarity.rare:
        return 'Raro';
      case BadgeRarity.epic:
        return 'Épico';
      case BadgeRarity.legendary:
        return 'Lendário';
    }
  }
}
