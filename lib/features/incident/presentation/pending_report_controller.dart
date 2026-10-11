import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/incident_providers.dart';
import '../data/models/create_incident_request.dart';
import '../data/models/pending_report.dart';
import '../data/pending_report_store.dart';

class PendingState {
  final PendingReport? report;
  final bool sending;

  /// رسالة خطأ لو السيرفر رفض البلاغ (مش مشكلة نت).
  final String? error;

  const PendingState({this.report, this.sending = false, this.error});
}

/// بيدير البلاغ المحفوظ (الطابور الأوفلاين). بلاغ واحد بس في المرة.
class PendingReportController extends Notifier<PendingState> {
  bool _staleConfirmed = false;

  @override
  PendingState build() {
    // بيتعاد بناؤه لما المستخدم يتغيّر (دخول/خروج)
    final user = ref.watch(sessionProvider);
    _staleConfirmed = false;

    if (user != null) {
      Future.microtask(() => _load(user.id));
    }
    return const PendingState();
  }

  Future<void> _load(int userId) async {
    final stored = await ref.read(pendingStoreProvider).load();
    if (!ref.mounted) return;
    if (ref.read(sessionProvider)?.id != userId) return;

    if (stored != null && stored.userId == userId) {
      state = PendingState(report: stored);
      await trySend();
    }
  }

  /// بيحفظ البلاغ محليًا (لما مفيش نت).
  Future<void> enqueue(CreateIncidentRequest request) async {
    final user = ref.read(sessionProvider);
    if (user == null) return;

    final now = DateTime.now();
    final report = PendingReport(
      id: now.microsecondsSinceEpoch.toString(),
      userId: user.id,
      request: request,
      capturedAt: now,
    );

    await ref.read(pendingStoreProvider).save(report);
    if (!ref.mounted) return;

    _staleConfirmed = false;
    state = PendingState(report: report);
  }

  /// بيحاول يبعت البلاغ المحفوظ.
  /// manual = true لما المستخدم هو اللي داس "Send now".
  Future<void> trySend({bool manual = false}) async {
    final current = state;
    final report = current.report;
    if (report == null || current.sending) return;

    // السيرفر رفض قبل كده: ما نعيدش تلقائيًا، المستخدم هو اللي يقرر
    if (!manual && current.error != null) return;

    // قديم (أكتر من 30 دقيقة): لازم المستخدم يوافق الأول
    if (report.isStale && !_staleConfirmed) {
      // instance جديد عشان الشاشة تتحدّث وتعرض رسالة "البلاغ قديم"
      state = PendingState(report: report, error: current.error);
      return;
    }

    state = PendingState(report: report, sending: true);
    try {
      final incident =
      await ref.read(incidentRepositoryProvider).createIncident(report.request);
      await ref.read(pendingStoreProvider).clear();
      if (!ref.mounted) return;

      ref.read(activeIncidentIdProvider.notifier).setId(incident.id);
      state = const PendingState();
    } on NetworkFailure {
      if (!ref.mounted) return;
      state = PendingState(report: report);
    } on Failure catch (e) {
      if (!ref.mounted) return;
      state = PendingState(report: report, error: e.message);
    }
  }

  /// المستخدم وافق يبعت بلاغ قديم.
  Future<void> confirmStaleAndSend() async {
    _staleConfirmed = true;
    await trySend(manual: true);
  }

  /// المستخدم حذف البلاغ المحفوظ.
  Future<void> discard() async {
    await ref.read(pendingStoreProvider).clear();
    if (!ref.mounted) return;

    _staleConfirmed = false;
    state = const PendingState();
  }
}

final pendingReportControllerProvider =
NotifierProvider<PendingReportController, PendingState>(
    PendingReportController.new);