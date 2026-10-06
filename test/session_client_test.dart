import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/session_client.dart';
import 'package:qjay_flutter_learning/services/wan_android_client.dart';

void main() {
  test('共享会话客户端把 CookieJar 中的认证信息带到后续请求', () async {
    final cookieJar = CookieJar();
    await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [
      Cookie('token_pass', 'shared_token')..path = '/',
    ]);
    String? requestCookie;
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter((options) {
        requestCookie = options.headers[HttpHeaders.cookieHeader]?.toString();
        return ResponseBody.fromString(
          '{"errorCode":0,"errorMsg":"","data":null}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json; charset=utf-8'],
          },
        );
      });
    final client = createWanAndroidSessionClient(
      dio: dio,
      cookieJar: cookieJar,
    );

    await client.dio.get<Map<String, dynamic>>('/lg/collect/list/0/json');

    expect(requestCookie, contains('token_pass=shared_token'));
    expect(identical(client.cookieJar, cookieJar), isTrue);
  });
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
