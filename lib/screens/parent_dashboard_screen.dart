import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:same_team_flutter/api_service.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getInt('userId') ?? -1;
    if (currentUserId != -1) {
      fetchDashboardData();
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      final users = await ApiService.fetchUsers();
      final chores = await ApiService.fetchChores();
      final completed = await ApiService.fetchCompletedChores();
      final me = users.firstWhere((u) => u.userId == currentUserId);

      setState(() {
        currentTeamId = me.teamId;
        teamName = me.teamName ?? '';
        children = users.where((u) => u.role == 'Child' && u.teamId == me.teamId).toList();
        allChores = chores;
        completedChores = completed;
      });
    } catch (e) {
      showToast('Error loading dashboard: $e');
    }
  }

  void showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Create Team"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _teamNameController, decoration: InputDecoration(labelText: 'Team Name')),
            TextField(controller: _teamPasswordController, decoration: InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                final team = await ApiService.createTeam(currentUserId, _teamNameController.text, _teamPasswordController.text);
                showToast("Team created: ${team.teamName}");
                fetchDashboardData();
                Navigator.pop(context);
              } catch (e) {
                showToast("Create team failed: $e");
              }
            },
            child: Text("Create"),
          )
        ],
      ),
    );
  }

  void showJoinTeamDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Join Team"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _teamNameController, decoration: InputDecoration(labelText: 'Team Name')),
            TextField(controller: _teamPasswordController, decoration: InputDecoration(labelText: 'Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                final team = await ApiService.joinTeam(currentUserId, _teamNameController.text, _teamPasswordController.text);
                showToast("Joined team: ${team.teamName}");
                fetchDashboardData();
                Navigator.pop(context);
              } catch (e) {
                showToast("Join team failed: $e");
              }
            },
            child: Text("Join"),
          )
        ],
      ),
    );
  }

  void showAddToTeamDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add User to Team"),
        content: TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'User Email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                if (currentTeamId != null) {
                  await ApiService.addUserToTeam(_emailController.text, currentTeamId!);
                  showToast("User added to team");
                  fetchDashboardData();
                  Navigator.pop(context);
                }
              } catch (e) {
                showToast("Failed to add user: $e");
              }
            },
            child: Text("Add"),
          )
        ],
      ),
    );
  }

  int getLevelIndex(int points) {
    final thresholds = [0, 200, 400, 600, 1000, 10000];
    return thresholds.indexWhere((t) => points < t) - 1;
  }

  Color getLevelColor(int levelIndex) {
    final colors = [
      Colors.grey,
      Colors.green[100],
      Colors.blue[100],
      Colors.yellow[100],
      Colors.orange[100],
    ];
    return colors[levelIndex] ?? Colors.grey;
  }

  List<Chore> getFilteredChores() {
    final now = DateTime.now();
    final end = now.add(Duration(days: 6));
    final ids = children.map((e) => e.userId).toList();

    return allChores.where((chore) {
      final assignedDate = DateTime.parse(chore.dateAssigned);
      final matchTeam = ids.contains(chore.assignedTo);
      final inRange = selectedDate != null
          ? assignedDate.year == selectedDate!.year &&
          assignedDate.month == selectedDate!.month &&
          assignedDate.day == selectedDate!.day
          : assignedDate.isAfter(now.subtract(Duration(days: 1))) &&
          assignedDate.isBefore(end.add(Duration(days: 1)));

      return matchTeam && !chore.completed && inRange;
    }).toList();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parent Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Team: $teamName", style: TextStyle(fontSize: 18)),
            Row(
              children: [
                ElevatedButton(onPressed: showCreateTeamDialog, child: Text("Create Team")),
                SizedBox(width: 8),
                ElevatedButton(onPressed: showJoinTeamDialog, child: Text("Join Team")),
                SizedBox(width: 8),
                ElevatedButton(onPressed: showAddToTeamDialog, child: Text("Add to Team")),
              ],
            ),
            SizedBox(height: 16),
            Text("Children Levels", style: TextStyle(fontWeight: FontWeight.bold)),
            ...children.map((child) {
              int points = completedChores.where((c) => c.assignedTo == child.userId).fold(0, (sum, c) => sum + c.points);
              int levelIndex = getLevelIndex(points);
              return Container(
                color: getLevelColor(levelIndex),
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text("${child.username} - Level ${levelIndex + 1} - $points pts")),
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
            Text("Upcoming Chores", style: TextStyle(fontWeight: FontWeight.bold)),
            ...getFilteredChores().map((chore) {
              final user = children.firstWhere((u) => u.userId == chore.assignedTo, orElse: () => User(userId: 0, username: 'Unknown', role: 'Child'));
              return ListTile(
                title: Text('${chore.choreText}'),
                subtitle: Text('${chore.dateAssigned} - ${user.username} (${chore.points} pts)'),
              );
            }).toList(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => setState(() => selectedDate = null), child: Text("Clear Date")),
                ElevatedButton(onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                }, child: Text("Select Date")),
                ElevatedButton(onPressed: logout, child: Text("Log Out")),
              ],
            )
          ],
        ),
      ),
    );
  }
}