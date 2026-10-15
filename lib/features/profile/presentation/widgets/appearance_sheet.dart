import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../app/theme_mode_controller.dart';
import '../../../../l10n/app_localizations.dart';

/// نافذة اختيار المظهر: حسب الجهاز / فاتح / داكن.
class AppearanceSheet extends ConsumerWidget {
  const AppearanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final current = ref.watch(themeModeProvider);

    Widget option(String label, IconData icon, ThemeMode mode) {
      final selected = current == mode;
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Icon(
          icon,
          color: selected ? AppColors.primary : n.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? AppColors.primary : n.textPrimary,
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : Icon(Icons.circle_outlined, color: n.borderStrong),
        onTap: () async {
          await ref.read(themeModeProvider.notifier).set(mode);
          if (context.mounted) Navigator.of(context).pop();
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.appearance,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: n.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          option(l10n.themeSystem, Icons.brightness_auto_outlined,
              ThemeMode.system),
          option(l10n.themeLight, Icons.light_mode_outlined, ThemeMode.light),
          option(l10n.themeDark, Icons.dark_mode_outlined, ThemeMode.dark),
        ],
      ),
    );
  }
}