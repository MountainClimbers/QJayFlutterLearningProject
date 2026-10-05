# 第 5 天：功能串联与面试复习

## 今天完成的功能

- 登录后点击首页用户名可以打开账户面板。
- 账户面板可以调用玩安卓退出接口并清理持久化 Cookie。
- 退出成功后 Riverpod 全局状态变为未登录，首页自动恢复登录入口。
- 退出失败时保留原用户并显示原因，避免页面状态与本地凭证不一致。
- 完整流程测试覆盖文章列表、详情导航、状态共享和退出登录。

## 项目完整流程

应用启动后，`ArticleListController` 请求文章列表，`AuthController` 同时从安全存储恢复登录状态。文章列表根据 `AsyncValue` 展示加载、数据或错误页面。

点击文章时，列表页通过 `Navigator` 和 `MaterialPageRoute` 把完整的 `Article` 对象传给详情页。详情页使用 WebView 打开经过校验的 HTTP 或 HTTPS 地址，展示加载进度，并处理加载失败和重试。

点击登录入口时，登录页先校验表单，再调用 `AuthController.login`。控制器通过 `AuthRepository` 发起请求，成功后保存用户状态。因为列表页也监听同一个 Provider，所以返回列表时会自动显示用户名。

点击用户名会打开账户面板。退出成功后，服务层清理 Cookie，控制器把状态改为未登录，账户面板关闭，首页自动恢复登录按钮。

## 各层职责

- Model：`Article` 和 `LoginUser` 使用 `freezed` 与 `json_serializable`，负责不可变数据、值相等、`copyWith` 和 JSON 转换。
- Service：`ArticleService` 与 `AuthService` 使用 Dio 请求接口，并把底层错误转换成页面可理解的异常。
- State：Riverpod `AsyncNotifier` 管理异步状态、刷新、登录、恢复和退出。
- UI：Widget 读取 `AsyncValue` 并绘制页面，不直接发送网络请求。
- Storage：`PersistCookieJar` 管理 Cookie 规则，`flutter_secure_storage` 把认证数据保存到系统安全存储。

## 常见面试问题与口述答案

### 1. 为什么 ArticleListPage 使用 ConsumerWidget？

因为文章列表和登录用户都由 Riverpod 管理，ConsumerWidget 可以通过 `ref.watch` 监听 Provider。状态变化以后页面会自动重建，不需要自己维护加载布尔值，也不需要手动调用 `setState`。

### 2. AsyncNotifier 在项目里解决了什么问题？

它把异步请求和页面状态放在一个地方管理。`AsyncValue` 自带加载、成功和失败三种状态，页面只需要根据状态绘制不同内容。刷新、登录和退出这些会改变状态的操作也集中放在 Notifier 中。

### 3. 为什么网络请求不直接写在页面里？

页面只负责展示和交互，网络请求交给 Repository。这样接口变化时不用修改 Widget，测试时也可以注入假 Repository，不需要真实网络，职责更清晰。

### 4. Freezed 和 json_serializable 分别负责什么？

Freezed 负责生成不可变对象、值相等、`copyWith` 和调试输出；json_serializable 负责生成 `fromJson` 字段映射。组合使用后可以减少重复代码，同时保留明确的数据类型。

### 5. 下拉刷新失败为什么保留原列表？

刷新属于增量操作，用户已经有可阅读的数据。如果失败就清空页面，体验会比较差。因此刷新失败时保留原来的 `AsyncData`，只用 SnackBar 提示；首次加载失败才显示完整错误页。

### 6. 登录状态为什么可以跨页面共享？

`authControllerProvider` 放在应用最外层的 `ProviderScope` 中。登录页修改的是同一个 Provider，文章列表监听的也是它，所以登录、恢复或退出后，相关页面会自动收到最新状态。

### 7. 登录 Cookie 为什么不能放普通偏好设置？

认证 Cookie 属于敏感数据。项目使用系统安全存储，在 iOS 上对应 Keychain，在 Android 上由安全存储插件使用平台加密能力，避免把认证令牌直接以明文文件保存。

### 8. 如何避免旧登录请求覆盖新状态？

控制器为登录操作维护递增序号，只有最后开始的请求可以写入状态。启动恢复完成前不会开始登录，首页在恢复期间也不开放登录入口，减少异步竞态。

### 9. 页面之间如何传递文章数据？

列表页创建 `MaterialPageRoute` 时把 `Article` 对象传给详情页构造方法。参数是明确类型，详情页不需要再次查找全局变量，也不依赖字符串形式的路由参数。

### 10. 为什么当前项目没有引入 go_router？

项目只有列表、详情和登录几个简单页面，Flutter 自带 Navigator 已经能清楚完成需求。路由规模扩大、需要深层链接或登录重定向时，再引入 go_router 更合适。

### 11. 项目如何测试网络层？

测试给 Dio 注入假的 `HttpClientAdapter`，检查请求方法、地址和参数，再返回准备好的 JSON 或异常。这样测试稳定、速度快，也能覆盖业务错误、HTTP 错误和解析错误。

### 12. 项目如何测试完整用户流程？

Widget 测试通过 Provider override 注入假文章仓库和假登录仓库，然后模拟点击文章、返回、打开账户面板和退出。测试既验证导航，也验证跨页面共享状态是否正确更新。

## 五天复习顺序

1. 从 `Article` 开始，理解 Freezed 和 JSON 映射。
2. 阅读 `ArticleService`，理解 Dio 请求和异常转换。
3. 阅读 `ArticleListController`，理解 Riverpod 异步状态。
4. 阅读 `ArticleListPage`，理解列表、刷新和页面导航。
5. 阅读 `ArticleDetailPage`，理解 WebView 生命周期和错误处理。
6. 阅读登录页、`AuthService` 与 `AuthController`，理解表单、Cookie 和全局状态。
7. 最后阅读 `app_flow_test.dart`，把所有层串在一起复习。
