import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_models.dart';

class ApiService {
  static const String baseUrl = 'https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/';

  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('${baseUrl}Auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(LoginRequest(email: email, password: password).toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(data);

      // Save token to local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);
      await prefs.setString('user', jsonEncode(loginResponse.user));
      return true;
    } else {
      return false;
    }
  }
}
