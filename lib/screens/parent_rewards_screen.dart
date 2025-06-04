import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/reward_model.dart';
import '../../models/redeemed_reward_model.dart';
import '../../services/api_service.dart';
import '../widgets/dialogs/add_reward_dialog.dart';
import '../widgets/dialogs/edit_reward_dialog.dart';
import '../widgets/dialogs/reward_child_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/theme_toggle_switch.dart';

class ParentRewardsScreen extends StatefulWidget {
  final int userId;
  const ParentRewardsScreen({super.key, required this.userId});

  @override
  State<ParentRewardsScreen> createState() => _ParentRewardsScreenState();
}

class _ParentRewardsScreenState extends State<ParentRewardsScreen> {
  List<Reward> rewards = [];
  List<RedeemedReward> redeemed = [];
  List<User> children = [];
  bool isLoading = true;
  bool section2Expanded = true;
  bool section3Expanded = true;
  int userId = -1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('userId') ?? -1;

      final users = await ApiService().fetchUsers();
      final currentUser = users.firstWhere((u) => u.userId == userId);
      final parentTeamId = currentUser.teamId;

      children = users
          .where((u) => u.role == 'Child' && u.teamId == parentTeamId)
          .toList();

      rewards = await ApiService().fetchRewards();

      final allRedeemedRewards = await ApiService().fetchAllRedeemedRewards();
      redeemed = allRedeemedRewards
          .where((r) => children.any((c) => c.userId == r.userId))
          .toList()
        ..sort((a, b) => b.dateRedeemed.compareTo(a.dateRedeemed));

      setState(() => isLoading = false);

      if (kDebugMode) {
        print("User ID: $userId, Children: ${children.length}, Redeemed: ${redeemed.length}");
      }
    } catch (e) {
      if (kDebugMode) print("Error in fetchData(): $e");
      setState(() => isLoading = false);
    }
  }

  void _addNewReward() async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (_) => AddRewardDialog(
        onSubmit: (reward) async {
          await ApiService().postReward(reward);
        },
      ),
    );
    if (shouldRefresh == true) fetchData();
  }

  void _rewardAChild() async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (_) => RewardChildDialog(
        children: children,
        onSubmit: (rewardChore) async {
          await ApiService().postChore(rewardChore);
        },
      ),
    );
    if (shouldRefresh == true) fetchData();
  }

  void _editReward(Reward reward) async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (_) => EditRewardDialog(
        reward: reward,
        onSubmit: (updatedReward) async {
          await ApiService().updateReward(updatedReward.rewardId, updatedReward);
        },
      ),
    );
    if (shouldRefresh == true) fetchData();
  }

  void _deleteReward(int rewardId) async {
    await ApiService().deleteReward(rewardId);
    fetchData();
  }

  void _goToParentDashboard() {
    Navigator.pushNamed(context, '/parentDashboard', arguments: widget.userId);
  }

  void _goToAddChoreScreen() {
    Navigator.pushNamed(context, '/addChore', arguments: widget.userId);
  }

  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/parentRewards', arguments: widget.userId);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
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
      case 'Dashboard': return Icons.dashboard;
      case 'Add Chore': return Icons.add;
      case 'Rewards': return Icons.card_giftcard;
      case 'Log Out': return Icons.logout;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reward Management'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: ThemeToggleSwitch(),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text("Reward a Child"),
                    onPressed: _rewardAChild,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add New Reward"),
                    onPressed: _addNewReward,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text("Manage Rewards", style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: section2Expanded,
                onExpansionChanged: (val) => setState(() => section2Expanded = val),
                children: rewards.map((reward) => ListTile(
                  title: Text(reward.name),
                  subtitle: Text("Cost: ${reward.cost} points"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'Edit Reward',
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editReward(reward),
                        ),
                      ),
                      Tooltip(
                        message: 'Delete Reward',
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteReward(reward.rewardId),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text("Redeemed Rewards", style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: section3Expanded,
                onExpansionChanged: (val) => setState(() => section3Expanded = val),
                children: children.map((child) {
                  final childRewards = redeemed
                      .where((r) => r.userId == child.userId)
                      .toList();

                  return ExpansionTile(
                    title: Text(child.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    children: childRewards.isEmpty
                        ? [const ListTile(title: Text("No redeemed rewards."))]
                        : childRewards.map((reward) => ListTile(
                      title: Text(reward.name),
                      subtitle: Text("Points: ${reward.pointsSpent} • ${reward.dateRedeemed}"),
                    )).toList(),
                  );
                }).toList(),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomButton('Dashboard', _goToParentDashboard),
                _bottomButton('Add Chore', _goToAddChoreScreen),
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
