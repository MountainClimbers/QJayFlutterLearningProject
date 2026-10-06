import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
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
      return const CollectionState();
    }

    final identity = _identityOf(user);
    _resetForAuthenticationChange();
    Future<void>.microtask(() => _load(identity)).ignore();
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
      final articles = nextCollected
          ? state.articles
          : state.articles
                .where((item) => _key(item, fromCollection: true) != key)
                .toList(growable: false);
      final mutationVersion = ++_mutationVersion;
      _mutationVersions[key] = mutationVersion;
      state = state.copyWith(articles: articles, confirmed: confirmed);
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

  Future<String?> refresh() async {
    final identity = state.identity;
    if (identity == null) return '请先登录';
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      await _load(identity, showLoading: false);
      return null;
    } catch (error) {
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

  Future<void> _load(String identity, {bool showLoading = true}) async {
    if (state.identity != identity) return;
    final requestGeneration = ++_requestGeneration;
    final mutationVersionAtStart = _mutationVersion;
    if (showLoading && !state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final records = await ref
          .read(collectionRepositoryProvider)
          .fetchCollections(page: 0)
          .then((page) => page.datas);
      if (!_isCurrentRequest(identity, requestGeneration)) return;
      final serverKeys = <String>{
        for (final record in records) _key(record, fromCollection: true),
      };
      final confirmed = <String, bool>{
        for (final key in {...state.confirmed.keys, ...serverKeys})
          key: serverKeys.contains(key),
        for (final entry in state.confirmed.entries)
          if ((_mutationVersions[entry.key] ?? 0) > mutationVersionAtStart)
            entry.key: entry.value,
      };
      final visibleRecords = records
          .where(
            (record) => confirmed[_key(record, fromCollection: true)] != false,
          )
          .toList(growable: false);
      state = state.copyWith(
        articles: visibleRecords,
        confirmed: confirmed,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
      );
      _mutationVersions.removeWhere(
        (key, version) => version <= mutationVersionAtStart,
      );
      _needsServerRecordRefresh =
          _latestCollectionMutationVersion > mutationVersionAtStart;
    } on CollectionAuthenticationException {
      if (!_isCurrentRequest(identity, requestGeneration)) return;
      await _expireSession(identity, _identityEpoch);
      rethrow;
    } catch (error) {
      if (_isCurrentRequest(identity, requestGeneration)) {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: error.toString(),
        );
        rethrow;
      }
    }
  }

  bool _isCurrentRequest(String identity, int requestGeneration) {
    return state.identity == identity &&
        requestGeneration == _requestGeneration;
  }

  bool _isCurrentIdentity(String identity, int identityEpoch) {
    return state.identity == identity && identityEpoch == _identityEpoch;
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
