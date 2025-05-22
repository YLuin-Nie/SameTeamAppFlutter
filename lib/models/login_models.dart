import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_models.freezed.dart';
part 'login_models.g.dart';

@freezed
class LoginModel with _$LoginModel {
  const factory LoginModel({
    required String email,
    required String password,
  }) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) => _$LoginModelFromJson(json);
}

@freezed
class RegisterModel with _$RegisterModel {
  const factory RegisterModel({
    required String username,
    required String email,
    required String password,
    String? role,
    String? team,
    String? teamPassword,
  }) = _RegisterModel;

  factory RegisterModel.fromJson(Map<String, dynamic> json) => _$RegisterModelFromJson(json);
}
