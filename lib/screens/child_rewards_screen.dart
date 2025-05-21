import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChildRewardsScreen extends StatefulWidget {
  @override
  _ChildRewardsScreenState createState() => _ChildRewardsScreenState();
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> {
  int? userId;
  int points = 0;
  List<dynamic> rewards = [];
  List<dynamic> redeemed = [];

  final api = "https://sameteamapiazure-gfawexgsaph0cvg2.centralus-01.azurewebsites.net/api/";

  @override
  void initState() {
    super.initState();
    loadRewards();
  }

  Future<void> loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final user = jsonDecode(prefs.getString('user')!);
    userId = user['userId'];

    final res = await http.get(Uri.parse("${api}Rewards"), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      setState(() {
        rewards = jsonDecode(res.body);
      });
      loadRedeemed();
    }
  }

  Future<void> loadRedeemed() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(Uri.parse("${api}RedeemedRewards/$userId"), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      setState(() {
        redeemed = jsonDecode(res.body);
      });
    }
    loadPoints();
  }

  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await http.get(Uri.parse("${api}Users/$userId"), headers: {
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode == 200) {
      setState(() {
        points = jsonDecode(res.body)['points'] ?? 0;
      });
    }
  }

  Future<void> redeemReward(Map reward) async {
    if (points < reward['cost']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not enough points.")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final body = {
      "redemptionId": 0,
      "userId": userId,
      "rewardId": reward['rewardId'],
      "rewardName": reward['name'],
      "pointsSpent": reward['cost'],
      "dateRedeemed": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

    final postRes = await http.post(
      Uri.parse("${api}RedeemedRewards"),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (postRes.statusCode == 200 || postRes.statusCode == 201) {
      final updatedPoints = points - reward['cost'];
      final updateRes = await http.put(
        Uri.parse("${api}Users/$userId/points"),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"points": updatedPoints}),
      );

      if (updateRes.statusCode == 200 || updateRes.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Redeemed ${reward['name']}!")));
        loadRewards(); // Refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update points.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Redemption failed.")));
    }
  }

  Widget rewardItem(Map reward) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${reward['name']} - ${reward['cost']} pts"),
        ElevatedButton(onPressed: () => redeemReward(reward), child: Text("Redeem")),
      ],
    );
  }

  Widget redeemedItem(Map item) {
    final name = item['rewardName'] ?? rewards.firstWhere(
          (r) => r['rewardId'] == item['rewardId'],
      orElse: () => {'name': 'Unnamed'},
    )['name'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$name - ${item['pointsSpent']} pts\nRedeemed on: ${item['dateRedeemed']}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Child Rewards")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔘 Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: Text("Dashboard")),
                ElevatedButton(onPressed: () {}, child: Text("Chores")),
                ElevatedButton(onPressed: () {}, child: Text("Rewards")),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("Logout"),
                ),
              ],
            ),
            SizedBox(height: 20),

            Text("Unspent Points: $points", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),

            Text("Available Rewards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (rewards.isEmpty) Text("No rewards available.")
            else ...rewards.map((r) => rewardItem(r)),

            Divider(height: 32, thickness: 1),

            Text("Redemption History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (redeemed.isEmpty) Text("No redemptions yet.")
            else ...redeemed.map((r) => redeemedItem(r)),
          ],
        ),
      ),
    );
  }
}
