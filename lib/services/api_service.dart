import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../exceptions/api_exception.dart';
import '../models/user_model.dart';
import '../models/chore_model.dart';
import '../models/completed_chore_model.dart';
import '../models/reward_model.dart';
import '../models/redeemed_reward_model.dart';
import '../models/team_model.dart';
import '../models/login_models.dart';
import '../models/register_model.dart';

class ApiService {
  static const String baseUrl = 'https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api';

  static Map<String, String> getHeaders() => {
    'Content-Type': 'application/json',
  };

  // ---------- AUTH ----------
  Future<void> register(RegisterModel model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Registration failed: ${res.body}');
    }
  }

  Future<LoginResponse> login(LoginRequest model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );
    if (res.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Login failed: ${res.body}');
    }
  }

  // ---------- USERS ----------
  Future<List<User>> fetchUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/Users'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<User> getUser(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/Users/$userId'));
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to get user');
    }
  }

  Future<Team> fetchTeam(int teamId) async {
    final res = await http.get(Uri.parse('$baseUrl/Users/team/$teamId'));
    if (res.statusCode == 200) {
      return Team.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch team');
    }
  }

  Future<User> addChild(String email, int parentId) async {
    final res = await http.post(Uri.parse('$baseUrl/Users/addChild?email=$email&parentId=$parentId'));
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to add child: ${res.body}');
    }
  }

  static Future<Map<String, dynamic>?> createTeam(
      String teamName, String teamPassword, int userId) async {
    final url = Uri.parse('$baseUrl/Users/createTeam');
    final body = jsonEncode({
      'teamName': teamName,
      'teamPassword': teamPassword,
      'userId': userId,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint('API error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return null;
    }
  }



  static Future<Map<String, dynamic>?> joinTeam(int userId, String teamName, String teamPassword) async {
    final url = Uri.parse('$baseUrl/Users/joinTeam');
    final body = jsonEncode({
      'userId': userId,
      'teamName': teamName,
      'teamPassword': teamPassword,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      debugPrint('API error ${response.statusCode}: ${response.body}');
      return null;
    }
  }


  static Future<bool> addUserToTeam(int teamId, String email) async {
    final url = Uri.parse('$baseUrl/Users/addUserToTeam');
    final body = jsonEncode({
      'email': email,
      'teamId': teamId,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('API error ${response.statusCode}: ${response.body}');
      return false;
    }
  }


  static Future<bool> removeUserFromTeam(int userId) async {
    final url = Uri.parse('$baseUrl/Users/removeFromTeam/$userId');
    final response = await http.post(url);
    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Remove failed: ${response.statusCode} - ${response.body}');
      return false;
    }
  }


  Future<void> updateUserPoints(int userId, int points) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Users/$userId/points'),
      headers: getHeaders(),
      body: jsonEncode({'points': points}),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Registration failed: ${res.body}');
    }
  }

  // ---------- CHORES ----------
  Future<List<Chore>> fetchChores() async {
    final res = await http.get(Uri.parse('$baseUrl/Chores'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Chore.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch chores');
    }
  }

  Future<Chore> postChore(Chore model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Chores'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return Chore.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to post chore: ${res.body}');
    }
  }


  Future<Chore> updateChore(int id, Chore model) async {
    print('Updating chore to: ${model.toJson()}');

    final res = await http.put(
      Uri.parse('$baseUrl/Chores/$id'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode == 200) {
      print('Update successful: ${res.statusCode}');
      return Chore.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 204) {
      print('Update successful: ${res.statusCode} (No Content)');
      return model;
    } else {
      throw Exception('Failed to update chore: ${res.statusCode}');
    }
  }

  Future<void> completeChoreWithDate(int choreId, String date) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Chores/complete/$choreId'),
      headers: getHeaders(),
      body: jsonEncode({"completionDate": date}),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to complete chore');
    }
  }

  Future<void> undoCompletedChore(int completedChoreId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Chores/undoComplete/$completedChoreId'),
      headers: getHeaders(),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to undo completed chore');
    }
  }

  Future<void> deleteChore(int choreId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/Chores/$choreId'),
      headers: getHeaders(),
    );

    if (res.statusCode == 204) {
      print('Chore deleted successfully (No Content)');
      return;
    } else if (res.statusCode == 200) {
      print('Chore deleted successfully (OK)');
      return;
    } else {
      throw Exception('Failed to delete chore: ${res.statusCode}');
    }
  }


  Future<List<CompletedChore>> fetchCompletedChores() async {
    final res = await http.get(Uri.parse('$baseUrl/Chores/completed'));

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => CompletedChore.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch completed chores');
    }
  }



  // ---------- REWARDS ----------
  Future<List<Reward>> fetchRewards() async {
    final res = await http.get(Uri.parse('$baseUrl/Rewards'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Reward.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch rewards');
    }
  }

  Future<Reward> postReward(Reward model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Rewards'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode == 200) {
      print('create successful: ${res.statusCode}');
      return Reward.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 201) {
      print('create successful: ${res.statusCode} (No Content)');
      return model;
    } else {
      throw Exception('Failed to create reward: ${res.statusCode}');
    }
  }

  Future<Reward> updateReward(int id, Reward model) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Rewards/$id'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode == 200) {
      print('Update successful: ${res.statusCode}');
      return Reward.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 204) {
      print('Update successful: ${res.statusCode} (No Content)');
      return model;
    } else {
      throw Exception('Failed to update reward: ${res.statusCode}');
    }
  }

  Future<void> deleteReward(int rewardId) async {
    final res = await http.delete(Uri.parse('$baseUrl/Rewards/$rewardId'));

    if (res.statusCode == 204) {
      print('Reward deleted successfully (No Content)');
      return;
    } else if (res.statusCode == 200) {
      print('Reward deleted successfully (OK)');
      return;
    } else {
      throw Exception('Failed to delete Reward: ${res.statusCode}');
    }
  }

  // ---------- REDEEMED REWARDS ----------
  Future<List<RedeemedReward>> fetchAllRedeemedRewards() async {
    final response = await http.get(Uri.parse('$baseUrl/RedeemedRewards'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RedeemedReward.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load redeemed rewards');
    }
  }

  Future<List<RedeemedReward>> fetchRedeemedRewards(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/RedeemedRewards/$userId'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => RedeemedReward.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch redeemed rewards');
    }
  }

  Future<RedeemedReward> postRedeemedReward(RedeemedReward model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/RedeemedRewards'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );

    if (res.statusCode == 200) {
      print('redeemed successful: ${res.statusCode}');
      return RedeemedReward.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 201) {
      print('redeemed successful: ${res.statusCode} (No Content)');
      return model;
    } else {
      throw Exception('Failed to redeemed reward: ${res.statusCode}');
    }
  }
}