class User {
  final int userId;
  final String username;
  final String email;
  final String role;
  final int points;
  final int totalPoints;
  final int? teamId;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.points,
    required this.totalPoints,
    this.teamId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      points: json['points'],
      totalPoints: json['totalPoints'],
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'role': role,
      'points': points,
      'totalPoints': totalPoints,
      'teamId': teamId,
    };
  }
}
