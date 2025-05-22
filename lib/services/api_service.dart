import 'dart:convert';
import 'package:http/http.dart' as http;

// Freezed model imports
import 'models/user_model.dart';
import 'models/chore_model.dart';
import 'models/reward_model.dart';
import 'models/redeemed_reward_model.dart';
import 'models/team_model.dart';
import 'models/login_models.dart';

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
      throw Exception('Registration failed: ${res.body}');
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
      throw Exception('Login failed: ${res.body}');
    }
  }

  // ---------------- USERS ----------------

  static Future<List<User>> fetchUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/Users'), headers: getHeaders(authorized: true));
    return (jsonDecode(res.body) as List).map((e) => User.fromJson(e)).toList();
  }

  static Future<User> getUser(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/Users/$userId'), headers: getHeaders(authorized: true));
    return User.fromJson(jsonDecode(res.body));
  }

  static Future<Team> fetchTeam(int teamId) async {
    final res = await http.get(Uri.parse('$baseUrl/Users/team/$teamId'), headers: getHeaders(authorized: true));
    return Team.fromJson(jsonDecode(res.body));
  }

  static Future<void> updateUser(int userId, User user) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Users/$userId'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(user.toJson()),
    );
    if (res.statusCode != 204) throw Exception('Failed to update user');
  }

  static Future<void> updateUserPoints(int userId, int points) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Users/$userId/points'),
      headers: getHeaders(authorized: true),
      body: jsonEncode({'points': points}),
    );
    if (res.statusCode != 204) throw Exception('Failed to update points');
  }

  static Future<User> addUserToTeam(String email, int teamId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Users/addUserToTeam'),
      headers: getHeaders(authorized: true),
      body: jsonEncode({'email': email, 'teamId': teamId}),
    );
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
    return Team.fromJson(jsonDecode(res.body));
  }

  static Future<void> removeUserFromTeam(int userId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Users/removeFromTeam/$userId'),
      headers: getHeaders(authorized: true),
    );
    if (res.statusCode != 200) throw Exception('Failed to remove user from team');
  }

  // ---------------- CHORES ----------------

  static Future<List<Chore>> fetchChores() async {
    final res = await http.get(Uri.parse('$baseUrl/Chores'), headers: getHeaders(authorized: true));
    return (jsonDecode(res.body) as List).map((e) => Chore.fromJson(e)).toList();
  }

  static Future<Chore> postChore(Chore chore) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Chores'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(chore.toJson()),
    );
    return Chore.fromJson(jsonDecode(res.body));
  }

  static Future<Chore> updateChore(int id, Chore chore) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Chores/$id'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(chore.toJson()),
    );
    return Chore.fromJson(jsonDecode(res.body));
  }

  static Future<void> deleteChore(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/Chores/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200 && res.statusCode != 204) throw Exception('Failed to delete chore');
  }

  static Future<void> moveChoreToCompleted(int id) async {
    final res = await http.post(Uri.parse('$baseUrl/Chores/complete/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw Exception('Failed to complete chore');
  }

  static Future<void> undoCompletedChore(int id) async {
    final res = await http.post(Uri.parse('$baseUrl/Chores/undoComplete/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200) throw Exception('Failed to undo chore');
  }

  static Future<List<CompletedChore>> fetchCompletedChores() async {
    final res = await http.get(Uri.parse('$baseUrl/Chores/completed'), headers: getHeaders(authorized: true));
    return (jsonDecode(res.body) as List).map((e) => CompletedChore.fromJson(e)).toList();
  }

  // ---------------- REWARDS ----------------

  static Future<List<Reward>> fetchRewards() async {
    final res = await http.get(Uri.parse('$baseUrl/Rewards'), headers: getHeaders(authorized: true));
    return (jsonDecode(res.body) as List).map((e) => Reward.fromJson(e)).toList();
  }

  static Future<Reward> postReward(Reward reward) async {
    final res = await http.post(
      Uri.parse('$baseUrl/Rewards'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(reward.toJson()),
    );
    return Reward.fromJson(jsonDecode(res.body));
  }

  static Future<Reward> updateReward(int id, Reward reward) async {
    final res = await http.put(
      Uri.parse('$baseUrl/Rewards/$id'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(reward.toJson()),
    );
    return Reward.fromJson(jsonDecode(res.body));
  }

  static Future<void> deleteReward(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/Rewards/$id'), headers: getHeaders(authorized: true));
    if (res.statusCode != 200 && res.statusCode != 204) throw Exception('Failed to delete reward');
  }

  // ---------------- REDEEMED REWARDS ----------------

  static Future<List<RedeemedReward>> fetchRedeemedRewards(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/RedeemedRewards/$userId'), headers: getHeaders(authorized: true));
    return (jsonDecode(res.body) as List).map((e) => RedeemedReward.fromJson(e)).toList();
  }

  static Future<RedeemedReward> postRedeemedReward(RedeemedReward reward) async {
    final res = await http.post(
      Uri.parse('$baseUrl/RedeemedRewards'),
      headers: getHeaders(authorized: true),
      body: jsonEncode(reward.toJson()),
    );
    return RedeemedReward.fromJson(jsonDecode(res.body));
  }
}
