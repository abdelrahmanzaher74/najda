import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../medical/data/medical_providers.dart';
import '../data/auth_providers.dart';
import '../data/models/app_user.dart';
import '../data/models/register_request.dart';
import 'session_controller.dart';

class RegisterController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async => null;

  /// بترجع true لو نجح التسجيل
  Future<bool> register(RegisterRequest request) async {
    state = const AsyncLoading();
    try {
      final user =
      await ref.read(authRepositoryProvider).registerCitizen(request);

      // الحساب الجديد لازم يعدّي على صفحة التاريخ الطبي قبل الرئيسية.
      // لازم نضبط العلم قبل ما نسجّل المستخدم عشان الـ router يلاقيه.
      ref.read(needsMedicalHistoryProvider.notifier).set(true);
      ref.read(sessionProvider.notifier).setUser(user);

      state = AsyncData(user);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final registerControllerProvider =
AsyncNotifierProvider<RegisterController, AppUser?>(
    RegisterController.new);