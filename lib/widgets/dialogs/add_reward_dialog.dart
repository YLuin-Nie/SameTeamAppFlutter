import 'package:flutter/material.dart';

class AddRewardDialog extends StatelessWidget {
  const AddRewardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController rewardNameController = TextEditingController();
    final TextEditingController rewardPointsController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Reward'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: rewardNameController,
            decoration: const InputDecoration(labelText: 'Reward Name'),
          ),
          TextField(
            controller: rewardPointsController,
            decoration: const InputDecoration(labelText: 'Reward Points'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // You can hook up API call logic here
            Navigator.pop(context);
          },
          child: const Text('Add'),
        )
      ],
    );
  }
}