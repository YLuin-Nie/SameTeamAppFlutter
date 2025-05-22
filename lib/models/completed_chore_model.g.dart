// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completed_chore_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompletedChoreImpl _$$CompletedChoreImplFromJson(Map<String, dynamic> json) =>
    _$CompletedChoreImpl(
      completedId: (json['completedId'] as num).toInt(),
      choreId: (json['choreId'] as num).toInt(),
      choreText: json['choreText'] as String,
      points: (json['points'] as num).toInt(),
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      dateAssigned: json['dateAssigned'] as String,
      completionDate: json['completionDate'] as String,
    );

Map<String, dynamic> _$$CompletedChoreImplToJson(
        _$CompletedChoreImpl instance) =>
    <String, dynamic>{
      'completedId': instance.completedId,
      'choreId': instance.choreId,
      'choreText': instance.choreText,
      'points': instance.points,
      'assignedTo': instance.assignedTo,
      'dateAssigned': instance.dateAssigned,
      'completionDate': instance.completionDate,
    };
