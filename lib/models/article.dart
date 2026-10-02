import 'package:html_unescape/html_unescape.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable(createToJson: false)
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.link,
    this.author = '',
    this.shareUser = '',
    this.superChapterName = '',
    this.chapterName = '',
    this.niceDate = '',
    this.niceShareDate = '',
  });

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

  @JsonKey(fromJson: _intValue)
  final int id;

  @JsonKey(fromJson: _plainText)
  final String title;

  @JsonKey(fromJson: _stringValue)
  final String link;

  @JsonKey(fromJson: _plainText)
  final String author;

  @JsonKey(fromJson: _plainText)
  final String shareUser;

  @JsonKey(fromJson: _plainText)
  final String superChapterName;

  @JsonKey(fromJson: _plainText)
  final String chapterName;

  @JsonKey(fromJson: _plainText)
  final String niceDate;

  @JsonKey(fromJson: _plainText)
  final String niceShareDate;

  String get displayAuthor => author.isNotEmpty ? author : shareUser;

  String get displayChapter => [
    superChapterName,
    chapterName,
  ].where((name) => name.isNotEmpty).join(' / ');

  String get displayDate => niceDate.isNotEmpty ? niceDate : niceShareDate;
}

final _htmlUnescape = HtmlUnescape();

String _plainText(Object? value) {
  return _htmlUnescape.convert(value?.toString() ?? '').trim();
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _stringValue(Object? value) => value?.toString().trim() ?? '';
