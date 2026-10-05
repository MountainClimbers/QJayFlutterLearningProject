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

  test('登录服务从完整认证 Cookie 恢复用户名', () async {
    final cookieJar = CookieJar();
    await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
      Cookie('token_pass', 'test_token')..path = '/',
    ]);
    final service = AuthService(dio: Dio(), cookieJar: cookieJar);

    final user = await service.restoreSession();

    expect(user?.username, 'MountainClimbers');
  });

  test('只有用户名或令牌 Cookie 时保持未登录', () async {
    for (final cookie in [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
      Cookie('token_pass', 'test_token')..path = '/',
    ]) {
      final cookieJar = CookieJar();
      await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [cookie]);
      final service = AuthService(dio: Dio(), cookieJar: cookieJar);

      expect(await service.restoreSession(), isNull);
    }
  });

  test('认证 Cookie 过期时保持未登录', () async {
    final cookieJar = CookieJar();
    await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
      Cookie('token_pass', 'expired_token')
        ..path = '/'
        ..expires = DateTime.now().subtract(const Duration(days: 1)),
    ]);
    final service = AuthService(dio: Dio(), cookieJar: cookieJar);

    expect(await service.restoreSession(), isNull);
  });

  test('登录服务区分响应解析错误', () async {
    final dio = _stubDio(
      (_) => ResponseBody.fromString(
        '这不是 JSON',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json; charset=utf-8'],
        },
      ),
    );
    final service = AuthService(dio: dio, cookieJar: CookieJar());

    expect(
      () => service.login(username: 'test', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '服务器返回的数据无法解析',
        ),
      ),
    );
  });

  test('登录服务把用户字段类型错误转换成解析异常', () async {
    final dio = _stubDio(
      (_) => _jsonResponse({
        'errorCode': 0,
        'errorMsg': '',
        'data': {'id': '不是数字', 'username': 'test'},
      }),
    );
    final service = AuthService(dio: dio, cookieJar: CookieJar());

    expect(
      () => service.login(username: 'test', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '服务器返回的数据无法解析',
        ),
      ),
    );
  });

  test('登录服务把错误码类型异常转换成解析异常', () async {
    final dio = _stubDio(
      (_) => _jsonResponse({
        'errorCode': '零',
        'errorMsg': '',
        'data': <String, dynamic>{},
      }),
    );
    final service = AuthService(dio: dio, cookieJar: CookieJar());

    expect(
      () => service.login(username: 'test', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '服务器返回的数据无法解析',
        ),
      ),
    );
  });

  test('登录服务区分 HTTP 错误和连接错误', () async {
    final httpService = AuthService(
      dio: _stubDio((_) => ResponseBody.fromString('服务异常', 503)),
      cookieJar: CookieJar(),
    );
    final connectionService = AuthService(
      dio: _stubDio(
        (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: '测试断网',
        ),
      ),
      cookieJar: CookieJar(),
    );

    await expectLater(
      httpService.login(username: 'test', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '登录请求失败（503）',
        ),
      ),
    );
    await expectLater(
      connectionService.login(username: 'test', password: '123456'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '网络连接失败，请稍后重试',
        ),
      ),
    );
  });

  test('没有登录 Cookie 时返回未登录状态', () async {
    final service = AuthService(dio: Dio(), cookieJar: CookieJar());

    expect(await service.restoreSession(), isNull);
  });

  test('退出登录请求正确接口并清理 Cookie', () async {
    final cookieJar = CookieJar();
    await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
      Cookie('token_pass', 'test_token')..path = '/',
    ]);
    final dio = _stubDio((options) {
      expect(options.method, 'GET');
      expect(options.uri.toString(), '$wanAndroidBaseUrl/user/logout/json');
      return _jsonResponse({'errorCode': 0, 'errorMsg': '', 'data': null});
    });
    final service = AuthService(dio: dio, cookieJar: cookieJar);

    await service.logout();

    expect(
      await cookieJar.loadForRequest(Uri.parse(wanAndroidBaseUrl)),
      isEmpty,
    );
  });

  test('退出接口返回业务错误时仍清理本地登录状态', () async {
    final cookieJar = CookieJar();
    await cookieJar.saveFromResponse(Uri.parse(wanAndroidBaseUrl), [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
      Cookie('token_pass', 'test_token')..path = '/',
    ]);
    final dio = _stubDio(
      (_) => _jsonResponse({'errorCode': -1, 'errorMsg': '退出失败', 'data': null}),
    );
    final service = AuthService(dio: dio, cookieJar: cookieJar);

    await expectLater(
      service.logout(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '退出失败',
        ),
      ),
    );
    expect(
      await cookieJar.loadForRequest(Uri.parse(wanAndroidBaseUrl)),
      isEmpty,
    );
  });

  test('本地登录状态清理失败时返回明确错误', () async {
    final dio = _stubDio(
      (_) => _jsonResponse({'errorCode': 0, 'errorMsg': '', 'data': null}),
    );
    final service = AuthService(dio: dio, cookieJar: _FailingDeleteCookieJar());

    await expectLater(
      service.logout(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          '本地登录凭证清理失败，请重新登录',
        ),
      ),
    );
  });
}

class _FailingDeleteCookieJar implements CookieJar {
  @override
  final bool ignoreExpires = false;

  @override
  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]) async {}

  @override
  Future<void> deleteAll() async {
    throw StateError('测试安全存储删除失败');
  }

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) async => [];

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {}
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
