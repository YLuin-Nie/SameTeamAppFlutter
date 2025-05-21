import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParentDashboardScreen extends StatefulWidget {
  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  String? teamName;
  List<dynamic> children = [];
  List<dynamic> allChores = [];
  List<dynamic> completedChores = [];
  DateTime? selectedDate;

  final List<int> thresholds = [0, 200, 400, 600, 1000, 10000];
  final List<String> levels = ["Beginner", "Rising Star", "Helper Pro", "Superstar", "Legend"];
  final List<Color> levelColors = [Colors.grey, Colors.green[200]!, Colors.blue[200]!, Colors.yellow[200]!, Colors.orange[200]!];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final currentUser = jsonDecode(prefs.getString('user')!);

    final userRes = await http.get(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (userRes.statusCode == 200) {
      final users = jsonDecode(userRes.body);
      final me = users.firstWhere((u) => u['userId'] == currentUser['userId']);
      final teamId = me['teamId'];

      setState(() {
        children = users.where((u) => u['role'] == 'Child' && u['teamId'] == teamId).toList();
      });

      // Get team name
      final teamRes = await http.get(
        Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Users/team/$teamId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (teamRes.statusCode == 200) {
        setState(() {
          teamName = jsonDecode(teamRes.body)['teamName'];
        });
      }

      // Get chores
      final choreRes = await http.get(
        Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final completeRes = await http.get(
        Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores/completed'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (choreRes.statusCode == 200 && completeRes.statusCode == 200) {
        setState(() {
          allChores = jsonDecode(choreRes.body);
          completedChores = jsonDecode(completeRes.body);
        });
      }
    }
  }

  int getLevelIndex(int points) {
    for (int i = 0; i < thresholds.length; i++) {
      if (points < thresholds[i]) return i - 1 >= 0 ? i - 1 : 0;
    }
    return levels.length - 1;
  }

  List<dynamic> getFilteredChores() {
    final userIds = children.map((c) => c['userId']).toList();
    return allChores.where((chore) {
      if (chore['completed'] == true) return false;
      if (!userIds.contains(chore['assignedTo'])) return false;

      final date = DateTime.parse(chore['dateAssigned']);
      if (selectedDate != null) {
        return date.year == selectedDate!.year &&
            date.month == selectedDate!.month &&
            date.day == selectedDate!.day;
      }

      final now = DateTime.now();
      return date.isAfter(now.subtract(Duration(days: 1))) &&
          date.isBefore(now.add(Duration(days: 7)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parent Dashboard")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Team: ${teamName ?? 'Loading...'}", style: TextStyle(fontSize: 18)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("Create")),
                ElevatedButton(onPressed: () {}, child: Text("Join")),
                ElevatedButton(onPressed: () {}, child: Text("Add")),
              ],
            ),
            SizedBox(height: 16),

            Text("Children Levels", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...children.map((child) {
              final points = completedChores
                  .where((c) => c['assignedTo'] == child['userId'])
                  .fold<int>(0, (sum, c) => sum + (c['points'] as num).toInt());
              final levelIndex = getLevelIndex(points);

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(12),
                color: levelColors[levelIndex],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${child['username']} - Level ${levelIndex + 1} (${levels[levelIndex]}) - $points pts"),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // TODO: Remove child from team
                      },
                    )
                  ],
                ),
              );
            }).toList(),

            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Text("Select Date"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() => selectedDate = null);
                  },
                  child: Text("Clear Date"),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              selectedDate == null
                  ? "Upcoming Chores (Next 7 Days)"
                  : "Chores for ${DateFormat('yyyy-MM-dd').format(selectedDate!)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...getFilteredChores().map((chore) {
              final assigned = children.firstWhere((c) => c['userId'] == chore['assignedTo'], orElse: () => null);
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${chore['choreText']} - ${chore['dateAssigned']} - ${assigned?['username'] ?? 'Unknown'} (${chore['points']} pts)",
                ),
              );
            }),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("Dashboard")),
                ElevatedButton(onPressed: () {}, child: Text("Add Chore")),
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
          ],
        ),
      ),
    );
  }
}
