import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_theme_config.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/theme/theme_models.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/app_gaps.dart';
import '../../../shared/widgets/rounded_card.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeControllerProvider);
    final ctrl = ref.read(themeControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apariencia',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        children: [
          _PreviewCard(state: state),
          gap24,
          const SectionHeaderWidget(
            title: 'Modo de tema',
            subtitle: 'Tema',
          ),
          gap12,
          SegmentedButton<ThemeModeOption>(
            segments: ThemeModeOption.values
                .map(
                  (m) => ButtonSegment(
                    value: m,
                    label: Text(m.label),
                    icon: Icon(switch (m) {
                      ThemeModeOption.system => Icons.brightness_auto,
                      ThemeModeOption.light => Icons.light_mode_outlined,
                      ThemeModeOption.dark => Icons.dark_mode_outlined,
                    }),
                  ),
                )
                .toList(),
            selected: {state.mode},
            onSelectionChanged: (s) => ctrl.setMode(s.first),
            showSelectedIcon: false,
          ),
          gap24,
          const SectionHeaderWidget(
            title: 'Paleta de colores',
            subtitle: 'Color',
          ),
          gap12,
          _PaletteGrid(state: state, ctrl: ctrl),
          gap24,
          const SectionHeaderWidget(
            title: 'Fondo de pantalla',
            subtitle: 'Fondo',
          ),
          gap12,
          _BackgroundStyleSelector(state: state, ctrl: ctrl),
          gap24,
          const SectionHeaderWidget(
            title: 'Intensidad',
            subtitle: 'Ajusta cuánto se nota el fondo',
          ),
          gap12,
          SegmentedButton<BackgroundIntensity>(
            segments: BackgroundIntensity.values
                .map(
                  (i) => ButtonSegment(value: i, label: Text(i.label)),
                )
                .toList(),
            selected: {state.intensity},
            onSelectionChanged: (s) => ctrl.setIntensity(s.first),
            showSelectedIcon: false,
          ),
          gap24,
        ],
      ),
    );
  }
}

/// Compact live preview of the current theme: a Now Playing mock plus the
/// mini player and the navigation bar, rendered with the active palette.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.state});

  final ThemeState state;

  @override
  Widget build(BuildContext context) {
    final palette = paletteById(state.palette);
    final colors = Theme.of(context).colorScheme;

    return RoundedCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                'Vista previa',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          gap12,
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 320,
              color: colors.surfaceContainerHigh,
              child: Column(
                children: [
                  Expanded(
                    child: _PreviewBackdrop(
                      state: state,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Canciones',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Center(
                              child: Container(
                                width: 116,
                                height: 116,
                                decoration: BoxDecoration(
                                  color: palette.surfaceHigh,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.album_outlined,
                                  size: 44,
                                  color: palette.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: _PreviewSeekBar(palette: palette),
                            ),
                            gap12,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _PreviewIcon(Icons.shuffle, palette.primary),
                                const SizedBox(width: 28),
                                _PreviewIcon(
                                  Icons.skip_previous_rounded,
                                  Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 20),
                                _PreviewIcon(
                                  Icons.play_circle_filled_rounded,
                                  palette.primary,
                                  size: 52,
                                ),
                                const SizedBox(width: 20),
                                _PreviewIcon(
                                  Icons.skip_next_rounded,
                                  Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 28),
                                _PreviewIcon(Icons.repeat, palette.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 46,
                    color: colors.surfaceContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: palette.surfaceHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.music_note,
                            size: 14,
                            color: palette.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 6,
                              decoration: BoxDecoration(
                                color: palette.surfaceHigh,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: palette.surfaceHigh.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.play_circle_filled,
                          color: palette.primary,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 44,
                    color: colors.surfaceContainer,
                    child: Row(
                      children: [
                        _PreviewNavIcon(Icons.home, true, palette, colors),
                        _PreviewNavIcon(Icons.search, false, palette, colors),
                        _PreviewNavIcon(
                          Icons.library_music,
                          false,
                          palette,
                          colors,
                        ),
                        _PreviewNavIcon(Icons.settings, false, palette, colors),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewBackdrop extends StatelessWidget {
  const _PreviewBackdrop({required this.state, required this.child});

  final ThemeState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = paletteById(state.palette);
    final k = state.intensity.blendFactor;
    final Widget bg = switch (state.backgroundStyle) {
      BackgroundStyle.solid => ColoredBox(
          color: Color.lerp(palette.primary, Colors.black, k)!,
        ),
      BackgroundStyle.gradient ||
      BackgroundStyle.softBlur ||
      BackgroundStyle.strongBlur =>
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(palette.primary, Colors.black, k)!,
                Color.lerp(palette.gradient.last, Colors.black, k)!,
              ],
            ),
          ),
        ),
      BackgroundStyle.dynamic => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(palette.primary, Colors.black, k)!,
                Color.lerp(palette.secondary, Colors.black, k)!,
              ],
            ),
          ),
        ),
    };
    return Stack(
      fit: StackFit.expand,
      children: [bg, child],
    );
  }
}

class _PreviewSeekBar extends StatelessWidget {
  const _PreviewSeekBar({required this.palette});

  final ThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 4,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.35,
            child: Container(
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  const _PreviewIcon(this.icon, this.color, {this.size = 24});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size);
  }
}

class _PreviewNavIcon extends StatelessWidget {
  const _PreviewNavIcon(
    this.icon,
    this.selected,
    this.palette,
    this.colors,
  );

  final IconData icon;
  final bool selected;
  final ThemePalette palette;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: selected ? palette.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(height: 2),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? palette.primary : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteGrid extends StatelessWidget {
  const _PaletteGrid({required this.state, required this.ctrl});

  final ThemeState state;
  final ThemeController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final palette in kThemePalettes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoundedCard(
              onTap: () => ctrl.setPalette(palette.id),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
              children: [
                _PaletteSwatch(palette),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    palette.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (state.palette == palette.id)
                  Icon(Icons.check_circle, color: palette.primary, size: 22),
              ],
            ),
          ),
          ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch(this.palette);

  final ThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.primary, palette.secondary],
        ),
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
    );
  }
}

class _BackgroundStyleSelector extends StatelessWidget {
  const _BackgroundStyleSelector({required this.state, required this.ctrl});

  final ThemeState state;
  final ThemeController ctrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: [
        for (final style in BackgroundStyle.values)
          _StyleTile(
            style: style,
            selected: state.backgroundStyle == style,
            onTap: () => ctrl.setBackgroundStyle(style),
            background: _stylePreview(style, colors),
          ),
      ],
    );
  }

  Widget _stylePreview(BackgroundStyle style, ColorScheme colors) {
    final palette = paletteById(state.palette);
    switch (style) {
      case BackgroundStyle.solid:
        return ColoredBox(color: Color.lerp(palette.primary, Colors.black, 0.65)!);
      case BackgroundStyle.gradient:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(palette.primary, Colors.black, 0.55)!,
                Color.lerp(palette.gradient.last, Colors.black, 0.75)!,
              ],
            ),
          ),
        );
      case BackgroundStyle.softBlur:
      case BackgroundStyle.strongBlur:
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(palette.primary, Colors.black, 0.4)!,
                    Color.lerp(palette.secondary, Colors.black, 0.6)!,
                  ],
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.blur_on,
                color: Colors.white.withValues(alpha: 0.7),
                size: 30,
              ),
            ),
          ],
        );
      case BackgroundStyle.dynamic:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.primary.withValues(alpha: 0.9),
                palette.secondary.withValues(alpha: 0.9),
              ],
            ),
          ),
        );
    }
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.style,
    required this.selected,
    required this.onTap,
    required this.background,
  });

  final BackgroundStyle style;
  final bool selected;
  final VoidCallback onTap;
  final Widget background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius - 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              background,
              Center(
                child: Text(
                  style.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeaderWidget extends StatelessWidget {
  const SectionHeaderWidget({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.brandAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
