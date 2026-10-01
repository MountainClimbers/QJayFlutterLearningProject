// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
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
);

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'link': instance.link,
  'author': instance.author,
  'shareUser': instance.shareUser,
  'superChapterName': instance.superChapterName,
  'chapterName': instance.chapterName,
  'niceDate': instance.niceDate,
  'niceShareDate': instance.niceShareDate,
};
