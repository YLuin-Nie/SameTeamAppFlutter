import 'package:flutter/material.dart';
import '../../models/reward_model.dart';

class AddRewardDialog extends StatefulWidget {
  final Function(Reward reward) onSubmit;

  const AddRewardDialog({super.key, required this.onSubmit});

  @override
  State<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<AddRewardDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  void _submit() {
    final name = _nameController.text.trim();
    final cost = int.tryParse(_costController.text.trim()) ?? 0;

    if (name.isEmpty || cost <= 0) return;

    final reward = Reward(
      rewardId: 0,
      name: name,
      cost: cost,
    );

    widget.onSubmit(reward);
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Reward'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Reward Name'),
          ),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cost in Points'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
