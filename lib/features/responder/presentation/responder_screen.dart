import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../core/location/location_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../incident/presentation/active_report.dart';
import '../data/models/responder_availability.dart';
import '../data/responder_providers.dart';

class ResponderScreen extends ConsumerStatefulWidget {
  const ResponderScreen({super.key});

  @override
  ConsumerState<ResponderScreen> createState() => _ResponderScreenState();
}

class _ResponderScreenState extends ConsumerState<ResponderScreen> {
  bool _checkingLocation = false;

  Future<void> _select(ResponderAvailability value) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // عشان يبقى "متاح" لازم الموقع الحقيقي والدقيق شغال
    if (value == ResponderAvailability.available) {
      setState(() => _checkingLocation = true);
      try {
        await ref.read(locationServiceProvider).getCurrentLocation();
      } catch (_) {
        if (!mounted) return;
        setState(() => _checkingLocation = false);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.responderNeedsLocation)),
        );
        return;
      }
      if (!mounted) return;
      setState(() => _checkingLocation = false);
    }

    final failure =
    await ref.read(availabilityProvider.notifier).set(value);
    if (failure != null && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  (IconData, Color, String, String) _describe(
      BuildContext context,
      ResponderAvailability value,
      ) {
    final l10n = AppLocalizations.of(context);
    final n = context.najda;

    return switch (value) {
      ResponderAvailability.available => (
      Icons.check_circle,
      n.success,
      l10n.availAvailable,
      l10n.availAvailableHint,
      ),
      ResponderAvailability.busy => (
      Icons.do_not_disturb_on,
      n.warning,
      l10n.availBusy,
      l10n.availBusyHint,
      ),
      ResponderAvailability.offline => (
      Icons.power_settings_new,
      n.textTertiary,
      l10n.availOffline,
      l10n.availOfflineHint,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    final chosen =
        ref.watch(availabilityProvider).value ?? ResponderAvailability.offline;
    final effective = ref.watch(effectiveAvailabilityProvider);
    final hasOwnReport = ref.watch(hasActiveIncidentProvider);
    final overriddenByReport = hasOwnReport &&
        chosen == ResponderAvailability.available &&
        effective == ResponderAvailability.busy;

    final (icon, color, label, hint) = _describe(context, effective);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.responderTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الحالة الحالية
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.responderStatusLabel,
                                style: textTheme.labelMedium
                                    ?.copyWith(color: n.textSecondary),
                              ),
                              Text(
                                label,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: n.textPrimary,
                                ),
                              ),
                              Text(
                                hint,
                                style: textTheme.bodySmall
                                    ?.copyWith(color: n.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // تنبيه: مشغول تلقائيًا بسبب بلاغ نشط
                  if (overriddenByReport) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: n.warningBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18, color: n.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.responderBusyOwnReport,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: n.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // اختيار الحالة
                  Row(
                    children: [
                      for (final option in ResponderAvailability.values) ...[
                        Expanded(
                          child: _StatusOption(
                            availability: option,
                            selected: chosen == option,
                            describe: _describe,
                            onTap: _checkingLocation
                                ? null
                                : () => _select(option),
                          ),
                        ),
                        if (option != ResponderAvailability.values.last)
                          const SizedBox(width: 10),
                      ],
                    ],
                  ),
                  if (_checkingLocation) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.checkingLocation,
                          style: textTheme.bodySmall
                              ?.copyWith(color: n.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // معلومة عن الخصوصية والتنبيهات
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.successBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 20, color: n.success),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.responderInfo,
                            style: textTheme.bodySmall
                                ?.copyWith(color: n.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // التنبيهات (هتتملي في الخطوة الجاية)
                  Text(
                    l10n.responderAlerts.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: n.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: n.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: n.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 36,
                          color: n.textTertiary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.responderNoAlerts,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: n.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final ResponderAvailability availability;
  final bool selected;
  final (IconData, Color, String, String) Function(
  BuildContext,
  ResponderAvailability,
  ) describe;
  final VoidCallback? onTap;

  const _StatusOption({
    required this.availability,
    required this.selected,
    required this.describe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.najda;
    final (icon, color, label, _) = describe(context, availability);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : n.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : n.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: n.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}