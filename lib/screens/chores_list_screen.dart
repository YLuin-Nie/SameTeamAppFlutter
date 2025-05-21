import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChoresListScreen extends StatefulWidget {
  @override
  _ChoresListScreenState createState() => _ChoresListScreenState();
}

class _ChoresListScreenState extends State<ChoresListScreen> {
  int? userId;
  int points = 0;
  List<dynamic> allChores = [];
  List<dynamic> completedChores = [];

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
    return Scaffold(
      appBar: AppBar(title: Text("Your Chores")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("Dashboard")),
                ElevatedButton(onPressed: () {}, child: Text("Chores")),
                ElevatedButton(onPressed: () {}, child: Text("Rewards")),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("Logout"),
                ),
              ],
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
    );
  }
}
