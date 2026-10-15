import 'models/first_responder_application.dart';

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي التنفيذ وهمي، وبعدين هيبقى الـ API الحقيقي
/// (POST /api/responders/apply وطلب حالة طلبي).
abstract class FirstResponderRepository {
  /// آخر طلب للمستخدم، أو null لو ما قدّمش.
  Future<FirstResponderApplication?> getMyApplication();

  Future<FirstResponderApplication> submitApplication(ApplyRequest request);
}