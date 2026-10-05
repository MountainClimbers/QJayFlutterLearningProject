import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/login_user.dart';
import '../../services/auth_service.dart';

/// 登录仓库需要先创建持久化 Cookie 容器，因此本身也是异步 Provider。
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) {
  return createPersistentAuthRepository();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, LoginUser?>(
      AuthController.new,
      retry: (_, _) => null,
    );

/// 管理应用范围内的登录用户，以及登录过程中加载和错误状态。
class AuthController extends AsyncNotifier<LoginUser?> {
  final Completer<void> _initialRestoreCompleted = Completer<void>();
  int _latestLoginOperation = 0;

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
  }) async {
    await _initialRestoreCompleted.future;
    final operation = ++_latestLoginOperation;
    state = const AsyncLoading<LoginUser?>();
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.login(
        username: username,
        password: password,
      );
      if (operation == _latestLoginOperation) {
        state = AsyncData(user);
      }
      return user;
    } catch (error, stackTrace) {
      if (operation == _latestLoginOperation) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _initialRestoreCompleted.future;
    final operation = ++_latestLoginOperation;
    final previousUser = switch (state) {
      AsyncData(:final value) => value,
      _ => null,
    };
    state = const AsyncLoading<LoginUser?>();
    try {
      final repository = await ref.read(authRepositoryProvider.future);
      await repository.logout();
      if (operation == _latestLoginOperation) {
        state = const AsyncData<LoginUser?>(null);
      }
    } catch (error) {
      if (operation == _latestLoginOperation) {
        state = AsyncData(previousUser);
      }
      rethrow;
    }
  }
}
