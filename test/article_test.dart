import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/models/article.dart';

void main() {
  test('文章模型解码标题，并在作者为空时使用分享人', () {
    // 如果删除 HTML 解码或作者回退逻辑，这个测试就会失败。
    final article = Article.fromJson({
      'id': 42,
      'title': 'Flutter &amp; iOS 入门',
      'link': 'https://example.com/flutter',
      'author': '',
      'shareUser': 'MountainClimbers',
      'superChapterName': '移动开发',
      'chapterName': 'Flutter',
      'niceDate': '刚刚',
    });

    expect(article.id, 42);
    expect(article.title, 'Flutter & iOS 入门');
    expect(article.author, 'MountainClimbers');
    expect(article.chapter, '移动开发 / Flutter');
    expect(article.date, '刚刚');
    expect(article.link, 'https://example.com/flutter');
  });
}
