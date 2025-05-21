import 'package:flutter/material.dart';

Future<void> showRewardChildDialog(
    BuildContext context, {
      required List<Map<String, dynamic>> children, // [{userId: 1, username: "Lulu"}]
      required void Function(String rewardName, int points, int assignedToUserId) onSubmit,
    }) async {
  final nameController = TextEditingController();
  final pointsController = TextEditingController();
  int selectedUserId = children.isNotEmpty ? children[0]['userId'] : -1;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Reward a Child"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: selectedUserId,
            items: children.map((child) {
              return DropdownMenuItem<int>(
                value: child['userId'],
                child: Text(child['username']),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) selectedUserId = value;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Assign To",
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Reward Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: pointsController,
            decoration: InputDecoration(
              hintText: "Points",
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
            final rewardName = nameController.text.trim();
            final points = int.tryParse(pointsController.text.trim()) ?? 0;

            if (rewardName.isNotEmpty && points > 0) {
              onSubmit(rewardName, points, selectedUserId);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter valid name and points.")),
              );
            }
          },
          child: Text("Submit"),
        ),
      ],
    ),
  );
}
