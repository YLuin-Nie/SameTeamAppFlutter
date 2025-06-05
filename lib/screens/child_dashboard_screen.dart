import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_toggle_switch.dart';
import '../services/api_service.dart';
import '../models/chore_model.dart';
import '../models/level_model.dart';

class ChildDashboardScreen extends StatefulWidget {
  final int userId;
  const ChildDashboardScreen({super.key, required this.userId});

  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  int userId = -1;
  List<Chore> allChores = [];
  DateTime? selectedDate;
  String username = '';
  int totalPoints = 0;
  int unspentPoints = 0;

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
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
      case 'Dashboard':
        return Icons.dashboard;
      case 'Chores':
        return Icons.check_box;
      case 'Rewards':
        return Icons.card_giftcard;
      case 'Log Out':
        return Icons.logout;
      default:
        return Icons.help_outline;
    }
  }

  void _goToChoresScreen() {
    Navigator.pushNamed(context, '/choresList', arguments: userId);
  }

  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/childRewards', arguments: userId);
  }

  void _goToDashboardScreen() {
    Navigator.pushNamed(context, '/childDashboard', arguments: userId);
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _clearDate() {
    setState(() => selectedDate = null);
  }

  Future<void> _loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt(kIsWeb ? 'flutter.userId' : 'userId') ?? -1;

    if (userId == -1) {
      if (kDebugMode) print('❌ No valid userId found');
      return;
    }

    try {
      allChores = await ApiService().fetchChores();
      final users = await ApiService().fetchUsers();
      final user = users.firstWhere((u) => u.userId == userId);

      setState(() {
        username = user.username;
        totalPoints = user.totalPoints ?? 0;
        unspentPoints = user.points ?? 0;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load child dashboard: $e");
      }
    }
  }


  List<Widget> buildChoreList() {
    final pendingChores = allChores.where((chore) {
      if (chore.assignedTo != userId || chore.completed == true) return false;
      if (chore.dateAssigned == null) return false;

      final parsedDate = DateTime.tryParse(chore.dateAssigned);
      if (parsedDate == null) return false;

      if (selectedDate != null) {
        return parsedDate.year == selectedDate!.year &&
            parsedDate.month == selectedDate!.month &&
            parsedDate.day == selectedDate!.day;
      }

      return true;
    }).toList()
      ..sort((a, b) => a.dateAssigned.compareTo(b.dateAssigned));

    if (pendingChores.isEmpty) {
      return [const Text("No chores found.")];
    }

    return pendingChores.map((chore) {
      return ListTile(
        title: Text('${chore.choreText} - ${chore.dateAssigned}'),
        subtitle: Text('${chore.points ?? 0} pts'),
      );
    }).toList();
  }

  Widget buildChildLevel() {
    final level = Level.getLevel(totalPoints);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: level.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$username - ${level.name} - $totalPoints pts',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Child Dashboard'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: ThemeToggleSwitch(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, $username!',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Unspent Points: $unspentPoints pts'),
                  const SizedBox(height: 8),
                  buildChildLevel(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _selectDate,
                        child: const Text("Select Date"),
                      ),
                      ElevatedButton(
                        onPressed: _clearDate,
                        child: const Text("Clear Filter"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    selectedDate == null
                        ? 'All Pending Chores'
                        : 'Chores for ${selectedDate!.toLocal().toString().split(" ")[0]}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...buildChoreList(),
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
        );
      },
    );
  }
}
