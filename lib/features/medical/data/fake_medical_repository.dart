import 'medical_repository.dart';
import 'models/medical_profile.dart';

/// بيحفظ في الذاكرة بس (بيضيع لما التطبيق يتقفل).
class FakeMedicalRepository implements MedicalRepository {
  MedicalProfile? _profile;

  @override
  Future<MedicalProfile?> getMyProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile;
  }

  @override
  Future<void> saveMyProfile(MedicalProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _profile = profile;
  }
}