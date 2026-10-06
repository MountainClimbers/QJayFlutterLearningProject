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
  final Set<String> _pendingOperations = {};

  @override
  CollectionState build() {
    final user = switch (ref.watch(authControllerProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return const CollectionState();

    final identity = _identityOf(user);
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

    final key = _key(article, fromCollection: fromCollection);
    final operationKey = '$identity|$key';
    if (!_pendingOperations.add(operationKey)) return;

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

      if (state.identity != identity) return;
      final nextCollected = fromCollection ? false : !wasCollected;
      final confirmed = {...state.confirmed, key: nextCollected};
      final articles = nextCollected
          ? state.articles
          : state.articles
                .where((item) => _key(item, fromCollection: true) != key)
                .toList(growable: false);
      state = state.copyWith(articles: articles, confirmed: confirmed);
    } finally {
      _pendingOperations.remove(operationKey);
      if (state.identity == identity) {
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

  Future<void> _load(String identity, {bool showLoading = true}) async {
    if (state.identity != identity) return;
    if (showLoading && !state.isLoading) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    try {
      final records = await ref
          .read(collectionRepositoryProvider)
          .fetchCollections();
      if (state.identity != identity) return;
      final serverConfirmed = <String, bool>{
        for (final record in records) _key(record, fromCollection: true): true,
      };
      final confirmed = {...serverConfirmed, ...state.confirmed};
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
    } catch (error) {
      if (state.identity == identity) {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: error.toString(),
        );
      }
      rethrow;
    }
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
