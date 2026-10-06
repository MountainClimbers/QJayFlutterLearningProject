import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/article.dart';

part 'collection_state.freezed.dart';

@freezed
abstract class CollectionState with _$CollectionState {
  const factory CollectionState({
    String? identity,
    @Default(<Article>[]) List<Article> articles,
    @Default(<String, bool>{}) Map<String, bool> confirmed,
    @Default(<String>{}) Set<String> busyKeys,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? errorMessage,
  }) = _CollectionState;
}
