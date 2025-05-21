import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showEditChoreDialog(
    BuildContext context, {
      required String initialName,
      required int initialPoints,
      required String initialDate,
      required int initialAssignedUserId,
      required List<Map<String, dynamic>> children, // [{userId: 1, username: "LuLu"}]
      required void Function(String name, int points, String date, int assignedTo) onSubmit,
    }) async {
  final nameController = TextEditingController(text: initialName);
  final pointsController = TextEditingController(text: initialPoints.toString());
  final dateController = TextEditingController(text: initialDate);

  int selectedChildId = initialAssignedUserId;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Edit Chore"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Chore Name",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: pointsController,
            decoration: InputDecoration(
              hintText: "Points",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          TextField(
            controller: dateController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Date",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(initialDate) ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                dateController.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: selectedChildId,
            items: children.map((child) {
              return DropdownMenuItem<int>(
                value: child['userId'],
                child: Text(child['username']),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) selectedChildId = value;
            },
            decoration: InputDecoration(
              hintText: "Assign To",
              border: OutlineInputBorder(),
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
            final name = nameController.text.trim();
            final points = int.tryParse(pointsController.text.trim()) ?? 0;
            final date = dateController.text.trim();

            if (name.isNotEmpty && points > 0 && date.isNotEmpty) {
              onSubmit(name, points, date, selectedChildId);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please fill out all fields.")),
              );
            }
          },
          child: Text("Save"),
        ),
      ],
    ),
  );
}
