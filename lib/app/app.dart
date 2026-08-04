import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class MusicallzApp extends StatelessWidget {
  const MusicallzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Musicallz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}