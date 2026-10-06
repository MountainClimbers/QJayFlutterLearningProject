import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/articles/article_detail_page.dart';
import '../features/articles/article_list_page.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/collections/collection_page.dart';
import '../models/article.dart';
import 'route_names.dart';

GoRouter createAppRouter({String initialLocation = homeRoutePath}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: homeRoutePath,
        name: homeRouteName,
        builder: (context, state) => const ArticleListPage(),
      ),
      GoRoute(
        path: articleDetailRoutePath,
        name: articleDetailRouteName,
        builder: (context, state) {
          final article = state.extra;
          if (article is! Article) return const _RouteArgumentErrorPage();
          return ArticleDetailPage(article: article);
        },
      ),
      GoRoute(
        path: accountRoutePath,
        name: accountRouteName,
        builder: (context, state) => const _AccountRoutePage(),
      ),
      GoRoute(
        path: collectionsRoutePath,
        name: collectionsRouteName,
        builder: (context, state) => const CollectionPage(),
      ),
    ],
  );
}

final appRouter = createAppRouter();

class _AccountRoutePage extends ConsumerWidget {
  const _AccountRoutePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoginPage(
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
  }
}

class _RouteArgumentErrorPage extends StatelessWidget {
  const _RouteArgumentErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面参数错误')),
      body: const Center(
        child: Padding(padding: EdgeInsets.all(32), child: Text('没有找到要打开的文章')),
      ),
    );
  }
}
