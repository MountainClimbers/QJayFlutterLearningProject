# Production Stack Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将现有文章列表迁移到 json_serializable、Dio、Riverpod 和 RefreshIndicator 组合。

**Architecture:** 模型由代码生成器处理字段映射，Dio Repository 负责远程数据，Riverpod AsyncNotifier 负责加载与刷新状态，ConsumerWidget 只负责根据 AsyncValue 绘制界面。

**Tech Stack:** Flutter 3.47、Dart 3.13、json_serializable、Dio、flutter_riverpod、Material 3

## Global Constraints

- 保持文章列表当前的加载、空数据、错误重试和下拉刷新功能。
- 不实现分页、详情、收藏或登录。
- `.vscode/` 不进入提交。
- 所有迁移只新增一个 Git commit。

---

### Task 1: 生成式文章模型

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/models/article.dart`
- Generate: `lib/models/article.g.dart`
- Modify: `test/article_test.dart`

**Interfaces:**
- Produces: `Article.fromJson(Map<String, dynamic>)`、`Article.toJson()`、`displayAuthor`、`displayChapter`

- [x] **Step 1: 更新模型测试，要求生成式字段映射和展示 getter**
- [x] **Step 2: 运行模型测试并确认旧模型不满足新接口**
- [x] **Step 3: 添加注解与代码生成依赖，运行 build_runner**
- [x] **Step 4: 运行模型测试并确认通过**

### Task 2: Dio 网络仓库

**Files:**
- Modify: `lib/services/article_service.dart`
- Modify: `test/article_service_test.dart`

**Interfaces:**
- Consumes: `Dio.get<Map<String, dynamic>>('/article/list/0/json')`
- Produces: `ArticleRepository.fetchArticles()`

- [x] **Step 1: 更新测试以使用 Dio HttpClientAdapter，并验证请求路径与异常转换**
- [x] **Step 2: 运行测试并确认 http 实现无法满足新测试**
- [x] **Step 3: 使用 BaseOptions 与 DioException 实现最小网络仓库**
- [x] **Step 4: 运行服务测试并确认通过**

### Task 3: Riverpod 页面状态与刷新

**Files:**
- Create: `lib/features/articles/article_list_controller.dart`
- Modify: `lib/features/articles/article_list_page.dart`
- Modify: `lib/features/articles/article_card.dart`
- Modify: `lib/main.dart`
- Modify: `test/article_list_page_test.dart`

**Interfaces:**
- Produces: `articleRepositoryProvider`、`articleListControllerProvider`、`ArticleListController.refresh()`
- Consumes: `AsyncValue<List<Article>>`

- [x] **Step 1: 更新 Widget 测试，通过 ProviderScope override 注入仓库**
- [x] **Step 2: 增加下拉刷新测试并确认旧 StatefulWidget 设计失败**
- [x] **Step 3: 实现 AsyncNotifier、ConsumerWidget 和 ProviderScope**
- [x] **Step 4: 运行 Widget 测试并确认通过**

### Task 4: 文档与完整验证

**Files:**
- Modify: `README.md`

**Interfaces:**
- Produces: 主流技术栈说明和代码生成命令

- [x] **Step 1: 更新 README 的技术与阅读说明**
- [x] **Step 2: 运行 build_runner、格式化、完整测试和静态分析**
- [x] **Step 3: 运行 iOS 模拟器构建**
- [x] **Step 4: 检查提交范围并创建一个 commit**
