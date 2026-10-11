import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/auth_providers.dart';
import '../data/models/app_user.dart';
import 'session_controller.dart';

class LoginController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async => null;

  /// بترجع true لو نجح تسجيل الدخول
  Future<bool> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      ref.read(sessionProvider.notifier).setUser(user);
      state = AsyncData(user);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final loginControllerProvider =
AsyncNotifierProvider<LoginController, AppUser?>(LoginController.new);