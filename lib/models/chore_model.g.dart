// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chore_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChoreImpl _$$ChoreImplFromJson(Map<String, dynamic> json) => _$ChoreImpl(
      choreId: (json['choreId'] as num).toInt(),
      choreText: json['choreText'] as String,
      points: (json['points'] as num).toInt(),
      assignedTo: (json['assignedTo'] as num).toInt(),
      dateAssigned: json['dateAssigned'] as String,
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$$ChoreImplToJson(_$ChoreImpl instance) =>
    <String, dynamic>{
      'choreId': instance.choreId,
      'choreText': instance.choreText,
      'points': instance.points,
      'assignedTo': instance.assignedTo,
      'dateAssigned': instance.dateAssigned,
      'completed': instance.completed,
    };
