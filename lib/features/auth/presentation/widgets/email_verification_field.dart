import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../email_verification_controller.dart';

bool _looksLikeEmail(String value) {
  final v = value.trim();
  return v.contains('@') && v.contains('.');
}

/// حقل الإيميل + إرسال الكود + إدخاله + حالة "تم التأكيد".
class EmailVerificationField extends ConsumerStatefulWidget {
  final TextEditingController emailController;

  const EmailVerificationField({super.key, required this.emailController});

  @override
  ConsumerState<EmailVerificationField> createState() =>
      _EmailVerificationFieldState();
}

class _EmailVerificationFieldState
    extends ConsumerState<EmailVerificationField> {
  final _codeController = TextEditingController();
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Widget _spinner({Color color = AppColors.primary}) {
    return SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final state = ref.watch(emailVerificationControllerProvider);
    final controller = ref.read(emailVerificationControllerProvider.notifier);
    final verified = state.step == EmailStep.verified;

    // عدّاد إعادة الإرسال: شغّال بس وإحنا مستنيين الكود
    ref.listen<EmailVerificationState>(emailVerificationControllerProvider,
            (previous, next) {
          if (next.step == EmailStep.codeSent) {
            _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
              if (mounted) setState(() {});
            });
          } else {
            _ticker?.cancel();
            _ticker = null;
          }

          // كود جديد أو خرجنا من مرحلة الكود: نمسح الخانة
          if (previous?.resendAvailableAt != next.resendAvailableAt ||
              next.step != EmailStep.codeSent) {
            _codeController.clear();
          }
        });

    final secondsLeft = state.resendAvailableAt == null
        ? 0
        : max(
      0,
      (state.resendAvailableAt!.difference(DateTime.now()).inMilliseconds /
          1000)
          .ceil(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.emailController,
          readOnly: verified,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.email,
            prefixIcon: const Icon(Icons.mail_outline),
            suffixIcon: verified
                ? Icon(Icons.verified, color: n.success)
                : null,
          ),
          onChanged: (value) {
            final current = ref.read(emailVerificationControllerProvider);
            // تغيير الإيميل بعد الإرسال/التأكيد بيلغي التأكيد
            if (current.step != EmailStep.idle &&
                value.trim() != current.email) {
              controller.reset();
            } else {
              controller.clearError();
            }
          },
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return l10n.emailRequired;
            if (!_looksLikeEmail(v)) return l10n.emailInvalid;
            if (ref.read(emailVerificationControllerProvider).step !=
                EmailStep.verified) {
              return l10n.emailNotVerified;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // 1) لسه ما اتبعتش كود
        if (state.step == EmailStep.idle)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.emailController,
            builder: (context, value, _) {
              final canSend = _looksLikeEmail(value.text) && !state.busy;
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: canSend ? AppColors.primary : n.border,
                    width: 1.5,
                  ),
                ),
                onPressed:
                canSend ? () => controller.sendCode(value.text) : null,
                child: state.busy
                    ? _spinner()
                    : Text(l10n.sendVerificationCode),
              );
            },
          ),

        // 2) الكود اتبعت: ندخله
        if (state.step == EmailStep.codeSent) ...[
          Text(
            '${l10n.verificationSentTo} ${state.email}',
            style: textTheme.bodySmall?.copyWith(color: n.textSecondary),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: textTheme.titleLarge?.copyWith(
              letterSpacing: 10,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: l10n.verificationCode,
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _codeController,
                  builder: (context, value, _) {
                    final ready = value.text.length == 6 && !state.busy;
                    return FilledButton(
                      onPressed: ready
                          ? () => controller.verify(value.text)
                          : null,
                      child: state.busy
                          ? _spinner(color: Colors.white)
                          : Text(l10n.verify),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: (secondsLeft == 0 && !state.busy)
                    ? () => controller.sendCode(state.email!)
                    : null,
                child: Text(
                  secondsLeft == 0
                      ? l10n.resendCode
                      : '${l10n.resendIn} $secondsLeft${l10n.secondsShort}',
                ),
              ),
            ],
          ),
        ],

        // 3) اتأكد
        if (verified)
          Row(
            children: [
              Icon(Icons.verified, size: 20, color: n.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.emailVerified,
                  style: textTheme.bodyMedium?.copyWith(
                    color: n.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: controller.reset,
                child: Text(l10n.changeEmail),
              ),
            ],
          ),

        if (state.error != null) ...[
          const SizedBox(height: 6),
          Text(
            state.error!,
            style: textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}