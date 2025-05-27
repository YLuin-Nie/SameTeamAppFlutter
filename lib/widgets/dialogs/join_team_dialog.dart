import 'package:flutter/material.dart';
import '/services/api_service.dart';

class JoinTeamDialog extends StatelessWidget {
  final int userId;
  final VoidCallback refreshParent;

  const JoinTeamDialog({
    Key? key,
    required this.userId,
    required this.refreshParent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController teamNameController = TextEditingController();
    final TextEditingController teamPasswordController = TextEditingController();

    return AlertDialog(
      title: const Text('Join a Team'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: teamNameController,
            decoration: const InputDecoration(labelText: 'Team Name'),
          ),
          TextField(
            controller: teamPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Team Password'),
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
            if (teamNameController.text.trim().isEmpty ||
                teamPasswordController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter both Team Name and Password'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            debugPrint("Joining team with userId: $userId");

            final response = await ApiService.joinTeam(
              userId,
              teamNameController.text.trim(),
              teamPasswordController.text.trim(),
            );

            if (response != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully joined team "${response['teamName']}"'),
                  backgroundColor: Colors.green,
                ),
              );

              await Future.delayed(const Duration(milliseconds: 800));
              Navigator.of(context).pop();
              refreshParent();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to join team'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Join'),
        ),
      ],
    );
  }
}
