import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/models/article.dart';

void main() {
  test('生成式文章模型解析字段并提供展示属性', () {
    // 如果生成映射、HTML 解码或展示属性损坏，这个测试就会失败。
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
    expect(article.displayAuthor, 'MountainClimbers');
    expect(article.displayChapter, '移动开发 / Flutter');
    expect(article.displayDate, '刚刚');
    expect(article.link, 'https://example.com/flutter');
  });

  test('生成式文章模型容忍接口中的空值与数字字符串', () {
    // 如果生成代码恢复为直接类型强转，线上脏数据会让整页崩溃。
    final article = Article.fromJson({'id': '42', 'title': null, 'link': null});

    expect(article.id, 42);
    expect(article.title, isEmpty);
    expect(article.link, isEmpty);
  });

  test('不可变文章模型支持值相等和复制修改', () {
    const article = Article(
      id: 42,
      title: 'Flutter',
      link: 'https://example.com/flutter',
    );
    const sameArticle = Article(
      id: 42,
      title: 'Flutter',
      link: 'https://example.com/flutter',
    );

    expect(article, sameArticle);
    expect(article.copyWith(title: 'Flutter 进阶').title, 'Flutter 进阶');
    expect(article.title, 'Flutter');
  });
}
