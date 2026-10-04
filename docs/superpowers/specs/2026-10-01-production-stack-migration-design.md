# 文章列表主流技术栈迁移设计

## 目标

保持文章列表的用户功能不变，将数据解析、网络请求和异步页面状态迁移为 Flutter 团队项目中常见的技术组合。

## 技术选择

- 数据对象使用 `freezed`、`json_serializable` 与 `build_runner` 生成不可变对象、值相等、`copyWith` 和 JSON 转换代码；展示作者和分类的业务组合逻辑保留为 getter。
- 网络请求使用单例配置思路的 `Dio`，通过 `BaseOptions` 统一设置 `baseUrl`、连接超时和接收超时。
- 页面状态使用 Riverpod `AsyncNotifier`，由 `AsyncValue` 表达加载、成功和失败，UI 不再手动维护布尔值或调用 `setState`。
- 下拉刷新继续使用 Flutter 官方 `RefreshIndicator`，其回调调用 Notifier 的 `refresh()`。
- UI 使用 `ConsumerWidget`、Material 3、模式匹配和 `ListView.builder`。

## 边界与测试

`ArticleRepository` 仍然是网络层与状态层之间的接口。测试通过 Provider override 注入假仓库，不访问真实网络。模型测试验证生成解析和业务 getter；Dio 测试使用自定义适配器验证路径、解析和异常；Widget 测试验证加载、数据展示、错误重试和下拉刷新。

本次不增加分页、详情、收藏或登录功能。现有未跟踪的 `.vscode/` 目录不纳入提交。
