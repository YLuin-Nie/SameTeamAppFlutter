import 'package:flutter/material.dart';

Future<void> showAddToTeamDialog(
    BuildContext context, {
      required void Function(String email) onSubmit,
    }) {
  final TextEditingController emailController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Center(
        child: Text(
          "Add User to Team",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final email = emailController.text.trim();
            if (email.isNotEmpty && email.contains('@')) {
              onSubmit(email);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter a valid email.")),
              );
            }
          },
          child: Text("Submit"),
        ),
      ],
    ),
  );
}
