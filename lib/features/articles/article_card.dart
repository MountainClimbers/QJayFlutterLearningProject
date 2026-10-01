import 'package:flutter/material.dart';

import '../../models/article.dart';

/// 只负责展示一篇文章，页面状态和网络请求交给外层处理。
class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: colors.primary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    article.author.isEmpty ? '匿名作者' : article.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (article.date.isNotEmpty)
                  Text(
                    article.date,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
            if (article.chapter.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                article.chapter,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: colors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
