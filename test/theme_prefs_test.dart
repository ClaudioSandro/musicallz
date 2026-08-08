import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicallz/app/app.dart';

void main() {
  testWidgets('app loads mode=light from prefs and renders light',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'light',
      'theme_palette': 'crimsonRed',
    });

    await tester.pumpWidget(
      const ProviderScope(child: MusicallzApp()),
    );
    // Let the async _load() complete and the theme animation settle.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final scaffold = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(scaffold);
    // ignore: avoid_print
    print('REAL brightness=${theme.brightness} '
        'scaffoldBg=${theme.scaffoldBackgroundColor} '
        'luminance=${theme.scaffoldBackgroundColor.computeLuminance()} '
        'surface=${theme.colorScheme.surface} '
        'surfaceHigh=${theme.colorScheme.surfaceContainerHigh} '
        'onSurface=${theme.colorScheme.onSurface}');
  });
}
