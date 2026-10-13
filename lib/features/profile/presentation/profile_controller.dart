import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/models/gender.dart';
import '../../auth/presentation/session_controller.dart';

/// رسالة خطأ جاهزة للعرض.
String profileErrorMessage(Object? error) {
  return error is Failure ? error.message : const UnknownFailure().message;
}

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// بترجع true لو اتحدّث البروفايل.
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required Gender gender,
    required String address,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).updateProfile(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        address: address,
      );
      ref.read(sessionProvider.notifier).setUser(user);
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// بتبعت كود للرقم الجديد. بترجّع وقت إعادة الإرسال، أو null لو فشلت.
  Future<DateTime?> startPhoneChange(String phoneE164) async {
    state = const AsyncLoading();
    try {
      final resendAt =
      await ref.read(authRepositoryProvider).startPhoneChange(phoneE164);
      state = const AsyncData(null);
      return resendAt;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// بتأكد الكود وتحدّث الرقم. بترجع true لو نجحت.
  Future<bool> confirmPhoneChange({
    required String phoneE164,
    required String code,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .confirmPhoneChange(phoneE164: phoneE164, code: code);
      ref.read(sessionProvider.notifier).setUser(user);
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final profileControllerProvider =
AsyncNotifierProvider<ProfileController, void>(ProfileController.new);