import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildDashboardScreen extends StatefulWidget {
  @override
  _ChildDashboardScreenState createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  int? userId;
  int totalPoints = 0;
  int unspentPoints = 0;
  List<dynamic> chores = [];
  DateTime? selectedDate;

  final api = "https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/";
  final levelThresholds = [0, 200, 400, 600, 1000, 10000];
  final levelNames = ["Beginner", "Rising Star", "Helper Pro", "Superstar", "Legend"];
  final levelColors = [Colors.grey, Colors.green[200], Colors.blue[200], Colors.yellow[200], Colors.orange[200]];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  int getLevelIndex(int pts) {
    for (int i = 0; i < levelThresholds.length; i++) {
      if (pts < levelThresholds[i]) return i - 1 >= 0 ? i - 1 : 0;
    }
    return levelThresholds.length - 2;
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final user = jsonDecode(prefs.getString('user')!);
    userId = user['userId'];

    final choresRes = await http.get(
      Uri.parse("${api}Chores"),
      headers: {'Authorization': 'Bearer $token'},
    );
    final userRes = await http.get(
      Uri.parse("${api}Users/$userId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (choresRes.statusCode == 200 && userRes.statusCode == 200) {
      final allChores = jsonDecode(choresRes.body);
      final currentUser = jsonDecode(userRes.body);

      setState(() {
        chores = allChores.where((c) => c['assignedTo'] == userId).toList();
        totalPoints = currentUser['totalPoints'];
        unspentPoints = currentUser['points'];
      });
    }
  }

  List<dynamic> get visibleChores {
    final upcoming = chores.where((c) => !c['completed']).toList();
    if (selectedDate != null) {
      return upcoming.where((c) {
        final d = DateTime.parse(c['dateAssigned']);
        return d.year == selectedDate!.year && d.month == selectedDate!.month && d.day == selectedDate!.day;
      }).toList();
    } else {
      final today = DateTime.now();
      final future = today.add(Duration(days: 7));
      return upcoming.where((c) {
        final d = DateTime.parse(c['dateAssigned']);
        return d.isAfter(today.subtract(Duration(days: 1))) && d.isBefore(future);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelIndex = getLevelIndex(totalPoints);
    final levelName = levelNames[levelIndex];
    final levelColor = levelColors[levelIndex]!;
    final nextLevel = levelThresholds[levelIndex + 1];

    return Scaffold(
      appBar: AppBar(title: Text("Child Dashboard")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Points: $totalPoints"),
            Text("Unspent Points: $unspentPoints"),
            Container(
              padding: EdgeInsets.all(12),
              color: levelColor,
              child: Text("Level ${levelIndex + 1} ($levelName) - $totalPoints pts"),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalPoints / nextLevel,
              minHeight: 10,
            ),

            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text("Select Date"),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() => selectedDate = null);
                  },
                  child: Text("Clear Date"),
                ),
              ],
            ),

            SizedBox(height: 12),
            Text(
              selectedDate != null
                  ? "Chores for ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                  : "Upcoming Chores (Next 7 Days)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            ...visibleChores.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text("${c['choreText']}\nDue: ${c['dateAssigned']} — ${c['points']} pts"),
            )),

            if (visibleChores.isEmpty)
              Text(selectedDate == null ? "No upcoming chores." : "No chores for selected date."),

            SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }
}
