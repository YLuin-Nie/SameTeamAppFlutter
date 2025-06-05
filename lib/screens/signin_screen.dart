import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_models.dart';
import '../services/api_service.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/child_dashboard_screen.dart';
import '../widgets/theme_toggle_switch.dart';

class SignInScreen extends StatefulWidget {
  final int userId;
  const SignInScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  Future<void> _saveUserSession(String token, String role, int userId, Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      await prefs.setString('flutter.token', token);
      await prefs.setString('flutter.role', role);
      await prefs.setInt('flutter.userId', userId);
      await prefs.setString('flutter.loggedInUser', jsonEncode(userJson));
    } else {
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setInt('userId', userId);
      await prefs.setString('loggedInUser', jsonEncode(userJson));
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final loginResponse = await ApiService().login(loginRequest);

      await _saveUserSession(
        loginResponse.token,
        loginResponse.user.role,
        loginResponse.user.userId,
        loginResponse.user.toJson(),
      );

      if (loginResponse.user.role == 'Parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentDashboardScreen(userId: loginResponse.user.userId),
          ),
        );
      } else if (loginResponse.user.role == 'Child') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChildDashboardScreen(userId: loginResponse.user.userId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In', style: theme.textTheme.titleLarge),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: ThemeToggleSwitch(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => showPassword = !showPassword),
                ),
              ),
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: _handleSignIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Don\'t have an account? Sign up',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
