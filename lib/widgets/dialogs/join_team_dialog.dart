import 'package:flutter/material.dart';

class JoinTeamDialog extends StatelessWidget {
  const JoinTeamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool obscureText = true;

    return AlertDialog(
      title: const Text('Join Team'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Team Name'),
          ),
          StatefulBuilder(
            builder: (context, setState) => TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: 'Team Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => obscureText = !obscureText),
                ),
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Hook up API call logic here
            Navigator.pop(context);
          },
          child: const Text('Join'),
        )
      ],
    );
  }
}