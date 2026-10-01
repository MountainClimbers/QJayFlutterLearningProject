# 文章列表功能设计

## 目标

第一天交付一个能够独立运行的 Flutter iOS 应用：首页从 WanAndroid 公开接口获取文章，并完整展示加载、成功、空数据和失败重试状态。代码面向 Flutter 初学者，文件职责单一并包含必要的中文注释。

## 范围

- 使用 `https://www.wanandroid.com/article/list/0/json` 获取第一页文章。
- 展示文章标题、作者、分类和时间。
- 支持下拉刷新；请求失败时展示错误信息和重试按钮。
- 为网络解析和页面主要状态编写自动化测试。
- 本次不实现文章详情、收藏、分页和登录；这些功能留给后续学习日程。

## 结构

- `lib/models/article.dart`：把接口 JSON 转换为页面使用的文章对象。
- `lib/services/article_service.dart`：封装 HTTP 请求、接口业务错误和 JSON 解析。
- `lib/features/articles/article_list_page.dart`：管理加载与刷新状态，组合页面。
- `lib/features/articles/article_card.dart`：绘制单篇文章。
- `lib/main.dart`：创建服务并启动应用。

页面通过构造参数接收抽象的 `ArticleRepository`。正式运行时使用网络实现，Widget 测试时使用内存假实现，因此测试无需访问外网。

## 数据流和异常处理

页面首次创建时调用 `fetchArticles()`。成功后替换文章列表；失败后保存可读错误文本。下拉刷新复用同一入口，已有内容在刷新期间保留。用户点击重试后重新进入加载流程。接口返回非 2xx 状态、非法 JSON 或 WanAndroid 的非零 `errorCode` 时都按失败处理。

## 验证标准

- 模型能正确处理 `author` 为空而 `shareUser` 有值的文章。
- 页面能够显示真实字段，并能从错误状态触发重试。
- `flutter analyze` 无错误。
- `flutter test` 全部通过。
- iOS 模拟器无签名构建成功。
