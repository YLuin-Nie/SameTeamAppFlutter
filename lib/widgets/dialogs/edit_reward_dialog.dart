import 'package:flutter/material.dart';

Future<void> showEditRewardDialog(
    BuildContext context, {
      required String initialName,
      required int initialCost,
      required void Function(String name, int cost) onSubmit,
    }) {
  final nameController = TextEditingController(text: initialName);
  final costController = TextEditingController(text: initialCost.toString());

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Edit Reward"),
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
              hintText: "Points",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
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
          child: Text("Save"),
        ),
      ],
    ),
  );
}
