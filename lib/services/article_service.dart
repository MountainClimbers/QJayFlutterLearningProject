import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';

/// 页面只依赖这个接口，因此测试可以换成不访问网络的假实现。
abstract interface class ArticleRepository {
  Future<List<Article>> fetchArticles();
}

/// 使用 WanAndroid 公开接口获取文章。
class ArticleService implements ArticleRepository {
  ArticleService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _articlesUri = Uri.https(
    'www.wanandroid.com',
    '/article/list/0/json',
  );

  final http.Client _client;

  @override
  Future<List<Article>> fetchArticles() async {
    try {
      final response = await _client.get(_articlesUri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ArticleLoadException('网络请求失败（${response.statusCode}）');
      }

      final root = jsonDecode(utf8.decode(response.bodyBytes));
      if (root is! Map<String, dynamic>) {
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
      final values = data is Map<String, dynamic> ? data['datas'] : null;
      if (values is! List) {
        throw const ArticleLoadException('服务器返回的数据格式不正确');
      }

      return values
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList(growable: false);
    } on ArticleLoadException {
      rethrow;
    } on FormatException {
      throw const ArticleLoadException('服务器返回的数据无法解析');
    } on http.ClientException {
      throw const ArticleLoadException('网络连接失败，请检查网络后重试');
    }
  }
}

class ArticleLoadException implements Exception {
  const ArticleLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}
