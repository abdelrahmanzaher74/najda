import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../incident/presentation/active_report.dart';
import 'fake_responder_repository.dart';
import 'models/responder_availability.dart';
import 'responder_repository.dart';

/// وقت الربط الحقيقي: FakeResponderRepository() ← RealResponderRepository(...)
final responderRepositoryProvider = Provider<ResponderRepository>((ref) {
  return FakeResponderRepository();
});

/// الحالة اللي المستجيب اختارها.
class AvailabilityController extends AsyncNotifier<ResponderAvailability> {
  @override
  Future<ResponderAvailability> build() {
    return ref.read(responderRepositoryProvider).getAvailability();
  }

  /// بترجّع null لو نجح، أو الـ Failure لو فشل (وبتلغي التغيير).
  Future<Failure?> set(ResponderAvailability value) async {
    final previous = state.value ?? ResponderAvailability.offline;
    if (previous == value) return null;

    // بنغيّر في الشاشة فورًا، ونرجّع لو فشل
    state = AsyncData(value);
    try {
      await ref.read(responderRepositoryProvider).setAvailability(value);
      return null;
    } on Failure catch (e) {
      state = AsyncData(previous);
      return e;
    }
  }
}

final availabilityProvider =
AsyncNotifierProvider<AvailabilityController, ResponderAvailability>(
    AvailabilityController.new);

/// الحالة الفعلية: لو عنده بلاغ نشط لنفسه وهو "متاح" بيتحسب "مشغول" تلقائيًا.
final effectiveAvailabilityProvider = Provider<ResponderAvailability>((ref) {
  final chosen =
      ref.watch(availabilityProvider).value ?? ResponderAvailability.offline;
  final hasOwnReport = ref.watch(hasActiveIncidentProvider);

  if (hasOwnReport && chosen == ResponderAvailability.available) {
    return ResponderAvailability.busy;
  }
  return chosen;
});