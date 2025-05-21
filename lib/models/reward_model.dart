class Reward {
  final int rewardId;
  final String name;
  final int cost;

  Reward({
    required this.rewardId,
    required this.name,
    required this.cost,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      rewardId: json['rewardId'],
      name: json['name'],
      cost: json['cost'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'name': name,
      'cost': cost,
    };
  }
}
