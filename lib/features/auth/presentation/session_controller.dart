import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_providers.dart';
import '../data/models/app_user.dart';

/// بيحتفظ بالمستخدم الحالي (null = مش مسجّل دخول).
/// الـ router بيراقبه عشان يوجّه المستخدم حسب الـ role.
class SessionController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void setUser(AppUser user) => state = user;

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }
}

final sessionProvider =
NotifierProvider<SessionController, AppUser?>(SessionController.new);