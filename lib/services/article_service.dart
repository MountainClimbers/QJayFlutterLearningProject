import 'package:dio/dio.dart';

import '../models/article_page.dart';
import 'wan_android_client.dart';

/// 状态层只依赖这个接口，因此测试和未来的本地缓存都能替换网络实现。
abstract interface class ArticleRepository {
  Future<ArticlePage> fetchArticles({
    required int page,
    int pageSize = wanAndroidPageSize,
  });
}

/// 使用 Dio 统一管理服务地址、超时与网络异常。
class ArticleService implements ArticleRepository {
  ArticleService({Dio? dio}) : _dio = dio ?? createWanAndroidDio() {
    _dio.options
      ..baseUrl = wanAndroidBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10);
  }

  final Dio _dio;

  @override
  Future<ArticlePage> fetchArticles({
    required int page,
    int pageSize = wanAndroidPageSize,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/article/list/$page/json',
        queryParameters: {'page_size': pageSize},
      );
      final root = response.data;
      if (root == null) {
        throw const ArticleLoadException('服务器返回的数据格式不正确');
      }

      final errorCode = (root['errorCode'] as num?)?.toInt() ?? -1;
      if (errorCode != 0) {
        final message = root['errorMsg']?.toString().trim();
        throw ArticleLoadException(
          message == null || message.isEmpty ? '文章加载失败' : message,
        );
      }

      final data = root['data'];
      if (data is! Map<String, dynamic> || data['datas'] is! List) {
        throw const ArticleLoadException('服务器返回的数据格式不正确');
      }

      return ArticlePage.fromJson(data);
    } on ArticleLoadException {
      rethrow;
    } on DioException catch (error) {
      if (error.error is FormatException) {
        throw const ArticleLoadException('服务器返回的数据无法解析');
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw ArticleLoadException('网络请求失败（$statusCode）');
      }
      throw const ArticleLoadException('网络连接失败，请检查网络后重试');
    } on FormatException {
      throw const ArticleLoadException('服务器返回的数据无法解析');
    }
  }
}

class ArticleLoadException implements Exception {
  const ArticleLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
