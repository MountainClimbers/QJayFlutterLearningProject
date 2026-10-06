import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';

void main() {
  test('Dio 文章服务请求正确路径并转换文章列表', () async {
    // 如果 baseUrl、请求路径或 data.datas 解析错误，这个测试就会失败。
    late RequestOptions request;
    final dio = _stubDio((options) {
      request = options;
      return _jsonResponse({
        'errorCode': 0,
        'errorMsg': '',
        'data': {
          'curPage': 3,
          'pageCount': 5,
          'over': false,
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
      });
    });

    final page = await ArticleService(dio: dio).fetchArticles(page: 2);

    expect(request.uri.path, '/article/list/2/json');
    expect(request.uri.queryParameters['page_size'], '10');
    expect(page.datas, hasLength(1));
    expect(page.datas.single.id, 7);
    expect(page.datas.single.title, '用 Flutter 写 iOS');
    expect(page.hasMore, isTrue);
  });

  test('Dio 文章服务把业务错误转换成可读异常', () async {
    final dio = _stubDio(
      (_) => _jsonResponse({'errorCode': -1, 'errorMsg': '服务暂时不可用'}),
    );

    expect(
      () => ArticleService(dio: dio).fetchArticles(page: 0),
      throwsA(
        isA<ArticleLoadException>().having(
          (error) => error.message,
          'message',
          '服务暂时不可用',
        ),
      ),
    );
  });

  test('Dio 文章服务把 HTTP 错误转换成可读异常', () async {
    final dio = _stubDio((_) => ResponseBody.fromString('服务错误', 503));

    expect(
      () => ArticleService(dio: dio).fetchArticles(page: 0),
      throwsA(
        isA<ArticleLoadException>().having(
          (error) => error.message,
          'message',
          '网络请求失败（503）',
        ),
      ),
    );
  });

  test('Dio 文章服务把连接错误转换成可读异常', () async {
    final dio = _stubDio((options) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    });

    expect(
      () => ArticleService(dio: dio).fetchArticles(page: 0),
      throwsA(
        isA<ArticleLoadException>().having(
          (error) => error.message,
          'message',
          '网络连接失败，请检查网络后重试',
        ),
      ),
    );
  });

  test('Dio 文章服务把非法 JSON 转换成解析异常', () async {
    final dio = _stubDio(
      (_) => ResponseBody.fromString(
        '{invalid json',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json; charset=utf-8'],
        },
      ),
    );

    expect(
      () => ArticleService(dio: dio).fetchArticles(page: 0),
      throwsA(
        isA<ArticleLoadException>().having(
          (error) => error.message,
          'message',
          '服务器返回的数据无法解析',
        ),
      ),
    );
  });
}

Dio _stubDio(ResponseBody Function(RequestOptions options) handler) {
  final dio = Dio();
  dio.httpClientAdapter = _StubAdapter(handler);
  return dio;
}

ResponseBody _jsonResponse(Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    },
  );
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
