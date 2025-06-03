import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/chore_model.dart';

class RewardChildDialog extends StatefulWidget {
  final List<User> children;
  final Function(Chore rewardChore) onSubmit;

  const RewardChildDialog({
    super.key,
    required this.children,
    required this.onSubmit,
  });

  @override
  State<RewardChildDialog> createState() => _RewardChildDialogState();
}

class _RewardChildDialogState extends State<RewardChildDialog> {
  int? selectedChildId;
  final _rewardNameController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');

  void _submit() {
    final name = _rewardNameController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 0;

    if (selectedChildId == null || name.isEmpty || points <= 0) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final chore = Chore(
      choreId: 0,
      choreText: name,
      points: points,
      assignedTo: selectedChildId!,
      dateAssigned: today,
      completed: false,
    );

    widget.onSubmit(chore);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reward a Child'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: selectedChildId,
            decoration: const InputDecoration(labelText: 'Select Child'),
            items: widget.children
                .map((child) => DropdownMenuItem(
              value: child.userId,
              child: Text(child.username),
            ))
                .toList(),
            onChanged: (value) => setState(() => selectedChildId = value),
          ),
          TextField(
            controller: _rewardNameController,
            decoration: const InputDecoration(labelText: 'Reward Name'),
          ),
          TextField(
            controller: _pointsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Points'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Assign')),
      ],
    );
  }
}
