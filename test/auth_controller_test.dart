import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/auth/auth_controller.dart';
import 'package:qjay_flutter_learning/models/login_user.dart';
import 'package:qjay_flutter_learning/services/auth_service.dart';

void main() {
  test('启动时从持久化凭证恢复用户', () async {
    const restoredUser = LoginUser(id: 7, username: 'mountain');
    final repository = _FakeAuthRepository(restoredUser: restoredUser);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    expect(await container.read(authControllerProvider.future), restoredUser);
  });

  test('登录成功后保存当前用户状态', () async {
    const loggedInUser = LoginUser(id: 8, nickname: '登山者');
    final repository = _FakeAuthRepository(loginResult: loggedInUser);
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final result = await container
        .read(authControllerProvider.notifier)
        .login(username: 'mountain', password: '123456');

    expect(result, loggedInUser);
    expect(container.read(authControllerProvider).value, loggedInUser);
    expect(repository.lastUsername, 'mountain');
    expect(repository.lastPassword, '123456');
  });

  test('登录失败后保存错误状态并继续抛出异常', () async {
    const exception = AuthException('账号密码不匹配！');
    final repository = _FakeAuthRepository(loginError: exception);
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await expectLater(
      container
          .read(authControllerProvider.notifier)
          .login(username: 'mountain', password: 'wrong'),
      throwsA(exception),
    );

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, exception);
  });
}

ProviderContainer _createContainer(AuthRepository repository) {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWith((ref) async => repository)],
  );
  container.listen(authControllerProvider, (_, _) {});
  return container;
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.restoredUser, this.loginResult, this.loginError});

  final LoginUser? restoredUser;
  final LoginUser? loginResult;
  final Object? loginError;
  String? lastUsername;
  String? lastPassword;

  @override
  Future<LoginUser> login({
    required String username,
    required String password,
  }) async {
    lastUsername = username;
    lastPassword = password;
    if (loginError case final Object error) throw error;
    return loginResult ?? const LoginUser(username: 'default');
  }

  @override
  Future<LoginUser?> restoreSession() async => restoredUser;
}
