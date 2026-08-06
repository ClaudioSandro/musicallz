import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_provider.dart';
import 'router.dart';
import 'theme.dart';

class MusicallzApp extends ConsumerWidget {
  const MusicallzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: 'Musicallz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(state: state, brightness: Brightness.light),
      darkTheme: AppTheme.build(state: state, brightness: Brightness.dark),
      themeMode: state.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 450),
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: appRouter,
    );
  }
}
