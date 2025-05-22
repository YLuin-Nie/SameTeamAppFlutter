import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/team_model.dart';
import '../models/chore_model.dart';

class ParentDashboardScreen extends StatefulWidget {
  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int currentUserId = -1;
  int? currentTeamId;
  String teamName = '';
  List<User> children = [];
  List<Chore> allChores = [];
  List<Chore> completedChores = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('userId') ?? -1;
    if (currentUserId != -1) {
      fetchDashboardData();
    } else {
      showToast('User ID not found');
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      final users = await ApiService.fetchUsers();
      final me = users.firstWhere((u) => u.userId == currentUserId, orElse: () => User(userId: -1, role: '', username: '', email: ''));

      if (me.teamId == null) {
        setState(() {
          teamName = 'No Team';
          children = [];
          allChores = [];
          completedChores = [];
        });
        return;
      }

      final team = await ApiService.fetchTeam(me.teamId!);
      final chores = await ApiService.fetchChores();
      final completed = await ApiService.fetchCompletedChores();

      setState(() {
        currentTeamId = team.teamId;
        teamName = team.teamName;
        children = users.where((u) => u.role == 'Child' && u.teamId == team.teamId).toList();
        allChores = chores;
        completedChores = completed;
      });
    } catch (e) {
      showToast("Error loading dashboard: $e");
    }
  }

  List<Chore> get filteredChores {
    final now = DateTime.now();
    final end = now.add(Duration(days: 6));
    final ids = children.map((c) => c.userId).toSet();

    return allChores.where((chore) {
      final assigned = DateTime.parse(chore.dateAssigned);
      final inRange = selectedDate != null
          ? assigned.year == selectedDate!.year &&
          assigned.month == selectedDate!.month &&
          assigned.day == selectedDate!.day
          : assigned.isAfter(now.subtract(Duration(days: 1))) &&
          assigned.isBefore(end.add(Duration(days: 1)));

      return !chore.completed && ids.contains(chore.assignedTo) && inRange;
    }).toList();
  }

  int getLevelIndex(int points) {
    final thresholds = [0, 200, 400, 600, 1000, 10000];
    for (int i = 0; i < thresholds.length; i++) {
      if (points < thresholds[i]) return i - 1 >= 0 ? i - 1 : 0;
    }
    return thresholds.length - 2;
  }

  Color getLevelColor(int levelIndex) {
    final colors = [
      Colors.grey[300],
      Colors.green[200],
      Colors.blue[200],
      Colors.yellow[200],
      Colors.orange[200],
    ];
    return colors[levelIndex] ?? Colors.grey;
  }

  void showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parent Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Team: ${teamName.isEmpty ? 'Loading...' : teamName}", style: TextStyle(fontSize: 18)),

              SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: Text("Create")),
                  SizedBox(width: 8),
                  ElevatedButton(onPressed: () {}, child: Text("Join")),
                  SizedBox(width: 8),
                  ElevatedButton(onPressed: () {}, child: Text("Add")),
                ],
              ),

              SizedBox(height: 16),
              Text("Children Levels", style: TextStyle(fontWeight: FontWeight.bold)),

              ...children.map((child) {
                final points = completedChores
                    .where((c) => c.assignedTo == child.userId)
                    .fold(0, (sum, c) => sum + c.points);
                final levelIndex = getLevelIndex(points);

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  color: getLevelColor(levelIndex),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("${child.username} - Level ${levelIndex + 1} - $points pts"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () async {
                          try {
                            await ApiService.removeUserFromTeam(child.userId);
                            showToast("Removed ${child.username}");
                            fetchDashboardData();
                          } catch (e) {
                            showToast("Failed to remove user: $e");
                          }
                        },
                      )
                    ],
                  ),
                );
              }).toList(),

              SizedBox(height: 16),
              Text(
                selectedDate != null
                    ? "Chores for ${selectedDate!.toLocal().toString().split(' ')[0]}"
                    : "Upcoming Chores (Next 7 Days)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...filteredChores.map((chore) {
                final user = children.firstWhere((u) => u.userId == chore.assignedTo,
                    orElse: () => User(userId: 0, role: 'Child', username: 'Unknown', email: ''));
                return ListTile(
                  title: Text(chore.choreText),
                  subtitle: Text('${chore.dateAssigned} - ${user.username} (${chore.points} pts)'),
                );
              }),

              if (filteredChores.isEmpty) Text("No chores."),

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => setState(() => selectedDate = null), child: Text("Clear Date")),
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
                  ElevatedButton(onPressed: logout, child: Text("Log Out")),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
