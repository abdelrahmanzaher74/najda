import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake_medical_repository.dart';
import 'medical_repository.dart';

/// وقت الربط الحقيقي: FakeMedicalRepository() ← RealMedicalRepository(...)
final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  return FakeMedicalRepository();
});

/// هل المواطن لسه لازم يعدّي على صفحة التاريخ الطبي؟
/// بيتفعّل بعد إنشاء الحساب، والـ router بيوجّه ليها.
/// (بعد الربط الحقيقي هنعرف ده من الـ Backend بدل ما نحتفظ بيه في الذاكرة.)
class NeedsMedicalHistoryController extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final needsMedicalHistoryProvider =
NotifierProvider<NeedsMedicalHistoryController, bool>(
    NeedsMedicalHistoryController.new);