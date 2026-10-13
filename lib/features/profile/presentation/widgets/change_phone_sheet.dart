import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/session_controller.dart';
import '../profile_controller.dart';

/// نافذة تغيير/تأكيد رقم الموبايل بكود SMS. بترجّع true لو اتأكد.
class ChangePhoneSheet extends ConsumerStatefulWidget {
  const ChangePhoneSheet({super.key});

  @override
  ConsumerState<ChangePhoneSheet> createState() => _ChangePhoneSheetState();
}

class _ChangePhoneSheetState extends ConsumerState<ChangePhoneSheet> {
  late final TextEditingController _phoneController;
  final _codeController = TextEditingController();

  bool _codeSent = false;
  String? _targetPhone;
  DateTime? _resendAt;
  Timer? _ticker;
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = ref.read(sessionProvider)?.phone ?? '';
    _phoneController =
        TextEditingController(text: normalizeEgyptianMobile(current) ?? '');
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context);
    final digits = normalizeEgyptianMobile(_phoneController.text);
    if (digits == null) {
      setState(() => _error = l10n.phoneInvalid);
      return;
    }

    setState(() => _error = null);
    final phone = toEgyptE164(digits);

    final resendAt =
    await ref.read(profileControllerProvider.notifier).startPhoneChange(phone);
    if (!mounted) return;

    if (resendAt == null) {
      setState(() {
        _error = profileErrorMessage(ref.read(profileControllerProvider).error);
      });
      return;
    }

    setState(() {
      _codeSent = true;
      _targetPhone = phone;
      _resendAt = resendAt;
      _codeController.clear();
    });
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _verify() async {
    setState(() => _error = null);

    final ok = await ref.read(profileControllerProvider.notifier).confirmPhoneChange(
      phoneE164: _targetPhone!,
      code: _codeController.text.trim(),
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

  void _useDifferentNumber() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _codeSent = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isLoading = ref.watch(profileControllerProvider).isLoading;

    final secondsLeft = _resendAt == null
        ? 0
        : max(
      0,
      (_resendAt!.difference(DateTime.now()).inMilliseconds / 1000).ceil(),
    );

    final spinner = const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );

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
              l10n.verifyPhoneTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),

            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: l10n.newPhoneNumber,
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
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isLoading ? null : _sendCode,
                child: isLoading ? spinner : Text(l10n.sendCode),
              ),
            ] else ...[
              Text(
                '${l10n.phoneCodeSentTo} $_targetPhone',
                style: textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _codeController,
                builder: (context, value, _) {
                  final ready = value.text.length == 6 && !isLoading;
                  return FilledButton(
                    onPressed: ready ? _verify : null,
                    child: isLoading ? spinner : Text(l10n.verify),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _useDifferentNumber,
                    child: Text(l10n.useDifferentNumber),
                  ),
                  TextButton(
                    onPressed: (secondsLeft == 0 && !isLoading) ? _sendCode : null,
                    child: Text(
                      secondsLeft == 0
                          ? l10n.resendCode
                          : '${l10n.resendIn} $secondsLeft${l10n.secondsShort}',
                    ),
                  ),
                ],
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(
                _error!,
                style: textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}