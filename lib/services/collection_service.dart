import 'package:dio/dio.dart';

import '../models/article_page.dart';
import 'wan_android_client.dart';

abstract interface class CollectionRepository {
  Future<ArticlePage> fetchCollections({
    required int page,
    int pageSize = wanAndroidPageSize,
  });

  Future<void> collect(int articleId);

  Future<void> uncollect(int articleId);

  Future<void> removeCollection({required int recordId, required int originId});
}

class CollectionService implements CollectionRepository {
  CollectionService({Dio? dio}) : _dio = dio ?? createWanAndroidDio() {
    _dio.options
      ..baseUrl = wanAndroidBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10);
  }

  final Dio _dio;

  @override
  Future<ArticlePage> fetchCollections({
    required int page,
    int pageSize = wanAndroidPageSize,
  }) {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/lg/collect/list/$page/json',
        queryParameters: {'page_size': pageSize},
      );
      final data = _responseData(response, fallbackMessage: '收藏列表加载失败');
      if (data is! Map<String, dynamic> || data['datas'] is! List) {
        throw const CollectionException('服务器返回的数据格式不正确');
      }
      final pageData = ArticlePage.fromJson(data);
      return pageData.copyWith(
        datas: pageData.datas
            .map((article) => article.copyWith(collected: true))
            .toList(growable: false),
      );
    });
  }

  @override
  Future<void> collect(int articleId) {
    return _post('/lg/collect/$articleId/json');
  }

  @override
  Future<void> uncollect(int articleId) {
    return _post('/lg/uncollect_originId/$articleId/json');
  }

  @override
  Future<void> removeCollection({
    required int recordId,
    required int originId,
  }) {
    return _post('/lg/uncollect/$recordId/json', data: {'originId': originId});
  }

  Future<void> _post(String path, {Map<String, dynamic>? data}) {
    return _guard(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: data == null
            ? null
            : Options(contentType: Headers.formUrlEncodedContentType),
      );
      _responseData(response, fallbackMessage: '收藏操作失败');
    });
  }

  Object? _responseData(
    Response<Map<String, dynamic>> response, {
    required String fallbackMessage,
  }) {
    final root = response.data;
    if (root == null) {
      throw const CollectionException('服务器返回的数据格式不正确');
    }
    final rawErrorCode = root['errorCode'];
    if (rawErrorCode is! num) {
      throw const CollectionException('服务器返回的数据无法解析');
    }
    final errorCode = rawErrorCode.toInt();
    if (errorCode != 0) {
      final message = root['errorMsg']?.toString().trim();
      final resolvedMessage = message == null || message.isEmpty
          ? fallbackMessage
          : message;
      if (errorCode == -1001) {
        throw CollectionAuthenticationException(resolvedMessage);
      }
      throw CollectionException(resolvedMessage);
    }
    return root['data'];
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on CollectionException {
      rethrow;
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const CollectionException('服务器返回的数据无法解析');
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw CollectionException('收藏请求失败（$statusCode）');
      }
      throw const CollectionException('网络连接失败，请稍后重试');
    } on FormatException {
      throw const CollectionException('服务器返回的数据无法解析');
    }
  }
}

class CollectionException implements Exception {
  const CollectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CollectionAuthenticationException extends CollectionException {
  const CollectionAuthenticationException(super.message);
}
