import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:qjay_flutter_learning/services/article_service.dart';

void main() {
  test('文章服务把 WanAndroid 响应转换成文章列表', () async {
    // 如果请求地址错误，或服务没有读取 data.datas，这个测试就会失败。
    final client = _StubClient((request) async {
      expect(
        request.url.toString(),
        'https://www.wanandroid.com/article/list/0/json',
      );
      return http.Response(
        jsonEncode({
          'errorCode': 0,
          'errorMsg': '',
          'data': {
            'datas': [
              {
                'id': 7,
                'title': '用 Flutter 写 iOS',
                'link': 'https://example.com/7',
                'author': '小明',
                'superChapterName': '跨平台',
                'chapterName': 'Flutter',
                'niceDate': '1 小时前',
              },
            ],
          },
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final articles = await ArticleService(client: client).fetchArticles();

    expect(articles, hasLength(1));
    expect(articles.single.id, 7);
    expect(articles.single.title, '用 Flutter 写 iOS');
  });

  test('文章服务把接口业务错误转换成可读异常', () async {
    final client = _StubClient(
      (_) async => http.Response(
        jsonEncode({'errorCode': -1, 'errorMsg': '服务暂时不可用'}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );

    expect(
      () => ArticleService(client: client).fetchArticles(),
      throwsA(
        isA<ArticleLoadException>().having(
          (error) => error.message,
          'message',
          '服务暂时不可用',
        ),
      ),
    );
  });
}

class _StubClient extends http.BaseClient {
  _StubClient(this.handler);

  final Future<http.Response> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}
