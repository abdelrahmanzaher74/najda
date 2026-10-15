import '../../../core/error/failure.dart';
import '../../../core/network/connectivity_helper.dart';
import 'first_responder_repository.dart';
import 'models/first_responder_application.dart';

/// بيحفظ في الذاكرة بس. بيحاكي مراجعة الـ Admin:
/// بعد 20 ثانية الطلب بيتوافق عليه، إلا لو الدافع فيه كلمة reject فبيترفض.
class FakeFirstResponderRepository implements FirstResponderRepository {
  FirstResponderApplication? _submitted;
  int _nextId = 1;

  FirstResponderApplication _resolve(FirstResponderApplication app) {
    final elapsed = DateTime.now().difference(app.submittedAt).inSeconds;
    if (elapsed < 20) return app;

    final rejected = app.motivation.toLowerCase().contains('reject');
    return FirstResponderApplication(
      id: app.id,
      status:
      rejected ? ApplicationStatus.rejected : ApplicationStatus.approved,
      motivation: app.motivation,
      submittedAt: app.submittedAt,
      reviewedAt: app.submittedAt.add(const Duration(seconds: 20)),
      reviewNotes:
      rejected ? 'The certificate is not clear. Please upload a clearer copy.' : null,
      documents: app.documents,
    );
  }

  @override
  Future<FirstResponderApplication?> getMyApplication() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final stored = _submitted;
    return stored == null ? null : _resolve(stored);
  }

  @override
  Future<FirstResponderApplication> submitApplication(
      ApplyRequest request,
      ) async {
    if (await isOffline()) throw const NetworkFailure();
    await Future.delayed(const Duration(milliseconds: 1500));

    final existing = _submitted == null ? null : _resolve(_submitted!);
    if (existing != null && existing.status != ApplicationStatus.rejected) {
      throw const ValidationFailure('You already have an application');
    }

    final app = FirstResponderApplication(
      id: _nextId++,
      status: ApplicationStatus.submitted,
      motivation: request.motivation,
      submittedAt: DateTime.now(),
      documents: [
        for (final d in request.documents) ApplicationDocument(d.name),
      ],
    );
    _submitted = app;
    return app;
  }
}