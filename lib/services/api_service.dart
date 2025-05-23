import 'dart:convert';
import 'package:http/http.dart' as http;

import '../exceptions/api_exception.dart';
import '../models/user_model.dart';
import '../models/chore_model.dart';
import '../models/completed_chore_model.dart';
import '../models/reward_model.dart';
import '../models/redeemed_reward_model.dart';
import '../models/team_model.dart';
import '../models/login_models.dart';

class ApiService {
  static const String baseUrl = 'https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api';
  static String? token;

  static Map<String, String> getHeaders({bool authorized = false}) {
    return {
      'Content-Type': 'application/json',
      if (authorized && token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------- AUTH ----------------

  static Future<void> register(RegisterModel model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Auth/register'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw ApiException('Registration failed: ${res.body}', res.statusCode);
    }
  }

  static Future<Map<String, dynamic>> login(LoginModel model) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Auth/login'),
      headers: getHeaders(),
      body: jsonEncode(model.toJson()),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      token = data['token'];
      return data;
    } else {
      throw ApiException('Login failed: ${res.body}', res.statusCode);
    }
  }

  // ---------------- USERS ----------------

  static Future<List<User>> fetchUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/Users'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to fetch users', res.statusCode);
    return (jsonDecode(res.body) as List).map((e) => User.fromJson(e)).toList();
  }

  static Future<User> getUser(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/Users/$userId'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to get user', res.statusCode);
    return User.fromJson(jsonDecode(res.body));
  }

  static Future<Team> fetchTeam(int teamId) async {
    final res = await http.get(Uri.parse('$baseUrl/Users/team/$teamId'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to fetch team', res.statusCode);
    return Team.fromJson(jsonDecode(res.body));
  }

  static Future<void> updateUser(int userId, User user) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Users/$userId'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(user.toJson()),
    );
    if (res.statusCode != 204) throw ApiException('Failed to update user', res.statusCode);
  }

  static Future<void> updateUserPoints(int userId, int points) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Users/$userId/points'),
      headers: getHeaders(authorized: true),
      body: jsonEncode({'points': points}),
    );
    if (res.statusCode != 204) throw ApiException('Failed to update points', res.statusCode);
  }

  static Future<User> addUserToTeam(String email, int teamId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Users/addUserToTeam'),
      headers: getHeaders(authorized: true),
      body: jsonEncode({'email': email, 'teamId': teamId}),
    );
    if (res.statusCode != 200) throw ApiException('Failed to add user to team', res.statusCode);
    return User.fromJson(jsonDecode(res.body));
  }

  static Future<Team> joinTeam(int userId, String teamName, String teamPassword) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Users/joinTeam'),
      headers: getHeaders(authorized: true),
      body: jsonEncode({
        'userId': userId,
        'teamName': teamName,
        'teamPassword': teamPassword,
      }),
    );
    if (res.statusCode != 200) throw ApiException('Failed to join team', res.statusCode);
    return Team.fromJson(jsonDecode(res.body));
  }

  static Future<Team> createTeam(int userId, String teamName, String teamPassword) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Users/createTeam'),
      headers: getHeaders(authorized: true),
      body: jsonEncode({
        'userId': userId,
        'teamName': teamName,
        'teamPassword': teamPassword,
      }),
    );
    if (res.statusCode != 200) throw ApiException('Failed to create team', res.statusCode);
    return Team.fromJson(jsonDecode(res.body));
  }

  static Future<void> removeUserFromTeam(int userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Users/removeFromTeam/$userId'),
      headers: getHeaders(authorized: true),
    );
    if (res.statusCode != 200) throw ApiException('Failed to remove user from team', res.statusCode);
  }

  // ---------------- CHORES ----------------

  static Future<List<Chore>> fetchChores() async {
    final res = await http.get(Uri.parse('$baseUrl/Chores'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to fetch chores', res.statusCode);
    return (jsonDecode(res.body) as List).map((e) => Chore.fromJson(e)).toList();
  }

  static Future<Chore> postChore(Chore chore) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Chores'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(chore.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) throw ApiException('Failed to create chore', res.statusCode);
    return Chore.fromJson(jsonDecode(res.body));
  }

  static Future<Chore> updateChore(int id, Chore chore) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Chores/$id'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(chore.toJson()),
    );
    if (res.statusCode != 200) throw ApiException('Failed to update chore', res.statusCode);
    return Chore.fromJson(jsonDecode(res.body));
  }

  static Future<void> deleteChore(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/Chores/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200 && res.statusCode != 204) throw ApiException('Failed to delete chore', res.statusCode);
  }

  static Future<void> moveChoreToCompleted(int id) async {
    final res = await http.post(Uri.parse('$baseUrl/Chores/complete/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to complete chore', res.statusCode);
  }

  static Future<void> undoCompletedChore(int id) async {
    final res = await http.post(Uri.parse('$baseUrl/Chores/undoComplete/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to undo completed chore', res.statusCode);
  }

  static Future<List<CompletedChore>> fetchCompletedChores() async {
    final res = await http.get(Uri.parse('$baseUrl/Chores/completed'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to fetch completed chores', res.statusCode);
    return (jsonDecode(res.body) as List).map((e) => CompletedChore.fromJson(e)).toList();
  }

  // ---------------- REWARDS ----------------

  static Future<List<Reward>> fetchRewards() async {
    final res = await http.get(Uri.parse('$baseUrl/Rewards'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to fetch rewards', res.statusCode);
    return (jsonDecode(res.body) as List).map((e) => Reward.fromJson(e)).toList();
  }

  static Future<Reward> postReward(Reward reward) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Rewards'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(reward.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) throw ApiException('Failed to create reward', res.statusCode);
    return Reward.fromJson(jsonDecode(res.body));
  }

  static Future<Reward> updateReward(int id, Reward reward) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Rewards/$id'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(reward.toJson()),
    );
    if (res.statusCode != 200) throw ApiException('Failed to update reward', res.statusCode);
    return Reward.fromJson(jsonDecode(res.body));
  }

  static Future<void> deleteReward(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/Rewards/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200 && res.statusCode != 204) throw ApiException('Failed to delete reward', res.statusCode);
  }

  // ---------------- REDEEMED REWARDS ----------------

  static Future<List<RedeemedReward>> fetchRedeemedRewards(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/RedeemedRewards/$userId'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw ApiException('Failed to fetch redeemed rewards', res.statusCode);
    return (jsonDecode(res.body) as List).map((e) => RedeemedReward.fromJson(e)).toList();
  }

  static Future<RedeemedReward> postRedeemedReward(RedeemedReward reward) async {
    final res = await http.post(
      Uri.parse('$baseUrl/RedeemedRewards'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(reward.toJson()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) throw ApiException('Failed to redeem reward', res.statusCode);
    return RedeemedReward.fromJson(jsonDecode(res.body));
  }
}
