import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../core/location/app_location.dart';
import '../../../core/location/location_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/create_incident_request.dart';
import '../data/models/incident_category.dart';
import 'report_controller.dart';
import 'widgets/location_map_card.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final IncidentCategory initialCategory;

  const ReportScreen({
    super.key,
    this.initialCategory = IncidentCategory.medical,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _descriptionController = TextEditingController();
  late IncidentCategory _category = widget.initialCategory;
  int _injured = 0;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _comingNext() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.comingNextStep)));
  }

  Future<void> _openSettings(LocationIssue issue) async {
    final service = ref.read(locationServiceProvider);
    if (issue == LocationIssue.serviceDisabled) {
      await service.openLocationSettings();
    } else {
      await service.openAppSettings();
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/citizen');
    }
  }

  Future<void> _submit() async {
    // قاعدة: ممنوع إرسال البلاغ من غير موقع حقيقي
    final location = ref.read(currentLocationProvider).asData?.value;
    if (location == null) return;

    final text = _descriptionController.text.trim();

    final request = CreateIncidentRequest(
      category: _category,
      description: text.isEmpty ? null : text,
      injuredCount: _injured,
      latitude: location.latitude,
      longitude: location.longitude,
    );

    final result =
    await ref.read(reportControllerProvider.notifier).submit(request);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    switch (result) {
      case SubmitResult.sent:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportSent)));
        _leave();
      case SubmitResult.queued:
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportQueued)));
        _leave();
      case SubmitResult.failed:
        final error = ref.read(reportControllerProvider).error;
        final message =
        error is Failure ? error.message : const UnknownFailure().message;
        messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  InputDecoration _areaDecoration(String hint) {
    final n = context.najda;
    final error = Theme.of(context).colorScheme.error;
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      border: border(n.border),
      enabledBorder: border(n.border),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(error),
      focusedErrorBorder: border(error, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final isLoading = ref.watch(reportControllerProvider).isLoading;
    final locationState = ref.watch(currentLocationProvider);
    final hasLocation = locationState.asData?.value != null;

    final sectionStyle = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
      color: n.textPrimary,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // نوع البلاغ
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.medical_services_outlined,
                          label: l10n.medical,
                          selected: _category == IncidentCategory.medical,
                          onTap: () => setState(
                                  () => _category = IncidentCategory.medical),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.local_fire_department_outlined,
                          label: l10n.fire,
                          selected: _category == IncidentCategory.fire,
                          onTap: () =>
                              setState(() => _category = IncidentCategory.fire),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CategoryCard(
                          icon: Icons.local_police_outlined,
                          label: l10n.police,
                          selected: _category == IncidentCategory.police,
                          onTap: () => setState(
                                  () => _category = IncidentCategory.police),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // الوصف
                  Text(l10n.whatsHappening.toUpperCase(), style: sectionStyle),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 2000,
                    textInputAction: TextInputAction.newline,
                    decoration: _areaDecoration(l10n.descriptionHint),
                  ),
                  const SizedBox(height: 12),

                  // عدد المصابين
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: n.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: n.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.personal_injury_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.numberOfInjured,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: n.textPrimary,
                            ),
                          ),
                        ),
                        _RoundButton(
                          icon: Icons.remove,
                          filled: false,
                          onTap: _injured > 0
                              ? () => setState(() => _injured--)
                              : null,
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_injured',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: n.textPrimary,
                            ),
                          ),
                        ),
                        _RoundButton(
                          icon: Icons.add,
                          filled: true,
                          onTap: _injured < 99
                              ? () => setState(() => _injured++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // المرفقات
                  Text(l10n.attachEvidence.toUpperCase(), style: sectionStyle),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _EvidenceButton(
                        icon: Icons.upload_outlined,
                        label: l10n.upload,
                        onTap: _comingNext,
                      ),
                      const SizedBox(width: 12),
                      _EvidenceButton(
                        icon: Icons.mic_none,
                        label: l10n.recordAudio,
                        onTap: _comingNext,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // الموقع + الخريطة
                  _LocationSection(
                    state: locationState,
                    onRetry: () => ref.invalidate(currentLocationProvider),
                    onOpenSettings: _openSettings,
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: (isLoading || !hasLocation) ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(l10n.sendReport),
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

class _LocationSection extends StatelessWidget {
  final AsyncValue<AppLocation> state;
  final VoidCallback onRetry;
  final Future<void> Function(LocationIssue issue) onOpenSettings;

  const _LocationSection({
    required this.state,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    return state.when(
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: n.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: n.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.gettingLocation,
              style: textTheme.bodySmall?.copyWith(color: n.textSecondary),
            ),
          ],
        ),
      ),
      data: (location) => LocationMapCard(location: location),
      error: (error, _) {
        final issue = error is LocationFailure
            ? error.issue
            : LocationIssue.unavailable;

        final message = switch (issue) {
          LocationIssue.serviceDisabled => l10n.locationServiceDisabled,
          LocationIssue.permissionDenied => l10n.locationPermissionDenied,
          LocationIssue.permissionDeniedForever =>
          l10n.locationPermissionForever,
          LocationIssue.unavailable => l10n.locationUnavailable,
          LocationIssue.mockLocation => l10n.mockLocationDetected,
          LocationIssue.imprecise => l10n.locationImprecise,
        };

        // الإعدادات مطلوبة بس لما المستخدم لازم يغيّر حاجة بإيده
        final needsSettings = issue == LocationIssue.permissionDeniedForever ||
            issue == LocationIssue.imprecise;

        final retryLabel = issue == LocationIssue.serviceDisabled
            ? l10n.turnOnLocation
            : l10n.tryAgain;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: textTheme.bodySmall?.copyWith(
                        color: n.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                children: [
                  TextButton(
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                  if (needsSettings)
                    TextButton(
                      onPressed: () => onOpenSettings(issue),
                      child: Text(l10n.openSettings),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.najda;
    final fg = selected ? Colors.white : n.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : n.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: fg),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _RoundButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = context.najda;
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled
              ? (enabled ? AppColors.primary : n.border)
              : n.border,
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? Colors.white : n.textPrimary,
        ),
      ),
    );
  }
}

class _EvidenceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EvidenceButton({
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
      child: Container(
        width: 100,
        height: 92,
        decoration: BoxDecoration(
          color: n.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: n.borderStrong),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: n.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}