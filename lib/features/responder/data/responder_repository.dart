import 'models/responder_availability.dart';

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي التنفيذ وهمي، وبعدين الـ API الحقيقي.
abstract class ResponderRepository {
  Future<ResponderAvailability> getAvailability();

  Future<void> setAvailability(ResponderAvailability value);
}