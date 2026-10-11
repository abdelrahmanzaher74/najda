import 'models/app_user.dart';
import 'models/email_verification.dart';
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

  Future<void> signOut();
}