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
  CollectionRepository collectionRepository,
) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWith((ref) async => _FakeAuthRepository()),
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
  });

  List<Article> collections;
  final Future<void> Function(int articleId)? collectHandler;
  final Object? collectError;
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
