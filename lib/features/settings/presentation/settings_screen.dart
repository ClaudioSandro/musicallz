import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/app_gaps.dart';
import '../../../shared/widgets/rounded_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Text(
              'Settings',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            gap24,
            const _AppInfoCard(),
            gap24,
            const SectionHeaderWidget(
              title: 'Apariencia',
              subtitle: 'Próximamente',
            ),
            gap12,
            const RoundedCard(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.dark_mode_outlined, color: AppColors.textSecondary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('Tema'),
                  ),
                  Chip(
                    label: Text('Oscuro'),
                    labelStyle: TextStyle(fontSize: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            gap24,
            const SectionHeaderWidget(
              title: 'Configuraciones futuras',
              subtitle: 'Reproducción y audio',
            ),
            gap12,
            const RoundedCard(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.audiotrack_outlined, color: AppColors.textSecondary),
                  SizedBox(width: 16),
                  Expanded(child: Text('Calidad de audio')),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
            gap12,
            const RoundedCard(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.storage_outlined, color: AppColors.textSecondary),
                  SizedBox(width: 16),
                  Expanded(child: Text('Almacenamiento')),
                  Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
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
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
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

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RoundedCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.black,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Musicallz',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión ${SettingsScreen.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tu música local, con estilo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
