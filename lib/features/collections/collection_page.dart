import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/article.dart';
import '../../models/login_user.dart';
import '../../router/route_names.dart';
import '../articles/article_card.dart';
import '../auth/auth_controller.dart';
import '../shared/paging_views.dart';
import 'collection_controller.dart';

typedef CollectionArticleDetailPageBuilder = Widget Function(Article article);
typedef CollectionLoginPageBuilder = Widget Function();

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({
    super.key,
    this.articleDetailPageBuilder,
    this.loginPageBuilder,
  });

  final CollectionArticleDetailPageBuilder? articleDetailPageBuilder;
  final CollectionLoginPageBuilder? loginPageBuilder;

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAfterLocalCollection();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          onLogin: () => _openLogin(context),
        ),
        _ => _CollectionBody(
          articleDetailPageBuilder: widget.articleDetailPageBuilder,
        ),
      },
    );
  }

  Future<void> _openLogin(BuildContext context) async {
    final customBuilder = widget.loginPageBuilder;
    if (customBuilder != null) {
      await Navigator.of(context)
          .push<LoginUser>(MaterialPageRoute(builder: (_) => customBuilder()));
    } else {
      await context.pushNamed<LoginUser>(accountRouteName);
    }
  }

  Future<void> _refreshAfterLocalCollection() async {
    final message = await ref
        .read(collectionControllerProvider.notifier)
        .refreshIfNeeded();
    if (message != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _CollectionBody extends ConsumerWidget {
  const _CollectionBody({required this.articleDetailPageBuilder});

  final CollectionArticleDetailPageBuilder? articleDetailPageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectionControllerProvider);
    final controller = ref.read(collectionControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => _refresh(context, ref),
      child: PagedListView<int, Article>(
        key: const PageStorageKey('collection-list'),
        state: state.pagingState,
        fetchNextPage: controller.loadNextPage,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        builderDelegate: PagedChildBuilderDelegate<Article>(
          invisibleItemsThreshold: 3,
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          firstPageErrorIndicatorBuilder: (_) => PagingFirstPageErrorView(
            message: state.errorMessage ?? '收藏列表加载失败',
            onRetry: controller.loadNextPage,
          ),
          noItemsFoundIndicatorBuilder: (_) => const PagingEmptyView(
            icon: Icons.bookmark_border,
            message: '还没有收藏文章',
          ),
          newPageProgressIndicatorBuilder: (_) => const PagingProgressView(),
          newPageErrorIndicatorBuilder: (_) =>
              PagingRetryView(onRetry: controller.loadNextPage),
          noMoreItemsIndicatorBuilder: (_) => const PagingEndView(),
          itemBuilder: (context, article, index) {
            return ArticleCard(
              article: article,
              collected: controller.isCollected(article, fromCollection: true),
              busy: controller.isBusy(article, fromCollection: true),
              onCollect: () => _remove(context, ref, article),
              onTap: () {
                final customBuilder = articleDetailPageBuilder;
                if (customBuilder != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => customBuilder(article),
                    ),
                  );
                } else {
                  context.pushNamed(articleDetailRouteName, extra: article);
                }
              },
            );
          },
        ),
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
