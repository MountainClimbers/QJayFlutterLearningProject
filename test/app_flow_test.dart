import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_controller.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_page.dart';
import 'package:qjay_flutter_learning/features/auth/auth_controller.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/models/login_user.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';
import 'package:qjay_flutter_learning/services/auth_service.dart';

void main() {
  testWidgets('文章详情导航与全局登录状态组成完整流程', (tester) async {
    const article = Article(
      id: 1,
      title: 'Flutter 五天复习',
      link: 'https://example.com/flutter',
      author: 'MountainClimbers',
    );
    final authRepository = _FlowAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          articleRepositoryProvider.overrideWithValue(
            _FlowArticleRepository(article),
          ),
          authRepositoryProvider.overrideWith((ref) async => authRepository),
        ],
        child: MaterialApp(
          home: ArticleListPage(
            articleDetailPageBuilder: (selectedArticle) => Scaffold(
              appBar: AppBar(title: const Text('流程详情页')),
              body: Text(selectedArticle.title),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('已登录：山友'), findsOneWidget);
    await tester.tap(find.text('Flutter 五天复习'));
    await tester.pumpAndSettle();
    expect(find.text('流程详情页'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Flutter 五天复习'), findsOneWidget);
    expect(find.byTooltip('已登录：山友'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('account-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('logout-button')));
    await tester.pumpAndSettle();

    expect(authRepository.logoutCallCount, 1);
    expect(find.byTooltip('登录'), findsOneWidget);
    expect(find.text('Flutter 五天复习'), findsOneWidget);
  });
}

class _FlowArticleRepository implements ArticleRepository {
  const _FlowArticleRepository(this.article);

  final Article article;

  @override
  Future<List<Article>> fetchArticles() async => [article];
}

class _FlowAuthRepository implements AuthRepository {
  int logoutCallCount = 0;

  @override
  Future<LoginUser> login({
    required String username,
    required String password,
  }) async {
    return LoginUser(username: username);
  }

  @override
  Future<void> logout() async {
    logoutCallCount += 1;
  }

  @override
  Future<LoginUser?> restoreSession() async {
    return const LoginUser(id: 7, username: 'MountainClimbers', nickname: '山友');
  }

  @override
  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  }) async {
    return LoginUser(username: username);
  }
}
