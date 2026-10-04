import 'dart:io';

import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/wan_android_client.dart';

void main() {
  test('共享客户端配置玩安卓域名和超时', () {
    final dio = createWanAndroidDio(debugMode: false);

    expect(dio.options.baseUrl, wanAndroidBaseUrl);
    expect(dio.options.connectTimeout, const Duration(seconds: 10));
    expect(dio.options.receiveTimeout, const Duration(seconds: 10));
  });

  test('调试模式为玩安卓的两个 HTTPS 域名接入证书例外', () {
    final httpClient = _RecordingHttpClient();
    final dio = createWanAndroidDio(
      debugMode: true,
      createHttpClient: () => httpClient,
    );
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    expect(adapter.createHttpClient, isNotNull);
    expect(adapter.createHttpClient!(), same(httpClient));

    final callback = httpClient.recordedBadCertificateCallback;
    expect(callback, isNotNull);
    expect(callback!(_FakeCertificate(), 'www.wanandroid.com', 443), isTrue);
    expect(callback(_FakeCertificate(), 'wanandroid.com', 443), isTrue);
    expect(callback(_FakeCertificate(), 'www.wanandroid.com', 80), isFalse);
    expect(callback(_FakeCertificate(), 'example.com', 443), isFalse);
  });

  test('发布模式不安装忽略证书的原生客户端', () {
    final dio = createWanAndroidDio(
      debugMode: false,
      createHttpClient: _RecordingHttpClient.new,
    );
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;

    expect(adapter.createHttpClient, isNull);
  });
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
