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
  @override
  Future<LoginUser?> build() async {
    final repository = await ref.watch(authRepositoryProvider.future);
    return repository.restoreSession();
  }

  Future<LoginUser> login({
    required String username,
    required String password,
  }) async {
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
  }
}
