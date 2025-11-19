import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_stats.g.dart';

@JsonSerializable()
class UserStats extends Equatable {
  final int level;
  @JsonKey(name: 'current_xp')
  final int currentXp;
  @JsonKey(name: 'total_xp')
  final int totalXp;
  @JsonKey(name: 'xp_to_next_level')
  final int xpToNextLevel;
  @JsonKey(name: 'progress_percentage')
  final double? progressPercentage;
  final RideStats? rides;
  final EarningsStats? earnings;
  final RatingStats? ratings;
  final StreakStats? streak;
  final BadgeStats? badges;
  final AchievementStats? achievements;

  const UserStats({
    required this.level,
    required this.currentXp,
    required this.totalXp,
    required this.xpToNextLevel,
    this.progressPercentage,
    this.rides,
    this.earnings,
    this.ratings,
    this.streak,
    this.badges,
    this.achievements,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  @override
  List<Object?> get props => [
        level,
        currentXp,
        totalXp,
        xpToNextLevel,
        progressPercentage,
        rides,
        earnings,
        ratings,
        streak,
        badges,
        achievements,
      ];
}

@JsonSerializable()
class RideStats extends Equatable {
  final int total;
  final int completed;
  final int cancelled;
  @JsonKey(name: 'completion_rate')
  final double completionRate;

  const RideStats({
    required this.total,
    required this.completed,
    required this.cancelled,
    required this.completionRate,
  });

  factory RideStats.fromJson(Map<String, dynamic> json) =>
      _$RideStatsFromJson(json);

  Map<String, dynamic> toJson() => _$RideStatsToJson(this);

  @override
  List<Object?> get props => [total, completed, cancelled, completionRate];
}

@JsonSerializable()
class EarningsStats extends Equatable {
  final double total;

  const EarningsStats({required this.total});

  factory EarningsStats.fromJson(Map<String, dynamic> json) =>
      _$EarningsStatsFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsStatsToJson(this);

  @override
  List<Object?> get props => [total];
}

@JsonSerializable()
class RatingStats extends Equatable {
  final double average;
  final int total;

  const RatingStats({
    required this.average,
    required this.total,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$RatingStatsToJson(this);

  @override
  List<Object?> get props => [average, total];
}

@JsonSerializable()
class StreakStats extends Equatable {
  final int current;
  final int longest;
  @JsonKey(name: 'last_ride_date')
  final String? lastRideDate;

  const StreakStats({
    required this.current,
    required this.longest,
    this.lastRideDate,
  });

  factory StreakStats.fromJson(Map<String, dynamic> json) =>
      _$StreakStatsFromJson(json);

  Map<String, dynamic> toJson() => _$StreakStatsToJson(this);

  @override
  List<Object?> get props => [current, longest, lastRideDate];
}

@JsonSerializable()
class BadgeStats extends Equatable {
  final int total;
  @JsonKey(name: 'by_rarity')
  final Map<String, int>? byRarity;
  final List<dynamic>? earned;

  const BadgeStats({
    required this.total,
    this.byRarity,
    this.earned,
  });

  factory BadgeStats.fromJson(Map<String, dynamic> json) =>
      _$BadgeStatsFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeStatsToJson(this);

  @override
  List<Object?> get props => [total, byRarity, earned];
}

@JsonSerializable()
class AchievementStats extends Equatable {
  final List<dynamic>? completed;
  @JsonKey(name: 'in_progress')
  final List<dynamic>? inProgress;

  const AchievementStats({
    this.completed,
    this.inProgress,
  });

  factory AchievementStats.fromJson(Map<String, dynamic> json) =>
      _$AchievementStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementStatsToJson(this);

  @override
  List<Object?> get props => [completed, inProgress];
}
