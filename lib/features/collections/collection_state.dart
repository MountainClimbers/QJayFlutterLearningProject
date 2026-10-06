import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/article.dart';

part 'collection_state.freezed.dart';

@freezed
abstract class CollectionState with _$CollectionState {
  const CollectionState._();

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

  List<Article> get articles =>
      pages.expand((page) => page).toList(growable: false);

  String? get errorMessage => error?.toString();

  PagingState<int, Article> get pagingState => PagingState(
    pages: pages.isEmpty ? null : pages,
    keys: pages.isEmpty
        ? null
        : List<int>.generate(pages.length, (index) => index),
    error: error,
    hasNextPage: hasMore,
    isLoading: isLoading,
  );
}
