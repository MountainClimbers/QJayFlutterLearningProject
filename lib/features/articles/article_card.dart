import 'package:flutter/material.dart';

import '../../models/article.dart';

/// 只负责展示一篇文章，页面状态和网络请求交给外层处理。
class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onCollect,
    this.collected,
    this.busy = false,
  });

  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onCollect;
  final bool? collected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                      article.displayAuthor.isEmpty
                          ? '匿名作者'
                          : article.displayAuthor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (article.displayDate.isNotEmpty)
                    Text(
                      article.displayDate,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  IconButton(
                    key: ValueKey('article-collect-${article.id}'),
                    tooltip: (collected ?? article.collected) ? '取消收藏' : '收藏',
                    onPressed: busy ? null : onCollect,
                    icon: busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            (collected ?? article.collected)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: (collected ?? article.collected)
                                ? colors.primary
                                : null,
                          ),
                  ),
                ],
              ),
              if (article.displayChapter.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  article.displayChapter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: colors.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
