import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../services/article_service.dart';
import '../../services/session_client.dart';

/// Repository 由 Provider 创建，测试可以用 overrideWithValue 换成假实现。
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleService(dio: ref.watch(sessionClientProvider).dio);
});

final articleListControllerProvider =
    AsyncNotifierProvider<ArticleListController, List<Article>>(
      ArticleListController.new,
      // 由页面的“重试”按钮控制重试时机，避免后台重复请求。
      retry: (_, _) => null,
    );

/// AsyncNotifier 统一持有加载、数据和错误三种异步状态。
class ArticleListController extends AsyncNotifier<List<Article>> {
  @override
  Future<List<Article>> build() {
    return ref.watch(articleRepositoryProvider).fetchArticles();
  }

  /// 下拉刷新时保留当前列表，RefreshIndicator 自己展示刷新进度。
  Future<String?> refresh() async {
    final repository = ref.read(articleRepositoryProvider);
    try {
      state = AsyncData(await repository.fetchArticles());
      return null;
    } catch (error) {
      // 刷新失败时保留旧的 AsyncData，让用户仍然可以阅读当前列表。
      return error.toString();
    }
  }
}
