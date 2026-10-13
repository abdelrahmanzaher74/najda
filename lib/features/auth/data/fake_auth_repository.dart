import '../../../core/error/failure.dart';
import 'auth_repository.dart';
import 'models/app_user.dart';
import 'models/email_verification.dart';
import 'models/gender.dart';
import 'models/register_request.dart';
import 'models/user_role.dart';

class FakeAuthRepository implements AuthRepository {
  static const _fakeCode = '123456';
  static const _maxAttempts = 5;

  /// عدد المحاولات الغلط لكل إيميل (بيحاكي attempts في الجدول)
  final Map<String, int> _codeAttempts = {};

  /// المستخدم الحالي (بيحاكي اللي الـ Backend عارفه من الـ token)
  AppUser? _user;

  /// كلمة المرور الحالية (بتتغيّر فعلًا لما تغيّرها من البروفايل)
  String _password = '123456';

  String? _pendingPhone;
  int _phoneAttempts = 0;

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

  AppUser _requireUser() {
    final user = _user;
    if (user == null) throw const AuthFailure('Not signed in');
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (password != _password) {
      throw const AuthFailure('Invalid email or password');
    }

    final user = AppUser(
      id: 1,
      firebaseUid: 'fake-uid',
      firstName: 'Test',
      lastName: 'User',
      email: email,
      phone: '+201000000000',
      address: 'Test address',
      gender: 'MALE',
      profileCompleted: true,
      role: _roleFromEmail(email),
      emailVerified: true,
      // للتجربة: إيميل يبدأ بـ google بيحاكي حساب Google (من غير كلمة مرور)
      hasPassword: !email.toLowerCase().startsWith('google'),
    );
    _user = user;
    return user;
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

    final user = AppUser(
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
      emailVerified: true,
    );
    _user = user;
    _password = request.password;
    return user;
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
  Future<AppUser> updateProfile({
    required String firstName,
    required String lastName,
    required Gender gender,
    required String address,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final updated = _requireUser().copyWith(
      firstName: firstName,
      lastName: lastName,
      gender: gender.code,
      address: address,
    );
    _user = updated;
    return updated;
  }

  @override
  Future<DateTime> startPhoneChange(String phoneE164) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _requireUser();

    // للتجربة: الرقم ده بيحاكي رقم مستخدم عند حد تاني
    if (phoneE164 == '+201111111111') {
      throw const ValidationFailure('This phone number is already used');
    }

    _pendingPhone = phoneE164;
    _phoneAttempts = 0;
    return DateTime.now().add(const Duration(seconds: 30));
  }

  @override
  Future<AppUser> confirmPhoneChange({
    required String phoneE164,
    required String code,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = _requireUser();

    if (_pendingPhone != phoneE164) {
      throw const ValidationFailure('Please request a new code first.');
    }
    if (_phoneAttempts >= _maxAttempts) {
      throw const ValidationFailure(
        'Too many attempts. Please request a new code.',
      );
    }
    if (code != _fakeCode) {
      _phoneAttempts++;
      final left = _maxAttempts - _phoneAttempts;
      throw ValidationFailure(
        left > 0
            ? 'Wrong code. $left attempts left.'
            : 'Too many attempts. Please request a new code.',
      );
    }

    final updated = user.copyWith(phone: phoneE164, phoneVerified: true);
    _user = updated;
    _pendingPhone = null;
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _requireUser();

    if (currentPassword != _password) {
      throw const AuthFailure('Current password is incorrect');
    }
    _password = newPassword;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}