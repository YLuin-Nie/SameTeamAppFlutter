import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChildRewardsScreen extends StatefulWidget {
  final int userId;
  const ChildRewardsScreen({super.key, required this.userId});

  @override
  _ChildRewardsScreenState createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> {
  int? userId;
  int points = 0;
  List<dynamic> rewards = [];
  List<dynamic> redeemed = [];

  final api = "https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/";

  // 🌙 Track dark mode state
  bool _isDarkMode = false;

  // 🌙 Toggle dark mode on or off
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }
  // Helper widget to create each bottom button with icon and label
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

  // Returns the correct icon based on the label
  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return Icons.dashboard;
      case 'Chore List':
        return Icons.add;
      case 'Rewards':
        return Icons.card_giftcard;
      case 'Log Out':
        return Icons.logout;
      default:
        return Icons.help_outline;
    }
  }

  // Navigates to Parent Dashboard screen
  void _goToChildDashbaordScreen() {
    Navigator.pushNamed(context, '/childDashboard', arguments: widget.userId);
  }
  // Navigates to Add Chore screen
  void _goToChoreListScreen() {
    Navigator.pushNamed(context, '/choresList', arguments: widget.userId);
  }

  // Navigates to Rewards screen
  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/childRewards', arguments: widget.userId);
  }

  // Logs out and navigates to Sign In screen
  void _logout() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  void initState() {
    super.initState();
    loadRewards();
  }

  Future<void> loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final user = jsonDecode(prefs.getString('user')!);
    userId = user['userId'];

    final res = await http.get(Uri.parse("${api}Rewards"), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      setState(() {
        rewards = jsonDecode(res.body);
      });
      loadRedeemed();
    }
  }

  Future<void> loadRedeemed() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(Uri.parse("${api}RedeemedRewards/$userId"), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      setState(() {
        redeemed = jsonDecode(res.body);
      });
    }
    loadPoints();
  }

  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(Uri.parse("${api}Users/$userId"), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      setState(() {
        points = jsonDecode(res.body)['points'] ?? 0;
      });
    }
  }

  Future<void> redeemReward(Map reward) async {
    if (points < reward['cost']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not enough points.")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final body = {
      "redemptionId": 0,
      "userId": userId,
      "rewardId": reward['rewardId'],
      "rewardName": reward['name'],
      "pointsSpent": reward['cost'],
      "dateRedeemed": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

    final postRes = await http.post(
      Uri.parse("${api}RedeemedRewards"),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (postRes.statusCode == 200 || postRes.statusCode == 201) {
      final updatedPoints = points - reward['cost'];
      final updateRes = await http.put(
        Uri.parse("${api}Users/$userId/points"),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"points": updatedPoints}),
      );

      if (updateRes.statusCode == 200 || updateRes.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Redeemed ${reward['name']}!")));
        loadRewards(); // Refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update points.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Redemption failed.")));
    }
  }

  Widget rewardItem(Map reward) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${reward['name']} - ${reward['cost']} pts"),
        ElevatedButton(onPressed: () => redeemReward(reward), child: Text("Redeem")),
      ],
    );
  }

  Widget redeemedItem(Map item) {
    final name = item['rewardName'] ?? rewards.firstWhere(
          (r) => r['rewardId'] == item['rewardId'],
      orElse: () => {'name': 'Unnamed'},
    )['name'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$name - ${item['pointsSpent']} pts\nRedeemed on: ${item['dateRedeemed']}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Child Rewards'),
              actions: [
                Row(
                  children: [
                    const Text("🌙", style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isDarkMode,
                      onChanged: _toggleTheme,
                    ),
                  ],
                ),
              ],
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            Text("Unspent Points: $points", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),

            Text("Available Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (rewards.isEmpty) Text("No rewards available.")
            else ...rewards.map((r) => rewardItem(r)),

            Divider(height: 32, thickness: 1),

            Text("Redemption History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (redeemed.isEmpty) Text("No redemptions yet.")
            else ...redeemed.map((r) => redeemedItem(r)),
          ],
        ),
      ),
      // Bottom navigation bar using custom BottomAppBar with 4 buttons
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey[50],
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomButton('Dashboard', _goToChildDashbaordScreen),
            _bottomButton('Chore List', _goToChoreListScreen),
            _bottomButton('Rewards', _goToRewardsScreen),
            _bottomButton('Log Out', _logout),
          ],
        ),
      ),
    ),
    );
  }
}
