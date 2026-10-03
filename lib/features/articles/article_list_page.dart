import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/login_page.dart';
import '../../models/article.dart';
import 'article_card.dart';
import 'article_detail_page.dart';
import 'article_list_controller.dart';

typedef ArticleDetailPageBuilder = Widget Function(Article article);
typedef LoginPageBuilder = Widget Function();

/// ConsumerWidget 只根据 Riverpod 状态绘制页面，不手动保存异步状态。
class ArticleListPage extends ConsumerWidget {
  const ArticleListPage({
    super.key,
    this.articleDetailPageBuilder,
    this.loginPageBuilder,
  });

  final ArticleDetailPageBuilder? articleDetailPageBuilder;
  final LoginPageBuilder? loginPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articleListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('文章列表'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: '登录',
            onPressed: () {
              final builder = loginPageBuilder ?? () => const LoginPage();
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => builder()));
            },
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      body: switch (articles) {
        AsyncData(:final value) => _ArticleList(
          articles: value,
          articleDetailPageBuilder:
              articleDetailPageBuilder ??
              (article) => ArticleDetailPage(article: article),
        ),
        AsyncError(:final error) => _ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(articleListControllerProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ArticleList extends ConsumerWidget {
  const _ArticleList({
    required this.articles,
    required this.articleDetailPageBuilder,
  });

  final List<Article> articles;
  final ArticleDetailPageBuilder articleDetailPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        final message = await ref
            .read(articleListControllerProvider.notifier)
            .refresh();
        if (message != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('刷新失败：$message')));
        }
      },
      child: articles.isEmpty
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
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => articleDetailPageBuilder(article),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
