// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      cpf: json['cpf'] as String?,
      userType: json['user_type'] as String,
      isVerified: json['is_verified'] as bool,
      isActive: json['is_active'] as bool,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      birthDate: json['birth_date'] as String?,
      deviceToken: json['device_token'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      totalRatings: (json['total_ratings'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'cpf': instance.cpf,
      'user_type': instance.userType,
      'is_verified': instance.isVerified,
      'is_active': instance.isActive,
      'profile_photo_url': instance.profilePhotoUrl,
      'birth_date': instance.birthDate,
      'device_token': instance.deviceToken,
      'average_rating': instance.averageRating,
      'total_ratings': instance.totalRatings,
      'created_at': instance.createdAt?.toIso8601String(),
    };
