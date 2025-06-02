import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:same_team_flutter/models/user_model.dart';
import 'package:same_team_flutter/services/api_service.dart';

Future<bool?> showAddChoreDialog(BuildContext context, int parentUserId) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AddChoreDialog(parentUserId: parentUserId),
  );
}

class AddChoreDialog extends StatefulWidget {
  final int parentUserId;

  const AddChoreDialog({super.key, required this.parentUserId});

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
      final allUsers = await ApiService().fetchUsers();
      final parent = allUsers.firstWhere((u) => u.userId == widget.parentUserId);

      setState(() {
        children = allUsers
            .where((u) => u.role == 'Child' && u.teamId == parent.teamId)
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching children: $e');
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid || _selectedChildId == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }


    try {
      if (!isValid || _selectedChildId == null || _selectedDate == null)
      {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create chore.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Chore'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Chore Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter chore name' : null,
                ),
                TextFormField(
                  controller: _pointsController,
                  decoration: const InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Enter points' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No date selected'
                            : DateFormat.yMd().format(_selectedDate!),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: const Text('Pick Date'),
                    )
                  ],
                ),
                DropdownButtonFormField<int>(
                  value: _selectedChildId,
                  decoration: const InputDecoration(labelText: 'Assign To'),
                  items: children.map((child) {
                    return DropdownMenuItem<int>(
                      value: child.userId,
                      child: Text(child.username),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedChildId = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Select a child' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
