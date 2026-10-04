import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_user.freezed.dart';
part 'login_user.g.dart';

@Freezed(toJson: false)
abstract class LoginUser with _$LoginUser {
  const LoginUser._();

  const factory LoginUser({
    @Default(0) int id,
    @Default('') String username,
    @Default('') String nickname,
    @Default('') String publicName,
  }) = _LoginUser;

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  String get displayName {
    if (nickname.isNotEmpty) return nickname;
    if (publicName.isNotEmpty) return publicName;
    return username;
  }
}
