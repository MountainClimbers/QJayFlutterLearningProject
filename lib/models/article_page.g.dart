// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ArticlePage _$ArticlePageFromJson(Map<String, dynamic> json) => _ArticlePage(
  datas:
      (json['datas'] as List<dynamic>?)
          ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Article>[],
  curPage: (json['curPage'] as num?)?.toInt() ?? 0,
  pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
  over: json['over'] as bool? ?? true,
);
