import 'package:html_unescape/html_unescape.dart';

/// 一篇文章的数据。
///
/// 数据模型只负责把接口字段整理成页面容易使用的 Dart 对象，
/// 不负责发送网络请求，也不负责绘制界面。
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.link,
    required this.author,
    required this.chapter,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final author = _plainText(json['author']);
    final chapters = [
      _plainText(json['superChapterName']),
      _plainText(json['chapterName']),
    ].where((name) => name.isNotEmpty).join(' / ');

    return Article(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _plainText(json['title']),
      link: json['link']?.toString() ?? '',
      author: author.isNotEmpty ? author : _plainText(json['shareUser']),
      chapter: chapters,
      date: _plainText(json['niceDate'] ?? json['niceShareDate']),
    );
  }

  final int id;
  final String title;
  final String link;
  final String author;
  final String chapter;
  final String date;
}

final _htmlUnescape = HtmlUnescape();

String _plainText(Object? value) {
  return _htmlUnescape.convert(value?.toString() ?? '').trim();
}
