import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api';

class ApiService {
  static Future<http.Response> loginRaw(String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
  }


  static Future<http.Response> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
    required String team,
    required String teamPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'team': team,
        'teamPassword': teamPassword,
      }),
    );
    return response;
  }
}
