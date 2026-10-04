import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

const wanAndroidBaseUrl = 'https://www.wanandroid.com';

/// 创建文章、登录等服务共享的 WanAndroid 客户端。
///
/// Debug 模式临时允许玩安卓接口的过期证书；Release 无法开启该例外。
Dio createWanAndroidDio({
  bool debugMode = kDebugMode,
  HttpClient Function()? createHttpClient,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: wanAndroidBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  if (kDebugMode && debugMode) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = (createHttpClient ?? HttpClient.new)();
        client.badCertificateCallback = (certificate, host, port) {
          // 接口可能在 www 与非 www 域名间跳转；只允许这两个 HTTPS 主机。
          return port == 443 &&
              (host == 'www.wanandroid.com' || host == 'wanandroid.com');
        };
        return client;
      },
    );
  }
  return dio;
}
