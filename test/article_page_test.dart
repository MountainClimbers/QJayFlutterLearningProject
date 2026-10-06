import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/models/article_page.dart';

void main() {
  test('分页模型解析文章并判断还有下一页', () {
    final page = ArticlePage.fromJson({
      'curPage': 1,
      'pageCount': 3,
      'over': false,
      'datas': [
        {'id': 7, 'title': '分页文章', 'link': 'https://example.com/7'},
      ],
    });

    expect(page.datas, hasLength(1));
    expect(page.datas.single.id, 7);
    expect(page.hasMore, isTrue);
  });

  test('服务端标记结束时分页模型判断没有下一页', () {
    final page = ArticlePage.fromJson({
      'curPage': 3,
      'pageCount': 3,
      'over': true,
      'datas': <Object?>[],
    });

    expect(page.datas, isEmpty);
    expect(page.hasMore, isFalse);
  });

  test('当前页已经达到总页数时分页模型判断没有下一页', () {
    final page = ArticlePage.fromJson({
      'curPage': 3,
      'pageCount': 3,
      'over': false,
      'datas': <Object?>[],
    });

    expect(page.hasMore, isFalse);
  });
}
