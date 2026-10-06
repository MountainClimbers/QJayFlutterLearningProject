import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: WanAndroidLearningApp()));
}

class WanAndroidLearningApp extends StatelessWidget {
  const WanAndroidLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '玩 Android · Flutter 学习',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B87)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
