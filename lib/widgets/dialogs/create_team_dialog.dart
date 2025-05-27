import 'package:flutter/material.dart';
import '/services/api_service.dart';

class CreateTeamDialog extends StatelessWidget {
  final int userId;
  final VoidCallback refreshParent;

  const CreateTeamDialog({
    Key? key,
    required this.userId,
    required this.refreshParent,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final TextEditingController teamNameController = TextEditingController();
    final TextEditingController teamPasswordController = TextEditingController();

    return AlertDialog(
      title: const Text('Create New Team'),
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
                  content: Text('Please enter a team name and password'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            // 🟡 Debug print to verify userId is correct
            debugPrint("Submitting team with userId: $userId");

            final response = await ApiService.createTeam(
              teamNameController.text,
              teamPasswordController.text,
              userId,
            );

            if (response != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Team "${response['teamName']}" created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );

              await Future.delayed(const Duration(milliseconds: 800));
              Navigator.of(context).pop();
              refreshParent();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to create team'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
