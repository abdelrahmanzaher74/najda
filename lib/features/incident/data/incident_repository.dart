import 'models/cancellation_category.dart';
import 'models/create_incident_request.dart';
import 'models/incident.dart';

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي التنفيذ وهمي، وبعدين هيبقى الـ API الحقيقي.
abstract class IncidentRepository {
  /// POST /api/incidents
  Future<Incident> createIncident(CreateIncidentRequest request);

  /// GET /api/incidents/{id}
  Future<Incident> getIncident(int id);

  /// متابعة البلاغ (بعدين: WebSocket /topic/emergency/{id})
  Stream<Incident> watchIncident(int id);

  /// POST /api/incidents/{id}/cancel
  Future<Incident> cancelIncident(
      int id, {
        required CancellationCategory category,
        String? reason,
      });
}