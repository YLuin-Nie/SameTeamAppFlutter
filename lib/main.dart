import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/child_dashboard_screen.dart';
import 'screens/add_chore_screen.dart';
import 'screens/chores_list_screen.dart';
import 'screens/child_rewards_screen.dart';
import 'screens/parent_rewards_screen.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SameTeamApp',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/', // ✅ Start with SplashScreen for auto-login
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignInScreen(userId: 0),
        '/signup': (context) => const SignUpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/parentDashboard': (context) => ParentDashboardScreen(userId: 0),
        '/childDashboard': (context) => ChildDashboardScreen(userId: 0),
        '/addChore': (context) => AddChoreScreen(userId: 0),
        '/choresList': (context) => ChoresListScreen(userId: 0),
        '/childRewards': (context) => ChildRewardsScreen(userId: 0),
        '/parentRewards': (context) => ParentRewardsScreen(userId: 0),
      },
    );
  }
}

// ✅ SplashScreen handles login check

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final tokenKey = kIsWeb ? 'flutter.token' : 'token';
    final roleKey = kIsWeb ? 'flutter.role' : 'role';
    final userIdKey = kIsWeb ? 'flutter.userId' : 'userId';

    final token = prefs.getString(tokenKey);
    final role = prefs.getString(roleKey);
    final userId = prefs.getInt(userIdKey);

    // 🐞 Debug prints
    print('🔍 Platform: ${kIsWeb ? 'WEB' : 'MOBILE'}');
    print('📦 token: $token');
    print('📦 role: $role');
    print('📦 userId: $userId');

    if (token != null && role != null && userId != null) {
      if (role == 'Parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentDashboardScreen(userId: userId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChildDashboardScreen(userId: userId),
          ),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
