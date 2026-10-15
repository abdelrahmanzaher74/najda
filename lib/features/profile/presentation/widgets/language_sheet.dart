import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/locale_controller.dart';
import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';

/// نافذة اختيار اللغة: لغة الجهاز / English / العربية.
class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final current = ref.watch(localeProvider)?.languageCode;

    Widget option(String label, String? code) {
      final selected = current == code;
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
          await ref
              .read(localeProvider.notifier)
              .set(code == null ? null : Locale(code));
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
            l10n.language,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: n.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          option(l10n.languageSystem, null),
          option(l10n.languageEnglish, 'en'),
          option(l10n.languageArabic, 'ar'),
        ],
      ),
    );
  }
}