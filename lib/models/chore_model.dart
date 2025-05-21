class Chore {
  final int choreId;
  final String choreText;
  final int points;
  final int assignedTo;
  final String dateAssigned;
  final bool completed;

  Chore({
    required this.choreId,
    required this.choreText,
    required this.points,
    required this.assignedTo,
    required this.dateAssigned,
    required this.completed,
  });

  factory Chore.fromJson(Map<String, dynamic> json) {
    return Chore(
      choreId: json['choreId'],
      choreText: json['choreText'],
      points: json['points'],
      assignedTo: json['assignedTo'],
      dateAssigned: json['dateAssigned'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'choreId': choreId,
      'choreText': choreText,
      'points': points,
      'assignedTo': assignedTo,
      'dateAssigned': dateAssigned,
      'completed': completed,
    };
  }
}
