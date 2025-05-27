import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/login_models.dart';
import '../services/api_service.dart';
import '../screens/parent_dashboard_screen.dart';
import '../screens/child_dashboard_screen.dart';


class SignInScreen extends StatefulWidget {
  final int userId;
  const SignInScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? selectedDate;
  bool showPassword = false;
  bool isLoading = false;

  // 🌙 Track dark mode state
  bool _isDarkMode = false;

  // 🌙 Toggle dark mode on or off
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final loginResponse = await ApiService().login(loginRequest);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);
      await prefs.setInt('userId', loginResponse.user.userId);
      await prefs.setString('role', loginResponse.user.role);

      if (loginResponse.user.role == 'Parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ParentDashboardScreen(
              userId: loginResponse.user.userId,
            ),
          ),
        );
      } else if (loginResponse.user.role == 'Child') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChildDashboardScreen(
              userId: loginResponse.user.userId,
            ),
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
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _handleSignIn,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
