import 'package:freezed_annotation/freezed_annotation.dart';

part 'chore_model.freezed.dart';
part 'chore_model.g.dart';

@freezed
class Chore with _$Chore {
  const factory Chore({
    required int choreId,
    required String choreText,
    required int points,
    required int assignedTo,
    required String dateAssigned,
    required bool completed,
  }) = _Chore;

  factory Chore.fromJson(Map<String, dynamic> json) => _$ChoreFromJson(json);
}
