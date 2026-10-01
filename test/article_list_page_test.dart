import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_controller.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_page.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';

void main() {
  const firstArticle = Article(
    id: 1,
    title: 'Flutter 面试准备',
    link: 'https://example.com/1',
    author: 'MountainClimbers',
    superChapterName: '移动开发',
    chapterName: 'Flutter',
    niceDate: '今天',
  );
  const refreshedArticle = Article(
    id: 2,
    title: 'Riverpod 实战',
    link: 'https://example.com/2',
    author: '小明',
  );

  testWidgets('Riverpod 加载成功后显示文章的主要信息', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(_testApp(repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(find.text('MountainClimbers'), findsOneWidget);
    expect(find.text('移动开发 / Flutter'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
  });

  testWidgets('Riverpod 错误状态点击重试后恢复文章列表', (tester) async {
    final repository = _SequenceRepository([
      () => Future.error(const ArticleLoadException('测试网络断开')),
      () async => [firstArticle],
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('测试网络断开'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(repository.callCount, 2);
  });

  testWidgets('下拉刷新通过 AsyncNotifier 重新获取文章', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
      () async => [refreshedArticle],
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text('Riverpod 实战'), findsOneWidget);
    expect(find.text('Flutter 面试准备'), findsNothing);
    expect(repository.callCount, 2);
  });

  testWidgets('下拉刷新失败时保留原列表并显示轻量提示', (tester) async {
    final repository = _SequenceRepository([
      () async => [firstArticle],
      () => Future.error(const ArticleLoadException('测试刷新失败')),
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(find.text('刷新失败：测试刷新失败'), findsOneWidget);
    expect(repository.callCount, 2);
  });
}

Widget _testApp(ArticleRepository repository) {
  return ProviderScope(
    overrides: [articleRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: ArticleListPage()),
  );
}

class _SequenceRepository implements ArticleRepository {
  _SequenceRepository(this.responses);

  final List<Future<List<Article>> Function()> responses;
  int callCount = 0;

  @override
  Future<List<Article>> fetchArticles() {
    final index = callCount++;
    return responses[index]();
  }
}
