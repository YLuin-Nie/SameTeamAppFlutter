import 'package:flutter/material.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/child_dashboard_screen.dart';
import 'screens/add_chore_screen.dart';
import 'screens/chores_list_screen.dart';
import 'screens/child_rewards_screen.dart';
import 'screens/parent_rewards_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SameTeamApp',
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/parentDashboard': (context) => ParentDashboardScreen(),
        '/childDashboard': (context) => ChildDashboardScreen(),
        '/addChore': (context) => AddChoreScreen(),
        '/choresList': (context) => ChoresListScreen(),
        '/childRewards': (context) => ChildRewardsScreen(),
        '/parentRewards': (context) => ParentRewardsScreen(),
      },
    );
  }
}