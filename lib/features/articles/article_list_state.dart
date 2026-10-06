import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/article.dart';

part 'article_list_state.freezed.dart';

@freezed
abstract class ArticleListState with _$ArticleListState {
  const ArticleListState._();

  const factory ArticleListState({
    @Default(<List<Article>>[]) List<List<Article>> pages,
    @Default(0) int nextPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    Object? error,
  }) = _ArticleListState;

  List<Article> get articles =>
      pages.expand((page) => page).toList(growable: false);

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
