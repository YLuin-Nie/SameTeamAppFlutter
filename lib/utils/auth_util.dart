import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<Map<String, dynamic>?> getCurrentUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('loggedInUser');
  if (userString == null) return null;
  return jsonDecode(userString);
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // removes token, userId, role, loggedInUser

  // Go back to SignIn
  Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
}
