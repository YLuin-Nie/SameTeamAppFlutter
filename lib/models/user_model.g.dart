// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      userId: (json['userId'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      points: (json['points'] as num?)?.toInt(),
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      teamId: (json['teamId'] as num?)?.toInt(),
      parentId: (json['parentId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'role': instance.role,
      'points': instance.points,
      'totalPoints': instance.totalPoints,
      'teamId': instance.teamId,
      'parentId': instance.parentId,
    };
