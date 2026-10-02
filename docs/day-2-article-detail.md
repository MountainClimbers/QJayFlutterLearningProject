# 第 2 天：文章详情

今天完成从文章列表进入文章详情页，重点学习路由跳转、参数传递和 WebView。

## 完成的功能

- 点击整张文章卡片进入详情页。
- 通过详情页构造函数传递完整的 `Article` 对象。
- 使用 `webview_flutter` 加载文章的 HTTP 或 HTTPS 链接。
- 网页加载期间显示顶部进度条。
- 网页主页面加载失败时显示错误信息和“重新加载”按钮。
- 链接为空、格式错误或使用其他协议时显示安全的错误页面。

## 推荐阅读顺序

1. `lib/features/articles/article_card.dart`：观察 `InkWell` 如何把普通卡片变成可点击组件。
2. `lib/features/articles/article_list_page.dart`：观察 `Navigator.push`、`MaterialPageRoute` 和 `Article` 参数传递。
3. `lib/features/articles/article_detail_page.dart`：观察 URL 校验、`WebViewController`、加载进度和错误状态。
4. `test/article_list_page_test.dart`：观察如何注入测试详情页，验证路由收到同一个文章对象。
5. `test/article_detail_page_test.dart`：观察如何隔离原生 WebView，测试 Dart 和 Flutter 页面行为。

## 核心调用链

```text
ArticleCard.onTap
  → Navigator.push
  → ArticleDetailPage(article: article)
  → parseArticleUri(article.link)
  → WebViewController.loadRequest(uri)
```

## 为什么传递完整 Article

详情页当前只使用标题和链接，但传递完整对象后，未来增加作者、收藏状态或分享信息时，不需要修改路由的参数列表。`Article` 是不可变对象，页面之间传递同一个实例也更容易理解和测试。

## 自己动手复习

1. 在详情页 AppBar 增加刷新按钮，并调用网页控制器重新加载。
2. 增加后退按钮：网页有历史记录时先返回网页上一页，否则退出 Flutter 页面。
3. 思考为什么 Widget 测试使用假的网页组件，而 iOS 构建负责验证真实插件集成。

## 验证命令

```bash
flutter test
flutter analyze
flutter build ios --simulator --no-codesign
```
