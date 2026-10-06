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

  test('注册成功后保存自动登录返回的用户', () async {
    const registeredUser = LoginUser(id: 10, username: 'new-user');
    final repository = _FakeAuthRepository(registerResult: registeredUser);
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final result = await container
        .read(authControllerProvider.notifier)
        .register(
          username: 'new-user',
          password: '123456',
          repeatedPassword: '123456',
        );

    expect(result, registeredUser);
    expect(container.read(authControllerProvider).value, registeredUser);
    expect(repository.lastRepeatedPassword, '123456');
  });

  test('注册进行中退出请求等待注册完成', () async {
    final registerCompleter = Completer<LoginUser>();
    final repository = _FakeAuthRepository(
      registerHandler: (_, _, _) => registerCompleter.future,
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final registerFuture = container
        .read(authControllerProvider.notifier)
        .register(
          username: 'new-user',
          password: '123456',
          repeatedPassword: '123456',
        );
    await Future<void>.delayed(Duration.zero);
    final logoutFuture = container
        .read(authControllerProvider.notifier)
        .logout();
    await Future<void>.delayed(Duration.zero);

    expect(repository.registerCallCount, 1);
    expect(repository.logoutCallCount, 0);

    registerCompleter.complete(const LoginUser(id: 10, username: 'new-user'));
    await registerFuture;
    await logoutFuture;
    expect(container.read(authControllerProvider).value, isNull);
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

  test('先登录后退出时，退出等待登录完成并最终清空用户', () async {
    final loginCompleter = Completer<LoginUser>();
    final repository = _FakeAuthRepository(
      loginHandler: (_, _) => loginCompleter.future,
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final loginFuture = container
        .read(authControllerProvider.notifier)
        .login(username: 'new-user', password: '123456');
    await Future<void>.delayed(Duration.zero);
    final logoutFuture = container
        .read(authControllerProvider.notifier)
        .logout();
    await Future<void>.delayed(Duration.zero);

    expect(repository.loginCallCount, 1);
    expect(repository.logoutCallCount, 0);

    const loggedInUser = LoginUser(id: 1, username: 'new-user');
    loginCompleter.complete(loggedInUser);
    expect(await loginFuture, loggedInUser);
    await logoutFuture;

    expect(repository.logoutCallCount, 1);
    expect(container.read(authControllerProvider).value, isNull);
  });

  test('先退出后登录时，登录等待退出完成并最终保存新用户', () async {
    final logoutCompleter = Completer<void>();
    const restoredUser = LoginUser(id: 7, username: 'old-user');
    const loggedInUser = LoginUser(id: 8, username: 'new-user');
    final repository = _FakeAuthRepository(
      restoredUser: restoredUser,
      loginResult: loggedInUser,
      logoutHandler: () => logoutCompleter.future,
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    final logoutFuture = container
        .read(authControllerProvider.notifier)
        .logout();
    await Future<void>.delayed(Duration.zero);
    final loginFuture = container
        .read(authControllerProvider.notifier)
        .login(username: 'new-user', password: '123456');
    await Future<void>.delayed(Duration.zero);

    expect(repository.logoutCallCount, 1);
    expect(repository.loginCallCount, 0);

    logoutCompleter.complete();
    await logoutFuture;
    expect(await loginFuture, loggedInUser);

    expect(repository.loginCallCount, 1);
    expect(container.read(authControllerProvider).value, loggedInUser);
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

  test('退出失败时清空界面用户并继续抛出异常', () async {
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

    expect(container.read(authControllerProvider).value, isNull);
  });

  test('会话过期时只清理本地凭证并重置登录状态', () async {
    const restoredUser = LoginUser(id: 7, username: 'MountainClimbers');
    final repository = _FakeAuthRepository(restoredUser: restoredUser);
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).expireSession();

    expect(repository.clearSessionCallCount, 1);
    expect(repository.logoutCallCount, 0);
    expect(container.read(authControllerProvider).value, isNull);
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
    this.registerResult,
    this.loginError,
    this.restoreHandler,
    this.loginHandler,
    this.registerHandler,
    this.logoutHandler,
    this.logoutError,
  });

  final LoginUser? restoredUser;
  final LoginUser? loginResult;
  final LoginUser? registerResult;
  final Object? loginError;
  final Future<LoginUser?> Function()? restoreHandler;
  final Future<LoginUser> Function(String username, String password)?
  loginHandler;
  final Future<LoginUser> Function(
    String username,
    String password,
    String repeatedPassword,
  )?
  registerHandler;
  final Future<void> Function()? logoutHandler;
  final Object? logoutError;
  String? lastUsername;
  String? lastPassword;
  String? lastRepeatedPassword;
  int loginCallCount = 0;
  int registerCallCount = 0;
  int logoutCallCount = 0;

  int clearSessionCallCount = 0;

  @override
  Future<void> clearSession() async {
    clearSessionCallCount += 1;
  }

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
  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  }) async {
    registerCallCount += 1;
    lastUsername = username;
    lastPassword = password;
    lastRepeatedPassword = repeatedPassword;
    if (registerHandler case final handler?) {
      return handler(username, password, repeatedPassword);
    }
    return registerResult ?? const LoginUser(username: 'registered');
  }

  @override
  Future<void> logout() async {
    logoutCallCount += 1;
    if (logoutHandler case final handler?) await handler();
    if (logoutError case final Object error) throw error;
  }
}
