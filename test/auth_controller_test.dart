import 'dart:async';

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

  test('启动恢复完成后才执行登录，恢复结果不会覆盖登录用户', () async {
    final restoreCompleter = Completer<LoginUser?>();
    const loggedInUser = LoginUser(id: 9, username: 'new-user');
    final repository = _FakeAuthRepository(
      restoreHandler: () => restoreCompleter.future,
      loginResult: loggedInUser,
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    final loginFuture = container
        .read(authControllerProvider.notifier)
        .login(username: 'new-user', password: '123456');
    await Future<void>.delayed(Duration.zero);
    expect(repository.loginCallCount, 0);

    restoreCompleter.complete(null);
    expect(await loginFuture, loggedInUser);
    expect(container.read(authControllerProvider).value, loggedInUser);
  });

  test('多个登录请求只允许最后开始的请求更新状态', () async {
    final firstCompleter = Completer<LoginUser>();
    final secondCompleter = Completer<LoginUser>();
    final repository = _FakeAuthRepository(
      loginHandler: (username, _) =>
          username == 'first' ? firstCompleter.future : secondCompleter.future,
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final firstLogin = container
        .read(authControllerProvider.notifier)
        .login(username: 'first', password: '123456');
    final secondLogin = container
        .read(authControllerProvider.notifier)
        .login(username: 'second', password: '123456');
    const secondUser = LoginUser(id: 2, username: 'second');
    secondCompleter.complete(secondUser);
    expect(await secondLogin, secondUser);
    expect(container.read(authControllerProvider).value, secondUser);

    const firstUser = LoginUser(id: 1, username: 'first');
    firstCompleter.complete(firstUser);
    expect(await firstLogin, firstUser);
    expect(container.read(authControllerProvider).value, secondUser);
  });

  test('退出成功后把全局用户状态改为未登录', () async {
    const restoredUser = LoginUser(id: 7, username: 'MountainClimbers');
    final repository = _FakeAuthRepository(restoredUser: restoredUser);
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).logout();

    expect(repository.logoutCallCount, 1);
    expect(container.read(authControllerProvider).value, isNull);
  });

  test('退出失败时保留原用户并继续抛出异常', () async {
    const restoredUser = LoginUser(id: 7, username: 'MountainClimbers');
    const exception = AuthException('退出失败');
    final repository = _FakeAuthRepository(
      restoredUser: restoredUser,
      logoutError: exception,
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await expectLater(
      container.read(authControllerProvider.notifier).logout(),
      throwsA(exception),
    );

    expect(container.read(authControllerProvider).value, restoredUser);
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
  _FakeAuthRepository({
    this.restoredUser,
    this.loginResult,
    this.loginError,
    this.restoreHandler,
    this.loginHandler,
    this.logoutError,
  });

  final LoginUser? restoredUser;
  final LoginUser? loginResult;
  final Object? loginError;
  final Future<LoginUser?> Function()? restoreHandler;
  final Future<LoginUser> Function(String username, String password)?
  loginHandler;
  final Object? logoutError;
  String? lastUsername;
  String? lastPassword;
  int loginCallCount = 0;
  int logoutCallCount = 0;

  @override
  Future<LoginUser> login({
    required String username,
    required String password,
  }) async {
    lastUsername = username;
    lastPassword = password;
    loginCallCount += 1;
    if (loginError case final Object error) throw error;
    if (loginHandler case final handler?) return handler(username, password);
    return loginResult ?? const LoginUser(username: 'default');
  }

  @override
  Future<LoginUser?> restoreSession() async {
    if (restoreHandler case final handler?) return handler();
    return restoredUser;
  }

  @override
  Future<void> logout() async {
    logoutCallCount += 1;
    if (logoutError case final Object error) throw error;
  }
}
