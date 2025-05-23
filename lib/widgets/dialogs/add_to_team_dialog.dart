import 'package:flutter/material.dart';

class AddToTeamDialog extends StatelessWidget {
  const AddToTeamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text('Add to Team'),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(labelText: 'Child Email'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // You can hook up API logic here
            Navigator.pop(context);
          },
          child: const Text('Add'),
        )
      ],
    );
  }
}
