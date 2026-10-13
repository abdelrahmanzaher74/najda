import 'models/app_user.dart';
import 'models/email_verification.dart';
import 'models/gender.dart';
import 'models/register_request.dart';

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي التنفيذ وهمي، وبعدين هيبقى Firebase + الـ API.
abstract class AuthRepository {
  Future<AppUser> signIn({required String email, required String password});

  /// بيبعت كود تأكيد (6 أرقام) للإيميل. (جدول email_verifications)
  Future<EmailCodeInfo> sendEmailCode(String email);

  /// بيتأكد من الكود، وبيرجّع registrationToken لازم يتبعت مع التسجيل.
  Future<EmailVerification> verifyEmailCode({
    required String email,
    required String code,
  });

  Future<AppUser> registerCitizen(RegisterRequest request);

  /// Firebase هو اللي بيبعت الإيميل مباشرة (مش الـ Backend).
  Future<void> sendPasswordReset(String email);

  /// PATCH /api/users/{id}/profile
  Future<AppUser> updateProfile({
    required String firstName,
    required String lastName,
    required Gender gender,
    required String address,
  });

  /// PATCH /api/users/me/phone (بيعلّم الرقم غير مؤكد) + إرسال كود SMS عن طريق Firebase.
  /// بيرجّع الوقت اللي يتاح فيه إعادة الإرسال.
  Future<DateTime> startPhoneChange(String phoneE164);

  /// تأكيد الكود (Firebase) ثم POST /api/users/me/sync-phone.
  Future<AppUser> confirmPhoneChange({
    required String phoneE164,
    required String code,
  });

  /// Firebase مباشرة: إعادة التحقق بالباسورد الحالي ثم تغييره.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();
}