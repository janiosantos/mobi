import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'achievement.g.dart';

enum AchievementType {
  milestone,
  progressive,
  secret,
  challenge,
}

@JsonSerializable()
class Achievement extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final AchievementType type;
  @JsonKey(name: 'target_value')
  final int targetValue;
  @JsonKey(name: 'target_metric')
  final String targetMetric;
  @JsonKey(name: 'xp_reward')
  final int xpReward;
  @JsonKey(name: 'money_reward')
  final double moneyReward;
  final Map<String, dynamic>? badge;
  @JsonKey(name: 'is_repeatable')
  final bool isRepeatable;
  final AchievementProgress? progress;

  const Achievement({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    required this.targetMetric,
    required this.xpReward,
    required this.moneyReward,
    this.badge,
    this.isRepeatable = false,
    this.progress,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        icon,
        type,
        targetValue,
        targetMetric,
        xpReward,
        moneyReward,
        badge,
        isRepeatable,
        progress,
      ];

  Achievement copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? icon,
    AchievementType? type,
    int? targetValue,
    String? targetMetric,
    int? xpReward,
    double? moneyReward,
    Map<String, dynamic>? badge,
    bool? isRepeatable,
    AchievementProgress? progress,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      targetMetric: targetMetric ?? this.targetMetric,
      xpReward: xpReward ?? this.xpReward,
      moneyReward: moneyReward ?? this.moneyReward,
      badge: badge ?? this.badge,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      progress: progress ?? this.progress,
    );
  }

  bool get isCompleted => progress?.isCompleted ?? false;
  double get progressPercentage => progress?.percentage ?? 0.0;
}

@JsonSerializable()
class AchievementProgress extends Equatable {
  final int current;
  final int target;
  final double percentage;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'times_completed')
  final int timesCompleted;

  const AchievementProgress({
    required this.current,
    required this.target,
    required this.percentage,
    required this.isCompleted,
    this.completedAt,
    this.timesCompleted = 0,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementProgressToJson(this);

  @override
  List<Object?> get props => [
        current,
        target,
        percentage,
        isCompleted,
        completedAt,
        timesCompleted,
      ];
}
