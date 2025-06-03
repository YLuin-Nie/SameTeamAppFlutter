import 'package:flutter/material.dart';
import '../../models/reward_model.dart';

class EditRewardDialog extends StatefulWidget {
  final Reward reward;
  final Function(Reward updatedReward) onSubmit;

  const EditRewardDialog({
    super.key,
    required this.reward,
    required this.onSubmit,
  });

  @override
  State<EditRewardDialog> createState() => _EditRewardDialogState();
}

class _EditRewardDialogState extends State<EditRewardDialog> {
  late TextEditingController _nameController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.reward.name);
    _costController = TextEditingController(text: widget.reward.cost.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final cost = int.tryParse(_costController.text.trim()) ?? 0;

    if (name.isEmpty || cost <= 0) return;

    final updated = Reward(
      rewardId: widget.reward.rewardId,
      name: name,
      cost: cost,
    );

    widget.onSubmit(updated);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Reward'),
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
            decoration: const InputDecoration(labelText: 'Point Cost'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
