import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fake_incident_repository.dart';
import 'incident_repository.dart';
import 'models/assigned_unit.dart';
import 'models/incident.dart';

/// وقت الربط الحقيقي: FakeIncidentRepository() ← RealIncidentRepository(...)
final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return FakeIncidentRepository();
});

/// رقم البلاغ النشط حاليًا (بيظهر كـ "Active report" في الرئيسية).
class ActiveIncidentController extends Notifier<int?> {
  @override
  int? build() => null;

  void setId(int? id) => state = id;
}

final activeIncidentIdProvider =
NotifierProvider<ActiveIncidentController, int?>(
    ActiveIncidentController.new);

/// متابعة بلاغ معيّن (الرئيسية وشاشة التتبع بيشاركوا نفس الـ stream).
final incidentStreamProvider =
StreamProvider.autoDispose.family<Incident, int>((ref, id) {
  return ref.read(incidentRepositoryProvider).watchIncident(id);
});

/// الوحدات المعيّنة على بلاغ ومواقعها (للخريطة).
final assignedUnitsProvider = StreamProvider.autoDispose
    .family<List<AssignedUnit>, int>((ref, incidentId) {
  return ref.read(incidentRepositoryProvider).watchAssignedUnits(incidentId);
});