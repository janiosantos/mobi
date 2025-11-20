// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Badge _$BadgeFromJson(Map<String, dynamic> json) => Badge(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: $enumDecode(_$BadgeCategoryEnumMap, json['category']),
      rarity: $enumDecode(_$BadgeRarityEnumMap, json['rarity']),
      points: (json['points'] as num).toInt(),
      criteria: json['criteria'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      isEarned: json['is_earned'] as bool?,
      earnedAt: json['earned_at'] == null
          ? null
          : DateTime.parse(json['earned_at'] as String),
    );

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'icon': instance.icon,
      'category': _$BadgeCategoryEnumMap[instance.category]!,
      'rarity': _$BadgeRarityEnumMap[instance.rarity]!,
      'points': instance.points,
      'criteria': instance.criteria,
      'is_active': instance.isActive,
      'is_earned': instance.isEarned,
      'earned_at': instance.earnedAt?.toIso8601String(),
    };

const _$BadgeCategoryEnumMap = {
  BadgeCategory.rides: 'rides',
  BadgeCategory.earnings: 'earnings',
  BadgeCategory.ratings: 'ratings',
  BadgeCategory.streak: 'streak',
  BadgeCategory.special: 'special',
};

const _$BadgeRarityEnumMap = {
  BadgeRarity.common: 'common',
  BadgeRarity.rare: 'rare',
  BadgeRarity.epic: 'epic',
  BadgeRarity.legendary: 'legendary',
};
