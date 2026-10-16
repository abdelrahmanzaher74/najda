import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/models/user_role.dart';
import '../../../auth/presentation/session_controller.dart';
import '../../data/first_responder_providers.dart';
import '../../data/models/first_responder_application.dart';

class FirstResponderHomeCard extends ConsumerWidget {
  const FirstResponderHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مستجيب أول فعلًا: مفيش داعي للكارت
    final role = ref.watch(sessionProvider)?.role;
    if (role == UserRole.firstResponder) return const SizedBox.shrink();

    final state = ref.watch(firstResponderApplicationProvider);

    // أثناء التحميل أو لو حصل خطأ مبنظهرش حاجة (الحالة مش معروفة)
    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (app) => _Card(app: app),
    );
  }
}

class _Card extends StatelessWidget {
  final FirstResponderApplication? app;

  const _Card({required this.app});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    final status = app?.status;
    final isNew = app == null;

    final (IconData icon, Color color, String title, String subtitle) =
    switch (status) {
      null => (
      Icons.health_and_safety,
      AppColors.primary,
      l10n.becomeFirstResponder,
      l10n.becomeFirstResponderHint,
      ),
      ApplicationStatus.approved => (
      Icons.verified,
      n.success,
      l10n.frHomeApproved,
      l10n.frHomeTapToView,
      ),
      ApplicationStatus.rejected => (
      Icons.cancel_outlined,
      AppColors.primary,
      l10n.frHomeRejected,
      l10n.frHomeTapToView,
      ),
      _ => (
      Icons.hourglass_top,
      n.warning,
      l10n.frHomeUnderReview,
      l10n.frHomeTapToView,
      ),
    };

    return InkWell(
      onTap: () => context.push('/citizen/first-responder'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: n.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style:
                    textTheme.bodySmall?.copyWith(color: n.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isNew)
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => context.push('/citizen/first-responder'),
                child: Text(l10n.frApply),
              )
            else
              Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}