// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Article _$ArticleFromJson(Map<String, dynamic> json) => _Article(
  id: _intValue(json['id']),
  title: _plainText(json['title']),
  link: _stringValue(json['link']),
  author: json['author'] == null ? '' : _plainText(json['author']),
  shareUser: json['shareUser'] == null ? '' : _plainText(json['shareUser']),
  superChapterName: json['superChapterName'] == null
      ? ''
      : _plainText(json['superChapterName']),
  chapterName: json['chapterName'] == null
      ? ''
      : _plainText(json['chapterName']),
  niceDate: json['niceDate'] == null ? '' : _plainText(json['niceDate']),
  niceShareDate: json['niceShareDate'] == null
      ? ''
      : _plainText(json['niceShareDate']),
  collected: json['collect'] == null ? false : _boolValue(json['collect']),
  originId: _nullableIntValue(json['originId']),
);
