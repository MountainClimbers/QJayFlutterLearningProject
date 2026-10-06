import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../models/login_user.dart';
import '../articles/article_card.dart';
import '../articles/article_detail_page.dart';
import '../auth/auth_controller.dart';
import '../auth/login_page.dart';
import 'collection_controller.dart';

typedef CollectionArticleDetailPageBuilder = Widget Function(Article article);
typedef CollectionLoginPageBuilder = Widget Function();

class CollectionPage extends ConsumerWidget {
  const CollectionPage({
    super.key,
    this.articleDetailPageBuilder,
    this.loginPageBuilder,
  });

  final CollectionArticleDetailPageBuilder? articleDetailPageBuilder;
  final CollectionLoginPageBuilder? loginPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: switch (authState) {
        AsyncLoading<LoginUser?>() => const Center(
          child: CircularProgressIndicator(),
        ),
        _ when currentUser == null => _LoginRequiredView(
          onLogin: () => _openLogin(context, ref),
        ),
        _ => _CollectionBody(
          articleDetailPageBuilder:
              articleDetailPageBuilder ??
              (article) => ArticleDetailPage(article: article),
        ),
      },
    );
  }

  Future<void> _openLogin(BuildContext context, WidgetRef ref) async {
    final builder =
        loginPageBuilder ??
        () => LoginPage(
          onSubmit: (credentials) => ref
              .read(authControllerProvider.notifier)
              .login(
                username: credentials.username,
                password: credentials.password,
              ),
          onRegister: (credentials) => ref
              .read(authControllerProvider.notifier)
              .register(
                username: credentials.username,
                password: credentials.password,
                repeatedPassword: credentials.repeatedPassword,
              ),
        );
    await Navigator.of(context)
        .push<LoginUser>(MaterialPageRoute(builder: (_) => builder()));
  }
}

class _CollectionBody extends ConsumerWidget {
  const _CollectionBody({required this.articleDetailPageBuilder});

  final CollectionArticleDetailPageBuilder articleDetailPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionControllerProvider);
    final controller = ref.read(collectionControllerProvider.notifier);

    if (state.isLoading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage case final String message
        when state.articles.isEmpty) {
      return _CollectionErrorView(
        message: message,
        onRetry: () => _refresh(context, ref),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(context, ref),
      child: state.articles.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 180),
                Icon(Icons.bookmark_border, size: 52),
                SizedBox(height: 12),
                Center(child: Text('还没有收藏文章')),
              ],
            )
          : ListView.builder(
              key: const PageStorageKey('collection-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return ArticleCard(
                  article: article,
                  collected: controller.isCollected(
                    article,
                    fromCollection: true,
                  ),
                  busy: controller.isBusy(article, fromCollection: true),
                  onCollect: () => _remove(context, ref, article),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => articleDetailPageBuilder(article),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final message = await ref
        .read(collectionControllerProvider.notifier)
        .refresh();
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Article article,
  ) async {
    try {
      await ref
          .read(collectionControllerProvider.notifier)
          .toggle(article, fromCollection: true);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 52),
            const SizedBox(height: 16),
            const Text('登录后查看和同步收藏'),
            const SizedBox(height: 16),
            FilledButton(onPressed: onLogin, child: const Text('去登录')),
          ],
        ),
      ),
    );
  }
}

class _CollectionErrorView extends StatelessWidget {
  const _CollectionErrorView({required this.message, required this.onRetry});

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
