import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../models/login_user.dart';
import 'session_client.dart';
import 'wan_android_client.dart';

abstract interface class AuthRepository {
  Future<LoginUser> login({required String username, required String password});

  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  });

  Future<LoginUser?> restoreSession();

  Future<void> clearSession();

  Future<void> logout();
}

class AuthService implements AuthRepository {
  AuthService({Dio? dio, CookieJar? cookieJar})
    : _dio = dio ?? createWanAndroidDio(),
      _cookieJar = cookieJar ?? CookieJar() {
    _dio.options
      ..baseUrl = wanAndroidBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10);
    if (_dio.interceptors.whereType<CookieManager>().isEmpty) {
      _dio.interceptors.add(CookieManager(_cookieJar));
    }
  }

  final Dio _dio;
  final CookieJar _cookieJar;

  @override
  Future<LoginUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/login',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final root = response.data;
      if (root == null) {
        throw const AuthException('服务器返回的数据格式不正确');
      }

      final rawErrorCode = root['errorCode'];
      if (rawErrorCode is! num) {
        throw const AuthException('服务器返回的数据无法解析');
      }
      final errorCode = rawErrorCode.toInt();
      if (errorCode != 0) {
        final message = root['errorMsg']?.toString().trim();
        throw AuthException(
          message == null || message.isEmpty ? '登录失败' : message,
        );
      }

      final data = root['data'];
      if (data is! Map<String, dynamic>) {
        throw const AuthException('服务器返回的数据格式不正确');
      }
      try {
        return LoginUser.fromJson(data);
      } on Object {
        throw const AuthException('服务器返回的数据无法解析');
      }
    } on AuthException {
      rethrow;
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const AuthException('服务器返回的数据无法解析');
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw AuthException('登录请求失败（$statusCode）');
      }
      throw const AuthException('网络连接失败，请稍后重试');
    } on FormatException {
      throw const AuthException('服务器返回的数据无法解析');
    }
  }

  @override
  Future<LoginUser> register({
    required String username,
    required String password,
    required String repeatedPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/user/register',
        data: {
          'username': username,
          'password': password,
          'repassword': repeatedPassword,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final root = response.data;
      if (root == null) {
        throw const AuthException('服务器返回的数据格式不正确');
      }
      final rawErrorCode = root['errorCode'];
      if (rawErrorCode is! num) {
        throw const AuthException('服务器返回的数据无法解析');
      }
      if (rawErrorCode.toInt() != 0) {
        final message = root['errorMsg']?.toString().trim();
        throw AuthException(
          message == null || message.isEmpty ? '注册失败' : message,
        );
      }
      return await login(username: username, password: password);
    } on AuthException {
      rethrow;
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const AuthException('服务器返回的数据无法解析');
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw AuthException('注册请求失败（$statusCode）');
      }
      throw const AuthException('网络连接失败，请稍后重试');
    } on FormatException {
      throw const AuthException('服务器返回的数据无法解析');
    }
  }

  @override
  Future<LoginUser?> restoreSession() async {
    final cookies = await _cookieJar.loadForRequest(
      Uri.parse('$wanAndroidBaseUrl/'),
    );
    String? username;
    var hasAuthToken = false;
    for (final cookie in cookies) {
      final value = cookie.value.trim();
      if (value.isEmpty) continue;
      if (cookie.name == 'loginUserName' ||
          cookie.name == 'loginUserName_wanandroid_com') {
        username = _decodeCookieValue(value);
      } else if (cookie.name == 'token_pass') {
        hasAuthToken = true;
      }
    }
    return username != null && hasAuthToken
        ? LoginUser(username: username)
        : null;
  }

  @override
  Future<void> clearSession() async {
    try {
      await _cookieJar.deleteAll();
    } catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const AuthException('本地登录凭证清理失败，请重新登录'),
        stackTrace,
      );
    }
  }

  @override
  Future<void> logout() async {
    Object? requestError;
    StackTrace? requestStackTrace;
    try {
      await _requestRemoteLogout();
    } catch (error, stackTrace) {
      requestError = error;
      requestStackTrace = stackTrace;
    }

    await clearSession();

    if (requestError != null) {
      Error.throwWithStackTrace(requestError, requestStackTrace!);
    }
  }

  Future<void> _requestRemoteLogout() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user/logout/json',
      );
      final root = response.data;
      if (root == null) {
        throw const AuthException('服务器返回的数据格式不正确');
      }

      final rawErrorCode = root['errorCode'];
      if (rawErrorCode is! num) {
        throw const AuthException('服务器返回的数据无法解析');
      }
      if (rawErrorCode.toInt() != 0) {
        final message = root['errorMsg']?.toString().trim();
        throw AuthException(
          message == null || message.isEmpty ? '退出登录失败' : message,
        );
      }
    } on AuthException {
      rethrow;
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const AuthException('服务器返回的数据无法解析');
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw AuthException('退出请求失败（$statusCode）');
      }
      throw const AuthException('网络连接失败，请稍后重试');
    } on FormatException {
      throw const AuthException('服务器返回的数据无法解析');
    }
  }
}

Future<AuthRepository> createPersistentAuthRepository() async {
  return createAuthRepository(createPersistentWanAndroidSessionClient());
}

Future<AuthRepository> createAuthRepository(
  WanAndroidSessionClient client,
) async {
  final cookieJar = client.cookieJar;
  if (cookieJar is PersistCookieJar) await cookieJar.forceInit();
  return AuthService(dio: client.dio, cookieJar: cookieJar);
}

String _decodeCookieValue(String value) {
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return value;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
