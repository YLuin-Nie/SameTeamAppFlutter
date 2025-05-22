import 'package:flutter/material.dart';
import '../services/api_service.dart'; // ✅ Relative import
import 'dart:convert';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    try {
      final response = await apiService.login(email, password);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final username = data['username'];
        final role = data['role']; // Make sure backend returns this

        print('Login successful: $token');

        if (!mounted) return;

        // ✅ Role-based redirection
        if (role == 'Parent') {
          Navigator.pushNamed(context, '/dashboard', arguments: {
            'token': token,
            'username': username,
            'role': role,
          });
        } else {
          Navigator.pushNamed(context, '/childDashboard', arguments: {
            'token': token,
            'username': username,
            'role': role,
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
