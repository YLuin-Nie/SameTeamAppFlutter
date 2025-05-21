class Team {
  final int teamId;
  final String teamName;

  Team({
    required this.teamId,
    required this.teamName,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      teamId: json['teamId'],
      teamName: json['teamName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
    };
  }
}
