import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_cookie_storage.dart';
import 'wan_android_client.dart';

/// 认证、文章和收藏服务共享的网络会话。
class WanAndroidSessionClient {
  const WanAndroidSessionClient({required this.dio, required this.cookieJar});

  final Dio dio;
  final CookieJar cookieJar;
}

WanAndroidSessionClient createWanAndroidSessionClient({
  Dio? dio,
  CookieJar? cookieJar,
}) {
  final resolvedDio = dio ?? createWanAndroidDio();
  final resolvedCookieJar = cookieJar ?? CookieJar();
  resolvedDio.options
    ..baseUrl = wanAndroidBaseUrl
    ..connectTimeout = const Duration(seconds: 10)
    ..receiveTimeout = const Duration(seconds: 10);
  if (resolvedDio.interceptors.whereType<CookieManager>().isEmpty) {
    resolvedDio.interceptors.add(CookieManager(resolvedCookieJar));
  }
  return WanAndroidSessionClient(
    dio: resolvedDio,
    cookieJar: resolvedCookieJar,
  );
}

WanAndroidSessionClient createPersistentWanAndroidSessionClient() {
  return createWanAndroidSessionClient(
    cookieJar: PersistCookieJar(
      storage: SecureCookieStorage(FlutterSecureKeyValueStore()),
    ),
  );
}

final sessionClientProvider = Provider<WanAndroidSessionClient>((ref) {
  return createPersistentWanAndroidSessionClient();
});
