import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chore_model.dart';
import '../models/completed_chore_model.dart';
import '../services/api_service.dart';

class ChoresListScreen extends StatefulWidget {
  final int userId;
  const ChoresListScreen({super.key, required this.userId});

  @override
  State<ChoresListScreen> createState() => _ChoresListScreenState();
}

class _ChoresListScreenState extends State<ChoresListScreen> {
  bool _isDarkMode = false;
  int userId = -1;
  int points = 0;
  int total = 0;
  int completed = 0;
  DateTime? selectedDate;
  List<Chore> chores = [];
  List<CompletedChore> completedChores = [];
  bool pendingExpanded = true;
  bool completedExpanded = false;

  void _toggleTheme(bool value) {
    setState(() => _isDarkMode = value);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  void _goToDashboardScreen() {
    Navigator.pushNamed(context, '/childDashboard', arguments: userId);
  }

  void _goToChoresScreen() {
    Navigator.pushNamed(context, '/choresList', arguments: userId);
  }

  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/childRewards', arguments: userId);
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? -1;

    try {
      final users = await ApiService().fetchUsers();
      final me = users.firstWhere((u) => u.userId == userId);
      final allChores = await ApiService().fetchChores();
      final allCompleted = await ApiService().fetchCompletedChores();

      final myChores = allChores.where((c) => c.assignedTo == userId).toList();
      final myCompleted = allCompleted
          .where((c) => c.assignedTo == userId)
          .toList()
        ..sort((a, b) => b.completionDate.compareTo(a.completionDate));

      setState(() {
        chores = myChores;
        completedChores = myCompleted;
        points = me.points ?? 0;
        total = myChores.length + myCompleted.length;
        completed = myCompleted.length;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading data: $e");
      }
    }
  }

  List<Widget> buildChoreList({required bool completedOnly}) {
    if (completedOnly) {
      final filtered = completedChores.where((c) {
        if (selectedDate == null) return true;
        final d = DateTime.tryParse(c.completionDate);
        return d != null &&
            d.year == selectedDate!.year &&
            d.month == selectedDate!.month &&
            d.day == selectedDate!.day;
      }).toList();

      if (filtered.isEmpty) return [const Text("No completed chores.")];

      return filtered.map((chore) {
        return ListTile(
          title: Text('${chore.choreText}'),
          subtitle: Text('${chore.points} pts — ${chore.completionDate}'),
          trailing: Tooltip(
            message: 'Undo',
            child: IconButton(
              icon: const Icon(Icons.undo, color: Colors.blue),
              onPressed: () => _undoCompletedChore(chore.completedId),
            ),
          ),
        );
      }).toList();
    } else {
      final filtered = chores.where((c) {
        if (c.completed == true || c.dateAssigned == null) return false;
        final d = DateTime.tryParse(c.dateAssigned);
        if (d == null) return false;
        if (selectedDate == null) return true;
        return d.year == selectedDate!.year &&
            d.month == selectedDate!.month &&
            d.day == selectedDate!.day;
      }).toList();

      if (filtered.isEmpty) return [const Text("No pending chores.")];

      return filtered.map((chore) {
        return ListTile(
          title: Text('${chore.choreText} - ${chore.dateAssigned}'),
          subtitle: Text('${chore.points ?? 0} pts'),
          trailing: Tooltip(
            message: 'Mark as Complete',
            child: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _completeChore(chore),
            ),
          ),
        );
      }).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _completeChore(Chore chore) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await ApiService().completeChoreWithDate(chore.choreId, today);
    _fetchData();
  }

  void _undoCompletedChore(int completedId) async {
    await ApiService().undoCompletedChore(completedId);
    _fetchData();
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
      case 'Chores': return Icons.check_box;
      case 'Rewards': return Icons.card_giftcard;
      case 'Log Out': return Icons.logout;
      case 'Undo': return Icons.undo;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = total == 0 ? 0 : completed / total;

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chores List'),
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
                Text('Your Unspent Points: $points'),
                const SizedBox(height: 4),
                Text('Task Completion Progress: ${(progress * 100).toStringAsFixed(0)}%'),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 16),

                ExpansionTile(
                  title: const Text("Pending Chores", style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: pendingExpanded,
                  onExpansionChanged: (val) => setState(() => pendingExpanded = val),
                  children: buildChoreList(completedOnly: false),
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text("Completed Chores", style: TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: completedExpanded,
                  onExpansionChanged: (val) => setState(() => completedExpanded = val),
                  children: buildChoreList(completedOnly: true),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bottomButton('Dashboard', _goToDashboardScreen),
              _bottomButton('Chores', _goToChoresScreen),
              _bottomButton('Rewards', _goToRewardsScreen),
              _bottomButton('Log Out', _logout),
            ],
          ),
        ),
      ),
    );
  }
}
