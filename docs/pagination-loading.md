# Flutter 列表刷新与分页知识点

## 项目采用的技术

文章列表和收藏列表使用同一套组合：

- 下拉刷新：Flutter SDK 自带的 `RefreshIndicator`。
- 上拉加载更多：`infinite_scroll_pagination` 包中的 `PagedListView`。
- 分页界面状态：`PagingState<int, Article>`。
- 分页状态组件：`PagedChildBuilderDelegate<Article>`。
- 业务状态管理：Riverpod 的 `NotifierProvider`。
- 网络请求：Dio。
- 数据对象：Freezed 与 json_serializable。

这种分工让 UI 组件处理手势和展示，让 Riverpod 处理页码、网络请求、去重和并发规则。

## 下拉刷新为什么使用 RefreshIndicator

`RefreshIndicator` 是 Flutter 官方 Material 组件。它负责监听向下拖动、展示刷新动画，并在达到触发距离后调用 `onRefresh`。项目把控制器的 `refresh()` 返回值交给它，因此刷新动画会一直显示到网络请求结束。

刷新时会重新请求第 0 页。成功后用新的第一页替换所有旧页面，并把下一页恢复为 1；失败时保留用户已经看到的内容，通过 SnackBar 显示错误。空列表也配置了 `AlwaysScrollableScrollPhysics`，所以没有数据时仍然可以下拉刷新。

## 上拉加载为什么使用 infinite_scroll_pagination

`infinite_scroll_pagination` 是专门处理无限滚动列表的成熟 Flutter 包。项目使用 5.1.1 版本。它提供标准的分页列表、触底预取和各种分页状态界面，减少手写 `ScrollController` 阈值判断和重复监听代码。

三个核心类型的作用如下：

- `PagedListView`：渲染文章列表，并在距离末尾还剩 3 个不可见条目时调用 `fetchNextPage`。
- `PagingState`：告诉列表已经加载的页面、是否正在请求、是否还有下一页以及最近的错误。
- `PagedChildBuilderDelegate`：构建文章卡片、首次加载、空列表、首次错误、下一页加载、下一页错误和全部结束等界面。

## Riverpod 与分页组件如何分工

分页组件不直接调用 Dio，也不决定服务端页码。它只根据 `PagingState` 绘制，并在需要下一页时通知控制器。

Riverpod 控制器负责：

1. 保存已经加载的页面。
2. 保存下一次应请求的 0 基页码。
3. 防止同一时间重复发送加载更多请求。
4. 调用 Repository 请求服务端。
5. 按文章业务编号去重。
6. 记录是否还有下一页。
7. 保存分页错误，供列表显示底部重试入口。
8. 通过请求世代丢弃过期响应。

文章列表使用 `ArticleListState`。收藏列表使用 `CollectionState`，并在分页字段之外继续保存当前账号、收藏确认状态、正在操作的文章和本地修改版本。

## 每页 10 条如何实现

项目定义统一常量 `wanAndroidPageSize = 10`。文章和收藏 Repository 都接收 `page` 与 `pageSize`，Dio 请求通过查询参数发送：

```text
page_size=10
```

文章接口路径为 `/article/list/{page}/json`，收藏接口路径为 `/lg/collect/list/{page}/json`。两个接口的客户端页码都从 0 开始。第 0 页成功后把 `nextPage` 设为 1，后续每成功加载一页就加一。

服务端分页响应由 `ArticlePage` 解析，主要字段包括：

- `datas`：当前页文章。
- `curPage`：服务端报告的当前页。
- `pageCount`：总页数。
- `over`：是否已经结束。

控制器根据 `ArticlePage.hasMore` 决定是否继续加载。即使接口某页出现重复文章，客户端页码仍然前进，避免反复请求同一页。

## 如何防止重复请求和重复数据

控制器发送下一页请求前检查两个条件：

- `isLoading` 为 false，当前没有请求正在执行。
- `hasMore` 为 true，服务端还有下一页。

文章列表按 `Article.id` 去重。收藏列表优先使用 `originId`，因为收藏记录的 `id` 是收藏记录编号，同一篇原文章应通过 `originId` 识别；没有有效 `originId` 时才使用收藏记录编号。

去重发生在控制器中，因此 Widget 只负责展示，不需要理解文章编号规则。

## 如何防止旧请求覆盖新数据

控制器保存一个请求世代 `requestGeneration`。下拉刷新会增加世代，使之前正在执行的加载更多请求立即过期。每个请求返回后都比较自己开始时记录的世代和当前世代；不一致就直接丢弃结果。

收藏列表还会同时比较：

- 当前账号标识。
- 当前登录周期 `identityEpoch`。
- 请求世代。
- 请求开始时的本地收藏修改版本。

因此退出登录、切换账号、同账号重新登录、刷新或收藏操作发生后，旧响应不能把过期数据写回当前页面。

## 首次失败和加载更多失败为什么不同

首次请求失败时页面没有任何内容可读，所以显示完整错误界面和“重试”按钮。

加载更多失败时第一页等旧数据仍然有效，所以项目保留已有文章，只在列表底部显示“加载失败，点击重试”。点击后继续请求原来的下一页，不会跳页，也不会清空列表。

全部数据加载完成后，列表底部显示“已经到底了”，并且控制器不再发送新请求。

## 面试口述示例

这个项目的下拉刷新用 Flutter 官方的 RefreshIndicator，上拉加载用 infinite_scroll_pagination。PagedListView 负责监听列表位置，PagingState 描述当前有哪些页、是否加载中、有没有下一页和错误状态，PagedChildBuilderDelegate 负责不同状态的 UI。真正的页码和网络请求放在 Riverpod 控制器里，Dio 每次从第 0 页开始请求，每页固定 10 条。

上拉时控制器先判断当前是否正在请求以及有没有下一页，请求成功后按文章 ID 去重并追加；失败时保留旧数据，在底部提供重试。下拉刷新会重新请求第 0 页，并用请求世代让旧的加载更多结果失效。收藏列表还会检查账号和登录周期，并用本地修改版本防止正在收藏或取消收藏时被旧接口响应覆盖。

## 常见追问

### 为什么不直接监听 ScrollController

手写 `ScrollController` 可以实现，但还需要自己处理触发距离、重复调用、底部加载、错误重试和结束状态。项目使用成熟分页包统一解决这些通用问题，Riverpod 只保留业务相关逻辑。

### 为什么不让分页包直接管理网络状态

收藏列表有账号切换、登录过期和本地收藏操作并发等业务规则。把请求状态放在 Riverpod 中更容易测试，也能让文章列表与收藏列表共享同一种架构。

### 为什么分页数据按页保存

`PagingState` 原生接收分页页组。按页保存可以直接交给分页组件，也能保留每次响应的边界。页面需要一维列表时，通过状态的 `articles` 计算属性展开。

### 刷新和加载更多同时发生怎么办

刷新增加请求世代，并开始新的第 0 页请求。旧的加载更多请求返回时发现世代不一致，会丢弃自己的结果，因此不会把旧页追加到刷新后的列表。

### 收藏列表为什么按 originId 去重

收藏接口中的 `id` 是收藏记录编号，同一篇文章在普通文章列表中的编号由 `originId` 表示。用 `originId` 才能把两种接口中的记录对应到同一篇文章。
