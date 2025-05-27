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
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    await Future.delayed(const Duration(seconds: 1)); // optional splash delay

    if (role == 'Parent') {
      Navigator.pushReplacementNamed(context, '/parentDashboard');
    } else if (role == 'Child') {
      Navigator.pushReplacementNamed(context, '/childDashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}