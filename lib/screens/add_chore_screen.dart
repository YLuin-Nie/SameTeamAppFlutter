import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/chore_model.dart';
import '../../services/api_service.dart';

class AddChoreScreen extends StatefulWidget {
  final int userId;
  const AddChoreScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  List<User> users = [];
  List<Chore> chores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final fetchedUsers = await ApiService().fetchUsers();
      final fetchedChores = await ApiService().fetchChores();

      setState(() {
        users = fetchedUsers.where((user) => user.parentId == widget.userId).toList();
        chores = fetchedChores;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  List<Chore> getChoresForChild(int childId) {
    return chores.where((chore) => chore.assignedTo == childId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Chores"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text("No children found."))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final child = users[index];
          final childChores = getChoresForChild(child.userId);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    const Text("No chores assigned.")
                  else
                    ...childChores.map((chore) => ListTile(
                      title: Text(chore.choreText),
                      subtitle: Text(
                          "Points: ${chore.points} • Assigned: ${chore.dateAssigned?.toString().split(' ')[0]}"),
                      trailing: Icon(
                        chore.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                        chore.completed ? Colors.green : Colors.grey,
                      ),
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
