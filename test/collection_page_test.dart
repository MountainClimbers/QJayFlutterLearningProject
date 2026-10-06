import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/auth/auth_controller.dart';
import 'package:qjay_flutter_learning/features/collections/collection_controller.dart';
import 'package:qjay_flutter_learning/features/collections/collection_page.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/models/article_page.dart';
import 'package:qjay_flutter_learning/models/login_user.dart';
import 'package:qjay_flutter_learning/services/auth_service.dart';
import 'package:qjay_flutter_learning/services/collection_service.dart';

void main() {
  const record = Article(
    id: 901,
    originId: 42,
    title: '我的 Flutter 收藏',
    link: 'https://example.com/42',
    collected: true,
  );

  testWidgets('未登录时提示登录并进入登录注册页面', (tester) async {
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(),
        collectionRepository: _FakeCollectionRepository(),
        loginPageBuilder: () => const Scaffold(body: Text('登录注册测试页')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录后查看和同步收藏'), findsOneWidget);
    await tester.tap(find.text('去登录'));
    await tester.pumpAndSettle();
    expect(find.text('登录注册测试页'), findsOneWidget);
  });

  testWidgets('登录后展示收藏并可以进入文章详情', (tester) async {
    Article? openedArticle;
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
        ),
        collectionRepository: _FakeCollectionRepository(collections: [record]),
        articleDetailPageBuilder: (article) {
          openedArticle = article;
          return Scaffold(body: Text('详情：${article.title}'));
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('我的 Flutter 收藏'), findsOneWidget);
    await tester.tap(find.text('我的 Flutter 收藏'));
    await tester.pumpAndSettle();
    expect(openedArticle, record);
    expect(find.text('详情：我的 Flutter 收藏'), findsOneWidget);
  });

  testWidgets('取消收藏成功后立即移除对应文章', (tester) async {
    final repository = _FakeCollectionRepository(collections: [record]);
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
        ),
        collectionRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('取消收藏'));
    await tester.pumpAndSettle();

    expect(repository.lastRemovedRecordId, 901);
    expect(repository.lastRemovedOriginId, 42);
    expect(find.text('我的 Flutter 收藏'), findsNothing);
    expect(find.text('还没有收藏文章'), findsOneWidget);
  });

  testWidgets('收藏列表加载失败时显示原因并可以重试', (tester) async {
    final repository = _FakeCollectionRepository(
      fetchError: const CollectionException('测试收藏网络失败'),
    );
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
        ),
        collectionRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('测试收藏网络失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('收藏列表判定会话过期时回到登录提示', (tester) async {
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
        ),
        collectionRepository: _FakeCollectionRepository(
          fetchError: const CollectionAuthenticationException('请先登录'),
        ),
        loginPageBuilder: () => const Scaffold(body: Text('登录注册测试页')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录后查看和同步收藏'), findsOneWidget);
    expect(find.text('去登录'), findsOneWidget);
    expect(find.text('请先登录'), findsNothing);
  });

  testWidgets('下拉刷新失败时保留原收藏并显示原因', (tester) async {
    final repository = _FakeCollectionRepository(
      collections: [record],
      refreshError: const CollectionException('测试刷新失败'),
    );
    await tester.pumpWidget(
      _testApp(
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
        ),
        collectionRepository: repository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text('我的 Flutter 收藏'), findsOneWidget);
    expect(find.text('测试刷新失败'), findsOneWidget);
  });
}

Widget _testApp({
  required AuthRepository authRepository,
  required CollectionRepository collectionRepository,
  Widget Function(Article article)? articleDetailPageBuilder,
  Widget Function()? loginPageBuilder,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWith((ref) async => authRepository),
      collectionRepositoryProvider.overrideWithValue(collectionRepository),
    ],
    child: MaterialApp(
      home: CollectionPage(
        articleDetailPageBuilder: articleDetailPageBuilder,
        loginPageBuilder: loginPageBuilder,
      ),
    ),
  );
}

class _FakeCollectionRepository implements CollectionRepository {
  _FakeCollectionRepository({
    this.collections = const [],
    this.fetchError,
    this.refreshError,
  });

  final List<Article> collections;
  final Object? fetchError;
  final Object? refreshError;
  int fetchCallCount = 0;
  int? lastRemovedRecordId;
  int? lastRemovedOriginId;

  @override
  Future<void> collect(int articleId) async {}

  @override
  Future<ArticlePage> fetchCollections({
    required int page,
    int pageSize = wanAndroidPageSize,
  }) async {
    fetchCallCount += 1;
    if (fetchError case final Object error) throw error;
    if (fetchCallCount > 1) {
      if (refreshError case final Object error) throw error;
    }
    return ArticlePage(datas: collections);
  }

  @override
  Future<void> removeCollection({
    required int recordId,
    required int originId,
  }) async {
    lastRemovedRecordId = recordId;
    lastRemovedOriginId = originId;
  }

  @override
  Future<void> uncollect(int articleId) async {}
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.restoredUser});

  final LoginUser? restoredUser;

  @override
  Future<void> clearSession() async {}

  @override
  Future<LoginUser> login({
    required String username,
    required String password,
  }) async => LoginUser(username: username);

  @override
  Future<void> logout() async {}

  @override
  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  }) async => LoginUser(username: username);

  @override
  Future<LoginUser?> restoreSession() async => restoredUser;
}
