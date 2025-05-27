import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chore_model.dart';
import '../models/completed_chore_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../widgets/dialogs/edit_chore_dialog.dart';

class AddChoreScreen extends StatefulWidget {
  final int userId;
  const AddChoreScreen({super.key, required this.userId});

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  List<User> allUsers = [];
  List<User> childList = [];
  List<Chore> allChores = [];
  List<CompletedChore> completedChores = [];

  final TextEditingController choreTextController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  int selectedChildIndex = 0;

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
  void _logout() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  void initState() {
    super.initState();
    fetchUsersAndChores();
  }

  Future<void> fetchUsersAndChores() async {
    try {
      allUsers = (await ApiService().fetchUsers()).cast<User>();
      final currentUser = allUsers.firstWhere((u) => u.userId == widget.userId);

      childList = allUsers
          .where((u) => u.role == 'Child' && u.teamId == currentUser.teamId)
          .toList();

      allChores = (await ApiService().fetchChores()).cast<Chore>();
      completedChores = (await ApiService().fetchCompletedChores()).cast<CompletedChore>();

      debugPrint('✅ UserId: ${widget.userId}');
      debugPrint('👤 All Users: ${allUsers.length}');
      debugPrint('👶 Children in team: ${childList.length}');
      debugPrint('📋 Pending Chores: ${allChores.length}');
      debugPrint('✅ Completed Chores: ${completedChores.length}');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    }
  }

  void addChore() async {
    final text = choreTextController.text.trim();
    final points = int.tryParse(pointsController.text.trim()) ?? 10;
    final date = dateController.text.trim();

    if (text.isEmpty || date.isEmpty || childList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final selectedUser = childList[selectedChildIndex];
    final chore = Chore(
      choreId: 0,
      choreText: text,
      points: points,
      assignedTo: selectedUser.userId,
      dateAssigned: date,
      completed: false,
    );

    await ApiService().postChore(chore);
    fetchUsersAndChores();
  }

  void completeChore(int id) async {
    await ApiService().completeChore(id);
    fetchUsersAndChores();
  }

  void deleteChore(int id) async {
    await ApiService().deleteChore(id);
    fetchUsersAndChores();
  }

  void undoChore(int id) async {
    await ApiService().undoCompletedChore(id);
    fetchUsersAndChores();
  }

  void showDatePickerDialog() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget buildChoreItem(Chore chore, bool isCompleted) {
    final assignedUser = childList.firstWhere(
          (u) => u.userId == chore.assignedTo,
      orElse: () => User(userId: 0, username: 'Unknown', email: '', role: ''),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${chore.choreText} — ${chore.points} pts — Assigned to: ${assignedUser.username}',
              style: TextStyle(
                decoration:
                isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isCompleted) ...[
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => EditChoreDialog(
                          chore: chore,
                          children: childList,
                          initialName: chore.choreText,
                          initialPoints: chore.points,
                          initialDate: chore.dateAssigned,
                          initialAssignedUserId: chore.assignedTo,
                          onSubmit: (updatedChore) async {
                            await ApiService().updateChore(chore.choreId, updatedChore);
                            fetchUsersAndChores();
                          },
                        ),
                      );
                    },
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () => completeChore(chore.choreId),
                    child: const Text('Complete'),
                  ),
                  TextButton(
                    onPressed: () => deleteChore(chore.choreId),
                    child: const Text('Delete'),
                  ),
                ] else
                  TextButton(
                    onPressed: () => undoChore(chore.choreId),
                    child: const Text('Undo'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCompletedChoreItem(CompletedChore c) {
    final assignedUser = childList.firstWhere(
          (u) => u.userId == c.assignedTo,
      orElse: () => User(userId: 0, username: 'Unknown', email: '', role: ''),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${c.choreText} — ${c.points} pts — Assigned to: ${assignedUser.username}',
              style: const TextStyle(decoration: TextDecoration.lineThrough),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => undoChore(c.completedId),
                  child: const Text('Undo'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final pending = allChores
        .where((c) => !c.completed && childList.any((ch) => ch.userId == c.assignedTo))
        .toList();

    final recentCompleted = completedChores
        .where((c) => DateTime.parse(c.dateAssigned).isAfter(
      DateTime.now().subtract(const Duration(days: 7)),
    ) &&
        childList.any((ch) => ch.userId == c.assignedTo))
        .toList();

    return Theme(
        data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Chore Management'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: choreTextController,
                decoration: const InputDecoration(labelText: 'Chore Text'),
              ),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Points'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date Assigned'),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Assign to'),
                value: selectedChildIndex,
                items: List.generate(childList.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(childList[index].username),
                  );
                }),
                onChanged: (val) => setState(() => selectedChildIndex = val ?? 0),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: addChore,
                child: const Text('Add Chore'),
              ),
              const Divider(),
              const Text('Pending Chores', style: TextStyle(fontWeight: FontWeight.bold)),
              ...pending.map((c) => buildChoreItem(c, false)).toList(),
              const Divider(),
              const Text('Completed Chores (last 7 days)', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recentCompleted.map((c) => buildCompletedChoreItem(c)).toList(),
            ],
          ),
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
    ),);
  }
}

