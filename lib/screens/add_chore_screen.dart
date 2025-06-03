import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/chore_model.dart';
import '../../models/completed_chore_model.dart';
import '../../services/api_service.dart';
import '../../widgets/dialogs/edit_chore_dialog.dart';
import '../widgets/dialogs/add_chore_dialog.dart';

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
  bool isLoading = true;
  int userId = -1;

  @override
  void initState() {
    super.initState();
    fetchData(); // 🔄 Load all data on screen start
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('userId') ?? -1;
      if (userId == -1) {
        print('User ID not found in SharedPreferences');
        return;
      }

      final users = await ApiService().fetchUsers();
      final currentUser = users.firstWhere((u) => u.userId == userId);
      final allChores = await ApiService().fetchChores();
      final fetchedCompleted = await ApiService().fetchCompletedChores();

      // ✅ Sort by most recent completion date, then alphabetically
      fetchedCompleted.sort((a, b) {
        final dateCompare = b.completionDate.compareTo(a.completionDate);
        return dateCompare != 0 ? dateCompare : a.choreText.compareTo(b.choreText);
      });

      final sameTeamChildren = users
          .where((u) => u.role == 'Child' && u.teamId == currentUser.teamId)
          .toList();

      setState(() {
        children = sameTeamChildren;
        chores = allChores;
        completedChores = fetchedCompleted;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<Chore> getPendingChoresForChild(int childId) {
    return chores
        .where((chore) =>
    chore.assignedTo == childId &&
        chore.dateAssigned != null &&
        !chore.completed)
        .toList()
      ..sort((a, b) => a.dateAssigned!.compareTo(b.dateAssigned!));
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

    if (shouldRefresh == true) {
      await fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chore updated!')),
      );
    }
  }

  void _completeChore(Chore chore) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      await ApiService().completeChoreWithDate(chore.choreId, today);
      fetchData();
    } catch (e) {
      print('Failed to complete chore: $e');
    }
  }

  void _undoCompletedChore(int completedId) async {
    try {
      await ApiService().undoCompletedChore(completedId);
      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chore marked as incomplete.")),
      );
    } catch (e) {
      print('Failed to undo chore: $e');
    }
  }

  String _getChildName(int childId) {
    final user = children.firstWhere(
          (c) => c.userId == childId,
      orElse: () => User(userId: 0, username: 'Unknown', email: '', role: ''),
    );
    return user.username;
  }

  void _deleteChore(int choreId) async {
    try {
      await ApiService().deleteChore(choreId);
      setState(() {
        chores.removeWhere((c) => c.choreId == choreId);
      });
    } catch (e) {
      print('Failed to delete chore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ALL Pending Chores")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : children.isEmpty
          ? const Center(child: Text("No children found."))
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add New Chore"),
              onPressed: () async {
                final shouldRefresh = await showDialog<bool>(
                  context: context,
                  builder: (context) => AddChoreDialog(userId: userId),
                );
                if (shouldRefresh == true) {
                  fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chore added successfully")),
                  );
                }
              },
            ),
          ),

          // ✅ Pending chores grouped by child
          ...children.map((child) {
            final childChores = getPendingChoresForChild(child.userId);
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (childChores.isEmpty)
                      const Text("No pending chores.")
                    else
                      ...childChores.map((chore) => ListTile(
                        title: Text(chore.choreText),
                        subtitle: Text(
                          "Points: ${chore.points} • Assigned: ${chore.dateAssigned}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Edit',
                              onPressed: () => _openEditChoreDialog(chore),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              tooltip: 'Complete',
                              onPressed: () => _completeChore(chore),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () => _deleteChore(chore.choreId),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // ✅ Completed chores list
          const Text(
            'Completed Chores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...completedChores.map((chore) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Chore info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chore.choreText,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Points: ${chore.points} — Assigned to: ${_getChildName(chore.assignedTo!)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Undo button
                ElevatedButton.icon(
                  onPressed: () => _undoCompletedChore(chore.completedId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.undo),
                  label: const Text("Undo"),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
