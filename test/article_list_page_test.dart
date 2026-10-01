import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/articles/article_list_page.dart';
import 'package:qjay_flutter_learning/models/article.dart';
import 'package:qjay_flutter_learning/services/article_service.dart';

void main() {
  const article = Article(
    id: 1,
    title: 'Flutter 面试准备',
    link: 'https://example.com/1',
    author: 'MountainClimbers',
    chapter: '移动开发 / Flutter',
    date: '今天',
  );

  testWidgets('加载成功后显示文章的主要信息', (tester) async {
    // 如果页面没有真正使用仓库返回的数据，这个测试就会失败。
    final repository = _SequenceRepository([
      () async => [article],
    ]);

    await tester.pumpWidget(_testApp(repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(find.text('MountainClimbers'), findsOneWidget);
    expect(find.text('移动开发 / Flutter'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
  });

  testWidgets('加载失败后点击重试可以恢复文章列表', (tester) async {
    // 如果重试按钮没有再次调用仓库，这个测试就会失败。
    final repository = _SequenceRepository([
      () => Future.error(const ArticleLoadException('测试网络断开')),
      () async => [article],
    ]);

    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('测试网络断开'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter 面试准备'), findsOneWidget);
    expect(repository.callCount, 2);
  });
}

Widget _testApp(ArticleRepository repository) {
  return MaterialApp(home: ArticleListPage(repository: repository));
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
