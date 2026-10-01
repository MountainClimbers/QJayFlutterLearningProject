import 'package:flutter/material.dart';

import 'features/articles/article_list_page.dart';
import 'services/article_service.dart';

void main() {
  runApp(const WanAndroidLearningApp());
}

class WanAndroidLearningApp extends StatelessWidget {
  const WanAndroidLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '玩 Android · Flutter 学习',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
      ),
      home: ArticleListPage(repository: ArticleService()),
    );
  }
}
