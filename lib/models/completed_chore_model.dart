import 'package:freezed_annotation/freezed_annotation.dart';

part 'completed_chore_model.freezed.dart';
part 'completed_chore_model.g.dart';

@freezed
class CompletedChore with _$CompletedChore {
  const factory CompletedChore({
    required int completedId,
    required int choreId,
    required String choreText,
    required int points,
    int? assignedTo,
    required String dateAssigned,
    required String completionDate,
  }) = _CompletedChore;

  factory CompletedChore.fromJson(Map<String, dynamic> json) =>
      _$CompletedChoreFromJson(json);
}
