import 'package:dio/dio.dart';

import '../models/article.dart';
import 'wan_android_client.dart';

abstract interface class CollectionRepository {
  Future<List<Article>> fetchCollections();

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
  Future<List<Article>> fetchCollections() {
    return _guard(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/lg/collect/list/0/json',
      );
      final data = _responseData(response, fallbackMessage: '收藏列表加载失败');
      final values = data is Map<String, dynamic> ? data['datas'] : null;
      if (values is! List) {
        throw const CollectionException('服务器返回的数据格式不正确');
      }
      return values
          .whereType<Map<String, dynamic>>()
          .map((json) => Article.fromJson(json).copyWith(collected: true))
          .toList(growable: false);
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
    if (rawErrorCode.toInt() != 0) {
      final message = root['errorMsg']?.toString().trim();
      throw CollectionException(
        message == null || message.isEmpty ? fallbackMessage : message,
      );
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
