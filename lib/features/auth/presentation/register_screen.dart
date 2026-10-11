import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/phone_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/gender.dart';
import '../data/models/register_request.dart';
import 'email_verification_controller.dart';
import 'register_controller.dart';
import 'widgets/email_verification_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  Gender? _gender;
  bool _obscure = true;

  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => _openLink(AppConfig.termsUrl);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _openLink(AppConfig.privacyUrl);

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _comingNext() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.comingNextStep)));
  }

  Future<void> _openLink(String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    if (!opened && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final verification = ref.read(emailVerificationControllerProvider);

    // صلاحية التأكيد ممكن تكون خلصت (بيتحفظ لمدة محدودة)
    if (!verification.isVerified) {
      ref.read(emailVerificationControllerProvider.notifier).reset();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.verificationExpired)));
      return;
    }

    final phoneDigits = normalizeEgyptianMobile(_phoneController.text)!;

    final request = RegisterRequest(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: verification.email!,
      phone: toEgyptE164(phoneDigits),
      address: _addressController.text.trim(),
      gender: _gender!,
      password: _passwordController.text,
      registrationToken: verification.registrationToken!,
    );

    final ok =
    await ref.read(registerControllerProvider.notifier).register(request);
    if (!mounted) return;

    if (ok) {
      // الـ router بيوجّه الحساب الجديد لصفحة التاريخ الطبي
      context.go('/citizen/medical-history');
    } else {
      final error = ref.read(registerControllerProvider).error;
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
    final isLoading = ref.watch(registerControllerProvider).isLoading;

    final linkStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    final noteStyle = textTheme.bodySmall?.copyWith(color: Colors.black54);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.registerTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Google + ملاحظة الشروط
                    OutlinedButton(
                      onPressed: _comingNext,
                      child: Text(l10n.continueWithGoogle),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: noteStyle,
                        children: [
                          TextSpan(text: l10n.googleTermsPrefix),
                          TextSpan(
                            text: l10n.termsOfService,
                            style: linkStyle,
                            recognizer: _termsTap,
                          ),
                          TextSpan(text: l10n.andWord),
                          TextSpan(
                            text: l10n.privacyPolicy,
                            style: linkStyle,
                            recognizer: _privacyTap,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l10n.or, style: noteStyle),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // الاسم الأول والأخير جنب بعض
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            textInputAction: TextInputAction.next,
                            decoration:
                            InputDecoration(labelText: l10n.firstName),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? l10n.firstNameRequired
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration:
                            InputDecoration(labelText: l10n.lastName),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? l10n.lastNameRequired
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // الإيميل + تأكيده بالكود
                    EmailVerificationField(emailController: _emailController),
                    const SizedBox(height: 16),

                    // الموبايل (+20)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      maxLength: 11,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.phone,
                        hintText: '1012345678',
                        counterText: '',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              '+20',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return l10n.phoneRequired;
                        if (normalizeEgyptianMobile(v) == null) {
                          return l10n.phoneInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.address,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.addressRequired
                          : null,
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (value.length < 6) return l10n.passwordTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: l10n.confirmPassword,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? l10n.passwordsDontMatch
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // الموافقة على الشروط (آخر سطر)
                    FormField<bool>(
                      initialValue: false,
                      validator: (value) =>
                      value == true ? null : l10n.mustAgree,
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
                                  child: Text.rich(
                                    TextSpan(
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.foreground,
                                      ),
                                      children: [
                                        TextSpan(text: l10n.agreePrefix),
                                        TextSpan(
                                          text: l10n.termsConditions,
                                          style: linkStyle,
                                          recognizer: _termsTap,
                                        ),
                                        TextSpan(text: l10n.andWord),
                                        TextSpan(
                                          text: l10n.privacyPolicy,
                                          style: linkStyle,
                                          recognizer: _privacyTap,
                                        ),
                                        TextSpan(text: l10n.agreeSuffix),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 4,
                              ),
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
                          : Text(l10n.createAccount),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(l10n.haveAccount),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(l10n.signIn),
                        ),
                      ],
                    ),
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