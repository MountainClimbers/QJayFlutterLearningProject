# QJay Flutter Learning Project

这是一个面向 iOS 面试准备的 Flutter 学习项目，参考 WanAndroid 项目逐步实现文章列表、文章详情和登录功能。

## 五天学习成果

当前已经完成：

- 请求 WanAndroid 真实文章接口；
- 解析文章标题、作者、分类和时间；
- 展示加载、空数据和失败状态；
- 支持失败重试和下拉刷新；
- 点击文章进入 WebView 详情页；
- 登录、Cookie 持久化和启动状态恢复；
- 登录与注册模式切换，注册成功后自动登录；
- 文章收藏、取消收藏和收藏状态同步；
- 我的收藏列表、下拉刷新和取消收藏；
- 首页侧边栏中的“登录/注册”和“我的收藏”入口；
- 账户面板与退出登录；
- 使用 `go_router` 集中管理页面导航；
- 使用单元测试和 Widget 测试保护主要逻辑。

## 项目技术栈

| 职责 | 技术 | 作用 |
| --- | --- | --- |
| 数据对象 | `freezed` + `json_serializable` | 生成不可变对象、值相等、`copyWith` 和 `fromJson` |
| 网络请求 | `Dio` | 统一配置域名、超时和网络异常 |
| 状态管理 | `Riverpod AsyncNotifier` | 管理加载、成功、错误和刷新状态 |
| 下拉刷新 | `RefreshIndicator` | Flutter 官方 Material 下拉刷新组件 |
| 登录凭证 | `PersistCookieJar` + `flutter_secure_storage` | 管理 Cookie 并写入系统安全存储 |
| 页面导航 | `go_router` | 集中声明命名路由并在页面间传递文章对象 |
| 页面 UI | `ConsumerWidget` + Material 3 | 监听 Provider 并根据 `AsyncValue` 绘制页面 |

主要接口包括文章列表、登录、注册、收藏、取消收藏和我的收藏，具体说明见 [收藏、注册与路由学习笔记](docs/collection-registration-routing.md)。

## 适合初学者的阅读顺序

1. `lib/models/article.dart`：学习 Freezed 工厂构造、JSON 注解和展示属性。
2. `lib/models/article.freezed.dart`：查看工具生成的不可变对象、值相等和 `copyWith`，不要手动修改。
3. `lib/models/article.g.dart`：查看 `json_serializable` 生成的字段映射，不要手动修改。
4. `lib/services/article_service.dart`：学习 Dio、`async/await` 和异常转换。
5. `lib/features/articles/article_list_controller.dart`：学习 Riverpod `AsyncNotifier`。
6. `lib/features/articles/article_card.dart`：学习 StatelessWidget 和常用布局。
7. `lib/features/articles/article_list_page.dart`：学习 ConsumerWidget、AsyncValue 和下拉刷新。
8. `lib/features/auth/auth_controller.dart`：学习登录恢复、登录、退出和并发保护。
9. `lib/features/collections/collection_controller.dart`：学习收藏状态、重复点击保护和账号隔离。
10. `lib/router/app_router.dart`：学习 `go_router` 命名路由和参数校验。
11. `test/app_router_test.dart`：查看详情、账号、收藏和侧边栏的路由测试。
12. `lib/main.dart`：查看 `ProviderScope`、`MaterialApp.router` 和主题。

修改带有 `@Freezed()` 的模型后，重新生成 Freezed 和 JSON 代码：

```bash
dart run build_runner build
```

## 五天学习安排

| 天数 | 目标 | 重点知识 | 状态 |
| --- | --- | --- | --- |
| 第 1 天 | 文章列表 | HTTP、JSON、ListView、加载与错误状态 | 已完成 |
| 第 2 天 | 文章详情 | 路由跳转、参数传递、WebView | 已完成 |
| 第 3 天 | 登录页面 | 表单、输入校验、密码框 | 已完成 |
| 第 4 天 | 接入登录接口 | POST、Cookie、登录状态 | 已完成 |
| 第 5 天 | 串联与复习 | 页面导航、状态共享、退出登录、面试题整理 | 已完成 |

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
