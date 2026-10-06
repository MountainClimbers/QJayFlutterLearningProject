# 文章与收藏列表分页 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为文章列表和收藏列表增加标准下拉刷新及每页 10 条的自动上拉分页。

**Architecture:** Flutter 官方 `RefreshIndicator` 负责下拉手势，`infinite_scroll_pagination` 的 `PagedListView` 负责触底和分页状态 UI，Riverpod 控制器负责页码、请求、去重和过期响应隔离。Dio Repository 返回由 Freezed 和 json_serializable 生成的 `ArticlePage`，收藏控制器继续维护账号周期与本地收藏修改版本。

**Tech Stack:** Flutter、Dart、Riverpod 3、Dio、Freezed、json_serializable、infinite_scroll_pagination 5.1.1、flutter_test

## Global Constraints

- 两个接口都从第 0 页开始，固定传递 `page_size=10`。
- 下拉刷新使用 Flutter SDK 的 `RefreshIndicator`。
- 上拉分页使用 `infinite_scroll_pagination ^5.1.1`。
- 数据模型继续使用 `freezed` 与 `json_serializable` 组合。
- 刷新必须作废正在执行的旧分页请求。
- 收藏分页必须保留账号、登录周期和本地收藏操作隔离。
- 所有 Git 提交信息使用中文，并按独立功能拆分。

---

## 文件结构

- 新建 `lib/models/article_page.dart`：解析 WanAndroid 分页字段并提供 `hasMore`。
- 新建 `lib/features/articles/article_list_state.dart`：文章列表的分页页组、页码、加载和错误状态。
- 修改 `lib/services/article_service.dart`：按页请求文章并返回 `ArticlePage`。
- 修改 `lib/services/collection_service.dart`：按页请求收藏并返回 `ArticlePage`。
- 修改 `lib/features/articles/article_list_controller.dart`：管理首次加载、刷新、下一页、去重和请求世代。
- 修改 `lib/features/articles/article_list_page.dart`：使用 `RefreshIndicator` 与 `PagedListView`。
- 修改 `lib/features/collections/collection_state.dart`：增加分页页组、下一页、结束状态和分页错误。
- 修改 `lib/features/collections/collection_controller.dart`：在现有收藏一致性规则上增加分页。
- 修改 `lib/features/collections/collection_page.dart`：使用统一分页列表状态 UI。
- 新建 `lib/features/shared/paging_views.dart`：两个页面复用的首次错误、空数据、下一页错误和结束提示。
- 新建 `test/article_page_test.dart` 和 `test/article_list_controller_test.dart`：覆盖模型与文章分页控制器。
- 修改现有服务、控制器、页面和应用流程测试：更新 Repository 接口并覆盖分页交互。
- 新建 `docs/pagination-loading.md`：记录面试时可口述的分页技术与数据流。

---

### Task 1: 分页模型与网络接口

**Files:**
- Create: `lib/models/article_page.dart`
- Generate: `lib/models/article_page.freezed.dart`
- Generate: `lib/models/article_page.g.dart`
- Create: `test/article_page_test.dart`
- Modify: `lib/services/article_service.dart`
- Modify: `lib/services/collection_service.dart`
- Modify: `test/article_service_test.dart`
- Modify: `test/collection_service_test.dart`
- Modify: `test/app_flow_test.dart`
- Modify: `test/app_router_test.dart`
- Modify: `test/article_list_page_test.dart`
- Modify: `test/collection_controller_test.dart`
- Modify: `test/collection_page_test.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

**Interfaces:**
- Produces: `const wanAndroidPageSize = 10`
- Produces: `ArticlePage.fromJson(Map<String, dynamic>)`
- Produces: `bool ArticlePage.hasMore`
- Produces: `Future<ArticlePage> ArticleRepository.fetchArticles({required int page, int pageSize = wanAndroidPageSize})`
- Produces: `Future<ArticlePage> CollectionRepository.fetchCollections({required int page, int pageSize = wanAndroidPageSize})`

- [ ] **Step 1: 写分页模型失败测试**

```dart
test('分页模型解析文章并判断还有下一页', () {
  final page = ArticlePage.fromJson({
    'curPage': 1,
    'pageCount': 3,
    'over': false,
    'datas': [
      {'id': 7, 'title': '分页文章', 'link': 'https://example.com/7'},
    ],
  });

  expect(page.datas.single.id, 7);
  expect(page.hasMore, isTrue);
});

test('over 为 true 时分页结束', () {
  final page = ArticlePage.fromJson({
    'curPage': 3,
    'pageCount': 3,
    'over': true,
    'datas': <Object?>[],
  });

  expect(page.hasMore, isFalse);
});
```

- [ ] **Step 2: 写服务分页参数失败测试**

```dart
final result = await ArticleService(dio: dio).fetchArticles(page: 2);
expect(request.uri.path, '/article/list/2/json');
expect(request.uri.queryParameters['page_size'], '10');
expect(result.datas.single.id, 7);

final collections = await CollectionService(dio: dio).fetchCollections(page: 3);
expect(request.uri.path, '/lg/collect/list/3/json');
expect(request.uri.queryParameters['page_size'], '10');
expect(collections.datas.single.collected, isTrue);
```

- [ ] **Step 3: 运行测试并确认因分页类型和新签名不存在而失败**

Run: `flutter test test/article_page_test.dart test/article_service_test.dart test/collection_service_test.dart`

Expected: FAIL，错误包含 `ArticlePage` 未定义或 `page` 命名参数不存在。

- [ ] **Step 4: 增加依赖并实现分页模型**

在 `pubspec.yaml` 增加：

```yaml
dependencies:
  infinite_scroll_pagination: ^5.1.1
```

实现模型：

```dart
const wanAndroidPageSize = 10;

@freezed
abstract class ArticlePage with _$ArticlePage {
  const ArticlePage._();

  const factory ArticlePage({
    @Default(<Article>[]) List<Article> datas,
    @Default(0) int curPage,
    @Default(0) int pageCount,
    @Default(true) bool over,
  }) = _ArticlePage;

  factory ArticlePage.fromJson(Map<String, dynamic> json) =>
      _$ArticlePageFromJson(json);

  bool get hasMore => !over && (pageCount == 0 || curPage < pageCount);
}
```

- [ ] **Step 5: 修改两个 Repository 和 Dio 实现**

```dart
Future<ArticlePage> fetchArticles({
  required int page,
  int pageSize = wanAndroidPageSize,
});

final response = await _dio.get<Map<String, dynamic>>(
  '/article/list/$page/json',
  queryParameters: {'page_size': pageSize},
);
return ArticlePage.fromJson(data);
```

收藏服务用相同分页参数解析 `ArticlePage`，再用 `copyWith` 把本页 `datas` 的 `collected` 设为 `true`。

- [ ] **Step 6: 更新所有测试替身以满足新 Repository 接口**

```dart
@override
Future<ArticlePage> fetchArticles({required int page, int pageSize = 10}) {
  return Future.value(
    ArticlePage(datas: articles, curPage: page + 1, pageCount: 1, over: true),
  );
}

@override
Future<ArticlePage> fetchCollections({required int page, int pageSize = 10}) {
  return Future.value(
    ArticlePage(datas: collections, curPage: page + 1, pageCount: 1, over: true),
  );
}
```

- [ ] **Step 7: 获取依赖、生成代码并运行回归测试**

Run: `flutter pub get`

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format lib/models/article_page.dart lib/services test`

Run: `flutter test test/article_page_test.dart test/article_service_test.dart test/collection_service_test.dart`

Run: `flutter test`

Expected: PASS。

- [ ] **Step 8: 提交分页模型与接口**

```bash
git add pubspec.yaml pubspec.lock lib/models lib/services test
git commit -m "功能：增加统一分页数据模型"
```

---

### Task 2: 文章列表下拉刷新与上拉分页

**Files:**
- Create: `lib/features/articles/article_list_state.dart`
- Generate: `lib/features/articles/article_list_state.freezed.dart`
- Create: `lib/features/shared/paging_views.dart`
- Create: `test/article_list_controller_test.dart`
- Modify: `lib/features/articles/article_list_controller.dart`
- Modify: `lib/features/articles/article_list_page.dart`
- Modify: `test/article_list_page_test.dart`

**Interfaces:**
- Consumes: `ArticleRepository.fetchArticles(page:, pageSize:)`
- Produces: `ArticleListState.pages`, `articles`, `nextPage`, `hasMore`, `isLoading`, `error`
- Produces: `Future<void> ArticleListController.loadNextPage()`
- Produces: `Future<String?> ArticleListController.refresh()`
- Produces: `PagingState<int, Article> ArticleListState.toPagingState()`

- [ ] **Step 1: 写文章分页控制器失败测试**

```dart
test('首次读取第零页并按顺序追加下一页', () async {
  final repository = _PagedArticleRepository({
    0: _page([first], over: false, curPage: 1, pageCount: 2),
    1: _page([second], over: true, curPage: 2, pageCount: 2),
  });
  final container = ProviderContainer(
    overrides: [articleRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  container.listen(articleListControllerProvider, (_, _) {});

  await _waitForArticleRequest(container);
  await container.read(articleListControllerProvider.notifier).loadNextPage();

  expect(repository.requestedPages, [0, 1]);
  expect(container.read(articleListControllerProvider).articles, [first, second]);
});

test('下一页失败时保留文章并重试同一页', () async {
  // 第一次 page=1 抛错，第二次 page=1 成功。
  expect(state.articles, [first]);
  expect(state.error, isNotNull);
  expect(repository.requestedPages, [0, 1, 1]);
});

test('下拉刷新会丢弃稍后返回的旧分页结果', () async {
  // page=1 使用 Completer；刷新 page=0 完成后再完成旧 page=1。
  expect(state.articles, [refreshed]);
});
```

再分别覆盖跨页相同 `Article.id` 去重，以及 `hasMore=false` 时不再请求。

- [ ] **Step 2: 运行控制器测试并确认因状态和分页方法不存在而失败**

Run: `flutter test test/article_list_controller_test.dart`

Expected: FAIL，错误包含 `ArticleListState` 或 `loadNextPage` 不存在。

- [ ] **Step 3: 实现 Freezed 文章分页状态**

```dart
@freezed
abstract class ArticleListState with _$ArticleListState {
  const ArticleListState._();

  const factory ArticleListState({
    @Default(<List<Article>>[]) List<List<Article>> pages,
    @Default(0) int nextPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    Object? error,
  }) = _ArticleListState;

  List<Article> get articles => pages.expand((page) => page).toList(growable: false);
}
```

`toPagingState()` 使用页下标作为 `keys`，把 `pages`、`hasMore`、`isLoading` 和 `error` 交给 `PagingState<int, Article>`。

- [ ] **Step 4: 实现文章分页控制器**

```dart
class ArticleListController extends Notifier<ArticleListState> {
  int _requestGeneration = 0;

  @override
  ArticleListState build() {
    Future<void>.microtask(_loadFirstPage).ignore();
    return const ArticleListState(isLoading: true);
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    await _load(page: state.nextPage, replace: false);
  }

  Future<String?> refresh() async {
    final generation = ++_requestGeneration;
    return _replaceFirstPage(generation);
  }
}
```

`_load` 在请求前设置 `isLoading=true` 并清除旧错误；成功后按 `Article.id` 过滤已存在文章并追加一页；失败时保留 `pages` 和 `nextPage`，只保存错误；完成时只有请求世代仍有效才写状态。

- [ ] **Step 5: 运行生成器和控制器测试直到通过**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format lib/features/articles test/article_list_controller_test.dart`

Run: `flutter test test/article_list_controller_test.dart`

Expected: PASS。

- [ ] **Step 6: 写文章页面分页失败测试**

```dart
testWidgets('滚动到底部后请求下一页并展示新文章', (tester) async {
  await tester.pumpWidget(_testApp(repository));
  await tester.pumpAndSettle();
  await tester.fling(find.byType(PagedListView<int, Article>), const Offset(0, -1200), 2000);
  await tester.pumpAndSettle();

  expect(repository.requestedPages, containsAllInOrder([0, 1]));
  expect(find.text('第二页文章'), findsOneWidget);
});

testWidgets('下一页失败时显示底部重试并保留第一页', (tester) async {
  expect(find.text('第一页文章'), findsOneWidget);
  expect(find.text('加载失败，点击重试'), findsOneWidget);
});
```

保留并改写已有下拉刷新测试，断言刷新重新请求第 0 页并替换所有旧页。

- [ ] **Step 7: 运行页面测试并确认原 ListView 实现不能满足分页断言**

Run: `flutter test test/article_list_page_test.dart`

Expected: FAIL，找不到 `PagedListView`、第二页文章或底部分页状态。

- [ ] **Step 8: 用分页组件重写文章列表 UI**

```dart
RefreshIndicator(
  onRefresh: () => _refresh(context, ref),
  child: PagedListView<int, Article>(
    state: state.toPagingState(),
    fetchNextPage: controller.loadNextPage,
    builderDelegate: PagedChildBuilderDelegate<Article>(
      itemBuilder: (context, article, index) => ArticleCard(
        article: article,
        collected: collectionController.isCollected(article),
        busy: collectionController.isBusy(article),
        onCollect: () => _toggleCollection(context, ref, article),
        onTap: () => _openArticle(context, article),
      ),
      newPageProgressIndicatorBuilder: (_) => const PagingProgressView(),
      newPageErrorIndicatorBuilder: (_) => PagingRetryView(
        onRetry: controller.loadNextPage,
      ),
      noMoreItemsIndicatorBuilder: (_) => const PagingEndView(),
    ),
  ),
)
```

共享视图固定使用“重试”“加载失败，点击重试”“已经到底了”等中文文案，并给关键控件设置稳定 Key。

- [ ] **Step 9: 运行文章相关测试和静态检查**

Run: `dart format lib/features/articles lib/features/shared test/article_list_page_test.dart`

Run: `flutter test test/article_list_controller_test.dart test/article_list_page_test.dart`

Run: `flutter analyze`

Expected: 全部通过，无警告。

- [ ] **Step 10: 提交文章分页**

```bash
git add lib/features/articles lib/features/shared test/article_list_controller_test.dart test/article_list_page_test.dart
git commit -m "功能：文章列表支持下拉刷新和分页"
```

---

### Task 3: 收藏列表下拉刷新与上拉分页

**Files:**
- Modify: `lib/features/collections/collection_state.dart`
- Generate: `lib/features/collections/collection_state.freezed.dart`
- Modify: `lib/features/collections/collection_controller.dart`
- Modify: `lib/features/collections/collection_page.dart`
- Modify: `test/collection_controller_test.dart`
- Modify: `test/collection_page_test.dart`
- Modify: `test/app_flow_test.dart`
- Modify: `test/app_router_test.dart`

**Interfaces:**
- Consumes: `CollectionRepository.fetchCollections(page:, pageSize:)`
- Produces: `CollectionState.pages`, `articles`, `nextPage`, `hasMore`, `isLoading`, `error`
- Produces: `Future<void> CollectionController.loadNextPage()`
- Preserves: `toggle`, `refresh`, `refreshIfNeeded`, `isCollected`, `isBusy`

- [ ] **Step 1: 写收藏控制器分页失败测试**

```dart
test('收藏列表追加下一页并用原文章编号去重', () async {
  final repository = _FakeCollectionRepository(pages: {
    0: _page([record42], over: false, curPage: 1, pageCount: 2),
    1: _page([duplicate42, record88], over: true, curPage: 2, pageCount: 2),
  });
  final container = await _createContainer(repository);
  addTearDown(container.dispose);
  await _waitForCollections(container);

  await container.read(collectionControllerProvider.notifier).loadNextPage();

  expect(repository.requestedPages, [0, 1]);
  expect(container.read(collectionControllerProvider).articles, [record42, record88]);
});

test('刷新后旧的加载更多响应不能写回收藏列表', () async {
  // 延迟 page=1，完成刷新 page=0 后再返回旧响应。
  expect(state.articles, [refreshedRecord]);
});
```

增加下一页失败同页重试、`hasMore=false` 停止请求、账号切换作废旧页、加载下一页期间完成取消收藏不会被覆盖等测试。

- [ ] **Step 2: 运行收藏控制器测试并确认分页能力缺失**

Run: `flutter test test/collection_controller_test.dart`

Expected: FAIL，错误包含 `loadNextPage` 不存在或没有请求第 1 页。

- [ ] **Step 3: 扩展收藏 Freezed 状态**

```dart
const factory CollectionState({
  String? identity,
  @Default(<List<Article>>[]) List<List<Article>> pages,
  @Default(0) int nextPage,
  @Default(true) bool hasMore,
  @Default(<String, bool>{}) Map<String, bool> confirmed,
  @Default(<String>{}) Set<String> busyKeys,
  @Default(false) bool isLoading,
  @Default(false) bool isRefreshing,
  Object? error,
}) = _CollectionState;

List<Article> get articles => pages.expand((page) => page).toList(growable: false);
```

- [ ] **Step 4: 将收藏读取改为分页请求**

```dart
Future<void> loadNextPage() async {
  final identity = state.identity;
  if (identity == null || state.isLoading || !state.hasMore) return;
  await _loadPage(identity, page: state.nextPage, replace: false);
}

Future<String?> refresh() async {
  final identity = state.identity;
  if (identity == null) return '请先登录';
  final requestGeneration = ++_requestGeneration;
  return _replaceFirstPage(identity, requestGeneration);
}
```

替换第一页时清空可见页组并把 `nextPage` 设为 1；追加页按收藏键去重。追加页只为返回记录写入 `confirmed=true`。第一页明确 `hasMore=false` 时才能把完整响应中不存在的旧服务端确认状态清理为 false。所有写状态操作继续核对 identity、identityEpoch、requestGeneration 和 mutationVersionAtStart。

- [ ] **Step 5: 让取消收藏从所有已加载页移除记录**

```dart
final pages = state.pages
    .map(
      (page) => page
          .where((item) => _key(item, fromCollection: true) != key)
          .toList(growable: false),
    )
    .toList(growable: false);
state = state.copyWith(pages: pages, confirmed: confirmed);
```

保留移除文章后产生的空页，UI 的 `keys` 仍按当前页组下标生成；远端 `nextPage` 由独立字段保存，因此不会重复请求已经加载的页。

- [ ] **Step 6: 生成代码并让收藏控制器测试通过**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format lib/features/collections test/collection_controller_test.dart`

Run: `flutter test test/collection_controller_test.dart`

Expected: 新分页测试和原有账号/收藏并发测试全部 PASS。

- [ ] **Step 7: 写收藏页面触底与底部状态失败测试**

```dart
testWidgets('收藏列表滚动到底部后加载十条一页的下一页', (tester) async {
  final repository = _FakeCollectionRepository(pages: {
    0: _page(firstTen, over: false, curPage: 1, pageCount: 2),
    1: _page(secondTen, over: true, curPage: 2, pageCount: 2),
  });
  await tester.pumpWidget(
    _testApp(
      authRepository: _FakeAuthRepository(
        restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
      ),
      collectionRepository: repository,
    ),
  );
  await tester.pumpAndSettle();
  await tester.fling(find.byType(PagedListView<int, Article>), const Offset(0, -1400), 2200);
  await tester.pumpAndSettle();

  expect(repository.requestedPages, containsAllInOrder([0, 1]));
  expect(repository.requestedPageSizes, everyElement(10));
});
```

增加下一页失败显示“加载失败，点击重试”、无更多数据显示“已经到底了”、下拉刷新回到第 0 页的断言。

- [ ] **Step 8: 使用 PagedListView 重写收藏列表并复用分页状态视图**

把现有 `ListView.builder` 替换为 `PagedListView<int, Article>`，外层保留 `RefreshIndicator`。`itemBuilder` 继续使用 `ArticleCard`，保留取消收藏、详情跳转和登录状态处理。

- [ ] **Step 9: 运行收藏页面测试与完整回归**

Run: `dart format lib/features/collections test`

Run: `flutter test test/collection_controller_test.dart test/collection_page_test.dart`

Run: `flutter test`

Run: `flutter analyze`

Expected: 全部通过，无警告。

- [ ] **Step 10: 提交收藏分页**

```bash
git add lib/features/collections test
git commit -m "功能：收藏列表支持下拉刷新和分页"
```

---

### Task 4: 学习文档与发布前验证

**Files:**
- Create: `docs/pagination-loading.md`

**Interfaces:**
- Consumes: 最终代码中的真实类名、状态字段和请求流程。
- Produces: 面试时可直接口述的技术说明、数据流和常见追问答案。

- [ ] **Step 1: 编写分页学习文档**

文档必须解释：

```text
下拉刷新为什么使用 RefreshIndicator；
上拉加载为什么使用 infinite_scroll_pagination；
PagedListView、PagingState、PagedChildBuilderDelegate 分别负责什么；
Riverpod 与分页组件如何分工；
为什么接口页码从 0 开始且 page_size 固定为 10；
如何防止重复请求、重复数据、旧请求覆盖刷新结果和跨账号串数据；
加载更多失败与首次加载失败为什么采用不同 UI。
```

- [ ] **Step 2: 运行生成代码一致性和格式检查**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format --set-exit-if-changed lib test`

Expected: 生成文件无冲突，格式检查退出码为 0。

- [ ] **Step 3: 运行完整自动化验证**

Run: `flutter test`

Run: `flutter analyze`

Run: `flutter build ios --simulator --no-codesign`

Expected: 全部测试通过；静态检查无问题；生成 `build/ios/iphonesimulator/Runner.app`。

- [ ] **Step 4: 提交学习文档**

```bash
git add docs/pagination-loading.md
git commit -m "文档：补充分页加载知识点"
```

- [ ] **Step 5: 检查提交和工作区**

Run: `git log -6 --oneline`

Run: `git status --short`

Expected: 新增提交信息全部为中文，工作区没有未提交文件。
