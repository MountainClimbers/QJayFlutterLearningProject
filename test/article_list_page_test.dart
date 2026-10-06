import 'dart:async';

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
  const firstArticle = Article(
    id: 1,
    title: 'Flutter 面试准备',
    link: 'https://example.com/1',
    author: 'MountainClimbers',
    superChapterName: '移动开发',
    chapterName: 'Flutter',
    niceDate: '今天',
  );
  const refreshedArticle = Article(
    id: 2,
    title: 'Riverpod 实战',
    link: 'https://example.com/2',
    author: '小明',
  );

  testWidgets('Riverpod 加载成功后显示文章的主要信息', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(_testApp(repository));
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(find.text('MountainClimbers'), findsOneWidget);
    expect(find.text('移动开发 / Flutter'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
  });

  testWidgets('点击文章卡片后把完整文章对象传给详情页', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);
    Article? receivedArticle;

    await tester.pumpWidget(
      _testApp(
        repository,
        articleDetailPageBuilder: (article) {
          receivedArticle = article;
          return Scaffold(
            appBar: AppBar(title: const Text('测试详情页')),
            body: Text(article.link),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flutter 面试准备'));
    await tester.pumpAndSettle();

    expect(find.text('测试详情页'), findsOneWidget);
    expect(find.text('https://example.com/1'), findsOneWidget);
    expect(receivedArticle, same(firstArticle));
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('点击登录入口后进入登录页面', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(
      _testApp(
        repository,
        loginPageBuilder: () => Scaffold(
          appBar: AppBar(title: const Text('测试登录页')),
          body: const Text('登录表单'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('登录'));
    await tester.pumpAndSettle();

    expect(find.text('测试登录页'), findsOneWidget);
    expect(find.text('登录表单'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('恢复登录状态后在首页展示当前用户', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(
      _testApp(
        repository,
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(id: 7, nickname: '山友'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('已登录：山友'), findsOneWidget);
    expect(find.text('山友'), findsOneWidget);
    expect(find.byTooltip('登录'), findsNothing);
  });

  testWidgets('点击当前用户后展示账户面板', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(
      _testApp(
        repository,
        authRepository: _FakeAuthRepository(
          restoredUser: const LoginUser(
            id: 7,
            username: 'MountainClimbers',
            nickname: '山友',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('account-action')));
    await tester.pumpAndSettle();

    expect(find.text('账户信息'), findsOneWidget);
    expect(find.text('山友'), findsWidgets);
    expect(find.byKey(const ValueKey('account-username')), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('账户面板退出成功后首页恢复登录入口', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);
    final authRepository = _FakeAuthRepository(
      restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
    );
    await tester.pumpWidget(
      _testApp(repository, authRepository: authRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('account-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('logout-button')));
    await tester.pumpAndSettle();

    expect(authRepository.logoutCallCount, 1);
    expect(find.byTooltip('登录'), findsOneWidget);
    expect(find.text('已退出登录'), findsOneWidget);
    expect(find.text('账户信息'), findsNothing);
  });

  testWidgets('账户面板退出失败时重置登录状态并显示原因', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);
    final authRepository = _FakeAuthRepository(
      restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
      logoutError: const AuthException('测试退出失败'),
    );
    await tester.pumpWidget(
      _testApp(repository, authRepository: authRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('account-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('logout-button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('测试退出失败'), findsOneWidget);
    expect(find.text('账户信息'), findsNothing);
    expect(find.byTooltip('登录'), findsOneWidget);
  });

  testWidgets('退出请求期间不能关闭账户面板且完成后仍有反馈', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);
    final logoutCompleter = Completer<void>();
    final authRepository = _FakeAuthRepository(
      restoredUser: const LoginUser(id: 7, username: 'MountainClimbers'),
      logoutHandler: () => logoutCompleter.future,
    );
    await tester.pumpWidget(
      _testApp(repository, authRepository: authRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('account-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('logout-button')));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('账户信息'), findsOneWidget);
    expect(find.text('正在退出'), findsOneWidget);

    logoutCompleter.completeError(const AuthException('测试网络中断'));
    await tester.pumpAndSettle();

    expect(find.text('账户信息'), findsNothing);
    expect(find.textContaining('测试网络中断'), findsOneWidget);
    expect(find.byTooltip('登录'), findsOneWidget);
  });

  testWidgets('恢复登录状态期间暂时禁用登录入口', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);
    final restoreCompleter = Completer<LoginUser?>();

    await tester.pumpWidget(
      _testApp(
        repository,
        authRepository: _FakeAuthRepository(
          restoreHandler: () => restoreCompleter.future,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('auth-restore-progress')), findsOneWidget);
    expect(find.byTooltip('登录'), findsNothing);

    restoreCompleter.complete(null);
    await tester.pumpAndSettle();
    expect(find.byTooltip('登录'), findsOneWidget);
  });

  testWidgets('首页登录入口调用接口状态并展示成功用户', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);
    final authRepository = _FakeAuthRepository(
      loginResult: const LoginUser(id: 8, username: 'MountainClimbers'),
    );

    await tester.pumpWidget(
      _testApp(repository, authRepository: authRepository),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('登录'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('login-username-field')),
      'MountainClimbers',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password-field')),
      '123456',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit-button')));
    await tester.pumpAndSettle();

    expect(authRepository.lastUsername, 'MountainClimbers');
    expect(authRepository.lastPassword, '123456');
    expect(find.byTooltip('已登录：MountainClimbers'), findsOneWidget);
    expect(find.text('登录成功：MountainClimbers'), findsOneWidget);
  });

  testWidgets('Riverpod 错误状态点击重试后恢复文章列表', (tester) async {
    final repository = _SequenceRepository([
      () => Future.error(const ArticleLoadException('测试网络断开')),
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('测试网络断开'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(repository.callCount, 2);
  });

  testWidgets('下拉刷新通过 AsyncNotifier 重新获取文章', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
      () async => [refreshedArticle],
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text('Riverpod 实战'), findsOneWidget);
    expect(find.text('Flutter 面试准备'), findsNothing);
    expect(repository.callCount, 2);
  });

  testWidgets('下拉刷新失败时保留原列表并显示轻量提示', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
      () => Future.error(const ArticleLoadException('测试刷新失败')),
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(find.text('刷新失败：测试刷新失败'), findsOneWidget);
    expect(repository.callCount, 2);
  });
}

Widget _testApp(
  ArticleRepository repository, {
  Widget Function(Article article)? articleDetailPageBuilder,
  Widget Function()? loginPageBuilder,
  AuthRepository? authRepository,
}) {
  return ProviderScope(
    overrides: [
      articleRepositoryProvider.overrideWithValue(repository),
      authRepositoryProvider.overrideWith(
        (ref) async => authRepository ?? _FakeAuthRepository(),
      ),
    ],
    child: MaterialApp(
      home: ArticleListPage(
        articleDetailPageBuilder: articleDetailPageBuilder,
        loginPageBuilder: loginPageBuilder,
      ),
    ),
  );
}

class _SequenceRepository implements ArticleRepository {
  _SequenceRepository(this.responses);

  final List<Future<List<Article>> Function()> responses;
  int callCount = 0;

  @override
  Future<List<Article>> fetchArticles() {
    final index = callCount++;
    return responses[index]();
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.restoredUser,
    this.loginResult,
    this.restoreHandler,
    this.logoutHandler,
    this.logoutError,
  });

  final LoginUser? restoredUser;
  final LoginUser? loginResult;
  final Future<LoginUser?> Function()? restoreHandler;
  final Future<void> Function()? logoutHandler;
  final Object? logoutError;
  String? lastUsername;
  String? lastPassword;
  int logoutCallCount = 0;

  @override
  Future<LoginUser> login({
    required String username,
    required String password,
  }) async {
    lastUsername = username;
    lastPassword = password;
    return loginResult ?? LoginUser(username: username);
  }

  @override
  Future<LoginUser?> restoreSession() async {
    if (restoreHandler case final handler?) return handler();
    return restoredUser;
  }

  @override
  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  }) async {
    lastUsername = username;
    lastPassword = password;
    return loginResult ?? LoginUser(username: username);
  }

  @override
  Future<void> logout() async {
    logoutCallCount += 1;
    if (logoutHandler case final handler?) await handler();
    if (logoutError case final Object error) throw error;
  }
}
