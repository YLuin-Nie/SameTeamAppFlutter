class RedeemedReward {
  final int redemptionId;
  final int userId;
  final int rewardId;
  final String rewardName;
  final int pointsSpent;
  final String dateRedeemed;

  RedeemedReward({
    required this.redemptionId,
    required this.userId,
    required this.rewardId,
    required this.rewardName,
    required this.pointsSpent,
    required this.dateRedeemed,
  });

  factory RedeemedReward.fromJson(Map<String, dynamic> json) {
    return RedeemedReward(
      redemptionId: json['redemptionId'],
      userId: json['userId'],
      rewardId: json['rewardId'],
      rewardName: json['rewardName'],
      pointsSpent: json['pointsSpent'],
      dateRedeemed: json['dateRedeemed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'redemptionId': redemptionId,
      'userId': userId,
      'rewardId': rewardId,
      'rewardName': rewardName,
      'pointsSpent': pointsSpent,
      'dateRedeemed': dateRedeemed,
    };
  }
}
