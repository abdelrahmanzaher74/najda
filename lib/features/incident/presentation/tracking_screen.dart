import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../core/geo/geo_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../chat/data/chat_providers.dart';
import '../data/incident_providers.dart';
import '../data/models/assigned_unit.dart';
import '../data/models/incident.dart';
import '../data/models/incident_status.dart';
import 'cancel_sheet.dart';
import 'labels.dart';
import 'unit_style.dart';
import 'widgets/tracking_map.dart';

class TrackingScreen extends ConsumerWidget {
  final int incidentId;

  const TrackingScreen({super.key, required this.incidentId});

  Future<void> _openCancelSheet(BuildContext context, WidgetRef ref) async {
    final cancelled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CancelSheet(incidentId: incidentId),
    );
    if (cancelled != true || !context.mounted) return;

    // نعيد تشغيل المتابعة عشان الحالة الجديدة تظهر فورًا
    ref.invalidate(incidentStreamProvider(incidentId));

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.reportCancelled)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(incidentStreamProvider(incidentId));
    final units = ref.watch(assignedUnitsProvider(incidentId)).value ??
        const <AssignedUnit>[];

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.reportNumber} #$incidentId'),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            message: error is Failure
                ? error.message
                : const UnknownFailure().message,
            onRetry: () => ref.invalidate(incidentStreamProvider(incidentId)),
          ),
          data: (incident) => _Content(
            incident: incident,
            units: units,
            onCancel: () => _openCancelSheet(context, ref),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final Incident incident;
  final List<AssignedUnit> units;
  final VoidCallback onCancel;

  const _Content({
    required this.incident,
    required this.units,
    required this.onCancel,
  });

  IconData _statusIcon(IncidentStatus s) {
    return switch (s) {
      IncidentStatus.pending => Icons.schedule,
      IncidentStatus.assigned => Icons.assignment_ind_outlined,
      IncidentStatus.enRoute => Icons.directions_car_outlined,
      IncidentStatus.onScene => Icons.place_outlined,
      IncidentStatus.completed => Icons.check_circle_outline,
      IncidentStatus.cancelled => Icons.cancel_outlined,
      IncidentStatus.unknown => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final status = incident.status;

    final isCancelled = status == IncidentStatus.cancelled;
    final isCompleted = status == IncidentStatus.completed;
    final tint = isCancelled
        ? Colors.black45
        : isCompleted
        ? const Color(0xFF1F9D8B)
        : AppColors.primary;

    final hasLocation = incident.latitude != null && incident.longitude != null;
    final incidentPoint = hasLocation
        ? LatLng(incident.latitude!, incident.longitude!)
        : null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الحالة الحالية
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _statusIcon(status),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusLabel(l10n, status),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            incidentCategoryLabel(l10n, incident.category),
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // الخريطة والوحدات (طول ما البلاغ شغال)
              if (!status.isFinished && incidentPoint != null) ...[
                TrackingMap(incident: incidentPoint, units: units),
                const SizedBox(height: 16),
                _UnitsSection(
                  units: units,
                  incident: incidentPoint,
                  status: status,
                ),
              ],

              // الشات مع غرفة العمليات (بيفضل متاح للقراءة بعد انتهاء البلاغ)
              if (!isCancelled) ...[
                _ChatCard(incidentId: incident.id),
                const SizedBox(height: 16),
              ],

              // التقدم أو سبب الإلغاء
              if (isCancelled)
                _Card(
                  title: l10n.reasonLabel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (incident.cancellationCategory != null)
                        Text(
                          cancellationLabel(l10n, incident.cancellationCategory!),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (incident.cancellationReason != null) ...[
                        const SizedBox(height: 4),
                        Text(incident.cancellationReason!),
                      ],
                    ],
                  ),
                )
              else
                _Card(
                  title: l10n.progress,
                  child: _Timeline(status: status),
                ),
              const SizedBox(height: 16),

              // التفاصيل
              _Card(
                title: l10n.details,
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.personal_injury_outlined,
                      label: l10n.injuredLabel,
                      value: '${incident.injuredCount}',
                    ),
                    if (hasLocation)
                      _DetailRow(
                        icon: Icons.location_on_outlined,
                        label: l10n.locationLabel,
                        value:
                        '${incident.latitude!.toStringAsFixed(4)}, ${incident.longitude!.toStringAsFixed(4)}',
                      ),
                    _DetailRow(
                      icon: Icons.notes_outlined,
                      label: l10n.whatsHappening,
                      value: (incident.description?.isNotEmpty ?? false)
                          ? incident.description!
                          : l10n.noDescription,
                    ),
                  ],
                ),
              ),

              if (status.canCancel) ...[
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: onCancel,
                  child: Text(l10n.cancelReport),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// كارت فتح الشات، وعليه علامة لو في رسالة جديدة.
class _ChatCard extends ConsumerWidget {
  final int incidentId;

  const _ChatCard({required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final unread = ref.watch(unreadChatProvider(incidentId));

    return InkWell(
      onTap: () => context.push('/citizen/incident/$incidentId/chat'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unread ? AppColors.primary : Colors.black12,
            width: unread ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatWithDispatcher,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.foreground,
                    ),
                  ),
                  Text(
                    l10n.chatCardSubtitle,
                    style:
                    textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.newMessage,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

/// قايمة الوحدات المعيّنة: النوع والحالة والمسافة والوقت المتوقع.
class _UnitsSection extends StatelessWidget {
  final List<AssignedUnit> units;
  final LatLng incident;
  final IncidentStatus status;

  const _UnitsSection({
    required this.units,
    required this.incident,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (units.isEmpty) {
      // لسه مفيش وحدة: بنعرض رسالة الانتظار في أول حالة بس
      if (status != IncidentStatus.pending) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _Card(
          title: l10n.unitsTitle,
          child: Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.noUnitsYet,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _Card(
        title: l10n.unitsTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final unit in units) _UnitTile(unit: unit, incident: incident),
            const SizedBox(height: 4),
            Text(
              l10n.etaApproxNote,
              style: textTheme.labelSmall?.copyWith(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final AssignedUnit unit;
  final LatLng incident;

  const _UnitTile({required this.unit, required this.incident});

  String _distanceText(AppLocalizations l10n, double meters) {
    if (meters < 1000) return '${meters.round()} ${l10n.metersShort}';
    return '${(meters / 1000).toStringAsFixed(1)} ${l10n.kmShort}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    final color = unitColor(unit.type);
    final arrived = unit.status == UnitStatus.arrived;
    final meters = distanceMeters(
      unit.latitude,
      unit.longitude,
      incident.latitude,
      incident.longitude,
    );

    final typeLabel = unitTypeLabel(l10n, unit.type);
    final title =
    unit.firstName == null ? typeLabel : '$typeLabel · ${unit.firstName}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(unitIcon(unit.type), color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                Text(
                  unitStatusLabel(l10n, unit.status),
                  style: textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          if (arrived)
            const Icon(Icons.check_circle, color: Color(0xFF1F9D8B))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _distanceText(l10n, meters),
                  style: textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '≈ ${unit.type.etaMinutes(meters)} ${l10n.minutesShort}',
                  style: textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final IncidentStatus status;

  const _Timeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.statusPending,
      l10n.statusAssigned,
      l10n.statusEnRoute,
      l10n.statusOnScene,
      l10n.statusCompleted,
    ];
    final current = status.stepIndex;
    final allDone = status == IncidentStatus.completed;

    return Column(
      children: [
        for (var i = 0; i < labels.length; i++)
          _TimelineRow(
            label: labels[i],
            done: allDone || i < current,
            active: !allDone && i == current,
            isLast: i == labels.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final bool isLast;

  const _TimelineRow({
    required this.label,
    required this.done,
    required this.active,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = done || active;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: highlighted ? AppColors.primary : Colors.black26,
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : active
                    ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? AppColors.primary : Colors.black12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  color: highlighted ? AppColors.foreground : Colors.black45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: Colors.black54),
                ),
                Text(value, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}