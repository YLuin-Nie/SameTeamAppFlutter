class CompletedChore {
  final int completedId;
  final int choreId;
  final String choreText;
  final int points;
  final int? assignedTo;
  final String dateAssigned;
  final String completionDate;

  CompletedChore({
    required this.completedId,
    required this.choreId,
    required this.choreText,
    required this.points,
    required this.assignedTo,
    required this.dateAssigned,
    required this.completionDate,
  });

  factory CompletedChore.fromJson(Map<String, dynamic> json) {
    return CompletedChore(
      completedId: json['completedId'],
      choreId: json['choreId'],
      choreText: json['choreText'],
      points: json['points'],
      assignedTo: json['assignedTo'],
      dateAssigned: json['dateAssigned'],
      completionDate: json['completionDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedId': completedId,
      'choreId': choreId,
      'choreText': choreText,
      'points': points,
      'assignedTo': assignedTo,
      'dateAssigned': dateAssigned,
      'completionDate': completionDate,
    };
  }
}
