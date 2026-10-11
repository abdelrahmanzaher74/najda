import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/auth_providers.dart';

enum EmailStep { idle, codeSent, verified }

class EmailVerificationState {
  final EmailStep step;
  final bool busy;
  final String? error;

  /// الإيميل اللي اتبعتله الكود أو اتأكد.
  final String? email;
  final DateTime? resendAvailableAt;
  final DateTime? verifiedUntil;
  final String? registrationToken;

  const EmailVerificationState({
    this.step = EmailStep.idle,
    this.busy = false,
    this.error,
    this.email,
    this.resendAvailableAt,
    this.verifiedUntil,
    this.registrationToken,
  });

  /// متأكد ولسه صلاحية التأكيد ما انتهتش
  bool get isVerified =>
      step == EmailStep.verified &&
          (verifiedUntil?.isAfter(DateTime.now()) ?? false);

  EmailVerificationState copyWith({
    bool? busy,
    String? error,
    bool clearError = false,
  }) {
    return EmailVerificationState(
      step: step,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      email: email,
      resendAvailableAt: resendAvailableAt,
      verifiedUntil: verifiedUntil,
      registrationToken: registrationToken,
    );
  }
}

class EmailVerificationController extends Notifier<EmailVerificationState> {
  @override
  EmailVerificationState build() => const EmailVerificationState();

  /// بيبعت الكود (أو بيعيد إرساله).
  Future<void> sendCode(String email) async {
    if (state.busy) return;

    final clean = email.trim();
    state = state.copyWith(busy: true, clearError: true);

    try {
      final info = await ref.read(authRepositoryProvider).sendEmailCode(clean);
      if (!ref.mounted) return;

      state = EmailVerificationState(
        step: EmailStep.codeSent,
        email: clean,
        resendAvailableAt: info.resendAvailableAt,
      );
    } on Failure catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, error: e.message);
    }
  }

  /// بيتأكد من الكود.
  Future<void> verify(String code) async {
    final email = state.email;
    if (email == null || state.busy) return;

    state = state.copyWith(busy: true, clearError: true);

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .verifyEmailCode(email: email, code: code.trim());
      if (!ref.mounted) return;

      state = EmailVerificationState(
        step: EmailStep.verified,
        email: email,
        verifiedUntil: result.verifiedUntil,
        registrationToken: result.registrationToken,
      );
    } on Failure catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, error: e.message);
    }
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }

  /// يرجّع للبداية (لما الإيميل يتغيّر مثلًا).
  void reset() => state = const EmailVerificationState();
}

/// autoDispose: بيتصفّر لما نخرج من شاشة التسجيل.
final emailVerificationControllerProvider = NotifierProvider.autoDispose<
    EmailVerificationController,
    EmailVerificationState>(EmailVerificationController.new);