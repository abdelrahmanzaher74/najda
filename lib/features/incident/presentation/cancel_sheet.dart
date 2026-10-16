import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/cancellation_category.dart';
import 'cancel_controller.dart';
import 'labels.dart';

/// نافذة الإلغاء. بترجّع true (عن طريق Navigator.pop) لو اتلغى البلاغ.
class CancelSheet extends ConsumerStatefulWidget {
  final int incidentId;

  const CancelSheet({super.key, required this.incidentId});

  @override
  ConsumerState<CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends ConsumerState<CancelSheet> {
  final _reasonController = TextEditingController();
  CancellationCategory? _category;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final reason = _reasonController.text.trim();

    if (_category == null) {
      setState(() => _error = l10n.cancelCategoryRequired);
      return;
    }
    if (_category == CancellationCategory.other && reason.isEmpty) {
      setState(() => _error = l10n.reasonRequired);
      return;
    }
    setState(() => _error = null);

    final ok = await ref.read(cancelControllerProvider.notifier).cancel(
      widget.incidentId,
      _category!,
      reason.isEmpty ? null : reason,
    );
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(cancelControllerProvider).error;
      setState(() {
        _error =
        error is Failure ? error.message : const UnknownFailure().message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final isLoading = ref.watch(cancelControllerProvider).isLoading;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.cancelTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: n.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.cancelWhy,
              style: textTheme.bodyMedium?.copyWith(color: n.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in CancellationCategory.values)
                  ChoiceChip(
                    label: Text(cancellationLabel(l10n, c)),
                    selected: _category == c,
                    showCheckmark: false,
                    backgroundColor: n.card,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: _category == c ? AppColors.primary : n.border,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _category == c
                          ? AppColors.primary
                          : n.textPrimary,
                    ),
                    onSelected: (_) => setState(() {
                      _category = c;
                      _error = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLength: 255,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.cancelReasonHint,
                border: border(n.border),
                enabledBorder: border(n.border),
                focusedBorder: border(AppColors.primary, 1.5),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                    isLoading ? null : () => Navigator.of(context).pop(false),
                    child: Text(l10n.keepReport),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : _confirm,
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(l10n.confirmCancel),
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