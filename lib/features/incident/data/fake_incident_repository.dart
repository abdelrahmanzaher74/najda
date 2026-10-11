import '../../../core/error/failure.dart';
import '../../../core/network/connectivity_helper.dart';
import 'incident_repository.dart';
import 'models/cancellation_category.dart';
import 'models/create_incident_request.dart';
import 'models/incident.dart';
import 'models/incident_status.dart';

class FakeIncidentRepository implements IncidentRepository {
  final Map<int, Incident> _items = {};
  int _nextId = 100;

  @override
  Future<Incident> createIncident(CreateIncidentRequest request) async {
    // بيحاكي الـ Backend الحقيقي: مفيش نت ← فشل شبكة
    if (await isOffline()) throw const NetworkFailure();

    await Future.delayed(const Duration(seconds: 1));

    final id = _nextId++;
    final incident = Incident(
      id: id,
      category: request.category,
      description: request.description,
      injuredCount: request.injuredCount,
      latitude: request.latitude,
      longitude: request.longitude,
      locationSource: request.locationSource,
      status: IncidentStatus.pending,
      createdAt: DateTime.now(),
    );
    _items[id] = incident;
    return incident;
  }

  /// بيحاكي تقدم الحالة مع الوقت:
  /// Pending لحد 20 ثانية، وبعدها كل 10 ثواني خطوة جديدة.
  Incident _current(int id) {
    final stored = _items[id];
    if (stored == null) {
      throw const ServerFailure('Report not found', statusCode: 404);
    }
    if (stored.status == IncidentStatus.cancelled) return stored;

    final seconds = DateTime.now().difference(stored.createdAt!).inSeconds;
    final status = seconds < 20
        ? IncidentStatus.pending
        : seconds < 30
        ? IncidentStatus.assigned
        : seconds < 40
        ? IncidentStatus.enRoute
        : seconds < 50
        ? IncidentStatus.onScene
        : IncidentStatus.completed;

    return stored.copyWith(status: status);
  }

  @override
  Future<Incident> getIncident(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _current(id);
  }

  @override
  Stream<Incident> watchIncident(int id) async* {
    while (true) {
      final incident = _current(id);
      yield incident;
      if (incident.status.isFinished) return;
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Future<Incident> cancelIncident(
      int id, {
        required CancellationCategory category,
        String? reason,
      }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final current = _current(id);
    if (!current.status.canCancel) {
      throw const ValidationFailure('This report can no longer be cancelled');
    }

    final cancelled = current.copyWith(
      status: IncidentStatus.cancelled,
      cancellationCategory: category,
      cancellationReason: reason,
      cancelledAt: DateTime.now(),
    );
    _items[id] = cancelled;
    return cancelled;
  }
}