import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../models/article_page.dart';
import '../../services/article_service.dart';
import '../../services/session_client.dart';
import 'article_list_state.dart';

/// Repository 由 Provider 创建，测试可以用 overrideWithValue 换成假实现。
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleService(dio: ref.watch(sessionClientProvider).dio);
});

final articleListControllerProvider =
    NotifierProvider<ArticleListController, ArticleListState>(
      ArticleListController.new,
    );

/// Riverpod 负责页码、请求和并发状态，分页组件只负责滚动与展示。
class ArticleListController extends Notifier<ArticleListState> {
  int _requestGeneration = 0;

  @override
  ArticleListState build() {
    ref.onDispose(() => _requestGeneration += 1);
    final generation = ++_requestGeneration;
    Future<void>.microtask(() => _loadFirstPage(generation)).ignore();
    return const ArticleListState(isLoading: true);
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isRefreshing || !state.hasMore) return;
    final generation = _requestGeneration;
    final page = state.nextPage;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ref
          .read(articleRepositoryProvider)
          .fetchArticles(page: page);
      if (!_isCurrent(generation)) return;
      _applyPage(result, requestedPage: page, replace: false);
    } catch (error) {
      if (!_isCurrent(generation)) return;
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  /// 下拉刷新保留已有文章；失败通过返回值交给页面显示 SnackBar。
  Future<String?> refresh() async {
    final previous = state;
    final generation = ++_requestGeneration;
    state = state.copyWith(
      isLoading: previous.pages.isEmpty,
      isRefreshing: true,
      error: null,
    );
    try {
      final result = await ref
          .read(articleRepositoryProvider)
          .fetchArticles(page: 0);
      if (!_isCurrent(generation)) return null;
      _applyPage(result, requestedPage: 0, replace: true);
      return null;
    } catch (error) {
      if (!_isCurrent(generation)) return null;
      state = previous.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: previous.pages.isEmpty ? error : null,
      );
      return error.toString();
    }
  }

  Future<void> _loadFirstPage(int generation) async {
    try {
      final result = await ref
          .read(articleRepositoryProvider)
          .fetchArticles(page: 0);
      if (!_isCurrent(generation)) return;
      _applyPage(result, requestedPage: 0, replace: true);
    } catch (error) {
      if (!_isCurrent(generation)) return;
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  void _applyPage(
    ArticlePage result, {
    required int requestedPage,
    required bool replace,
  }) {
    final knownIds = replace
        ? <int>{}
        : state.articles.map((article) => article.id).toSet();
    final uniqueArticles = <Article>[];
    for (final article in result.datas) {
      if (knownIds.add(article.id)) uniqueArticles.add(article);
    }
    state = state.copyWith(
      pages: replace ? [uniqueArticles] : [...state.pages, uniqueArticles],
      nextPage: requestedPage + 1,
      hasMore: result.hasMore,
      isLoading: false,
      isRefreshing: false,
      error: null,
    );
  }

  bool _isCurrent(int generation) {
    return ref.mounted && generation == _requestGeneration;
  }
}
