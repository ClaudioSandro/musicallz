import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/player/presentation/widgets/mini_player.dart';
import 'app_bottom_bar.dart';

/// Persistent bottom area for detail screens.
///
/// Keeps the [MiniPlayer] and the [AppBottomBar] visible on album, artist,
/// playlist, liked songs, queue and genre screens, mirroring the Spotify
/// behaviour where you can keep controlling music without leaving the page.
///
/// The [PopScope] keeps system back working: pushed detail routes pop
/// normally, and a detail opened directly at the root of the navigation stack
/// (deep link) falls back to the Library tab instead of closing the app.
/// When no [GoRouter] is present (widget tests) the shell stays inert.
class PlayerBottomShell extends StatelessWidget {
  const PlayerBottomShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    return PopScope(
      canPop: router == null || router.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || router == null) return;
        router.go('/library');
      },
      child: Column(
        children: [
          Expanded(child: child),
          const MiniPlayer(),
          AppBottomBar(),
        ],
      ),
    );
  }
}
