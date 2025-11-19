import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? cpf;
  @JsonKey(name: 'user_type')
  final String userType;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;
  @JsonKey(name: 'birth_date')
  final String? birthDate;
  @JsonKey(name: 'device_token')
  final String? deviceToken;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'total_ratings')
  final int? totalRatings;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cpf,
    required this.userType,
    required this.isVerified,
    required this.isActive,
    this.profilePhotoUrl,
    this.birthDate,
    this.deviceToken,
    this.averageRating,
    this.totalRatings,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isPassenger => userType == 'passenger';
  bool get isDriver => userType == 'driver';
  bool get isAdmin => userType == 'admin';

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        cpf,
        userType,
        isVerified,
        isActive,
        profilePhotoUrl,
        birthDate,
        deviceToken,
        averageRating,
        totalRatings,
        createdAt,
      ];
}
