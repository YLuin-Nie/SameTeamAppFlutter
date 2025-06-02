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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'utils/auth_util.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SameTeamApp',
      debugShowCheckedModeBanner: false,
    //  initialRoute: '/welcome',
      home: const SplashScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(userId: 0,),
        '/signup': (context) => const SignUpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/parentDashboard': (context) => ParentDashboardScreen(userId: 0,),
        '/childDashboard': (context) => ChildDashboardScreen(userId: 0,),
        '/addChore': (context) => AddChoreScreen(userId: 0,),
        '/choresList': (context) => ChoresListScreen(userId: 0,),
        '/childRewards': (context) => ChildRewardsScreen(userId: 0,),
        '/parentRewards': (context) => ParentRewardsScreen(userId: 0,),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkLoginStatus() async {
    final user = await getCurrentUser();

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
    } else if (user['role'] == 'Parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParentDashboardScreen(userId: user['userId']),
        ),
      );
    } else if (user['role'] == 'Child') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChildDashboardScreen(userId: user['userId']),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}