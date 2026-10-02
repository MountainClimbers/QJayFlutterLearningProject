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
}
