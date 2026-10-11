import '../../../core/error/failure.dart';
import 'auth_repository.dart';
import 'models/app_user.dart';
import 'models/email_verification.dart';
import 'models/register_request.dart';
import 'models/user_role.dart';

class FakeAuthRepository implements AuthRepository {
  static const _fakeCode = '123456';
  static const _maxAttempts = 5;

  /// عدد المحاولات الغلط لكل إيميل (بيحاكي attempts في الجدول)
  final Map<String, int> _codeAttempts = {};

  /// للتجربة بس: الدور بيتحدد من اسم الإيميل
  /// (ambulance@test.com ← Ambulance، admin@test.com ← Admin، وهكذا)
  UserRole _roleFromEmail(String email) {
    switch (email.split('@').first.toLowerCase()) {
      case 'responder':
        return UserRole.firstResponder;
      case 'ambulance':
        return UserRole.ambulanceCrew;
      case 'fire':
        return UserRole.firefighter;
      case 'police':
        return UserRole.police;
      case 'dispatcher':
        return UserRole.dispatcher;
      case 'hospital':
        return UserRole.hospitalStaff;
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
        return UserRole.superAdmin;
      default:
        return UserRole.citizen;
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (password != '123456') {
      throw const AuthFailure('Invalid email or password');
    }

    return AppUser(
      id: 1,
      firebaseUid: 'fake-uid',
      firstName: 'Test',
      lastName: 'User',
      email: email,
      phone: '01000000000',
      address: 'Test address',
      profileCompleted: true,
      role: _roleFromEmail(email),
    );
  }

  @override
  Future<EmailCodeInfo> sendEmailCode(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final key = email.trim().toLowerCase();

    // للتجربة: الإيميل ده بيحاكي حساب موجود
    if (key == 'taken@test.com') {
      throw const ValidationFailure('Email already registered');
    }

    _codeAttempts[key] = 0;
    final now = DateTime.now();
    return EmailCodeInfo(
      expiresAt: now.add(const Duration(minutes: 10)),
      resendAvailableAt: now.add(const Duration(seconds: 30)),
    );
  }

  @override
  Future<EmailVerification> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final key = email.trim().toLowerCase();
    final attempts = _codeAttempts[key] ?? 0;

    if (attempts >= _maxAttempts) {
      throw const ValidationFailure(
        'Too many attempts. Please request a new code.',
      );
    }

    if (code != _fakeCode) {
      _codeAttempts[key] = attempts + 1;
      final left = _maxAttempts - attempts - 1;
      throw ValidationFailure(
        left > 0
            ? 'Wrong code. $left attempts left.'
            : 'Too many attempts. Please request a new code.',
      );
    }

    return EmailVerification(
      registrationToken: 'fake-registration-token-$key',
      verifiedUntil: DateTime.now().add(const Duration(minutes: 30)),
    );
  }

  @override
  Future<AppUser> registerCitizen(RegisterRequest request) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // زي الـ Backend الحقيقي: لازم الإيميل يكون متأكد
    if (request.registrationToken.isEmpty) {
      throw const ValidationFailure('Email not verified');
    }

    return AppUser(
      id: 2,
      firebaseUid: 'fake-uid-new',
      firstName: request.firstName,
      lastName: request.lastName,
      email: request.email,
      phone: request.phone,
      address: request.address,
      gender: request.gender.code,
      profileCompleted: true,
      role: UserRole.citizen,
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // للتجربة: الإيميل ده بيحاكي انقطاع النت
    if (email == 'fail@test.com') {
      throw const NetworkFailure();
    }
  }

  @override
  Future<void> signOut() async {}
}