import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:same_team_flutter/models/user_model.dart';
import 'package:same_team_flutter/models/chore_model.dart';
import 'package:same_team_flutter/services/api_service.dart';

class AddChoreDialog extends StatefulWidget {
  final int userId;
  const AddChoreDialog({super.key, required this.userId});

  @override
  State<AddChoreDialog> createState() => _AddChoreDialogState();
}

class _AddChoreDialogState extends State<AddChoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pointsController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedChildId;
  List<User> children = [];

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    try {
      final users = await ApiService().fetchUsers();
      final parent = users.firstWhere((u) => u.userId == widget.userId);

      setState(() {
        children = users
            .where((u) => u.role == 'Child' && u.teamId == parent.teamId)
            .toList();
      });
    } catch (e) {
      print('Error loading children: $e');
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _selectedDate == null || _selectedChildId == null) return;

    final newChore = Chore(
      choreId: 0, // will be ignored by backend
      choreText: _nameController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      assignedTo: _selectedChildId!,
      dateAssigned: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      completed: false
    );

    try {
      await ApiService().postChore(newChore);
      Navigator.of(context).pop(true); // ✅ success
    } catch (e) {
      print("Failed to create chore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add chore")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Chore"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Chore Name'),
              validator: (val) => val == null || val.isEmpty ? 'Enter chore name' : null,
            ),
            TextFormField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Points'),
              validator: (val) =>
              val == null || int.tryParse(val) == null ? 'Enter a valid number' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Assign to'),
              items: children
                  .map((child) => DropdownMenuItem<int>(
                value: child.userId,
                child: Text(child.username),
              ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedChildId = val),
              validator: (val) => val == null ? 'Select a child' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(_selectedDate == null
                      ? 'Select a date'
                      : 'Assigned: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: const Text("Pick Date"),
                ),
              ],
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(onPressed: _submit, child: const Text("Save")),
      ],
    );
  }
}
