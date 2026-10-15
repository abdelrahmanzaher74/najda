import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';

/// مجموعة اختيارات (Chips). لو onAddOther موجود بيظهر زر "Other"
/// بيفتح نافذة تكتب فيها اختيارك، وبيتضاف كـ Chip تقدر تحذفه.
class OptionChipGroup<T> extends StatelessWidget {
  final List<T> options;
  final String Function(T option) labelOf;
  final Set<T> selected;
  final ValueChanged<T> onToggle;

  final List<String> others;
  final ValueChanged<String>? onAddOther;
  final ValueChanged<String>? onRemoveOther;

  const OptionChipGroup({
    super.key,
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onToggle,
    this.others = const [],
    this.onAddOther,
    this.onRemoveOther,
  });

  Future<void> _addOther(BuildContext context) async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _AddOtherDialog(),
    );
    if (text != null && text.isNotEmpty) onAddOther?.call(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final n = context.najda;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(labelOf(option)),
            selected: selected.contains(option),
            showCheckmark: false,
            onSelected: (_) => onToggle(option),
            backgroundColor: n.card,
            selectedColor: AppColors.primary,
            shape: const StadiumBorder(),
            side: BorderSide(
              color: selected.contains(option) ? AppColors.primary : n.border,
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected.contains(option) ? Colors.white : n.textPrimary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          ),

        // اختيارات المستخدم نفسه
        for (final other in others)
          InputChip(
            label: Text(other),
            onDeleted: () => onRemoveOther?.call(other),
            deleteIconColor: Colors.white,
            backgroundColor: AppColors.primary,
            shape: const StadiumBorder(),
            side: const BorderSide(color: AppColors.primary),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          ),

        if (onAddOther != null)
          ActionChip(
            avatar: const Icon(Icons.add, size: 18, color: AppColors.primary),
            label: Text(l10n.otherOption),
            onPressed: () => _addOther(context),
            backgroundColor: n.card,
            shape: const StadiumBorder(),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          ),
      ],
    );
  }
}

class _AddOtherDialog extends StatefulWidget {
  const _AddOtherDialog();

  @override
  State<_AddOtherDialog> createState() => _AddOtherDialogState();
}

class _AddOtherDialogState extends State<_AddOtherDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.addOtherTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 50,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(hintText: l10n.addOtherHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _submit,
          child: Text(l10n.add),
        ),
      ],
    );
  }
}