// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'redeemed_reward_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RedeemedRewardImpl _$$RedeemedRewardImplFromJson(Map<String, dynamic> json) =>
    _$RedeemedRewardImpl(
      redemptionId: (json['redemptionId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      rewardId: (json['rewardId'] as num).toInt(),
      rewardName: json['rewardName'] as String,
      pointsSpent: (json['pointsSpent'] as num).toInt(),
      dateRedeemed: json['dateRedeemed'] as String,
    );

Map<String, dynamic> _$$RedeemedRewardImplToJson(
        _$RedeemedRewardImpl instance) =>
    <String, dynamic>{
      'redemptionId': instance.redemptionId,
      'userId': instance.userId,
      'rewardId': instance.rewardId,
      'rewardName': instance.rewardName,
      'pointsSpent': instance.pointsSpent,
      'dateRedeemed': instance.dateRedeemed,
    };
