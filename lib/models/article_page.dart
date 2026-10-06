import 'package:freezed_annotation/freezed_annotation.dart';

import 'article.dart';

part 'article_page.freezed.dart';
part 'article_page.g.dart';

const wanAndroidPageSize = 10;

@Freezed(toJson: false)
abstract class ArticlePage with _$ArticlePage {
  const ArticlePage._();

  const factory ArticlePage({
    @Default(<Article>[]) List<Article> datas,
    @Default(0) int curPage,
    @Default(0) int pageCount,
    @Default(true) bool over,
  }) = _ArticlePage;

  factory ArticlePage.fromJson(Map<String, dynamic> json) =>
      _$ArticlePageFromJson(json);

  bool get hasMore => !over && (pageCount == 0 || curPage < pageCount);
}
