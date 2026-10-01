# QJay Flutter Learning Project

这是一个面向 iOS 面试准备的 Flutter 学习项目，参考 WanAndroid 项目逐步实现文章列表、文章详情和登录功能。

## 第一天：文章列表

当前已经完成：

- 请求 WanAndroid 真实文章接口；
- 解析文章标题、作者、分类和时间；
- 展示加载、空数据和失败状态；
- 支持失败重试和下拉刷新；
- 使用单元测试和 Widget 测试保护主要逻辑。

接口地址：`https://www.wanandroid.com/article/list/0/json`

## 适合初学者的阅读顺序

1. `lib/models/article.dart`：学习如何把 JSON 变成 Dart 对象。
2. `lib/services/article_service.dart`：学习 HTTP 请求、`async/await` 和异常处理。
3. `lib/features/articles/article_card.dart`：学习 StatelessWidget 和常用布局。
4. `lib/features/articles/article_list_page.dart`：学习 StatefulWidget、页面状态、刷新和重试。
5. `lib/main.dart`：查看应用入口、主题和依赖注入。

## 五天学习安排

| 天数 | 目标 | 重点知识 |
| --- | --- | --- |
| 第 1 天 | 文章列表 | HTTP、JSON、ListView、加载与错误状态 |
| 第 2 天 | 文章详情 | 路由跳转、参数传递、WebView |
| 第 3 天 | 登录页面 | 表单、输入校验、密码框 |
| 第 4 天 | 接入登录接口 | POST、Cookie、登录状态 |
| 第 5 天 | 串联与复习 | 页面导航、状态共享、面试题整理 |

## 命令行运行

环境：Flutter 3.47.5、Dart 3.13.4。

```bash
cd /Users/cuilu/Desktop/qjay/QJayFlutterLearningProject
flutter pub get
flutter run
```

运行测试与静态检查：

```bash
flutter test
flutter analyze
```

## 使用 Xcode 运行

1. 先启动 iOS Simulator，或在 Xcode 的 **Window → Devices and Simulators** 中创建模拟器。
2. 在终端进入项目并执行 `flutter pub get`。
3. 使用下面的命令打开工作区：

   ```bash
   open ios/Runner.xcworkspace
   ```

4. 在 Xcode 顶部选择 **Runner** Scheme，再选择一个 iPhone 模拟器。
5. 点击左上角运行按钮，或按 `Command + R`。

使用模拟器不需要配置开发者证书。若要运行到真机，请打开 **Runner → Signing & Capabilities**，选择自己的 Team，并确保 Bundle Identifier 唯一。
