import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/auth_service.dart';
import 'package:qjay_flutter_learning/services/wan_android_client.dart';

void main() {
  test('登录服务提交表单、解析用户并保存 Cookie', () async {
    final cookieJar = CookieJar();
    final dio = _stubDio((options) {
      expect(options.method, 'POST');
      expect(options.uri.toString(), '$wanAndroidBaseUrl/user/login');
      expect(options.contentType, Headers.formUrlEncodedContentType);
      expect(options.data, {
        'username': 'MountainClimbers',
        'password': '123456',
      });
      return _jsonResponse(
        {
          'errorCode': 0,
          'errorMsg': '',
          'data': {
            'id': 7,
            'username': 'MountainClimbers',
            'nickname': '山友',
            'publicName': 'MountainClimbers',
          },
        },
        cookies: [
          'loginUserName=MountainClimbers; Path=/; Secure; HttpOnly',
          'token_pass=test_token; Path=/; Secure; HttpOnly',
        ],
      );
    });
    final service = AuthService(dio: dio, cookieJar: cookieJar);

    final user = await service.login(
      username: 'MountainClimbers',
      password: '123456',
    );

    expect(user.id, 7);
    expect(user.username, 'MountainClimbers');
    expect(user.displayName, '山友');
    final cookies = await cookieJar.loadForRequest(
      Uri.parse('$wanAndroidBaseUrl/article/list/0/json'),
    );
    expect(cookies.map((cookie) => cookie.name), contains('loginUserName'));
    expect(cookies.map((cookie) => cookie.name), contains('token_pass'));
  });

  test('登录服务把业务错误转换成可读异常', () async {
    final dio = _stubDio(
      (_) => _jsonResponse({
        'errorCode': -1,
        'errorMsg': '账号密码不匹配！',
        'data': null,
      }),
    );
    final service = AuthService(dio: dio, cookieJar: CookieJar());

    expect(
      () => service.login(username: 'wrong', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '账号密码不匹配！',
        ),
      ),
    );
  });

  test('登录服务从持久 Cookie 恢复用户名', () async {
    final cookieJar = CookieJar();
    await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
    ]);
    final service = AuthService(dio: Dio(), cookieJar: cookieJar);

    final user = await service.restoreSession();

    expect(user?.username, 'MountainClimbers');
  });

  test('没有登录 Cookie 时返回未登录状态', () async {
    final service = AuthService(dio: Dio(), cookieJar: CookieJar());

    expect(await service.restoreSession(), isNull);
  });
}

Dio _stubDio(ResponseBody Function(RequestOptions options) handler) {
  final dio = Dio();
  dio.httpClientAdapter = _StubAdapter(handler);
  return dio;
}

ResponseBody _jsonResponse(
  Map<String, dynamic> body, {
  List<String> cookies = const [],
}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      if (cookies.isNotEmpty) HttpHeaders.setCookieHeader: cookies,
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
