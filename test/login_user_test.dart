import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/models/login_user.dart';

void main() {
  test('登录用户模型解析字段并提供展示名称', () {
    final user = LoginUser.fromJson({
      'id': 7,
      'username': 'MountainClimbers',
      'nickname': '山友',
      'publicName': '登山者',
    });

    expect(user.id, 7);
    expect(user.username, 'MountainClimbers');
    expect(user.displayName, '山友');
  });

  test('登录用户模型为空字段提供默认值', () {
    final user = LoginUser.fromJson(<String, dynamic>{});

    expect(user.id, 0);
    expect(user.username, isEmpty);
    expect(user.nickname, isEmpty);
    expect(user.publicName, isEmpty);
  });

  test('不可变登录用户支持值相等和复制修改', () {
    const user = LoginUser(id: 7, username: 'MountainClimbers');
    const sameUser = LoginUser(id: 7, username: 'MountainClimbers');

    expect(user, sameUser);
    expect(user.copyWith(nickname: '山友').displayName, '山友');
    expect(user.nickname, isEmpty);
  });
}
