import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/medical_providers.dart';
import '../data/models/medical_profile.dart';

class MedicalHistoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// بترجع true لو اتحفظ
  Future<bool> save(MedicalProfile profile) async {
    state = const AsyncLoading();
    try {
      await ref.read(medicalRepositoryProvider).saveMyProfile(profile);
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final medicalHistoryControllerProvider =
AsyncNotifierProvider<MedicalHistoryController, void>(
    MedicalHistoryController.new);