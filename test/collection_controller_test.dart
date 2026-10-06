import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/auth/auth_controller.dart';
import 'package:qjay_flutter_learning/features/collections/collection_controller.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/models/login_user.dart';
import 'package:qjay_flutter_learning/services/auth_service.dart';
import 'package:qjay_flutter_learning/services/collection_service.dart';

void main() {
  const regularArticle = Article(
    id: 42,
    title: '普通文章',
    link: 'https://example.com/42',
  );
  const collectionRecord = Article(
    id: 901,
    originId: 42,
    title: '收藏文章',
    link: 'https://example.com/42',
    collected: true,
  );
  const newAccountRecord = Article(
    id: 902,
    originId: 88,
    title: '新账号收藏',
    link: 'https://example.com/88',
    collected: true,
  );

  test('登录后加载收藏记录并同步普通文章图标', () async {
    final repository = _FakeCollectionRepository(
      collections: [collectionRecord],
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await _waitForCollections(container);

    final controller = container.read(collectionControllerProvider.notifier);
    expect(controller.isCollected(regularArticle), isTrue);
    expect(container.read(collectionControllerProvider).articles, [
      collectionRecord,
    ]);
  });

  test('收藏失败时保持原状态并解除按钮忙碌', () async {
    final repository = _FakeCollectionRepository(
      collectError: const CollectionException('收藏失败'),
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    await expectLater(
      controller.toggle(regularArticle),
      throwsA(isA<CollectionException>()),
    );

    expect(controller.isCollected(regularArticle), isFalse);
    expect(controller.isBusy(regularArticle), isFalse);
  });

  test('同一篇文章请求进行中重复点击只发送一次收藏', () async {
    final completer = Completer<void>();
    final repository = _FakeCollectionRepository(
      collectHandler: (_) => completer.future,
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    final first = controller.toggle(regularArticle);
    final second = controller.toggle(regularArticle);
    await Future<void>.delayed(Duration.zero);

    expect(repository.collectCallCount, 1);
    expect(controller.isBusy(regularArticle), isTrue);

    completer.complete();
    await Future.wait([first, second]);
    expect(controller.isCollected(regularArticle), isTrue);
  });

  test('首页新增收藏后进入收藏页会按需重新获取收藏记录', () async {
    final repository = _FakeCollectionRepository();
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    await controller.toggle(regularArticle);
    repository.collections = [collectionRecord];
    await controller.refreshIfNeeded();

    expect(repository.fetchCallCount, 2);
    expect(container.read(collectionControllerProvider).articles, [
      collectionRecord,
    ]);
  });

  test('服务器刷新可以同时清除旧收藏并补充新收藏', () async {
    final repository = _FakeCollectionRepository(
      collections: [collectionRecord],
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    repository.collections = const [];
    await controller.refresh();
    expect(controller.isCollected(regularArticle), isFalse);

    repository.collections = [collectionRecord];
    await controller.refresh();
    expect(controller.isCollected(regularArticle), isTrue);
  });

  test('刷新请求期间完成的收藏操作不会被旧响应覆盖', () async {
    final refreshCompleter = Completer<List<Article>>();
    final repository = _FakeCollectionRepository(
      fetchHandler: (callCount) =>
          callCount == 1 ? Future.value(const []) : refreshCompleter.future,
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    final refresh = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    await controller.toggle(regularArticle);
    refreshCompleter.complete(const []);
    await refresh;

    expect(controller.isCollected(regularArticle), isTrue);
  });

  test('同一账号并发刷新时只有最后发起的请求可以更新状态', () async {
    final olderRequest = Completer<List<Article>>();
    final latestRequest = Completer<List<Article>>();
    final repository = _FakeCollectionRepository(
      fetchHandler: (callCount) => switch (callCount) {
        1 => Future.value(const []),
        2 => olderRequest.future,
        _ => latestRequest.future,
      },
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    final olderRefresh = controller.refresh();
    final latestRefresh = controller.refresh();
    latestRequest.complete(const []);
    await latestRefresh;
    olderRequest.complete([collectionRecord]);
    await olderRefresh;

    expect(container.read(collectionControllerProvider).articles, isEmpty);
    expect(controller.isCollected(regularArticle), isFalse);
  });

  test('账号切换后旧账号的异步响应不能覆盖新账号状态', () async {
    final oldAccountRequest = Completer<List<Article>>();
    final repository = _FakeCollectionRepository(
      fetchHandler: (callCount) => switch (callCount) {
        1 => Future.value(const []),
        2 => oldAccountRequest.future,
        _ => Future.value([newAccountRecord]),
      },
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);

    final oldRefresh = container
        .read(collectionControllerProvider.notifier)
        .refresh();
    await container
        .read(authControllerProvider.notifier)
        .login(username: 'new-user', password: '123456');
    await _waitForCollections(container);

    oldAccountRequest.complete([collectionRecord]);
    await oldRefresh;

    final state = container.read(collectionControllerProvider);
    expect(state.identity, '0:new-user');
    expect(state.articles, [newAccountRecord]);
  });

  test('收藏接口判定会话过期时清理本地登录状态', () async {
    final authRepository = _FakeAuthRepository();
    final repository = _FakeCollectionRepository(
      collectError: const CollectionAuthenticationException('请先登录'),
    );
    final container = await _createContainer(
      repository,
      authRepository: authRepository,
    );
    addTearDown(container.dispose);
    await _waitForCollections(container);

    await expectLater(
      container
          .read(collectionControllerProvider.notifier)
          .toggle(regularArticle),
      throwsA(isA<CollectionAuthenticationException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(authRepository.clearSessionCallCount, 1);
    expect(container.read(authControllerProvider).value, isNull);
    expect(container.read(collectionControllerProvider).identity, isNull);
  });

  test('收藏列表加载判定会话过期时清理本地登录状态', () async {
    final authRepository = _FakeAuthRepository();
    final repository = _FakeCollectionRepository(
      fetchHandler: (_) =>
          Future.error(const CollectionAuthenticationException('请先登录')),
    );
    final container = await _createContainer(
      repository,
      authRepository: authRepository,
    );
    addTearDown(container.dispose);

    for (var index = 0; index < 20; index++) {
      if (container.read(authControllerProvider).value == null) break;
      await Future<void>.delayed(Duration.zero);
    }

    expect(authRepository.clearSessionCallCount, 1);
    expect(container.read(authControllerProvider).value, isNull);
    expect(container.read(collectionControllerProvider).identity, isNull);
  });

  test('收藏页取消使用记录编号和原文章编号并移除记录', () async {
    final repository = _FakeCollectionRepository(
      collections: [collectionRecord],
    );
    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    await _waitForCollections(container);
    final controller = container.read(collectionControllerProvider.notifier);

    await controller.toggle(collectionRecord, fromCollection: true);

    expect(repository.lastRemovedRecordId, 901);
    expect(repository.lastRemovedOriginId, 42);
    expect(container.read(collectionControllerProvider).articles, isEmpty);
    expect(controller.isCollected(regularArticle), isFalse);
  });
}

Future<ProviderContainer> _createContainer(
  CollectionRepository collectionRepository, {
  _FakeAuthRepository? authRepository,
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWith(
        (ref) async => authRepository ?? _FakeAuthRepository(),
      ),
      collectionRepositoryProvider.overrideWithValue(collectionRepository),
    ],
  );
  container.listen(authControllerProvider, (_, _) {});
  await container.read(authControllerProvider.future);
  container.listen(collectionControllerProvider, (_, _) {});
  return container;
}

Future<void> _waitForCollections(ProviderContainer container) async {
  for (var index = 0; index < 20; index++) {
    if (!container.read(collectionControllerProvider).isLoading) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('收藏列表未在预期时间内完成加载');
}

class _FakeCollectionRepository implements CollectionRepository {
  _FakeCollectionRepository({
    this.collections = const [],
    this.collectHandler,
    this.collectError,
    this.fetchHandler,
  });

  List<Article> collections;
  final Future<void> Function(int articleId)? collectHandler;
  final Object? collectError;
  final Future<List<Article>> Function(int callCount)? fetchHandler;
  int collectCallCount = 0;
  int fetchCallCount = 0;
  int? lastRemovedRecordId;
  int? lastRemovedOriginId;

  @override
  Future<void> collect(int articleId) async {
    collectCallCount += 1;
    if (collectHandler case final handler?) await handler(articleId);
    if (collectError case final Object error) throw error;
  }

  @override
  Future<List<Article>> fetchCollections() async {
    fetchCallCount += 1;
    if (fetchHandler case final handler?) return handler(fetchCallCount);
    return collections;
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
  int clearSessionCallCount = 0;

  @override
  Future<void> clearSession() async {
    clearSessionCallCount += 1;
  }

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
  Future<LoginUser?> restoreSession() async {
    return const LoginUser(id: 7, username: 'MountainClimbers');
  }
}
