import 'package:flutter/material.dart';

import '../../models/article.dart';
import '../../services/article_service.dart';
import 'article_card.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key, required this.repository});

  final ArticleRepository repository;

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<Article> _articles = const [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  /// 首次进入、点击重试和下拉刷新都复用同一个加载入口。
  Future<void> _loadArticles() async {
    setState(() {
      _errorMessage = null;
      if (_articles.isEmpty) _isLoading = true;
    });

    try {
      final articles = await widget.repository.fetchArticles();
      if (!mounted) return;
      setState(() => _articles = articles);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文章列表'), centerTitle: false),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadArticles, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: _articles.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                Icon(Icons.article_outlined, size: 52),
                SizedBox(height: 12),
                Center(child: Text('暂时没有文章，下拉刷新试试')),
              ],
            )
          : ListView.builder(
              key: const PageStorageKey('article-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                return ArticleCard(article: _articles[index]);
              },
            ),
    );
  }
}
