import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/article.dart';
import '../../models/login_user.dart';
import '../../router/route_names.dart';
import '../../services/collection_service.dart';
import '../auth/auth_controller.dart';
import '../collections/collection_controller.dart';
import '../shared/paging_views.dart';
import 'article_card.dart';
import 'article_list_controller.dart';
import 'article_list_state.dart';

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
    final authState = ref.watch(authControllerProvider);
    final currentUser = switch (authState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isRestoringSession = authState is AsyncLoading<LoginUser?>;

    return Scaffold(
      drawer: const _HomeDrawer(),
      appBar: AppBar(
        title: const Text('文章列表'),
        centerTitle: false,
        actions: [
          if (isRestoringSession)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox.square(
                key: ValueKey('auth-restore-progress'),
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (currentUser == null)
            IconButton(
              tooltip: '登录',
              onPressed: () => _openLogin(context),
              icon: const Icon(Icons.login),
            )
          else
            _CurrentUserView(
              user: currentUser,
              onPressed: () => _openAccount(context, currentUser),
            ),
        ],
      ),
      body: _ArticleList(
        state: articles,
        articleDetailPageBuilder: articleDetailPageBuilder,
        onLoginRequired: () => _openLogin(context),
      ),
    );
  }

  Future<void> _openLogin(BuildContext context) async {
    final customBuilder = loginPageBuilder;
    late final LoginUser? user;
    if (customBuilder != null) {
      user = await Navigator.of(context)
          .push<LoginUser>(MaterialPageRoute(builder: (_) => customBuilder()));
    } else {
      user = await context.pushNamed<LoginUser>(accountRouteName);
    }
    if (user != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('登录成功：${user.displayName}')));
    }
  }

  Future<void> _openAccount(BuildContext context, LoginUser currentUser) async {
    final feedback = await showModalBottomSheet<_LogoutFeedback>(
      context: context,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _AccountSheet(user: currentUser),
    );
    if (feedback != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(feedback.message)));
    }
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            ListTile(
              key: const ValueKey('drawer-account'),
              leading: const Icon(Icons.person_outline),
              title: const Text('登录/注册'),
              onTap: () => _open(context, accountRouteName),
            ),
            ListTile(
              key: const ValueKey('drawer-collections'),
              leading: const Icon(Icons.bookmarks_outlined),
              title: const Text('我的收藏'),
              onTap: () => _open(context, collectionsRouteName),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String routeName) {
    Navigator.of(context).pop();
    context.pushNamed(routeName);
  }
}

class _LogoutFeedback {
  const _LogoutFeedback(this.message);

  final String message;
}

class _CurrentUserView extends StatelessWidget {
  const _CurrentUserView({required this.user, required this.onPressed});

  final LoginUser user;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '已登录：${user.displayName}',
      child: TextButton.icon(
        key: const ValueKey('account-action'),
        onPressed: onPressed,
        icon: const Icon(Icons.account_circle_outlined),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _AccountSheet extends ConsumerWidget {
  const _AccountSheet({required this.user});

  final LoginUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoggingOut = authState is AsyncLoading<LoginUser?>;

    return PopScope(
      canPop: !isLoggingOut,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    key: const ValueKey('account-close-button'),
                    tooltip: '关闭账户面板',
                    onPressed: isLoggingOut
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                const Icon(Icons.account_circle, size: 64),
                const SizedBox(height: 12),
                Text(
                  '账户信息',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(user.displayName),
                if (user.username.isNotEmpty &&
                    user.username != user.displayName)
                  Text(
                    user.username,
                    key: const ValueKey('account-username'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    key: const ValueKey('logout-button'),
                    onPressed: isLoggingOut
                        ? null
                        : () => _logout(context, ref),
                    icon: isLoggingOut
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(isLoggingOut ? '正在退出' : '退出登录'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    late final _LogoutFeedback feedback;
    try {
      await ref.read(authControllerProvider.notifier).logout();
      feedback = const _LogoutFeedback('已退出登录');
    } catch (error) {
      feedback = _LogoutFeedback('登录状态已重置：$error');
    }
    if (context.mounted) Navigator.of(context).pop(feedback);
  }
}

class _ArticleList extends ConsumerWidget {
  const _ArticleList({
    required this.state,
    required this.articleDetailPageBuilder,
    required this.onLoginRequired,
  });

  final ArticleListState state;
  final ArticleDetailPageBuilder? articleDetailPageBuilder;
  final Future<void> Function() onLoginRequired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(collectionControllerProvider);
    final collectionController = ref.read(
      collectionControllerProvider.notifier,
    );
    final articleController = ref.read(articleListControllerProvider.notifier);
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
      child: PagedListView<int, Article>(
        key: const PageStorageKey('article-list'),
        state: state.pagingState,
        fetchNextPage: articleController.loadNextPage,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        builderDelegate: PagedChildBuilderDelegate<Article>(
          invisibleItemsThreshold: 3,
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          firstPageErrorIndicatorBuilder: (_) => PagingFirstPageErrorView(
            message: state.error?.toString() ?? '文章加载失败',
            onRetry: articleController.loadNextPage,
          ),
          noItemsFoundIndicatorBuilder: (_) => const PagingEmptyView(
            icon: Icons.article_outlined,
            message: '暂时没有文章，下拉刷新试试',
          ),
          newPageProgressIndicatorBuilder: (_) => const PagingProgressView(),
          newPageErrorIndicatorBuilder: (_) =>
              PagingRetryView(onRetry: articleController.loadNextPage),
          noMoreItemsIndicatorBuilder: (_) => const PagingEndView(),
          itemBuilder: (context, article, index) {
            return ArticleCard(
              article: article,
              collected: collectionController.isCollected(article),
              busy: collectionController.isBusy(article),
              onCollect: () async {
                final user = switch (ref.read(authControllerProvider)) {
                  AsyncData(:final value) => value,
                  _ => null,
                };
                if (user == null) {
                  await onLoginRequired();
                  return;
                }
                try {
                  await collectionController.toggle(article);
                } catch (error) {
                  if (error is CollectionAuthenticationException) {
                    await onLoginRequired();
                    return;
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
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
}
