import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ParentRewardsScreen extends StatefulWidget {
  final int userId;
  const ParentRewardsScreen({super.key, required this.userId});

  @override
  _ParentRewardsScreenState createState() => _ParentRewardsScreenState();
}

class _ParentRewardsScreenState extends State<ParentRewardsScreen> {
  List<dynamic> _children = [];
  List<dynamic> _rewards = [];
  Map<String, List<dynamic>> _redeemedMap = {};
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
      case 'Add Chore':
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
  void _goToParentDashbaordScreen() {
    Navigator.pushNamed(context, '/parentDashboard', arguments: widget.userId);
  }
  // Navigates to Add Chore screen
  void _goToAddChoreScreen() {
    Navigator.pushNamed(context, '/addChore', arguments: widget.userId);
  }

  // Navigates to Rewards screen
  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/parentRewards', arguments: widget.userId);
  }

  // Logs out and navigates to Sign In screen
  void _logout() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  void initState() {
    super.initState();
    _fetchUsersAndRewards();
  }

  Future<void> _fetchUsersAndRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final currentUser = jsonDecode(prefs.getString('user')!);

    final userRes = await http.get(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (userRes.statusCode == 200) {
      final users = jsonDecode(userRes.body);
      final current = users.firstWhere((u) => u['userId'] == currentUser['userId'], orElse: () => null);

      if (current != null) {
        setState(() {
          _children = users.where((u) => u['role'] == 'Child' && u['teamId'] == current['teamId']).toList();
        });
      }

      final rewardRes = await http.get(
        Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Rewards'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (rewardRes.statusCode == 200) {
        setState(() {
          _rewards = jsonDecode(rewardRes.body);
        });

        for (var child in _children) {
          final rrRes = await http.get(
            Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/RedeemedRewards/${child['userId']}'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (rrRes.statusCode == 200) {
            final rewards = jsonDecode(rrRes.body);
            setState(() {
              _redeemedMap[child['username']] = rewards;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Reward Management'),
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
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // TODO: Show reward-to-child popup
              },
              child: Text("Reward a Child"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Show add reward popup
              },
              child: Text("Add New Reward"),
            ),
            SizedBox(height: 30),

            Text("Manage Rewards", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ..._rewards.map((reward) {
              return ListTile(
                title: Text("${reward['name']} - ${reward['cost']} pts"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.edit), onPressed: () {}),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteReward(reward['rewardId']);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),

            Divider(height: 40),

            Text("Redeemed Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._redeemedMap.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ...entry.value.map((r) {
                    return Text("${r['rewardName'] ?? 'Unnamed'} - ${r['pointsSpent']} pts on ${r['dateRedeemed']}");
                  }).toList(),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
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
            _bottomButton('Dashboard', _goToParentDashbaordScreen),
            _bottomButton('Add Chore', _goToAddChoreScreen),
            _bottomButton('Rewards', _goToRewardsScreen),
            _bottomButton('Log Out', _logout),
          ],
        ),
      ),
    ));
  }

  void _deleteReward(int rewardId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final res = await http.delete(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Rewards/$rewardId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      setState(() {
        _rewards.removeWhere((r) => r['rewardId'] == rewardId);
      });
    }
  }
}
