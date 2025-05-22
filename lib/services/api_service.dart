import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api';

  // Login - returns full response
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/Auth/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
  }

  // Register - returns full response
  Future<http.Response> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? team,
    String? teamPassword,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/register');
    final Map<String, dynamic> body = {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };

    // Optional team info
    if (team != null) body['team'] = team;
    if (teamPassword != null) body['teamPassword'] = teamPassword;

    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  // Get chores - sample with token
  Future<http.Response> getChores(String token) async {
    final url = Uri.parse('$baseUrl/Chores');
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Add chore - example POST request with token
  Future<http.Response> addChore(Map<String, dynamic> choreData, String token) async {
    final url = Uri.parse('$baseUrl/Chores');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(choreData),
    );
  }

  // Redeem reward - example
  Future<http.Response> redeemReward(Map<String, dynamic> rewardData, String token) async {
    final url = Uri.parse('$baseUrl/RedeemedRewards');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(rewardData),
    );
  }
}
