import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../core/files/document_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/first_responder_providers.dart';
import '../data/models/first_responder_application.dart';
import 'first_responder_controller.dart';

const _maxFiles = 3;
const _maxFileBytes = 5 * 1024 * 1024;

String _formatSize(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

class FirstResponderScreen extends ConsumerStatefulWidget {
  const FirstResponderScreen({super.key});

  @override
  ConsumerState<FirstResponderScreen> createState() =>
      _FirstResponderScreenState();
}

class _FirstResponderScreenState extends ConsumerState<FirstResponderScreen> {
  /// بعد الرفض: المستخدم ضغط "قدّم مرة أخرى"
  bool _reapply = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final n = context.najda;
    final state = ref.watch(firstResponderApplicationProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.frScreenTitle)),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is Failure
                        ? error.message
                        : const UnknownFailure().message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: n.textPrimary),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(firstResponderApplicationProvider),
                    child: Text(l10n.tryAgain),
                  ),
                ],
              ),
            ),
          ),
          data: (app) {
            final showForm = app == null ||
                (app.status == ApplicationStatus.rejected && _reapply);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: showForm
                      ? _ApplyForm(
                    onSubmitted: () => setState(() => _reapply = false),
                  )
                      : _StatusView(
                    app: app!,
                    onReapply: () => setState(() => _reapply = true),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ───────────────────────── نموذج التقديم ─────────────────────────

class _ApplyForm extends ConsumerStatefulWidget {
  final VoidCallback onSubmitted;

  const _ApplyForm({required this.onSubmitted});

  @override
  ConsumerState<_ApplyForm> createState() => _ApplyFormState();
}

class _ApplyFormState extends ConsumerState<_ApplyForm> {
  final _formKey = GlobalKey<FormState>();
  final _motivation = TextEditingController();
  final List<PickedDocument> _docs = [];
  String? _docsError;

  @override
  void dispose() {
    _motivation.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final l10n = AppLocalizations.of(context);
    final picked = await ref.read(documentPickerProvider).pickDocuments();
    if (!mounted || picked.isEmpty) return;

    String? error;
    final merged = [..._docs];

    for (final doc in picked) {
      if (doc.sizeBytes > _maxFileBytes) {
        error = l10n.frFileTooLarge;
        continue;
      }
      if (merged.any((d) => d.path == doc.path)) continue;
      if (merged.length >= _maxFiles) {
        error = l10n.frTooManyFiles;
        break;
      }
      merged.add(doc);
    }

    setState(() {
      _docs
        ..clear()
        ..addAll(merged);
      _docsError = error;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);

    final formOk = _formKey.currentState!.validate();
    if (_docs.isEmpty) setState(() => _docsError = l10n.frFilesRequired);
    if (!formOk || _docs.isEmpty) return;

    final ok = await ref.read(firstResponderControllerProvider.notifier).submit(
      ApplyRequest(
        motivation: _motivation.text.trim(),
        documents: List.of(_docs),
      ),
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.frSubmitted)));
      widget.onSubmitted();
    } else {
      final error = ref.read(firstResponderControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error is Failure ? error.message : const UnknownFailure().message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final isLoading = ref.watch(firstResponderControllerProvider).isLoading;

    final sectionStyle = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
      color: n.textPrimary,
    );

    Widget introStep(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodySmall?.copyWith(color: n.textPrimary),
              ),
            ),
          ],
        ),
      );
    }

    OutlineInputBorder areaBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // مقدمة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.health_and_safety,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.frIntroTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: n.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.frIntroBody,
                  style:
                  textTheme.bodyMedium?.copyWith(color: n.textPrimary),
                ),
                const SizedBox(height: 4),
                introStep(l10n.frStep1),
                introStep(l10n.frStep2),
                introStep(l10n.frStep3),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // الدافع
          Text(l10n.frMotivationLabel.toUpperCase(), style: sectionStyle),
          const SizedBox(height: 10),
          TextFormField(
            controller: _motivation,
            minLines: 4,
            maxLines: 6,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.frMotivationHint,
              border: areaBorder(n.border),
              enabledBorder: areaBorder(n.border),
              focusedBorder: areaBorder(AppColors.primary, 1.5),
            ),
            validator: (v) => (v == null || v.trim().length < 20)
                ? l10n.frMotivationTooShort
                : null,
          ),
          const SizedBox(height: 12),

          // الشهادات
          Text(l10n.frCertificates.toUpperCase(), style: sectionStyle),
          const SizedBox(height: 4),
          Text(
            l10n.frCertificatesHint,
            style: textTheme.bodySmall?.copyWith(color: n.textSecondary),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isLoading ? null : _pickFiles,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.frUploadFiles),
          ),
          for (final doc in _docs)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: n.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: n.border),
              ),
              child: Row(
                children: [
                  Icon(
                    doc.name.toLowerCase().endsWith('.pdf')
                        ? Icons.picture_as_pdf_outlined
                        : Icons.image_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: n.textPrimary,
                          ),
                        ),
                        Text(
                          _formatSize(doc.sizeBytes),
                          style: textTheme.labelSmall
                              ?.copyWith(color: n.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.removeFile,
                    color: n.textSecondary,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _docs.remove(doc);
                      _docsError = null;
                    }),
                  ),
                ],
              ),
            ),
          if (_docsError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _docsError!,
                style: textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),

          // الإقرار
          FormField<bool>(
            initialValue: false,
            validator: (value) => value == true ? null : l10n.mustAgree,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: field.value ?? false,
                      activeColor: AppColors.primary,
                      onChanged: (value) => field.didChange(value),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          l10n.frConfirmation,
                          style: textTheme.bodySmall
                              ?.copyWith(color: n.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: Text(
                      field.errorText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(l10n.frSubmit),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── حالة الطلب ─────────────────────────

class _StatusView extends ConsumerWidget {
  final FirstResponderApplication app;
  final VoidCallback onReapply;

  const _StatusView({required this.app, required this.onReapply});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    final (IconData icon, Color color, String title, String body) =
    switch (app.status) {
      ApplicationStatus.approved => (
      Icons.verified,
      n.success,
      l10n.frStatusApprovedTitle,
      l10n.frStatusApprovedBody,
      ),
      ApplicationStatus.rejected => (
      Icons.cancel_outlined,
      AppColors.primary,
      l10n.frStatusRejectedTitle,
      l10n.frStatusRejectedBody,
      ),
      _ => (
      Icons.hourglass_top,
      n.warning,
      l10n.frStatusSubmittedTitle,
      l10n.frStatusSubmittedBody,
      ),
    };

    final submittedOn =
    MaterialLocalizations.of(context).formatMediumDate(app.submittedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // الحالة
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: n.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: n.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ملاحظات المراجِع (لو في)
        if (app.status == ApplicationStatus.rejected &&
            (app.reviewNotes?.isNotEmpty ?? false)) ...[
          _InfoCard(
            title: l10n.frReviewerNotes,
            child: Text(
              app.reviewNotes!,
              style: textTheme.bodyMedium?.copyWith(color: n.textPrimary),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // التفاصيل
        _InfoCard(
          title: l10n.details,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.frSubmittedOn}: $submittedOn',
                style: textTheme.bodySmall?.copyWith(color: n.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                app.motivation,
                style: textTheme.bodyMedium?.copyWith(color: n.textPrimary),
              ),
              if (app.documents.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.frDocuments,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: n.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                for (final d in app.documents)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 16,
                          color: n.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            d.fileName,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall
                                ?.copyWith(color: n.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),

        if (app.status == ApplicationStatus.rejected) ...[
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onReapply,
            child: Text(l10n.frApplyAgain),
          ),
        ],
        if (app.status == ApplicationStatus.approved) ...[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOut),
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: n.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: n.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}