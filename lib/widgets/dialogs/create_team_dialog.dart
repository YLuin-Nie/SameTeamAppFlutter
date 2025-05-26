import 'package:flutter/material.dart';

class CreateTeamDialog extends StatefulWidget {
  const CreateTeamDialog({super.key});

  @override
  State<CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<CreateTeamDialog> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamPasswordController = TextEditingController();

  void _submitData() {
    final name = _teamNameController.text.trim();
    final pass = _teamPasswordController.text.trim();

    if (name.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields must be filled")),
      );
      return;
    }

    Navigator.of(context).pop({
      'teamName': name,
      'teamPassword': pass,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Team"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _teamNameController,
            decoration: const InputDecoration(labelText: 'Team Name'),
          ),
          TextField(
            controller: _teamPasswordController,
            decoration: const InputDecoration(labelText: 'Team Password'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submitData,
          child: const Text("Create"),
        ),
      ],
    );
  }
}
