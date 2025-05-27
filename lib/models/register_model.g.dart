// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterModelImpl _$$RegisterModelImplFromJson(Map<String, dynamic> json) =>
    _$RegisterModelImpl(
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      team: json['team'] as String?,
      teamPassword: json['teamPassword'] as String?,
    );

Map<String, dynamic> _$$RegisterModelImplToJson(_$RegisterModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'password': instance.password,
      'role': instance.role,
      'team': instance.team,
      'teamPassword': instance.teamPassword,
    };
