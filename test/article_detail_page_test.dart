import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/features/articles/article_detail_page.dart';
import 'package:qjay_flutter_learning/models/article.dart';

void main() {
  const article = Article(
    id: 1,
    title: 'Flutter 文章详情',
    link: 'https://example.com/flutter',
  );

  test('只接受 HTTP 和 HTTPS 文章链接', () {
    expect(parseArticleUri('https://example.com/a')?.host, 'example.com');
    expect(parseArticleUri('http://example.com/a')?.host, 'example.com');
    expect(parseArticleUri('javascript:alert(1)'), isNull);
    expect(parseArticleUri('不是链接'), isNull);
    expect(parseArticleUri(''), isNull);
  });

  testWidgets('详情页显示文章标题并把链接交给网页组件', (tester) async {
    Uri? receivedUri;

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailPage(
          article: article,
          webViewBuilder: (context, uri, onProgress, onError) {
            receivedUri = uri;
            return const Center(child: Text('模拟网页内容'));
          },
        ),
      ),
    );

    expect(find.text('Flutter 文章详情'), findsOneWidget);
    expect(find.text('模拟网页内容'), findsOneWidget);
    expect(receivedUri, Uri.parse(article.link));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('详情页遇到非法链接时显示错误且不创建网页组件', (tester) async {
    var buildCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailPage(
          article: const Article(id: 2, title: '错误链接', link: 'file:///tmp/a'),
          webViewBuilder: (context, uri, onProgress, onError) {
            buildCount += 1;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(find.text('文章链接无效，无法打开'), findsOneWidget);
    expect(buildCount, 0);
  });

  testWidgets('网页加载完成后隐藏进度条', (tester) async {
    late ValueChanged<int> onProgress;

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailPage(
          article: article,
          webViewBuilder: (context, uri, progress, onError) {
            onProgress = progress;
            return const Text('模拟网页内容');
          },
        ),
      ),
    );

    onProgress(60);
    await tester.pump();
    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, 0.6);

    onProgress(100);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('网页主页面加载失败后可以重新创建网页', (tester) async {
    late ValueChanged<String> onError;
    final receivedUris = <Uri>[];
    var buildCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ArticleDetailPage(
          article: article,
          webViewBuilder: (context, uri, onProgress, error) {
            buildCount += 1;
            receivedUris.add(uri);
            onError = error;
            return const Text('模拟网页内容');
          },
        ),
      ),
    );

    onError('网页加载失败：测试错误');
    await tester.pump();

    expect(find.text('网页加载失败：测试错误'), findsOneWidget);
    expect(find.text('重新加载'), findsOneWidget);
    expect(find.text('模拟网页内容'), findsNothing);

    await tester.tap(find.text('重新加载'));
    await tester.pump();

    expect(find.text('模拟网页内容'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(buildCount, 2);
    expect(receivedUris, [Uri.parse(article.link), Uri.parse(article.link)]);
  });
}
