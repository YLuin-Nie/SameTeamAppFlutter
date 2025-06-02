
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/dialogs/create_team_dialog.dart';
import '../widgets/dialogs/join_team_dialog.dart';
import '../widgets/dialogs/add_to_team_dialog.dart';
import '../screens/add_chore_screen.dart';
import '../screens/parent_rewards_screen.dart';
import '../models/team_model.dart';
import '../models/user_model.dart';
import '../models/chore_model.dart';
import '../models/level_model.dart';

class ParentDashboardScreen extends StatefulWidget {
  final int userId;
  const ParentDashboardScreen({super.key, required this.userId});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  DateTime? selectedDate;
  String teamName = '';
  int userId = -1;
  List<User> children = [];
  List<Chore> allChores = [];
  DateTime? selectedChoreDate;
  List<Chore> choresForSelectedDate = [];


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
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ clears token, userId, role, etc.

    // Navigate to SignIn and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  void displayChoresOnDate(DateTime selectedDate) {
    final childUserIds = children.map((c) => c.userId).toSet();

    final filtered = allChores.where((chore) {
      if (chore.dateAssigned == null || chore.assignedTo == null)
        return false;
      final date = DateTime.tryParse(chore.dateAssigned!);
      if (date == null) return false;

      // Only compare Y-M-D part
      final sameDay = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      return sameDay && childUserIds.contains(chore.assignedTo);
    }).toList();

    setState(() {
      selectedChoreDate = selectedDate;
      choresForSelectedDate = filtered;
    });
  }

  void _openDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  void _clearDateFilter() {
    setState(() => selectedDate = null);
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label),
    );
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateTeamDialog(
          userId: widget.userId,
          refreshParent: _loadDashboard,
        );
      },
    );
  }

  void _showJoinTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return JoinTeamDialog(
          userId: widget.userId,
          refreshParent: _loadDashboard,
        );
      },
    );
  }

  void _showAddToTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddToTeamDialog(
          userId: widget.userId,
          refreshParent: _loadDashboard,
        );
      },
    );
  }

  void _confirmRemoveChild(int userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Child"),
        content: Text("Are you sure you want to remove $username from the team?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              //  Navigator.of(context).pop();
              final success = await ApiService.removeUserFromTeam(userId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Removed $username")),
                );
                Navigator.of(context).pop(); // 👈 do this AFTER showing snack
                setState(() {
                  _loadDashboard(); // or fetchUsersThenChores()
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to remove $username")),
                );
                Navigator.of(context).pop(); // still pop dialog even on failure
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    //  _loadDashboard();
  }


  Future<void> _loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? -1;
    allChores = await ApiService().fetchChores();
    final users = await ApiService().fetchUsers();
    final currentUser = users.firstWhere((u) => u.userId == userId);
    final chores = await ApiService().fetchChores();

    if (userId == -1) return;

    try {
      final users = await ApiService().fetchUsers();
      final currentUser = users.firstWhere((u) => u.userId == userId);

      if (currentUser.teamId != null) {
        final team = await ApiService().fetchTeam(currentUser.teamId!);
        setState(() {
          teamName = team.teamName ?? '';
          children = users
              .where((u) =>
          u.role == 'Child' && u.teamId == currentUser.teamId)
              .toList();
        });
      }
    } catch (e) {
      print("Failed to load dashboard: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }


  List<Widget> buildChildLevels() {
    return children.map((child) {
      final points = child.totalPoints ?? 0;
      final level = Level.getLevel(points);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        color: level.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${child.username} - ${level.name} - $points pts',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: "Remove from Team",
              onPressed: () => _confirmRemoveChild(child.userId, child.username),
            ),
          ],
        ),
      );
    }).toList();
  }

  void fetchTeam(int teamId) async {
    try {
      final team = await ApiService().fetchTeam(teamId);
      setState(() {
        teamName = team.teamName ?? '';
      });
    } catch (e) {
      print('Error fetching team: $e');
    }
  }

  List<Widget> buildUpcomingChores() {
    final childIds = children.map((c) => c.userId).toSet();

    final choresToShow = allChores.where((chore) {
      final rawDate = chore.dateAssigned;
      final assignedTo = chore.assignedTo;

      if (rawDate == null || assignedTo == null) return false;
      if (!childIds.contains(assignedTo)) return false;

      final parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate == null) return false;

      if (selectedDate != null) {
        // Show only for selected date
        return parsedDate.year == selectedDate!.year &&
            parsedDate.month == selectedDate!.month &&
            parsedDate.day == selectedDate!.day;
      }

      // Show for next 7 days
      final now = DateTime.now();
      final end = now.add(const Duration(days: 6));
      return !parsedDate.isBefore(now) && !parsedDate.isAfter(end);
    }).toList()
      ..sort((a, b) => a.dateAssigned!.compareTo(b.dateAssigned!));

    if (choresToShow.isEmpty) {
      return [const Text("No chores found.")];
    }

    return choresToShow.map((chore) {
      final child = children.firstWhere(
            (c) => c.userId == chore.assignedTo,
        orElse: () => User(userId: 0, username: 'Unknown', email: '', role: ''),
      );

      return ListTile(
        title: Text('${chore.choreText} - ${chore.dateAssigned}'),
        subtitle: Text('${child.username} (${chore.points ?? 0} pts)'),
      );
    }).toList();
  }


  void fetchChores() async {
    try {
      final chores = await ApiService().fetchChores();
      setState(() {
        allChores = chores;
      });
    } catch (e) {
      print('Error fetching chores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Parent Dashboard'),
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
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Team: $teamName', style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton('Create Team', _showCreateTeamDialog),
                      _buildActionButton('Join Team', _showJoinTeamDialog),
                      _buildActionButton('Add to Team', _showAddToTeamDialog),
                    ]),

                const Text('Children:', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...buildChildLevels(),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _openDatePicker,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text("Select a Date"),
                      ),
                      ElevatedButton(
                        onPressed: _clearDateFilter,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text("Clear Date Filter"),
                      ),
                    ]),
                const SizedBox(height: 20),
                Text(
                  selectedDate == null
                      ? 'Upcoming Chores (Next 7 Days)'
                      : 'Chores for ${selectedDate!
                      .toLocal()
                      .toString()
                      .split(" ")[0]}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...buildUpcomingChores(),
                const SizedBox(height: 10),
              ]),
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
}