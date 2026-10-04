# 第四天：登录接口设计

## 目标

把第 3 天的本地登录表单接到 WanAndroid 登录接口，学习 POST 表单、Cookie 持久化和 Riverpod 登录状态。注册、退出登录和收藏功能不在本次范围内。

## 接口

- 地址：`POST https://www.wanandroid.com/user/login`
- 参数：`username`、`password`
- 编码：`application/x-www-form-urlencoded`
- 成功：`errorCode == 0`，解析 `data` 中的用户信息，并保存响应 Cookie。
- 失败：把 `errorMsg` 转换成页面可展示的登录异常。

## 技术方案

- `Dio` 发送 POST 表单。
- `dio_cookie_manager` 把 Cookie 自动附加到请求并从响应保存 Cookie。
- `PersistCookieJar` 把 Cookie 保存到应用支持目录，重启后仍可恢复。
- `json_serializable` 生成登录用户的 JSON 映射。
- `Riverpod AsyncNotifier` 保存恢复中、未登录、登录中、登录成功和失败状态。

## 页面行为

- 表单校验通过后发起真实登录请求。
- 请求期间禁用输入框和登录按钮，并显示进度。
- 登录失败时保留输入内容并显示服务端错误。
- 登录成功后返回文章列表，右上角显示当前用户名。
- App 启动时根据持久化 Cookie 恢复用户名。

## 提交拆分

1. 制定第 4 天设计和计划。
2. 添加 Cookie 持久化依赖。
3. 实现登录数据对象、POST 服务和 Cookie 保存。
4. 实现 Riverpod 登录状态。
5. 把登录页面与文章列表接入登录状态。
6. 补充测试、学习文档和最终验证。
