# 收藏、注册与路由升级实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为文章列表增加登录态收藏，补齐注册、我的收藏、侧边栏，并用 go_router 统一四个页面的导航。

**Architecture:** 一个持久化会话客户端共享 Dio 与 CookieJar，认证、文章和收藏 Repository 各自负责接口边界。Riverpod AsyncNotifier 管理全局用户、文章与收藏状态，UI 只负责展示和触发动作。go_router 集中声明命名路由，文章详情通过 extra 传递强类型 Article。

**Tech Stack:** Flutter、Dart、go_router、Riverpod、Dio、PersistCookieJar、flutter_secure_storage、Freezed、json_serializable、flutter_test。

## Global Constraints

- 所有 Git 提交信息使用中文。
- Git 作者必须为 `MountainClimbers <hua138ng@yeah.net>`。
- 收藏、文章与认证请求必须共享同一个持久化 CookieJar。
- 登录、注册和退出必须串行执行。
- 收藏写请求成功后才能改变已确认状态。
- 页面导航统一使用 go_router。
- 不实现站外文章录入、编辑收藏和加载更多分页。

---

### Task 1: 共享会话客户端

**Files:**
- Create: `lib/services/session_client.dart`
- Modify: `lib/services/auth_service.dart`
- Modify: `lib/features/auth/auth_controller.dart`
- Modify: `lib/features/articles/article_list_controller.dart`
- Test: `test/auth_service_test.dart`
- Test: `test/article_list_page_test.dart`

**Interfaces:**
- Produces: `Future<WanAndroidSessionClient> createPersistentSessionClient()`。
- Produces: `sessionClientProvider`，认证、文章和收藏 Provider 从中取得同一个 Dio 与 CookieJar。

- [x] **Step 1: 编写共享 Cookie 行为测试**

在认证和文章测试中注入同一个内存 CookieJar，先保存认证 Cookie，再断言文章请求携带该 Cookie；该测试应因文章 Repository 尚未使用共享客户端而失败。

- [x] **Step 2: 运行测试确认失败**

Run: `flutter test test/auth_service_test.dart test/article_service_test.dart`
Expected: FAIL，文章请求没有共享认证 Cookie。

- [x] **Step 3: 实现会话客户端并调整 Provider**

```dart
class WanAndroidSessionClient {
  const WanAndroidSessionClient({required this.dio, required this.cookieJar});
  final Dio dio;
  final CookieJar cookieJar;
}
```

由 `sessionClientProvider` 异步创建安全 CookieJar，给 Dio 安装一个 CookieManager。`AuthService`、`ArticleService` 构造时接收该 Dio；测试仍可覆盖 Repository Provider。

- [x] **Step 4: 运行认证与文章测试确认通过**

Run: `flutter test test/auth_service_test.dart test/article_service_test.dart test/article_list_page_test.dart`
Expected: PASS。

- [x] **Step 5: 中文提交**

```bash
git commit -m "架构：共享认证与内容请求会话"
```

### Task 2: 文章收藏字段与收藏服务

**Files:**
- Modify: `lib/models/article.dart`
- Modify generated: `lib/models/article.freezed.dart`
- Modify generated: `lib/models/article.g.dart`
- Create: `lib/services/collection_service.dart`
- Test: `test/article_test.dart`
- Create: `test/collection_service_test.dart`

**Interfaces:**
- Produces: `Article.collected`、`Article.originId`。
- Produces: `CollectionRepository.fetchCollections/collect/uncollect/removeCollection`。

- [x] **Step 1: 编写模型和接口失败测试**

```dart
expect(Article.fromJson({'id': 901, 'originId': 42, 'collect': true,
  'title': '收藏文章', 'link': 'https://example.com'}).originId, 42);
```

服务测试分别断言：

- GET `/lg/collect/list/0/json`
- POST `/lg/collect/42/json`
- POST `/lg/uncollect_originId/42/json`
- POST `/lg/uncollect/901/json`，表单为 `originId=42`

- [x] **Step 2: 运行测试确认失败**

Run: `flutter test test/article_test.dart test/collection_service_test.dart`
Expected: FAIL，字段和 CollectionService 尚不存在。

- [x] **Step 3: 实现最小模型与服务**

```dart
abstract interface class CollectionRepository {
  Future<List<Article>> fetchCollections();
  Future<void> collect(int articleId);
  Future<void> uncollect(int articleId);
  Future<void> removeCollection(int recordId, int originId);
}
```

所有响应统一检查 `errorCode`，并把业务、HTTP、连接和解析错误转换为 `CollectionException`。

- [x] **Step 4: 生成代码并确认测试通过**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `flutter test test/article_test.dart test/collection_service_test.dart`
Expected: PASS。

- [x] **Step 5: 中文提交**

```bash
git commit -m "功能：增加文章收藏模型与接口"
```

### Task 3: 注册接口与全局认证状态

**Files:**
- Modify: `lib/services/auth_service.dart`
- Modify: `lib/features/auth/auth_controller.dart`
- Test: `test/auth_service_test.dart`
- Test: `test/auth_controller_test.dart`

**Interfaces:**
- Produces: `AuthRepository.register({username, password, repeatedPassword})`。
- Produces: `AuthController.register(...) -> Future<LoginUser>`。

- [x] **Step 1: 编写注册失败测试**

测试注册提交 `/user/register` 的三个表单字段；注册成功后继续请求 `/user/login` 并返回登录用户；控制器注册与退出按调用顺序串行。

- [x] **Step 2: 运行测试确认失败**

Run: `flutter test test/auth_service_test.dart test/auth_controller_test.dart`
Expected: FAIL，register 方法不存在。

- [x] **Step 3: 实现注册后登录**

```dart
Future<LoginUser> register({
  required String username,
  required String password,
  required String repeatedPassword,
});
```

服务先检查注册响应，再调用现有 login 建立会话。控制器把整个注册流程放入 `_runSerialized`，成功写入 `AsyncData(user)`，失败写入 `AsyncError`。

- [x] **Step 4: 运行测试确认通过**

Run: `flutter test test/auth_service_test.dart test/auth_controller_test.dart`
Expected: PASS。

- [x] **Step 5: 中文提交**

```bash
git commit -m "功能：实现账号注册并自动登录"
```

### Task 4: 登录注册页面切换

**Files:**
- Modify: `lib/features/auth/login_page.dart`
- Test: `test/login_page_test.dart`

**Interfaces:**
- Consumes: `AuthController.login` 与 `AuthController.register`。
- Produces: 登录/注册共用页面，成功时都返回 `LoginUser`。

- [x] **Step 1: 编写页面失败测试**

测试“没有账号，去注册”切换后出现确认密码；两次密码不一致不调用注册；有效注册提交三项凭证；“已有账号，去登录”恢复登录模式。

- [x] **Step 2: 运行测试确认失败**

Run: `flutter test test/login_page_test.dart`
Expected: FAIL，页面没有注册模式。

- [x] **Step 3: 实现注册表单**

新增 `RegistrationCredentials` 和 `RegisterSubmitCallback`。注册模式验证确认密码，提交中禁用全部输入与模式切换，异常继续显示服务端消息。

- [x] **Step 4: 运行测试确认通过**

Run: `flutter test test/login_page_test.dart`
Expected: PASS。

- [x] **Step 5: 中文提交**

```bash
git commit -m "功能：登录页面支持账号注册"
```

### Task 5: Riverpod 收藏状态与文章卡片

**Files:**
- Create: `lib/features/collections/collection_controller.dart`
- Modify: `lib/features/articles/article_card.dart`
- Modify: `lib/features/articles/article_list_page.dart`
- Create: `test/collection_controller_test.dart`
- Modify: `test/article_list_page_test.dart`

**Interfaces:**
- Produces: `collectionControllerProvider`。
- Produces: `isCollected`、`isBusy`、`toggle`、`refresh`。
- Consumes: `authControllerProvider` 与 `CollectionRepository`。

- [x] **Step 1: 编写控制器失败测试**

覆盖登录后加载收藏、收藏/取消收藏路径、失败保持状态、同一文章重复点击只发送一次请求、账号变化清空旧状态。

- [x] **Step 2: 编写文章卡片失败测试**

覆盖收藏按钮、忙碌进度、未登录点击进入账号页、已登录点击调用 toggle、失败显示 SnackBar。

- [x] **Step 3: 运行测试确认失败**

Run: `flutter test test/collection_controller_test.dart test/article_list_page_test.dart`
Expected: FAIL，收藏控制器和按钮尚不存在。

- [x] **Step 4: 实现收藏状态和卡片连接**

控制器以 `article:{originId}` 或 `record:{recordId}` 为同步键；每次异步完成前核对当前用户身份。ArticleCard 只接收 `collected`、`busy` 和 `onCollect`，网络与导航由列表页处理。

- [x] **Step 5: 运行测试确认通过**

Run: `flutter test test/collection_controller_test.dart test/article_list_page_test.dart`
Expected: PASS。

- [x] **Step 6: 中文提交**

```bash
git commit -m "功能：文章列表支持登录态收藏"
```

### Task 6: 我的收藏页面

**Files:**
- Create: `lib/features/collections/collection_page.dart`
- Create: `test/collection_page_test.dart`

**Interfaces:**
- Consumes: `collectionControllerProvider`、`authControllerProvider`、文章详情导航。
- Produces: 登录提示、收藏列表、刷新、取消收藏和详情入口。

- [x] **Step 1: 编写页面失败测试**

覆盖未登录提示和去登录、加载/空/错误状态、展示收藏数据、取消后移除、刷新失败保留列表。

- [x] **Step 2: 运行测试确认失败**

Run: `flutter test test/collection_page_test.dart`
Expected: FAIL，CollectionPage 尚不存在。

- [x] **Step 3: 实现收藏页面**

页面监听认证和收藏 AsyncValue；列表复用 ArticleCard；从收藏页取消时传 `fromCollection: true`，成功后从当前列表删除记录。

- [x] **Step 4: 运行测试确认通过**

Run: `flutter test test/collection_page_test.dart`
Expected: PASS。

- [x] **Step 5: 中文提交**

```bash
git commit -m "功能：增加我的收藏列表页面"
```

### Task 7: go_router 与首页侧边栏

**Files:**
- Modify: `pubspec.yaml`
- Modify generated: `pubspec.lock`
- Create: `lib/router/app_router.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/articles/article_list_page.dart`
- Modify: `lib/features/articles/article_detail_page.dart` only if route construction requires a public error view.
- Create: `test/app_router_test.dart`
- Modify: `test/article_list_page_test.dart`
- Modify: `test/app_flow_test.dart`

**Interfaces:**
- Produces named routes: `home`、`articleDetail`、`account`、`collections`。
- Produces paths: `/`、`/article`、`/account`、`/collections`。

- [x] **Step 1: 添加依赖并编写路由失败测试**

Run: `flutter pub add go_router`

测试 `MaterialApp.router` 能从首页打开详情、账号和收藏；`/article` 缺少合法 Article extra 时显示参数错误页。

- [x] **Step 2: 运行测试确认失败**

Run: `flutter test test/app_router_test.dart test/app_flow_test.dart`
Expected: FAIL，路由配置和 Drawer 尚不存在。

- [x] **Step 3: 实现命名路由与 Drawer**

```dart
final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', name: 'home', builder: (_, _) => const ArticleListPage()),
    GoRoute(path: '/article', name: 'articleDetail', builder: buildArticleRoute),
    GoRoute(path: '/account', name: 'account', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/collections', name: 'collections', builder: (_, _) => const CollectionPage()),
  ],
);
```

应用改为 `MaterialApp.router(routerConfig: appRouter)`。Drawer 只包含“登录/注册”和“我的收藏”，先关闭 Drawer，再 `pushNamed`。

- [x] **Step 4: 运行路由与流程测试确认通过**

Run: `flutter test test/app_router_test.dart test/article_list_page_test.dart test/app_flow_test.dart`
Expected: PASS。

- [x] **Step 5: 中文提交**

```bash
git commit -m "架构：使用统一路由管理页面导航"
```

- [x] **Step 6: 中文提交侧边栏行为**

侧边栏与集中路由属于同一个可验证功能点，已合并在上一条中文提交中。

```bash
git commit -m "功能：首页侧边栏增加账号与收藏入口"
```

### Task 8: 文档与完整验证

**Files:**
- Modify: `README.md`
- Create: `docs/collection-registration-routing.md`
- Modify: `docs/superpowers/plans/2026-10-06-collection-registration-routing.md`

**Interfaces:**
- Documents: 接口、状态流、go_router、面试口述和运行验证。

- [x] **Step 1: 更新学习文档**

记录普通文章 ID 与收藏记录 ID 的区别、注册后登录原因、共享 Cookie、收藏状态同步、go_router 命名路由与未登录跳转。

- [x] **Step 2: 运行完整验证**

Run: `dart run build_runner build --delete-conflicting-outputs`

Run: `dart format lib test`

Run: `flutter test`

Run: `flutter analyze`

Run: `flutter build ios --simulator --no-codesign`

Expected: 代码生成无冲突，格式化完成，测试全部通过，静态检查无问题，生成 `build/ios/iphonesimulator/Runner.app`。

- [x] **Step 3: 中文提交**

```bash
git commit -m "文档：整理收藏注册与路由知识点"
```
