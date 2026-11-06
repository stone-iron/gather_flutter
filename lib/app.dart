import 'package:flutter/material.dart';

import 'router/app_router.dart';

class GatherHereApp extends StatelessWidget {
  const GatherHereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '여기모여',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35)),
        useMaterial3: true,
      ),
    );
  }
}
