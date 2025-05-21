import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddChoreScreen extends StatefulWidget {
  @override
  _AddChoreScreenState createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final _choreController = TextEditingController();
  final _pointsController = TextEditingController();
  final _dateController = TextEditingController();

  List<dynamic> _children = [];
  dynamic _selectedChild;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final currentUserId = jsonDecode(prefs.getString('user')!)['userId'];

    final res = await http.get(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Users'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final users = jsonDecode(res.body);
      final currentUser = users.firstWhere((u) => u['userId'] == currentUserId, orElse: () => null);
      if (currentUser == null) return;

      setState(() {
        _children = users.where((u) => u['role'] == 'Child' && u['teamId'] == currentUser['teamId']).toList();
      });
    }
  }

  Future<void> _submitChore() async {
    if (_selectedChild == null || _choreController.text.isEmpty || _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final body = {
      "choreId": 0,
      "choreText": _choreController.text.trim(),
      "points": int.tryParse(_pointsController.text.trim()) ?? 10,
      "assignedTo": _selectedChild['userId'],
      "dateAssigned": _dateController.text.trim(),
      "completed": false
    };

    final res = await http.post(
      Uri.parse('https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/Chores'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chore added successfully')));
      _choreController.clear();
      _pointsController.clear();
      _dateController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add chore')));
    }
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Chore')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _choreController,
              decoration: InputDecoration(labelText: 'Chore Description'),
            ),
            TextField(
              controller: _pointsController,
              decoration: InputDecoration(labelText: 'Points'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Assign Date'),
              readOnly: true,
              onTap: _selectDate,
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Assign To'),
              items: _children.map((child) {
                return DropdownMenuItem(
                  value: child,
                  child: Text(child['username']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedChild = value),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitChore,
              child: Text('Add Chore'),
            ),
          ],
        ),
      ),
    );
  }
}
