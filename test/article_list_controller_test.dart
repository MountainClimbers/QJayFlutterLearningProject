import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_controller.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/models/article_page.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';

void main() {
  const firstArticle = Article(
    id: 1,
    title: '第一页文章',
    link: 'https://example.com/1',
  );
  const secondArticle = Article(
    id: 2,
    title: '第二页文章',
    link: 'https://example.com/2',
  );
  const refreshedArticle = Article(
    id: 3,
    title: '刷新后的文章',
    link: 'https://example.com/3',
  );

  test('首次读取第零页并按顺序追加下一页', () async {
    final repository = _FakePagedArticleRepository((page, callCount) async {
      return switch (page) {
        0 => _page([firstArticle], page: 0, hasMore: true),
        1 => _page([secondArticle], page: 1, hasMore: false),
        _ => throw StateError('不应该请求第 $page 页'),
      };
    });
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitForRequest(container);
    await container.read(articleListControllerProvider.notifier).loadNextPage();

    expect(repository.requestedPages, [0, 1]);
    expect(repository.requestedPageSizes, [10, 10]);
    expect(container.read(articleListControllerProvider).articles, [
      firstArticle,
      secondArticle,
    ]);
    expect(container.read(articleListControllerProvider).hasMore, isFalse);
  });

  test('追加下一页时按照文章编号去重', () async {
    final repository = _FakePagedArticleRepository((page, callCount) async {
      return page == 0
          ? _page([firstArticle], page: 0, hasMore: true)
          : _page([firstArticle, secondArticle], page: 1, hasMore: false);
    });
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitForRequest(container);
    await container.read(articleListControllerProvider.notifier).loadNextPage();

    expect(container.read(articleListControllerProvider).articles, [
      firstArticle,
      secondArticle,
    ]);
  });

  test('下一页失败时保留文章并重试同一页', () async {
    var secondPageAttempts = 0;
    final repository = _FakePagedArticleRepository((page, callCount) async {
      if (page == 0) return _page([firstArticle], page: 0, hasMore: true);
      secondPageAttempts += 1;
      if (secondPageAttempts == 1) {
        throw const ArticleLoadException('下一页加载失败');
      }
      return _page([secondArticle], page: 1, hasMore: false);
    });
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    final controller = container.read(articleListControllerProvider.notifier);

    await _waitForRequest(container);
    await controller.loadNextPage();

    var state = container.read(articleListControllerProvider);
    expect(state.articles, [firstArticle]);
    expect(state.error.toString(), '下一页加载失败');
    expect(state.nextPage, 1);

    await controller.loadNextPage();

    state = container.read(articleListControllerProvider);
    expect(repository.requestedPages, [0, 1, 1]);
    expect(state.articles, [firstArticle, secondArticle]);
    expect(state.error, isNull);
  });

  test('没有更多数据时不再请求接口', () async {
    final repository = _FakePagedArticleRepository(
      (page, callCount) async => _page([firstArticle], page: 0, hasMore: false),
    );
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await _waitForRequest(container);
    await container.read(articleListControllerProvider.notifier).loadNextPage();

    expect(repository.requestedPages, [0]);
  });

  test('下拉刷新会丢弃稍后返回的旧分页结果', () async {
    final oldSecondPage = Completer<ArticlePage>();
    var firstPageRequests = 0;
    final repository = _FakePagedArticleRepository((page, callCount) async {
      if (page == 1) return oldSecondPage.future;
      firstPageRequests += 1;
      return firstPageRequests == 1
          ? _page([firstArticle], page: 0, hasMore: true)
          : _page([refreshedArticle], page: 0, hasMore: false);
    });
    final container = _createContainer(repository);
    addTearDown(container.dispose);
    final controller = container.read(articleListControllerProvider.notifier);

    await _waitForRequest(container);
    final loadingMore = controller.loadNextPage();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(articleListControllerProvider).isLoading, isTrue);

    expect(await controller.refresh(), isNull);
    oldSecondPage.complete(_page([secondArticle], page: 1, hasMore: false));
    await loadingMore;

    final state = container.read(articleListControllerProvider);
    expect(state.articles, [refreshedArticle]);
    expect(state.nextPage, 1);
    expect(state.hasMore, isFalse);
  });
}

ProviderContainer _createContainer(ArticleRepository repository) {
  final container = ProviderContainer(
    overrides: [articleRepositoryProvider.overrideWithValue(repository)],
  );
  container.listen(articleListControllerProvider, (_, _) {});
  return container;
}

Future<void> _waitForRequest(ProviderContainer container) async {
  for (var index = 0; index < 30; index++) {
    final state = container.read(articleListControllerProvider);
    if (!state.isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('文章列表未在预期时间内完成加载');
}

ArticlePage _page(
  List<Article> articles, {
  required int page,
  required bool hasMore,
}) {
  return ArticlePage(
    datas: articles,
    curPage: page + 1,
    pageCount: hasMore ? page + 2 : page + 1,
    over: !hasMore,
  );
}

class _FakePagedArticleRepository implements ArticleRepository {
  _FakePagedArticleRepository(this.handler);

  final Future<ArticlePage> Function(int page, int callCount) handler;
  final List<int> requestedPages = [];
  final List<int> requestedPageSizes = [];

  @override
  Future<ArticlePage> fetchArticles({
    required int page,
    int pageSize = wanAndroidPageSize,
  }) {
    requestedPages.add(page);
    requestedPageSizes.add(pageSize);
    return handler(page, requestedPages.length);
  }
}
