import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/auth_providers.dart';

class ForgotPasswordController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// بترجع true لو اتبعت الرابط
  Future<bool> sendReset(String email) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final forgotPasswordControllerProvider =
AsyncNotifierProvider<ForgotPasswordController, void>(
    ForgotPasswordController.new);