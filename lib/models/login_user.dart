import 'package:json_annotation/json_annotation.dart';

part 'login_user.g.dart';

@JsonSerializable(createToJson: false)
class LoginUser {
  const LoginUser({
    this.id = 0,
    this.username = '',
    this.nickname = '',
    this.publicName = '',
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(defaultValue: '')
  final String username;

  @JsonKey(defaultValue: '')
  final String nickname;

  @JsonKey(defaultValue: '')
  final String publicName;

  String get displayName {
    if (nickname.isNotEmpty) return nickname;
    if (publicName.isNotEmpty) return publicName;
    return username;
  }
}
