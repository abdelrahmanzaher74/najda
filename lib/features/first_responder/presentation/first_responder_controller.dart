import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/first_responder_providers.dart';
import '../data/models/first_responder_application.dart';

class FirstResponderController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// بترجع true لو الطلب اتبعت.
  Future<bool> submit(ApplyRequest request) async {
    state = const AsyncLoading();
    try {
      await ref.read(firstResponderRepositoryProvider).submitApplication(request);
      // نحدّث حالة الطلب فورًا
      ref.invalidate(firstResponderApplicationProvider);
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final firstResponderControllerProvider =
AsyncNotifierProvider<FirstResponderController, void>(
    FirstResponderController.new);