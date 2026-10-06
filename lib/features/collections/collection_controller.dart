import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../models/article_page.dart';
import '../../models/login_user.dart';
import '../../services/collection_service.dart';
import '../../services/session_client.dart';
import '../auth/auth_controller.dart';
import 'collection_state.dart';

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionService(dio: ref.watch(sessionClientProvider).dio);
});

final collectionControllerProvider =
    NotifierProvider<CollectionController, CollectionState>(
      CollectionController.new,
    );

class CollectionController extends Notifier<CollectionState> {
  final Map<String, Completer<void>> _pendingOperations = {};
  final Map<String, int> _mutationVersions = {};
  bool _needsServerRecordRefresh = false;
  int _mutationVersion = 0;
  int _latestCollectionMutationVersion = 0;
  int _requestGeneration = 0;
  int _identityEpoch = 0;

  @override
  CollectionState build() {
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      _resetForAuthenticationChange();
      return const CollectionState(hasMore: false);
    }

    final identity = _identityOf(user);
    _resetForAuthenticationChange();
    final identityEpoch = _identityEpoch;
    final requestGeneration = _requestGeneration;
    Future<void>.microtask(
      () => _loadInitialPage(identity, identityEpoch, requestGeneration),
    ).ignore();
    return CollectionState(identity: identity, isLoading: true);
  }

  bool isCollected(Article article, {bool fromCollection = false}) {
    return state.confirmed[_key(article, fromCollection: fromCollection)] ??
        (fromCollection || article.collected);
  }

  bool isBusy(Article article, {bool fromCollection = false}) {
    return state.busyKeys.contains(
      _key(article, fromCollection: fromCollection),
    );
  }

  Future<void> toggle(Article article, {bool fromCollection = false}) async {
    final identity = state.identity;
    if (identity == null) throw const CollectionException('请先登录');
    final identityEpoch = _identityEpoch;

    final key = _key(article, fromCollection: fromCollection);
    final operationKey = '$identityEpoch|$identity|$key';
    if (_pendingOperations.containsKey(operationKey)) return;
    final operationCompletion = Completer<void>();
    _pendingOperations[operationKey] = operationCompletion;

    final wasCollected = isCollected(article, fromCollection: fromCollection);
    state = state.copyWith(busyKeys: {...state.busyKeys, key});
    try {
      final repository = ref.read(collectionRepositoryProvider);
      if (fromCollection) {
        await repository.removeCollection(
          recordId: article.id,
          originId: article.originId ?? -1,
        );
      } else if (wasCollected) {
        await repository.uncollect(article.id);
      } else {
        await repository.collect(article.id);
      }

      if (!_isCurrentIdentity(identity, identityEpoch)) return;
      final nextCollected = fromCollection ? false : !wasCollected;
      final confirmed = {...state.confirmed, key: nextCollected};
      final pages = nextCollected
          ? state.pages
          : state.pages
                .map(
                  (page) => page
                      .where((item) => _key(item, fromCollection: true) != key)
                      .toList(growable: false),
                )
                .toList(growable: false);
      final mutationVersion = ++_mutationVersion;
      _mutationVersions[key] = mutationVersion;
      state = state.copyWith(pages: pages, confirmed: confirmed);
      if (!fromCollection && !wasCollected) {
        _needsServerRecordRefresh = true;
        _latestCollectionMutationVersion = mutationVersion;
      }
    } on CollectionAuthenticationException {
      await _expireSession(identity, identityEpoch);
      rethrow;
    } finally {
      _pendingOperations.remove(operationKey);
      if (!operationCompletion.isCompleted) operationCompletion.complete();
      if (_isCurrentIdentity(identity, identityEpoch)) {
        state = state.copyWith(busyKeys: {...state.busyKeys}..remove(key));
      }
    }
  }

  Future<void> loadNextPage() async {
    final identity = state.identity;
    if (identity == null ||
        state.isLoading ||
        state.isRefreshing ||
        !state.hasMore) {
      return;
    }
    final identityEpoch = _identityEpoch;
    final requestGeneration = _requestGeneration;
    final mutationVersionAtStart = _mutationVersion;
    final page = state.nextPage;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ref
          .read(collectionRepositoryProvider)
          .fetchCollections(page: page);
      if (!_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        return;
      }
      _applyPage(
        result,
        requestedPage: page,
        replace: false,
        mutationVersionAtStart: mutationVersionAtStart,
      );
    } on CollectionAuthenticationException {
      if (_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        await _expireSession(identity, identityEpoch);
      }
    } catch (error) {
      if (_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        state = state.copyWith(isLoading: false, error: error);
      }
    }
  }

  Future<String?> refresh() async {
    final identity = state.identity;
    if (identity == null) return '请先登录';
    final identityEpoch = _identityEpoch;
    final requestGeneration = ++_requestGeneration;
    final mutationVersionAtStart = _mutationVersion;
    state = state.copyWith(
      isRefreshing: true,
      isLoading: state.pages.isEmpty,
      error: null,
    );
    try {
      final result = await ref
          .read(collectionRepositoryProvider)
          .fetchCollections(page: 0);
      if (!_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        return null;
      }
      _applyPage(
        result,
        requestedPage: 0,
        replace: true,
        mutationVersionAtStart: mutationVersionAtStart,
      );
      return null;
    } on CollectionAuthenticationException catch (error) {
      if (_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        await _expireSession(identity, identityEpoch);
      }
      return error.toString();
    } catch (error) {
      if (_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: state.pages.isEmpty ? error : null,
        );
      }
      return error.toString();
    }
  }

  Future<String?> refreshIfNeeded() async {
    final identity = state.identity;
    if (identity == null) return null;
    final identityEpoch = _identityEpoch;
    final operationPrefix = '$identityEpoch|$identity|';
    final pendingOperations = _pendingOperations.entries
        .where((entry) => entry.key.startsWith(operationPrefix))
        .map((entry) => entry.value.future)
        .toList(growable: false);
    if (pendingOperations.isNotEmpty) {
      await Future.wait(pendingOperations);
    }
    if (!_isCurrentIdentity(identity, identityEpoch)) return null;
    if (!_needsServerRecordRefresh) return null;
    return refresh();
  }

  Future<void> _loadInitialPage(
    String identity,
    int identityEpoch,
    int requestGeneration,
  ) async {
    if (!_isCurrentRequest(identity, identityEpoch, requestGeneration)) return;
    final mutationVersionAtStart = _mutationVersion;
    try {
      final result = await ref
          .read(collectionRepositoryProvider)
          .fetchCollections(page: 0);
      if (!_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        return;
      }
      _applyPage(
        result,
        requestedPage: 0,
        replace: true,
        mutationVersionAtStart: mutationVersionAtStart,
      );
    } on CollectionAuthenticationException {
      if (_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        await _expireSession(identity, identityEpoch);
      }
    } catch (error) {
      if (_isCurrentRequest(identity, identityEpoch, requestGeneration)) {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          error: error,
        );
      }
    }
  }

  void _applyPage(
    ArticlePage result, {
    required int requestedPage,
    required bool replace,
    required int mutationVersionAtStart,
  }) {
    final serverKeys = <String>{
      for (final record in result.datas) _key(record, fromCollection: true),
    };
    final confirmed = replace && !result.hasMore
        ? <String, bool>{
            for (final key in {...state.confirmed.keys, ...serverKeys})
              key: serverKeys.contains(key),
          }
        : <String, bool>{...state.confirmed};
    for (final key in serverKeys) {
      confirmed[key] = true;
    }
    for (final entry in state.confirmed.entries) {
      if ((_mutationVersions[entry.key] ?? 0) > mutationVersionAtStart) {
        confirmed[entry.key] = entry.value;
      }
    }

    final knownKeys = replace
        ? <String>{}
        : state.articles
              .map((record) => _key(record, fromCollection: true))
              .toSet();
    final visibleRecords = <Article>[];
    for (final record in result.datas) {
      final key = _key(record, fromCollection: true);
      if (confirmed[key] != false && knownKeys.add(key)) {
        visibleRecords.add(record);
      }
    }

    state = state.copyWith(
      pages: replace ? [visibleRecords] : [...state.pages, visibleRecords],
      nextPage: requestedPage + 1,
      hasMore: result.hasMore,
      confirmed: confirmed,
      isLoading: false,
      isRefreshing: false,
      error: null,
    );
    _mutationVersions.removeWhere(
      (key, version) => version <= mutationVersionAtStart,
    );
    if (replace) {
      _needsServerRecordRefresh =
          _latestCollectionMutationVersion > mutationVersionAtStart;
    }
  }

  bool _isCurrentRequest(
    String identity,
    int identityEpoch,
    int requestGeneration,
  ) {
    return ref.mounted &&
        state.identity == identity &&
        identityEpoch == _identityEpoch &&
        requestGeneration == _requestGeneration;
  }

  bool _isCurrentIdentity(String identity, int identityEpoch) {
    return ref.mounted &&
        state.identity == identity &&
        identityEpoch == _identityEpoch;
  }

  Future<void> _expireSession(String identity, int identityEpoch) async {
    if (!_isCurrentIdentity(identity, identityEpoch)) return;
    try {
      await ref.read(authControllerProvider.notifier).expireSession();
    } catch (_) {
      // AuthController 即使清理 Cookie 失败，也会把内存登录状态重置为未登录。
    }
  }

  void _resetForAuthenticationChange() {
    _identityEpoch += 1;
    _requestGeneration += 1;
    _mutationVersions.clear();
    _mutationVersion = 0;
    _latestCollectionMutationVersion = 0;
    _needsServerRecordRefresh = false;
  }
}

String _identityOf(LoginUser user) => '${user.id}:${user.username}';

String _key(Article article, {required bool fromCollection}) {
  if (fromCollection) {
    final originId = article.originId;
    return originId != null && originId >= 0
        ? 'article:$originId'
        : 'record:${article.id}';
  }
  return 'article:${article.id}';
}
