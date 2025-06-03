import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/dialogs/create_team_dialog.dart';
import '../widgets/dialogs/join_team_dialog.dart';
import '../widgets/dialogs/add_to_team_dialog.dart';
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
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
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

  void _goToParentDashbaordScreen() {
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

  void displayChoresOnDate(DateTime selectedDate) {
    final childUserIds = children.map((c) => c.userId).toSet();
    final filtered = allChores.where((chore) {
      if (chore.dateAssigned == null || chore.assignedTo == null) return false;
      final date = DateTime.tryParse(chore.dateAssigned!);
      if (date == null) return false;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label),
    );
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CreateTeamDialog(userId: widget.userId, refreshParent: _loadDashboard),
    );
  }

  void _showJoinTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => JoinTeamDialog(userId: widget.userId, refreshParent: _loadDashboard),
    );
  }

  void _showAddToTeamDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddToTeamDialog(userId: widget.userId, refreshParent: _loadDashboard),
    );
  }

  void _confirmRemoveChild(int userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Child"),
        content: Text("Are you sure you want to remove $username from the team?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final success = await ApiService.removeUserFromTeam(userId);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Removed $username")));
                Navigator.of(context).pop();
                setState(() => _loadDashboard());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to remove $username")));
                Navigator.of(context).pop();
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? -1;
    if (userId == -1) return;

    try {
      final users = await ApiService().fetchUsers();
      final currentUser = users.firstWhere((u) => u.userId == userId);
      allChores = await ApiService().fetchChores();

      if (currentUser.teamId != null) {
        final team = await ApiService().fetchTeam(currentUser.teamId!);
        setState(() {
          teamName = team.teamName ?? '';
          children = users.where((u) => u.role == 'Child' && u.teamId == currentUser.teamId).toList();
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
            Expanded(child: Text('${child.username} - ${level.name} - $points pts', style: const TextStyle(fontSize: 16))),
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
        return parsedDate.year == selectedDate!.year &&
            parsedDate.month == selectedDate!.month &&
            parsedDate.day == selectedDate!.day;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.dateAssigned!.compareTo(b.dateAssigned!));

    if (choresToShow.isEmpty) return [const Text("No chores found.")];

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
      setState(() => allChores = chores);
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
                Switch(value: _isDarkMode, onChanged: _toggleTheme),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Team: $teamName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Create Team', _showCreateTeamDialog),
                    _buildActionButton('Join Team', _showJoinTeamDialog),
                    _buildActionButton('Add to Team', _showAddToTeamDialog),
                  ],
                ),
                const Text('Children:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...buildChildLevels(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _openDatePicker,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Select a Date"),
                    ),
                    ElevatedButton(
                      onPressed: _clearDateFilter,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text("Clear Date Filter"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  selectedDate == null
                      ? 'ALL Pending Chores'
                      : 'Chores for ${selectedDate!
                      .toLocal()
                      .toString()
                      .split(" ")[0]}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...buildUpcomingChores(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
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
      ),
    );
  }
}