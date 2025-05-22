// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardImpl _$$RewardImplFromJson(Map<String, dynamic> json) => _$RewardImpl(
      rewardId: (json['rewardId'] as num).toInt(),
      name: json['name'] as String,
      cost: (json['cost'] as num).toInt(),
    );

Map<String, dynamic> _$$RewardImplToJson(_$RewardImpl instance) =>
    <String, dynamic>{
      'rewardId': instance.rewardId,
      'name': instance.name,
      'cost': instance.cost,
    };
