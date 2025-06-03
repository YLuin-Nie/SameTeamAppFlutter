import 'package:freezed_annotation/freezed_annotation.dart';

part 'redeemed_reward_model.freezed.dart';
part 'redeemed_reward_model.g.dart';

@freezed
class RedeemedReward with _$RedeemedReward {
  const factory RedeemedReward({
    required int redemptionId,
    required int userId,
    required int rewardId,
    required String name,
    required int pointsSpent,
    required String dateRedeemed,
  }) = _RedeemedReward;

  factory RedeemedReward.fromJson(Map<String, dynamic> json) =>
      _$RedeemedRewardFromJson(json);
}
