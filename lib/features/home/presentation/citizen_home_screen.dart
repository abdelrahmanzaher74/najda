import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/session_controller.dart';
import '../../first_responder/presentation/widgets/first_responder_home_card.dart';
import '../../incident/data/incident_providers.dart';
import '../../incident/presentation/active_report.dart';
import '../../incident/presentation/labels.dart';
import '../../incident/presentation/pending_report_controller.dart';
import 'widgets/sos_button.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  void _comingNext(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.comingNextStep)));
  }

  /// قاعدة: بلاغ واحد نشط في المرة.
  void _openReport(BuildContext context, WidgetRef ref, String category) {
    final l10n = AppLocalizations.of(context);

    // في بلاغ محفوظ بانتظار الإرسال
    if (ref.read(pendingReportControllerProvider).report != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.pendingAlready)));
      return;
    }

    // في بلاغ نشط: نفتح تتبعه
    final activeId = ref.read(activeIncidentIdProvider);
    if (activeId != null && ref.read(hasActiveIncidentProvider)) {
      context.push('/citizen/incident/$activeId');
      return;
    }

    context.push('/citizen/report?category=$category');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final user = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الهيدر
              Row(
                children: [
                  const _LogoAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(l10n),
                          style: textTheme.bodySmall
                              ?.copyWith(color: n.textSecondary),
                        ),
                        Text(
                          user?.fullName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: n.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _BellButton(onPressed: () => _comingNext(context)),
                ],
              ),
              const SizedBox(height: 16),

              // شريط الحماية
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: n.successBg,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: n.success,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.protectedLocationOn,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: n.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // بلاغ محفوظ بانتظار الإرسال، أو بلاغ نشط (لو موجود)
              const _PendingReportBanner(),
              const _ActiveReportBanner(),
              const SizedBox(height: 32),

              // زر SOS
              Center(
                child: SosButton(
                  label: l10n.sos,
                  hint: l10n.holdToAlert,
                  onTriggered: () => _openReport(context, ref, 'MEDICAL'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.sosHint,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: n.textSecondary),
              ),
              const SizedBox(height: 32),

              // Quick report
              Text(
                l10n.quickReport,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: n.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickReportItem(
                      icon: Icons.medical_services_outlined,
                      label: l10n.medical,
                      onTap: () => _openReport(context, ref, 'MEDICAL'),
                    ),
                  ),
                  Expanded(
                    child: _QuickReportItem(
                      icon: Icons.local_fire_department_outlined,
                      label: l10n.fire,
                      onTap: () => _openReport(context, ref, 'FIRE'),
                    ),
                  ),
                  Expanded(
                    child: _QuickReportItem(
                      icon: Icons.local_police_outlined,
                      label: l10n.police,
                      onTap: () => _openReport(context, ref, 'POLICE'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // طلب الانضمام كمستجيب أول
              const FirstResponderHomeCard(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// كارت البلاغ المحفوظ (الطابور الأوفلاين).
class _PendingReportBanner extends ConsumerWidget {
  const _PendingReportBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingReportControllerProvider);
    final report = pending.report;
    if (report == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final controller = ref.read(pendingReportControllerProvider.notifier);

    final stale = report.isStale;
    final accent = stale ? AppColors.primary : n.warning;
    final background =
    stale ? AppColors.primary.withValues(alpha: 0.08) : n.warningBg;
    final savedAt = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(report.capturedAt),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  stale ? Icons.warning_amber_rounded : Icons.cloud_off_outlined,
                  color: accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stale ? l10n.pendingStaleTitle : l10n.pendingTitle,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stale ? l10n.pendingStaleBody : l10n.pendingBody,
                        style: textTheme.bodySmall
                            ?.copyWith(color: n.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.pendingSavedAt} $savedAt',
                        style: textTheme.labelSmall
                            ?.copyWith(color: n.textSecondary),
                      ),
                      if (pending.error != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          pending.error!,
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: pending.sending
                        ? null
                        : () => stale
                        ? controller.confirmStaleAndSend()
                        : controller.trySend(manual: true),
                    child: pending.sending
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      stale ? l10n.pendingSendAnyway : l10n.pendingSendNow,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: pending.sending ? null : controller.discard,
                    child: Text(l10n.pendingDiscard),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveReportBanner extends ConsumerWidget {
  const _ActiveReportBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(activeIncidentIdProvider);
    if (id == null) return const SizedBox.shrink();

    final incident = ref.watch(incidentStreamProvider(id)).value;
    if (incident == null || incident.status.isFinished) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: () => context.push('/citizen/incident/$id'),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.crisis_alert, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.activeReport,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      statusLabel(l10n, incident.status),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: n.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// اللوجو بخلفية بيضا (اللوجو نفسه خلفيته بيضا)، فبيفضل أبيض في الوضعين.
class _LogoAvatar extends StatelessWidget {
  const _LogoAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.emergency,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _BellButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final n = context.najda;

    return Stack(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.notifications_none),
            color: n.textPrimary,
          ),
        ),
        PositionedDirectional(
          top: 10,
          end: 12,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickReportItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickReportItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.najda;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: n.card,
              shape: BoxShape.circle,
              border: Border.all(color: n.border),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: n.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}