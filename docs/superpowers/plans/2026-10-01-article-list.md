# Article List Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建一个从 WanAndroid API 加载文章并支持错误重试和下拉刷新的 Flutter iOS 页面。

**Architecture:** 页面依赖 `ArticleRepository` 接口，生产环境注入 HTTP 实现，测试注入内存假实现。文章数据、网络边界和界面分别放在独立文件中，便于初学者逐层理解。

**Tech Stack:** Flutter、Dart、Material 3、`http`、`flutter_test`

## Global Constraints

- 只实现文章列表，不实现文章详情、收藏、分页和登录。
- 使用 `https://www.wanandroid.com/article/list/0/json`。
- 代码包含必要的中文学习注释。
- 按工程基础与模型、网络服务、列表界面、学习文档拆成多个小型 Git commit。

---

### Task 1: Flutter 工程与文章模型

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/main.dart`
- Create: `lib/models/article.dart`
- Test: `test/article_test.dart`

**Interfaces:**
- Produces: `Article.fromJson(Map<String, dynamic>)`

- [x] **Step 1: 使用 `flutter create` 生成标准 iOS Flutter 工程并添加 `http` 依赖**
- [x] **Step 2: 编写失败测试，断言标题 HTML 解码且空 `author` 回退到 `shareUser`**
- [x] **Step 3: 运行 `flutter test test/article_test.dart`，确认因 `Article` 缺失而失败**
- [x] **Step 4: 实现最小 `Article` 模型并再次运行测试，确认通过**

### Task 2: 网络服务

**Files:**
- Create: `lib/services/article_service.dart`
- Test: `test/article_service_test.dart`

**Interfaces:**
- Produces: `abstract interface class ArticleRepository { Future<List<Article>> fetchArticles(); }`
- Produces: `ArticleService({http.Client? client}).fetchArticles()`

- [x] **Step 1: 编写失败测试，使用自定义 `http.Client` 返回完整接口 JSON，断言服务产生文章列表**
- [x] **Step 2: 运行服务测试，确认因服务缺失而失败**
- [x] **Step 3: 实现状态码、业务错误和数据解析逻辑**
- [x] **Step 4: 再次运行服务测试，确认通过**

### Task 3: 文章列表页面

**Files:**
- Create: `lib/features/articles/article_card.dart`
- Create: `lib/features/articles/article_list_page.dart`
- Modify: `lib/main.dart`
- Test: `test/article_list_page_test.dart`

**Interfaces:**
- Consumes: `ArticleRepository.fetchArticles()` 与 `Article`
- Produces: `ArticleListPage(repository: repository)`

- [x] **Step 1: 编写失败 Widget 测试，断言加载后显示文章字段**
- [x] **Step 2: 编写失败 Widget 测试，断言错误页点击“重试”后显示文章**
- [x] **Step 3: 运行页面测试并确认失败原因是页面尚未实现**
- [x] **Step 4: 实现文章卡片、加载、空数据、错误重试和下拉刷新**
- [x] **Step 5: 更新 `main.dart` 注入网络服务，运行全部测试**

### Task 4: 文档、静态检查与 iOS 构建

**Files:**
- Modify: `README.md`

**Interfaces:**
- Produces: 初学者可执行的安装、运行和代码阅读说明

- [x] **Step 1: 更新 README，解释目录、API、常用 Flutter 命令和 Xcode 操作**
- [x] **Step 2: 运行 `dart format .`、`flutter analyze` 和 `flutter test`**
- [x] **Step 3: 运行 `flutter build ios --simulator --no-codesign`**
- [x] **Step 4: 检查 diff，配置本仓库作者并确认多个功能 commit 的边界清晰**
