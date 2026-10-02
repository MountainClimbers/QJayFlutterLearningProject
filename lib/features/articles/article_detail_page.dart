import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/article.dart';

typedef ArticleWebViewBuilder = Widget Function(
  BuildContext context,
  Uri uri,
  ValueChanged<int> onProgress,
  ValueChanged<String> onError,
);

/// 只允许 WebView 打开普通网页链接，避免把无效或其他协议交给原生组件。
Uri? parseArticleUri(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

class ArticleDetailPage extends StatefulWidget {
  const ArticleDetailPage({
    super.key,
    required this.article,
    this.webViewBuilder,
  });

  final Article article;

  /// 测试可以替换原生 WebView，同时仍验证 URL 和页面状态。
  final ArticleWebViewBuilder? webViewBuilder;

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late final Uri? _articleUri = parseArticleUri(widget.article.link);
  int _progress = 0;
  int _reloadVersion = 0;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final uri = _articleUri;
    if (uri == null) {
      return const _ArticleDetailError(message: '文章链接无效，无法打开');
    }

    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      return _ArticleDetailError(
        message: errorMessage,
        onRetry: () {
          setState(() {
            _errorMessage = null;
            _progress = 0;
            _reloadVersion += 1;
          });
        },
      );
    }

    final builder = widget.webViewBuilder ?? _defaultWebViewBuilder;
    return Column(
      children: [
        if (_progress < 100)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress / 100,
          ),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey(_reloadVersion),
            child: builder(context, uri, _handleProgress, _handleError),
          ),
        ),
      ],
    );
  }

  Widget _defaultWebViewBuilder(
    BuildContext context,
    Uri uri,
    ValueChanged<int> onProgress,
    ValueChanged<String> onError,
  ) {
    return _ArticleWebView(uri: uri, onProgress: onProgress, onError: onError);
  }

  void _handleProgress(int progress) {
    if (!mounted || progress == _progress) return;
    setState(() => _progress = progress);
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
  }
}

class _ArticleWebView extends StatefulWidget {
  const _ArticleWebView({
    required this.uri,
    required this.onProgress,
    required this.onError,
  });

  final Uri uri;
  final ValueChanged<int> onProgress;
  final ValueChanged<String> onError;

  @override
  State<_ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<_ArticleWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: widget.onProgress,
          onWebResourceError: (error) {
            if (error.isForMainFrame != false) {
              widget.onError('网页加载失败：${error.description}');
            }
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}

class _ArticleDetailError extends StatelessWidget {
  const _ArticleDetailError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public_off_outlined, size: 52),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('重新加载')),
            ],
          ],
        ),
      ),
    );
  }
}
