import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_model.dart';
import '../models/redeemed_reward_model.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_switch.dart';

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

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  void _goToDashboardScreen() {
    Navigator.pushNamed(context, '/childDashboard', arguments: userId);
  }

  void _goToChoresScreen() {
    Navigator.pushNamed(context, '/choresList', arguments: userId);
  }

  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/childRewards', arguments: userId);
  }

  Widget _bottomButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForLabel(label)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return Icons.dashboard;
      case 'Chores':
        return Icons.check_box;
      case 'Rewards':
        return Icons.card_giftcard;
      case 'Log Out':
        return Icons.logout;
      default:
        return Icons.help_outline;
    }
  }

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
        redeemed = myRedemptions
          ..sort((a, b) => b.dateRedeemed.compareTo(a.dateRedeemed));
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading child rewards: $e");
      }
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
      if (kDebugMode) {
        print("❌ Failed to redeem reward: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not complete redemption.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Child Rewards'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: ThemeToggleSwitch(),
              ),
            ],
          ),
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
                          trailing: Tooltip(
                            message: 'Redeem',
                            child: IconButton(
                              icon: const Icon(Icons.card_giftcard, color: Colors.blue),
                              onPressed: () => _redeemReward(reward),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text("Redeemed Rewards History",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomButton('Dashboard', _goToDashboardScreen),
                _bottomButton('Chores', _goToChoresScreen),
                _bottomButton('Rewards', _goToRewardsScreen),
                _bottomButton('Log Out', _logout),
              ],
            ),
          ),
        );
      },
    );
  }
}
