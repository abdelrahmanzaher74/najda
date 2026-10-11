import 'models/medical_profile.dart';

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي التنفيذ وهمي، وبعدين هيبقى الـ API الحقيقي.
abstract class MedicalRepository {
  Future<MedicalProfile?> getMyProfile();

  Future<void> saveMyProfile(MedicalProfile profile);
}