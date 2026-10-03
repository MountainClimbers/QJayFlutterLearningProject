import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';

void main() {
  test('调试模式把限定范围的证书例外接入原生客户端', () {
    final httpClient = _RecordingHttpClient();
    final dio = createArticleDio(
      debugMode: true,
      createHttpClient: () => httpClient,
    );
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    expect(adapter.createHttpClient, isNotNull);
    expect(adapter.createHttpClient!(), same(httpClient));

    final callback = httpClient.recordedBadCertificateCallback;
    expect(callback, isNotNull);
    expect(callback!(_FakeCertificate(), 'www.wanandroid.com', 443), isTrue);
    expect(callback(_FakeCertificate(), 'www.wanandroid.com', 80), isFalse);
    expect(callback(_FakeCertificate(), 'example.com', 443), isFalse);
  });

  test('发布模式不安装忽略证书的原生客户端', () {
    final dio = createArticleDio(
      debugMode: false,
      createHttpClient: _RecordingHttpClient.new,
    );
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    expect(adapter.createHttpClient, isNull);
  });

  test('Dio 文章服务请求正确路径并转换文章列表', () async {
    // 如果 baseUrl、请求路径或 data.datas 解析错误，这个测试就会失败。
    final dio = _stubDio((options) {
      expect(
        options.uri.toString(),
        'https://www.wanandroid.com/article/list/0/json',
      );
      return _jsonResponse({
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
      });
    });

    final articles = await ArticleService(dio: dio).fetchArticles();

    expect(articles, hasLength(1));
    expect(articles.single.id, 7);
    expect(articles.single.title, '用 Flutter 写 iOS');
  });

  test('Dio 文章服务把业务错误转换成可读异常', () async {
    final dio = _stubDio(
      (_) => _jsonResponse({'errorCode': -1, 'errorMsg': '服务暂时不可用'}),
    );

    expect(
      () => ArticleService(dio: dio).fetchArticles(),
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
      () => ArticleService(dio: dio).fetchArticles(),
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
      () => ArticleService(dio: dio).fetchArticles(),
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
      () => ArticleService(dio: dio).fetchArticles(),
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

class _RecordingHttpClient implements HttpClient {
  bool Function(X509Certificate certificate, String host, int port)?
  recordedBadCertificateCallback;

  @override
  set badCertificateCallback(
    bool Function(X509Certificate certificate, String host, int port)? callback,
  ) {
    recordedBadCertificateCallback = callback;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCertificate implements X509Certificate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
