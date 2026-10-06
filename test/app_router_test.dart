import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_controller.dart';
import 'package:qjay_flutter_learning/features/auth/auth_controller.dart';
import 'package:qjay_flutter_learning/features/collections/collection_controller.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/models/login_user.dart';
import 'package:qjay_flutter_learning/router/app_router.dart';
import 'package:qjay_flutter_learning/router/route_names.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';
import 'package:qjay_flutter_learning/services/auth_service.dart';
import 'package:qjay_flutter_learning/services/collection_service.dart';

void main() {
  const article = Article(id: 7, title: '路由管理面试题', link: '不是网页地址');

  testWidgets('命名路由把文章对象传给详情页', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router, article));
    await tester.pumpAndSettle();

    await tester.tap(find.text('路由管理面试题'));
    await tester.pumpAndSettle();

    expect(router.state.path, articleDetailRoutePath);
    expect(find.text('路由管理面试题'), findsOneWidget);
    expect(find.text('文章链接无效，无法打开'), findsOneWidget);
  });

  testWidgets('首页侧边栏只有登录注册和我的收藏两个入口', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router, article));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('登录/注册'), findsOneWidget);
    expect(find.text('我的收藏'), findsOneWidget);

    await tester.tap(find.text('登录/注册'));
    await tester.pumpAndSettle();
    expect(router.state.path, accountRoutePath);
    expect(find.text('登录 WanAndroid'), findsOneWidget);
  });

  testWidgets('侧边栏可以通过命名路由进入我的收藏', (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router, article));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的收藏'));
    await tester.pumpAndSettle();

    expect(router.state.path, collectionsRoutePath);
    expect(find.text('登录后查看和同步收藏'), findsOneWidget);
  });

  testWidgets('详情路由缺少文章参数时显示可理解的错误页', (tester) async {
    final router = createAppRouter(initialLocation: articleDetailRoutePath);
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router, article));
    await tester.pumpAndSettle();

    expect(find.text('页面参数错误'), findsOneWidget);
    expect(find.text('没有找到要打开的文章'), findsOneWidget);
  });
}

Widget _testApp(GoRouter router, Article article) {
  return ProviderScope(
    overrides: [
      articleRepositoryProvider.overrideWithValue(_ArticleRepository(article)),
      authRepositoryProvider.overrideWith((ref) async => _AuthRepository()),
      collectionRepositoryProvider.overrideWithValue(_CollectionRepository()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _ArticleRepository implements ArticleRepository {
  const _ArticleRepository(this.article);

  final Article article;

  @override
  Future<List<Article>> fetchArticles() async => [article];
}

class _AuthRepository implements AuthRepository {
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
  Future<LoginUser?> restoreSession() async => null;
}

class _CollectionRepository implements CollectionRepository {
  @override
  Future<void> collect(int articleId) async {}

  @override
  Future<List<Article>> fetchCollections() async => const [];

  @override
  Future<void> removeCollection({
    required int recordId,
    required int originId,
  }) async {}

  @override
  Future<void> uncollect(int articleId) async {}
}
