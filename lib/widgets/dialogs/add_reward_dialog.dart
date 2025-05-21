import 'package:flutter/material.dart';

Future<void> showAddRewardDialog(
    BuildContext context, {
      required void Function(String name, int cost) onSubmit,
    }) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Add New Reward"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Reward Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: costController,
            decoration: InputDecoration(
              hintText: "Cost (points)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
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
            final name = nameController.text.trim();
            final cost = int.tryParse(costController.text.trim()) ?? 0;
            if (name.isNotEmpty && cost > 0) {
              onSubmit(name, cost);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter valid name and cost.")),
              );
            }
          },
          child: Text("Add Reward"),
        ),
      ],
    ),
  );
}
