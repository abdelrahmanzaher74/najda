import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../data/medical_providers.dart';
import '../data/models/medical_profile.dart';
import 'medical_history_controller.dart';
import 'medical_labels.dart';
import 'widgets/option_chip_group.dart';

class MedicalHistoryScreen extends ConsumerStatefulWidget {
  /// true = تعديل (تبويب البطاقة الطبية)، false = أول مرة بعد التسجيل.
  final bool editing;

  const MedicalHistoryScreen({super.key, this.editing = false});

  @override
  ConsumerState<MedicalHistoryScreen> createState() =>
      _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends ConsumerState<MedicalHistoryScreen> {
  final _formKey = GlobalKey<FormState>();

  BloodType? _bloodType;
  final Set<Allergy> _allergies = {};
  final List<String> _otherAllergies = [];
  final Set<MedicalCondition> _conditions = {};
  final List<String> _otherConditions = [];

  final _medicationsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  bool _loadingExisting = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing) {
      _loadingExisting = true;
      _loadExisting();
    }
  }

  @override
  void dispose() {
    _medicationsController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  /// بيحمّل البيانات المحفوظة (في وضع التعديل).
  Future<void> _loadExisting() async {
    try {
      final profile = await ref.read(medicalRepositoryProvider).getMyProfile();
      if (!mounted) return;

      if (profile != null) {
        setState(() {
          _bloodType = profile.bloodType;
          _allergies.addAll(profile.allergies);
          _otherAllergies.addAll(profile.otherAllergies);
          _conditions.addAll(profile.conditions);
          _otherConditions.addAll(profile.otherConditions);
          _medicationsController.text = profile.medications ?? '';

          final contact = profile.emergencyContact;
          if (contact != null) {
            _contactNameController.text = contact.name;
            _contactPhoneController.text =
                normalizeEgyptianMobile(contact.phone) ?? contact.phone;
          }
        });
      }
    } catch (_) {
      // لو فشل التحميل بنسيب الفورم فاضي
    }

    if (mounted) setState(() => _loadingExisting = false);
  }

  void _toggle<T>(Set<T> set, T value) {
    setState(() {
      if (!set.remove(value)) set.add(value);
    });
  }

  void _addOther(List<String> list, String text) {
    final exists = list.any((e) => e.toLowerCase() == text.toLowerCase());
    if (!exists) setState(() => list.add(text));
  }

  void _removeOther(List<String> list, String text) {
    setState(() => list.remove(text));
  }

  /// بعد أول تسجيل: بنصفّر العلم ونروح للرئيسية.
  void _finishOnboarding() {
    ref.read(needsMedicalHistoryProvider.notifier).set(false);
    context.go('/citizen');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _contactNameController.text.trim();
    final phoneDigits = normalizeEgyptianMobile(_contactPhoneController.text);
    final medications = _medicationsController.text.trim();

    final profile = MedicalProfile(
      bloodType: _bloodType,
      allergies: _allergies.toList(),
      otherAllergies: List.of(_otherAllergies),
      conditions: _conditions.toList(),
      otherConditions: List.of(_otherConditions),
      medications: medications.isEmpty ? null : medications,
      emergencyContact: (name.isNotEmpty && phoneDigits != null)
          ? EmergencyContact(name: name, phone: toEgyptE164(phoneDigits))
          : null,
    );

    final ok =
    await ref.read(medicalHistoryControllerProvider.notifier).save(profile);
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.medicalSaved)));

      // في وضع التبويب بنفضل في مكاننا، وأول مرة بنكمّل للرئيسية
      if (!widget.editing) _finishOnboarding();
    } else {
      final error = ref.read(medicalHistoryControllerProvider).error;
      final message =
      error is Failure ? error.message : const UnknownFailure().message;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final isLoading = ref.watch(medicalHistoryControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.medicalHistoryTitle),
      ),
      body: SafeArea(
        child: _loadingExisting
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.medicalHistorySubtitle,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: n.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // فصيلة الدم (اختيار واحد)
                    _SectionCard(
                      icon: Icons.water_drop_outlined,
                      title: l10n.bloodType,
                      subtitle: l10n.bloodTypeHint,
                      child: OptionChipGroup<BloodType>(
                        options: BloodType.values,
                        labelOf: (b) => b.code,
                        selected: {if (_bloodType != null) _bloodType!},
                        onToggle: (b) => setState(
                              () => _bloodType = _bloodType == b ? null : b,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // الحساسية
                    _SectionCard(
                      icon: Icons.warning_amber_rounded,
                      title: l10n.allergies,
                      subtitle: l10n.selectAllThatApply,
                      child: OptionChipGroup<Allergy>(
                        options: Allergy.values,
                        labelOf: (a) => allergyLabel(l10n, a),
                        selected: _allergies,
                        onToggle: (a) => _toggle(_allergies, a),
                        others: _otherAllergies,
                        onAddOther: (text) =>
                            _addOther(_otherAllergies, text),
                        onRemoveOther: (text) =>
                            _removeOther(_otherAllergies, text),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // الأمراض
                    _SectionCard(
                      icon: Icons.monitor_heart_outlined,
                      title: l10n.medicalConditions,
                      subtitle: l10n.selectAllThatApply,
                      child: OptionChipGroup<MedicalCondition>(
                        options: MedicalCondition.values,
                        labelOf: (c) => conditionLabel(l10n, c),
                        selected: _conditions,
                        onToggle: (c) => _toggle(_conditions, c),
                        others: _otherConditions,
                        onAddOther: (text) =>
                            _addOther(_otherConditions, text),
                        onRemoveOther: (text) =>
                            _removeOther(_otherConditions, text),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // الأدوية
                    _SectionCard(
                      icon: Icons.medication_outlined,
                      title: l10n.currentMedications,
                      subtitle: l10n.optionalLabel,
                      child: TextFormField(
                        controller: _medicationsController,
                        maxLength: 255,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: l10n.medicationsHint,
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // جهة اتصال الطوارئ
                    _SectionCard(
                      icon: Icons.phone_in_talk_outlined,
                      title: l10n.emergencyContact,
                      subtitle: l10n.emergencyContactHint,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _contactNameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.contactName,
                              prefixIcon:
                              const Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              final phoneFilled = _contactPhoneController
                                  .text
                                  .trim()
                                  .isNotEmpty;
                              final nameEmpty =
                                  value?.trim().isEmpty ?? true;
                              return (phoneFilled && nameEmpty)
                                  ? l10n.contactNameRequired
                                  : null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _contactPhoneController,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            maxLength: 11,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.contactPhone,
                              hintText: '1012345678',
                              counterText: '',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    '+20',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: n.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              final raw = value?.trim() ?? '';
                              if (raw.isEmpty) {
                                return _contactNameController.text
                                    .trim()
                                    .isNotEmpty
                                    ? l10n.phoneRequired
                                    : null;
                              }
                              return normalizeEgyptianMobile(raw) == null
                                  ? l10n.phoneInvalid
                                  : null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: isLoading ? null : _save,
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        widget.editing
                            ? l10n.save
                            : l10n.saveAndContinue,
                      ),
                    ),
                    if (!widget.editing) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: isLoading ? null : _finishOnboarding,
                        child: Text(l10n.skipForNow),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: n.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: n.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      subtitle,
                      style: textTheme.bodySmall
                          ?.copyWith(color: n.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}