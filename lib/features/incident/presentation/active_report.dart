import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/incident_providers.dart';
import 'pending_report_controller.dart';

/// هل في بلاغ نشط (لسه ما خلصش، أو محفوظ وبانتظار الإرسال)؟
/// لو آه، ممنوع بلاغ جديد.
/// أثناء التحميل بنعتبره نشط (للأمان)، ولو حصل خطأ مبنمنعش المواطن.
final hasActiveIncidentProvider = Provider<bool>((ref) {
  if (ref.watch(pendingReportControllerProvider).report != null) return true;

  final id = ref.watch(activeIncidentIdProvider);
  if (id == null) return false;

  return ref.watch(incidentStreamProvider(id)).when(
    data: (incident) => !incident.status.isFinished,
    loading: () => true,
    error: (_, __) => false,
  );
});