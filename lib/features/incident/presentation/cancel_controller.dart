import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../data/incident_providers.dart';
import '../data/models/cancellation_category.dart';

class CancelController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// بترجع true لو اتلغى البلاغ
  Future<bool> cancel(
      int incidentId,
      CancellationCategory category,
      String? reason,
      ) async {
    state = const AsyncLoading();
    try {
      await ref.read(incidentRepositoryProvider).cancelIncident(
        incidentId,
        category: category,
        reason: reason,
      );
      state = const AsyncData(null);
      return true;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final cancelControllerProvider =
AsyncNotifierProvider<CancelController, void>(CancelController.new);