import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/collection_service.dart';
import 'package:qjay_flutter_learning/services/wan_android_client.dart';

void main() {
  test('收藏服务读取收藏列表并保留记录编号和原文章编号', () async {
    final dio = _stubDio((options) {
      expect(options.method, 'GET');
      expect(
        options.uri.toString(),
        '$wanAndroidBaseUrl/lg/collect/list/0/json',
      );
      return _jsonResponse({
        'errorCode': 0,
        'errorMsg': '',
        'data': {
          'datas': [
            {
              'id': 901,
              'originId': 42,
              'title': '收藏文章',
              'link': 'https://example.com/42',
            },
          ],
        },
      });
    });

    final articles = await CollectionService(dio: dio).fetchCollections();

    expect(articles, hasLength(1));
    expect(articles.single.id, 901);
    expect(articles.single.originId, 42);
    expect(articles.single.collected, isTrue);
  });

  test('收藏服务使用原文章编号收藏和取消收藏', () async {
    final requests = <RequestOptions>[];
    final dio = _stubDio((options) {
      requests.add(options);
      return _successResponse();
    });
    final service = CollectionService(dio: dio);

    await service.collect(42);
    await service.uncollect(42);

    expect(requests[0].method, 'POST');
    expect(requests[0].uri.path, '/lg/collect/42/json');
    expect(requests[1].method, 'POST');
    expect(requests[1].uri.path, '/lg/uncollect_originId/42/json');
  });

  test('收藏页使用收藏记录编号和 originId 取消收藏', () async {
    late RequestOptions request;
    final dio = _stubDio((options) {
      request = options;
      return _successResponse();
    });

    await CollectionService(dio: dio)
        .removeCollection(recordId: 901, originId: 42);

    expect(request.method, 'POST');
    expect(request.uri.path, '/lg/uncollect/901/json');
    expect(request.data, {'originId': 42});
    expect(request.contentType, Headers.formUrlEncodedContentType);
  });

  test('收藏服务把未登录错误转换成认证失效异常', () async {
    final dio = _stubDio(
      (_) =>
          _jsonResponse({'errorCode': -1001, 'errorMsg': '请先登录', 'data': null}),
    );

    await expectLater(
      CollectionService(dio: dio).collect(42),
      throwsA(
        isA<CollectionAuthenticationException>().having(
          (error) => error.message,
          'message',
          '请先登录',
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

ResponseBody _successResponse() {
  return _jsonResponse({'errorCode': 0, 'errorMsg': '', 'data': null});
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
