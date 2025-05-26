
import 'package:flutter/material.dart';

class ParentDashboardScreen extends StatefulWidget {
  final int userId;

  const ParentDashboardScreen({super.key, required this.userId});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  // 🌙 Track dark mode state
  bool _isDarkMode = false;

  // 🌙 Toggle dark mode on or off
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }
  // Helper widget to create each bottom button with icon and label
  Widget _bottomButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForLabel(label)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Returns the correct icon based on the label
  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return Icons.dashboard;
      case 'Add Chore':
        return Icons.add;
      case 'Rewards':
        return Icons.card_giftcard;
      case 'Log Out':
        return Icons.logout;
      default:
        return Icons.help_outline;
    }
  }

  // Navigates to Add Chore screen
  void _goToAddChoreScreen() {
    Navigator.pushNamed(context, '/addChore', arguments: widget.userId);
  }

  // Navigates to Rewards screen
  void _goToRewardsScreen() {
    Navigator.pushNamed(context, '/parentRewards', arguments: widget.userId);
  }

  // Logs out and navigates to Sign In screen
  void _logout() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Parent Dashboard'),
            actions: [
              Row(
                children: [
                  const Text("🌙", style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _isDarkMode,
                    onChanged: _toggleTheme,
                  ),
                ],
              ),
            ],
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello, Parent!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),

            // Row for date filters
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Select a Date logic
                  },
                  child: const Text('Select a Date'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Clear Date Filter logic
                  },
                  child: const Text('Clear Date Filter'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upcoming chores title
            const Text(
              'Upcoming Chores (Next 7 Days)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Placeholder for dynamic chores list
            const Text('TODO: Chore list goes here'),
          ],
        ),
      ),

      // Bottom navigation bar using custom BottomAppBar with 4 buttons
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey[50],
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomButton('Dashboard', () {
              setState(() {}); // Refresh dashboard
            }),
            _bottomButton('Add Chore', _goToAddChoreScreen),
            _bottomButton('Rewards', _goToRewardsScreen),
            _bottomButton('Log Out', _logout),
          ],
        ),
      ),
    ));
  }
}
