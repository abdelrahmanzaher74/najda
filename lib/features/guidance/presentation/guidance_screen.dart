import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../l10n/app_localizations.dart';
import '../../incident/data/incident_providers.dart';
import '../data/guidance_providers.dart';
import '../data/guidance_repository.dart';
import '../data/models/guidance_card.dart';

class GuidanceScreen extends ConsumerWidget {
  final int incidentId;

  const GuidanceScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final incident = ref.watch(incidentStreamProvider(incidentId)).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guidanceTitle)),
      body: SafeArea(
        child: incident == null
            ? const Center(child: CircularProgressIndicator())
            : _Cards(
          request: (
          category: incident.category,
          injuredCount: incident.injuredCount,
          languageCode: Localizations.localeOf(context).languageCode,
          ),
        ),
      ),
    );
  }
}

class _Cards extends ConsumerWidget {
  final GuidanceRequest request;

  const _Cards({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final state = ref.watch(guidanceProvider(request));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error is Failure ? error.message : const UnknownFailure().message,
            textAlign: TextAlign.center,
            style: TextStyle(color: n.textPrimary),
          ),
        ),
      ),
      data: (cards) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // تنبيه: تعليمات غرفة العمليات أولًا
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
                    l10n.guidanceDisclaimer,
                    style:
                    textTheme.bodySmall?.copyWith(color: n.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final card in cards) ...[
            _GuidanceTile(card: card),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _GuidanceTile extends StatelessWidget {
  final GuidanceCard card;

  const _GuidanceTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    return Container(
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: card.isGeneral
              ? AppColors.primary.withValues(alpha: 0.45)
              : n.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: card.isGeneral,
          iconColor: n.textSecondary,
          collapsedIconColor: n.textSecondary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            card.title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: n.textPrimary,
            ),
          ),
          children: [
            for (var i = 0; i < card.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        card.steps[i],
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: n.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (card.warning != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${l10n.guidanceImportant}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: n.link,
                              ),
                            ),
                            TextSpan(text: card.warning),
                          ],
                        ),
                        style: textTheme.bodySmall
                            ?.copyWith(color: n.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}