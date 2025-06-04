import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_model.dart';
import '../models/redeemed_reward_model.dart';
import '../services/api_service.dart';

class ChildRewardsScreen extends StatefulWidget {
  final int userId;
  const ChildRewardsScreen({super.key, required this.userId});

  @override
  State<ChildRewardsScreen> createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> {
  int userId = -1;
  int points = 0;
  bool isLoading = true;
  List<Reward> rewards = [];
  List<RedeemedReward> redeemed = [];

  @override
  void initState() {
    super.initState();
    _loadRewardsData();
  }

  Future<void> _loadRewardsData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? widget.userId;

    try {
      final users = await ApiService().fetchUsers();
      final me = users.firstWhere((u) => u.userId == userId);
      final availableRewards = await ApiService().fetchRewards();
      final myRedemptions = await ApiService().fetchRedeemedRewards(userId);

      setState(() {
        points = me.points ?? 0;
        rewards = availableRewards;
        redeemed = myRedemptions..sort((a, b) => b.dateRedeemed.compareTo(a.dateRedeemed));
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading child rewards: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _redeemReward(Reward reward) async {
    if (points < reward.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough points to redeem this reward.")),
      );
      return;
    }

    try {
      final redemption = RedeemedReward(
        redemptionId: 0,
        userId: userId,
        rewardId: reward.rewardId,
        name: reward.name,
        pointsSpent: reward.cost,
        dateRedeemed: DateTime.now().toIso8601String().split('T')[0],
      );

      final saved = await ApiService().postRedeemedReward(redemption);
      final updatedPoints = points - reward.cost;

      await ApiService().updateUserPoints(userId, updatedPoints);

      setState(() {
        points = updatedPoints;
        redeemed.insert(0, saved);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 You redeemed: ${reward.name}")),
      );
    } catch (e) {
      print("❌ Failed to redeem reward: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not complete redemption.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Child Rewards")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Unspent Points: $points", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              const Text("Available Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              rewards.isEmpty
                  ? const Text("No rewards available.")
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return Card(
                    child: ListTile(
                      title: Text("${reward.name} - ${reward.cost} pts"),
                      trailing: ElevatedButton(
                        onPressed: () => _redeemReward(reward),
                        child: const Text("Redeem"),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),

              const Text("Redeemed Rewards History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              redeemed.isEmpty
                  ? const Text("You haven't redeemed any rewards yet.")
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: redeemed.length,
                itemBuilder: (context, index) {
                  final r = redeemed[index];
                  return ListTile(
                    title: Text("${r.name} - ${r.pointsSpent} pts"),
                    subtitle: Text("Redeemed on: ${r.dateRedeemed}"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
