import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/dialogs/create_team_dialog.dart';
import '../widgets/dialogs/join_team_dialog.dart';
import '../widgets/dialogs/add_to_team_dialog.dart';
import '../screens/add_chore_screen.dart';
import '../screens/parent_rewards_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  DateTime? selectedDate;

  final List<Map<String, dynamic>> childLevels = [
    {'name': 'LuLu', 'level': 1, 'points': 0},
    {'name': 'Luna', 'level': 1, 'points': 77},
  ];

  final List<Map<String, dynamic>> upcomingChores = [
    {'title': "Luna's Second Chore", 'date': '2025-05-22', 'child': 'Luna', 'points': 25},
    {'title': "Luna's First Chore", 'date': '2025-05-22', 'child': 'Luna', 'points': 125},
    {'title': "small Chores", 'date': '2025-05-22', 'child': 'LuLu', 'points': 33},
    {'title': "AA task", 'date': '2025-05-23', 'child': 'LuLu', 'points': 155},
    {'title': "Vercel Task", 'date': '2025-05-23', 'child': 'LuLu', 'points': 220},
    {'title': "Extra Points for Cuteness", 'date': '2025-05-24', 'child': 'Luna', 'points': 405},
    {'title': "New Task", 'date': '2025-05-24', 'child': 'LuLu', 'points': 10},
    {'title': "Azure Task", 'date': '2025-05-24', 'child': 'LuLu', 'points': 102},
    {'title': "Android with Azure", 'date': '2025-05-24', 'child': 'LuLu', 'points': 245},
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = null; // Default view is upcoming chores
  }

  List<Map<String, dynamic>> getFilteredChores() {
    if (selectedDate == null) {
      DateTime today = DateTime.now();
      DateTime endDate = today.add(const Duration(days: 6));
      return upcomingChores.where((chore) {
        DateTime date = DateTime.parse(chore['date']);
        return date.isAfter(today.subtract(const Duration(days: 1))) && date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } else {
      return upcomingChores.where((chore) => chore['date'] == selectedDate!.toIso8601String().split('T')[0]).toList();
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _clearDateFilter() {
    setState(() => selectedDate = null);
  }

  void _showCreateTeamDialog() => showDialog(context: context, builder: (_) => const CreateTeamDialog());
  void _showJoinTeamDialog() => showDialog(context: context, builder: (_) => const JoinTeamDialog());
  void _showAddToTeamDialog() => showDialog(context: context, builder: (_) => const AddToTeamDialog());
  void _goToAddChoreScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => AddChoreScreen()));
  void _goToRewardsScreen() => Navigator.push(context, MaterialPageRoute(builder: (_) => ParentRewardsScreen()));
  void _logout() => Navigator.popUntil(context, (route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final chores = getFilteredChores();

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Team: AzureTeam", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildActionButton('Create Team', _showCreateTeamDialog),
              _buildActionButton('Join Team', _showJoinTeamDialog),
              _buildActionButton('Add to Team', _showAddToTeamDialog),
            ]),
            const SizedBox(height: 20),
            const Text('Child Levels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...childLevels.map((child) => Card(
              child: ListTile(
                title: Text('${child['name']} - Level ${child['level']} (Beginner) - ${child['points']} pts'),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {},
                ),
              ),
            )),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                onPressed: _selectDate,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Select a Date"),
              ),
              ElevatedButton(
                onPressed: _clearDateFilter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Clear Date Filter"),
              ),
            ]),
            const SizedBox(height: 20),
            Text(
              selectedDate == null ? 'Upcoming Chores (Next 7 Days)' : 'Chores for ${selectedDate!.toLocal().toString().split(" ")[0]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...chores.map((chore) => Text("${chore['title']} - ${chore['date']} - ${chore['child']} (${chore['points']} pts)")),
          ]),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _bottomButton('Dashboard', () {}),
          _bottomButton('Add Chore', _goToAddChoreScreen),
          _bottomButton('Rewards', _goToRewardsScreen),
          _bottomButton('Log Out', _logout),
        ]),
      ),
    );
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

  Widget _bottomButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
