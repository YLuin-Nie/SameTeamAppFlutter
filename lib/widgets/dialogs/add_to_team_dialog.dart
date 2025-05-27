import 'package:flutter/material.dart';
import '/services/api_service.dart';

class AddToTeamDialog extends StatelessWidget {
  final int userId;
  final VoidCallback refreshParent;

  const AddToTeamDialog({
    Key? key,
    required this.userId,
    required this.refreshParent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Member to Team'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'User Email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final email = emailController.text.trim();

            if (email.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter an email'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            debugPrint('Adding user $email to current team by userId: $userId');

            final result = await ApiService.addUserToTeam(userId, email);

            if (result) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User added to team successfully'),
                  backgroundColor: Colors.green,
                ),
              );

              await Future.delayed(const Duration(milliseconds: 800));
              Navigator.of(context).pop();
              refreshParent();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to add user to team'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
