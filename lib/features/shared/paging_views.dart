import 'package:flutter/material.dart';

class PagingFirstPageErrorView extends StatelessWidget {
  const PagingFirstPageErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class PagingEmptyView extends StatelessWidget {
  const PagingEmptyView({required this.icon, required this.message, super.key});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}

class PagingProgressView extends StatelessWidget {
  const PagingProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class PagingRetryView extends StatelessWidget {
  const PagingRetryView({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('paging-retry'),
      onTap: onRetry,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('加载失败，点击重试')),
      ),
    );
  }
}

class PagingEndView extends StatelessWidget {
  const PagingEndView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text('已经到底了', style: TextStyle(color: Colors.black54)),
      ),
    );
  }
}
