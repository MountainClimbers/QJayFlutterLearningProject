# 收藏、注册与路由学习笔记

这次功能把文章列表、登录注册、我的收藏和文章详情串成了完整流程。生产代码使用 `Dio`、`PersistCookieJar`、Riverpod 和 `go_router`，模型继续使用 `freezed` 与 `json_serializable`。

## 功能入口

首页文章卡片右侧有收藏按钮：

- 未登录点击收藏：进入登录注册页；
- 已登录点击收藏：调用收藏接口，成功后图标变为已收藏；
- 再次点击已收藏图标：调用普通文章取消收藏接口；
- 请求进行中：按钮显示进度并禁止重复点击。

首页左侧侧边栏只有两个入口：

- “登录/注册”：进入同一个账号页面，页面内可以切换登录与注册；
- “我的收藏”：进入收藏列表，未登录时先提示登录。

注册成功后会自动调用登录接口。这样服务端会返回登录 Cookie，后面的收藏请求才能被识别为当前账号。

## 接口与编号

| 功能 | 方法与路径 | 关键参数 |
| --- | --- | --- |
| 注册 | `POST /user/register` | `username`、`password`、`repassword` |
| 登录 | `POST /user/login` | `username`、`password` |
| 收藏文章 | `POST /lg/collect/{articleId}/json` | 普通文章编号 |
| 普通列表取消收藏 | `POST /lg/uncollect_originId/{articleId}/json` | 普通文章编号 |
| 我的收藏 | `GET /lg/collect/list/0/json` | 无 |
| 收藏列表取消收藏 | `POST /lg/uncollect/{recordId}/json` | 请求体传 `originId` |

普通文章列表中的 `id` 是文章编号。收藏列表中的 `id` 是收藏记录编号，`originId` 才是原文章编号。因此从收藏列表取消收藏时，不能直接复用普通列表的取消接口。

`Article` 同时保存以下两个收藏字段：

- `collected`：对应接口 JSON 中的 `collect`，表示文章是否已收藏；
- `originId`：收藏记录对应的原文章编号。

## 共享登录会话

`WanAndroidSessionClient` 创建一份共享的 `Dio` 和 `PersistCookieJar`。登录、注册、文章和收藏服务都从 Riverpod 的 `sessionClientProvider` 取得同一客户端。

登录响应中的 Cookie 会写入安全存储。应用重启后，认证控制器检查 Cookie 是否完整且有效，再恢复用户状态。收藏接口和账号接口共享 Cookie，所以不需要在每个请求里手动添加登录参数。

## 收藏状态流

`CollectionController` 是应用级 Riverpod `Notifier`，负责：

1. 登录后获取收藏列表；
2. 使用 `article:{originId}` 把收藏记录映射回首页文章；
3. 记录正在请求的文章，阻止连续点击发出重复请求；
4. 只在接口成功后修改收藏图标和列表；
5. 用户退出或切换账号时清空旧账号收藏状态；
6. 首页新增收藏后，在进入收藏页时按需刷新，取得服务端生成的收藏记录编号；
7. 通过请求序号忽略较早返回的旧刷新结果，只让最后发起的请求更新页面；
8. 刷新时以服务端结果为基准，同时保留请求期间刚完成的本地收藏操作；
9. 每次登录生命周期使用独立版本号，即使退出后重新登录同一账号，旧请求也不能写入新会话；
10. 如果进入收藏页时收藏请求还未完成，按需同步会先等待该操作，再获取服务端生成的收藏记录。

文章卡片只负责显示图标、进度和点击回调。是否登录、调用哪个接口、失败提示和状态同步都由页面与控制器处理。

WanAndroid 用 `errorCode == -1001` 表示登录会话已经失效。收藏服务会把它转换成专门的认证异常，认证控制器随后清除本地 Cookie 和内存用户。文章列表会直接进入登录注册页，收藏列表则恢复为未登录提示，避免界面继续显示过期账号。

## go_router 路由

项目使用 Flutter 应用中常见的 `go_router` 集中管理页面路由。入口已经从 `MaterialApp` 改为 `MaterialApp.router`。

| 路由名 | 路径 | 页面 | 参数 |
| --- | --- | --- | --- |
| `home` | `/` | 文章列表 | 无 |
| `articleDetail` | `/article` | 文章详情 | `extra` 传完整 `Article` |
| `account` | `/account` | 登录注册 | 无 |
| `collections` | `/collections` | 我的收藏 | 无 |

路由名和路径放在 `lib/router/route_names.dart`，路由表放在 `lib/router/app_router.dart`。页面通过 `context.pushNamed(...)` 跳转。详情路由会先检查 `extra` 是否为 `Article`，参数不正确时展示可读错误页，避免类型转换崩溃。

Widget 测试仍可注入测试页面构造器，这只用于隔离原生 WebView 和表单页面；应用实际运行时统一经过 `go_router`。

## 面试口述参考

“我用 `go_router` 集中声明文章列表、详情、登录注册和我的收藏四个路由，页面使用命名路由跳转，详情通过 `extra` 传完整文章对象。登录和收藏共用同一个 Dio 与持久化 Cookie，所以登录后收藏请求会自动带上会话。收藏状态由 Riverpod 的 Notifier 统一管理，页面只负责展示。点击收藏时先判断登录状态，未登录进入账号页，已登录再调用接口；请求成功才更新 UI，并通过忙碌状态防止重复点击。收藏列表里的记录编号和文章编号不同，所以我为普通列表和收藏列表分别调用对应的取消接口。”

## 验证命令

```bash
dart run build_runner build
dart format lib test
flutter test
flutter analyze
flutter build ios --simulator --no-codesign
```
