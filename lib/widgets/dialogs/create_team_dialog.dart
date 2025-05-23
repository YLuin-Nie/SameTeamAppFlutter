import 'package:flutter/material.dart';

class CreateTeamDialog extends StatelessWidget {
  const CreateTeamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool obscureText = true;

    return AlertDialog(
      title: const Text('Create Team'),
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
            // You can hook up API logic here
            Navigator.pop(context);
          },
          child: const Text('Create'),
        )
      ],
    );
  }
}
