import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChoresListScreen extends StatefulWidget {
  final int userId;
  const ChoresListScreen({super.key, required this.userId});

  @override
  _ChoresListScreenState createState() => _ChoresListScreenState();
}

class _ChoresListScreenState extends State<ChoresListScreen> {
  int? userId;
  int points = 0;
  List<dynamic> allChores = [];
  List<dynamic> completedChores = [];


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
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final user = jsonDecode(prefs.getString('user')!);
    userId = user['userId'];

    final choresRes = await http.get(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final completedRes = await http.get(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores/completed'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final userRes = await http.get(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Users/${userId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (choresRes.statusCode == 200 && completedRes.statusCode == 200 && userRes.statusCode == 200) {
      setState(() {
        allChores = jsonDecode(choresRes.body)
            .where((c) => c['assignedTo'] == userId)
            .toList();
        completedChores = jsonDecode(completedRes.body)
            .where((c) => c['assignedTo'] == userId)
            .toList();
        points = jsonDecode(userRes.body)['points'] ?? 0;
      });
    }
  }

  List<dynamic> get pendingChores => allChores.where((c) => !c['completed']).toList();

  List<dynamic> get recentCompleted {
    final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    return completedChores.where((c) {
      final date = DateTime.parse(c['dateAssigned']);
      return date.isAfter(sevenDaysAgo);
    }).toList();
  }

  int get progressPercent => (allChores.isNotEmpty && allChores.every((c) => c['completed'])) ? 100 : 0;

  Future<void> markComplete(int choreId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    await http.post(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores/complete/$choreId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await loadData();
  }

  Future<void> undoComplete(int choreId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    await http.post(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores/undoComplete/$choreId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await loadData();
  }

  Widget buildChoreItem(Map chore, bool isPending) {
    final textStyle = isPending ? null : TextStyle(decoration: TextDecoration.lineThrough);
    final dateLabel = isPending ? "Due" : "Completed on";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${chore['choreText']} (${chore['points']} pts)", style: textStyle),
          Text("$dateLabel: ${chore['dateAssigned']}"),
          ElevatedButton(
            onPressed: () => isPending ? markComplete(chore['choreId']) : undoComplete(chore['choreId']),
            child: Text(isPending ? "Complete" : "Undo"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chores List'),
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
            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [],
            ),
            SizedBox(height: 20),

            Text("Your Points: $points", style: TextStyle(fontSize: 18)),
            Text("Task Completion Progress: $progressPercent%", style: TextStyle(fontSize: 18)),
            LinearProgressIndicator(value: progressPercent / 100),
            SizedBox(height: 20),

            Text("Pending Chores", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (pendingChores.isEmpty)
              Text("No pending chores.")
            else
              ...pendingChores.map((c) => buildChoreItem(c, true)),

            SizedBox(height: 20),
            Text("Completed Chores", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (recentCompleted.isEmpty)
              Text("No completed chores.")
            else
              ...recentCompleted.map((c) => buildChoreItem(c, false)),
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
    ));
  }
}
