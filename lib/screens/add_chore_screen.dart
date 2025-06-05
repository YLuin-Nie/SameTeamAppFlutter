import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/chore_model.dart';
import '../../models/completed_chore_model.dart';
import '../../services/api_service.dart';
import '../../widgets/dialogs/edit_chore_dialog.dart';
import '../../widgets/dialogs/add_chore_dialog.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/theme_toggle_switch.dart';

class AddChoreScreen extends StatefulWidget {
  final int userId;
  const AddChoreScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  List<User> children = [];
  List<Chore> chores = [];
  List<CompletedChore> completedChores = [];
  Map<int, bool> expandedState = {};
  bool isLoading = true;
  int userId = -1;
  bool section2Expanded = true;
  bool section3Expanded = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt(kIsWeb ? 'flutter.userId' : 'userId') ?? -1;

    if (userId == -1) {
      if (kDebugMode) print("🚫 userId not found");
      return;
    }

    try {
      final users = await ApiService().fetchUsers();
      final currentUser = users.firstWhere((u) => u.userId == userId);
      final allChores = await ApiService().fetchChores();
      final fetchedCompleted = await ApiService().fetchCompletedChores();

      fetchedCompleted.sort((a, b) => b.completionDate.compareTo(a.completionDate));

      final sameTeamChildren = users
          .where((u) => u.role == 'Child' && u.teamId == currentUser.teamId)
          .toList();

      setState(() {
        children = sameTeamChildren;
        chores = allChores;
        completedChores = fetchedCompleted;
        expandedState = {for (var child in sameTeamChildren) child.userId: true};
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print("❌ fetchData error: $e");
    }
  }

  List<Chore> getPendingChoresForChild(int childId) {
    return chores
        .where((c) => c.assignedTo == childId && c.dateAssigned != null && !c.completed)
        .toList()
      ..sort((a, b) => a.dateAssigned.compareTo(b.dateAssigned));
  }

  void _openEditChoreDialog(Chore chore) async {
    final shouldRefresh = await showDialog<bool>(
      context: context,
      builder: (context) => EditChoreDialog(
        chore: chore,
        children: children,
        initialName: chore.choreText,
        initialPoints: chore.points,
        initialDate: chore.dateAssigned,
        initialAssignedUserId: chore.assignedTo,
        onSubmit: (updatedChore) async {
          await ApiService().updateChore(updatedChore.choreId, updatedChore);
        },
      ),
    );
    if (shouldRefresh == true) fetchData();
  }

  void _completeChore(Chore chore) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await ApiService().completeChoreWithDate(chore.choreId, today);
    fetchData();
  }

  void _undoCompletedChore(int completedId) async {
    await ApiService().undoCompletedChore(completedId);
    fetchData();
  }

  void _deleteChore(int choreId) async {
    await ApiService().deleteChore(choreId);
    fetchData();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chore Management'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: ThemeToggleSwitch(),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add New Chore"),
                onPressed: () async {
                  final shouldRefresh = await showDialog<bool>(
                    context: context,
                    builder: (_) => AddChoreDialog(userId: userId),
                  );
                  if (shouldRefresh == true) fetchData();
                },
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text(
                  "All Pending Chores",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: section2Expanded,
                onExpansionChanged: (val) =>
                    setState(() => section2Expanded = val),
                children: [
                  ...children.map((child) {
                    final chores = getPendingChoresForChild(child.userId);
                    return ExpansionTile(
                      title: Text(child.username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      initiallyExpanded: expandedState[child.userId] ?? true,
                      onExpansionChanged: (expanded) =>
                          setState(() => expandedState[child.userId] = expanded),
                      children: chores.isEmpty
                          ? [const ListTile(title: Text("No pending chores."))]
                          : chores
                          .map((chore) => ListTile(
                        title: Text(chore.choreText),
                        subtitle: Text(
                            "Points: ${chore.points} • ${chore.dateAssigned}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Edit Chore',
                              child: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () =>
                                    _openEditChoreDialog(chore),
                              ),
                            ),
                            Tooltip(
                              message: 'Mark as Complete',
                              child: IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () =>
                                    _completeChore(chore),
                              ),
                            ),
                            Tooltip(
                              message: 'Delete Chore',
                              child: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _deleteChore(chore.choreId),
                              ),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                    );
                  })
                ],
              ),
              const SizedBox(height: 20),
              ExpansionTile(
                title: const Text(
                  "Completed Chores",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: section3Expanded,
                onExpansionChanged: (val) =>
                    setState(() => section3Expanded = val),
                children: [
                  ...completedChores.map((chore) {
                    final child = children.firstWhere(
                          (c) => c.userId == chore.assignedTo,
                      orElse: () => User(userId: 0, username: 'Unknown', email: '', role: ''),
                    );

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${chore.choreText} (${child.username})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text("Points: ${chore.points} — ${chore.completionDate}"),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _undoCompletedChore(chore.completedId),
                            icon: const Icon(Icons.undo),
                            label: const Text("Undo"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                            ),
                          )
                        ],
                      ),
                    );
                  })
                ],
              )
            ],
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
        );
      },
    );
  }
}
