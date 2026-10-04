# 第 4 天：登录接口与 Cookie 持久化

## 今天完成的功能

登录页现在会向玩安卓发送真实的登录请求。请求期间表单会被禁用并显示进度；失败时显示服务端返回的原因；成功时回到文章列表，并在右上角显示当前用户。应用再次启动时，会从本地 Cookie 恢复用户名。

## 一次登录经历了什么

1. `LoginPage` 校验用户名和密码，并把输入包装成 `LoginCredentials`。
2. `AuthController` 把状态改为加载中，再调用登录仓库。
3. `AuthService` 用 `Dio` 发送 `POST /user/login` 表单。
4. `CookieManager` 读取响应头里的 Cookie，交给 `PersistCookieJar` 保存。
5. `LoginUser.fromJson` 把接口字典转换成有类型的数据对象。
6. `AuthController` 保存登录用户，首页根据这个状态更新右上角内容。

## 关键文件

- `lib/models/login_user.dart`：登录用户不可变数据对象，由 `freezed` 生成值相等和 `copyWith`，由 `json_serializable` 生成 JSON 解析。
- `lib/services/wan_android_client.dart`：玩安卓共享网络客户端和超时设置。
- `lib/services/auth_service.dart`：登录 POST 请求、业务错误转换和 Cookie 恢复。
- `lib/services/secure_cookie_storage.dart`：把 Cookie 序列化结果写入系统安全存储。
- `lib/features/auth/auth_controller.dart`：Riverpod 全局登录状态。
- `lib/features/auth/login_page.dart`：表单校验、加载状态和错误提示。
- `lib/features/articles/article_list_page.dart`：打开登录页并展示当前用户。

## 为什么这样拆分

页面只处理输入和显示，不直接认识 Dio。登录服务只负责接口和 Cookie，不操作 Widget。控制器连接两者并保存全局状态。这样修改接口、替换页面或编写单元测试时，不需要同时改动所有代码。

## Cookie 和登录状态

服务器登录成功后通过响应头设置 Cookie。`dio_cookie_manager` 负责在请求与响应之间自动传递 Cookie，`PersistCookieJar` 负责 Cookie 的过期和域名规则，`flutter_secure_storage` 把序列化结果保存到 iOS Keychain 或 Android Keystore 支持的安全存储中。应用启动时必须同时读取到用户名和认证令牌 Cookie 才恢复用户，缺少任意一个都保持未登录。

启动恢复与登录请求会按顺序执行，多个登录请求发生重叠时只有最后开始的请求可以更新全局状态，避免旧结果覆盖新用户。

当前练习项目没有实现退出登录。后续实现退出时，除了请求退出接口，还要清理 Cookie 并把 `AuthController` 改回未登录状态。

## 错误处理

- `errorCode != 0`：显示接口的 `errorMsg`，例如账号密码不匹配。
- HTTP 状态异常：显示状态码，方便定位服务端问题。
- 无法建立连接：显示“网络连接失败，请稍后重试”。
- 未知页面异常：显示统一提示，不把底层异常直接暴露给用户。

## 调试提示

玩安卓当前证书异常时，项目只在调试构建中允许指定域名的过期证书，发布构建仍执行正常证书校验。这个处理是临时调试方案，服务端证书恢复后应删除例外。

## 今天对应的面试点

- `application/x-www-form-urlencoded` 与 JSON 请求体的区别。
- Dio 拦截器如何自动保存和携带 Cookie。
- Cookie 持久化与内存 Cookie 的区别。
- Riverpod `AsyncNotifier` 如何表达加载、数据和错误状态。
- 为什么 Repository 通过 Provider 注入后更容易测试。
- 为什么密码不应该写入日志、状态展示或普通偏好设置。
