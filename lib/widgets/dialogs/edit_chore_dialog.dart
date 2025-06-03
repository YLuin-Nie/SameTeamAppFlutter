import 'package:flutter/material.dart';
import '../../models/chore_model.dart';
import '../../models/user_model.dart';

class EditChoreDialog extends StatefulWidget {
  final Chore chore;
  final List<User> children;
  final String initialName;
  final int initialPoints;
  final String initialDate;
  final int initialAssignedUserId;
  final Function(Chore updatedChore) onSubmit;

  const EditChoreDialog({
    super.key,
    required this.chore,
    required this.children,
    required this.initialName,
    required this.initialPoints,
    required this.initialDate,
    required this.initialAssignedUserId,
    required this.onSubmit,
  });

  @override
  State<EditChoreDialog> createState() => _EditChoreDialogState();
}

class _EditChoreDialogState extends State<EditChoreDialog> {
  late TextEditingController nameController;
  late TextEditingController pointsController;
  late TextEditingController dateController;
  late int selectedUserId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    pointsController = TextEditingController(text: widget.initialPoints.toString());
    dateController = TextEditingController(text: widget.initialDate);
    selectedUserId = widget.initialAssignedUserId;
  }

  void showDatePickerDialog() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.initialDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateController.text = picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Chore'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Chore'),
            ),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(labelText: 'Points'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date Assigned'),
              onTap: showDatePickerDialog,
            ),
            DropdownButtonFormField<int>(
              value: selectedUserId,
              decoration: const InputDecoration(labelText: 'Assigned To'),
              items: widget.children.map((child) {
                return DropdownMenuItem<int>(
                  value: child.userId,
                  child: Text(child.username),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedUserId = value ?? selectedUserId);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedChore = widget.chore.copyWith(
              choreText: nameController.text,
              points: int.tryParse(pointsController.text) ?? widget.chore.points,
              dateAssigned: dateController.text,
              assignedTo: selectedUserId,
            );
            widget.onSubmit(updatedChore);
            print('Updated chore: ${updatedChore.toJson()}');
            Navigator.of(context).pop(true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
