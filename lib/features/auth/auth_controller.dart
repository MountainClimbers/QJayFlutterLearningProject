import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/login_user.dart';
import '../../services/auth_service.dart';
import '../../services/session_client.dart';

/// 登录仓库需要先创建持久化 Cookie 容器，因此本身也是异步 Provider。
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) {
  final client = ref.watch(sessionClientProvider);
  return createAuthRepository(client);
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, LoginUser?>(
      AuthController.new,
      retry: (_, _) => null,
    );

/// 管理应用范围内的登录用户，以及登录过程中加载和错误状态。
class AuthController extends AsyncNotifier<LoginUser?> {
  final Completer<void> _initialRestoreCompleted = Completer<void>();
  Future<void> _authenticationQueue = Future<void>.value();

  @override
  Future<LoginUser?> build() async {
    try {
      final repository = await ref.watch(authRepositoryProvider.future);
      return await repository.restoreSession();
    } finally {
      if (!_initialRestoreCompleted.isCompleted) {
        _initialRestoreCompleted.complete();
      }
    }
  }

  Future<LoginUser> login({
    required String username,
    required String password,
  }) {
    return _runSerialized(() async {
      await _initialRestoreCompleted.future;
      state = const AsyncLoading<LoginUser?>();
      try {
        final repository = await ref.read(authRepositoryProvider.future);
        final user = await repository.login(
          username: username,
          password: password,
        );
        state = AsyncData(user);
        return user;
      } catch (error, stackTrace) {
        state = AsyncError(error, stackTrace);
        rethrow;
      }
    });
  }

  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  }) {
    return _runSerialized(() async {
      await _initialRestoreCompleted.future;
      state = const AsyncLoading<LoginUser?>();
      try {
        final repository = await ref.read(authRepositoryProvider.future);
        final user = await repository.register(
          username: username,
          password: password,
          repeatedPassword: repeatedPassword,
        );
        state = AsyncData(user);
        return user;
      } catch (error, stackTrace) {
        state = AsyncError(error, stackTrace);
        rethrow;
      }
    });
  }

  Future<void> logout() {
    return _runSerialized(() async {
      await _initialRestoreCompleted.future;
      state = const AsyncLoading<LoginUser?>();
      try {
        final repository = await ref.read(authRepositoryProvider.future);
        await repository.logout();
        state = const AsyncData<LoginUser?>(null);
      } catch (_) {
        // 退出请求和本地 Cookie 清理无法一起回滚，失败后也不能继续显示已登录。
        state = const AsyncData<LoginUser?>(null);
        rethrow;
      }
    });
  }

  Future<void> expireSession() {
    return _runSerialized(() async {
      await _initialRestoreCompleted.future;
      try {
        final repository = await ref.read(authRepositoryProvider.future);
        await repository.clearSession();
      } finally {
        state = const AsyncData<LoginUser?>(null);
      }
    });
  }

  Future<T> _runSerialized<T>(Future<T> Function() operation) {
    final result = Completer<T>();
    _authenticationQueue = _authenticationQueue.then((_) async {
      try {
        result.complete(await operation());
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }
}
