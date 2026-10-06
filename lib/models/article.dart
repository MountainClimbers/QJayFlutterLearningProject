import 'package:html_unescape/html_unescape.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@Freezed(toJson: false)
abstract class Article with _$Article {
  const Article._();

  const factory Article({
    @JsonKey(fromJson: _intValue) required int id,
    @JsonKey(fromJson: _plainText) required String title,
    @JsonKey(fromJson: _stringValue) required String link,
    @JsonKey(fromJson: _plainText) @Default('') String author,
    @JsonKey(fromJson: _plainText) @Default('') String shareUser,
    @JsonKey(fromJson: _plainText) @Default('') String superChapterName,
    @JsonKey(fromJson: _plainText) @Default('') String chapterName,
    @JsonKey(fromJson: _plainText) @Default('') String niceDate,
    @JsonKey(fromJson: _plainText) @Default('') String niceShareDate,
    @JsonKey(name: 'collect', fromJson: _boolValue)
    @Default(false)
    bool collected,
    @JsonKey(fromJson: _nullableIntValue) int? originId,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);

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

int? _nullableIntValue(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _boolValue(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

String _stringValue(Object? value) => value?.toString().trim() ?? '';
