import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import 'fake_first_responder_repository.dart';
import 'first_responder_repository.dart';
import 'models/first_responder_application.dart';

/// وقت الربط الحقيقي: FakeFirstResponderRepository() ← RealFirstResponderRepository(...)
final firstResponderRepositoryProvider =
Provider<FirstResponderRepository>((ref) {
  return FakeFirstResponderRepository();
});

/// حالة طلبي. بيتابع كل 5 ثواني وهو قيد المراجعة، وبعدها كل دقيقة.
/// (الرئيسية وشاشة الطلب بيشاركوا نفس الـ stream.)
final firstResponderApplicationProvider =
StreamProvider.autoDispose<FirstResponderApplication?>((ref) async* {
  final repo = ref.read(firstResponderRepositoryProvider);
  var first = true;

  while (true) {
    try {
      final app = await repo.getMyApplication();
      first = false;
      yield app;

      final waiting = app?.status == ApplicationStatus.submitted;
      await Future.delayed(Duration(seconds: waiting ? 5 : 60));
    } on Failure {
      // أول تحميل فشل: نظهر الخطأ. غير كده نكمّل بهدوء.
      if (first) rethrow;
      await Future.delayed(const Duration(seconds: 30));
    }
  }
});