import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/models/gender.dart';
import '../../../auth/presentation/session_controller.dart';
import '../profile_controller.dart';

/// نافذة تعديل الاسم والنوع والعنوان. بترجّع true لو اتحفظ.
class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _address;
  Gender? _gender;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider);
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _address = TextEditingController(text: user?.address ?? '');

    for (final g in Gender.values) {
      if (g.code == user?.gender) _gender = g;
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final ok = await ref.read(profileControllerProvider.notifier).updateProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      gender: _gender!,
      address: _address.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = profileErrorMessage(ref.read(profileControllerProvider).error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isLoading = ref.watch(profileControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.editProfileTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstName,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l10n.firstName),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.firstNameRequired
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastName,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l10n.lastName),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.lastNameRequired
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: l10n.gender,
                  prefixIcon: const Icon(Icons.wc_outlined),
                ),
                items: [
                  DropdownMenuItem(
                    value: Gender.male,
                    child: Text(l10n.male),
                  ),
                  DropdownMenuItem(
                    value: Gender.female,
                    child: Text(l10n.female),
                  ),
                ],
                onChanged: (value) => setState(() => _gender = value),
                validator: (v) => v == null ? l10n.genderRequired : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.addressRequired
                    : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 18),
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
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}