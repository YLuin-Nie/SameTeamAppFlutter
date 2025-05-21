import 'package:flutter/material.dart';
import 'package:same_team_flutter/screens/add_chore_screen.dart';
import 'package:same_team_flutter/screens/child_dashboard_screen.dart';
import 'package:same_team_flutter/screens/child_rewards_screen.dart';
import 'package:same_team_flutter/screens/chores_list_screen.dart';
import 'package:same_team_flutter/screens/parent_dashboard_screen.dart';
import 'package:same_team_flutter/screens/parent_rewards_screen.dart';
import 'package:same_team_flutter/screens/signin_screen.dart';
import 'package:same_team_flutter/screens/signup_screen.dart';
import 'package:same_team_flutter/screens/welcome_screen.dart';

void main() {
  runApp(const SameTeamApp());
}

class SameTeamApp extends StatelessWidget {
  const SameTeamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SameTeam Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/parentDashboard': (context) => const ParentDashboardScreen(),
        '/addChore': (context) => const AddChoreScreen(),
        '/parentRewards': (context) => const ParentRewardsScreen(),
        '/childDashboard': (context) => const ChildDashboardScreen(),
        '/choresList': (context) => const ChoresListScreen(),
        '/childRewards': (context) => const ChildRewardsScreen(),
      },
    );
  }
}
