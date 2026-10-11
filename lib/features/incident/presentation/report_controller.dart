import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/network/connectivity_helper.dart';
import '../data/incident_providers.dart';
import '../data/models/create_incident_request.dart';
import '../data/models/incident.dart';
import 'active_report.dart';
import 'pending_report_controller.dart';

/// نتيجة محاولة الإرسال.
enum SubmitResult {
  /// وصل للسيرفر
  sent,

  /// مفيش نت: اتحفظ على الموبايل وهيتبعت تلقائيًا
  queued,

  /// فشل (رسالة الخطأ في state)
  failed,
}

class ReportController extends AsyncNotifier<Incident?> {
  @override
  Future<Incident?> build() async => null;

  Future<SubmitResult> submit(CreateIncidentRequest request) async {
    // قاعدة: بلاغ واحد نشط في المرة (السيرفر لازم يطبّقها كمان)
    if (ref.read(hasActiveIncidentProvider)) {
      state = AsyncError(
        const ValidationFailure('You already have an active report'),
        StackTrace.current,
      );
      return SubmitResult.failed;
    }

    state = const AsyncLoading();
    final pending = ref.read(pendingReportControllerProvider.notifier);

    // مفيش نت؟ نحفظ فورًا من غير ما نستنى مهلة الاتصال
    if (await isOffline()) {
      await pending.enqueue(request);
      state = const AsyncData(null);
      return SubmitResult.queued;
    }

    try {
      final incident =
      await ref.read(incidentRepositoryProvider).createIncident(request);
      ref.read(activeIncidentIdProvider.notifier).setId(incident.id);
      state = AsyncData(incident);
      return SubmitResult.sent;
    } on NetworkFailure {
      await pending.enqueue(request);
      state = const AsyncData(null);
      return SubmitResult.queued;
    } on Failure catch (e, st) {
      state = AsyncError(e, st);
      return SubmitResult.failed;
    }
  }
}

final reportControllerProvider =
AsyncNotifierProvider<ReportController, Incident?>(ReportController.new);