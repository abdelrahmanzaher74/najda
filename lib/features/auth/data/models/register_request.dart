import 'gender.dart';

/// بيانات التسجيل. الحقول بتطابق جدول users،
/// وكلمة المرور بتروح لـ Firebase بس (مش بتتبعت للـ Backend).
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final Gender gender;
  final String password;

  /// الـ token اللي رجع بعد تأكيد الإيميل بالكود.
  final String registrationToken;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.password,
    required this.registrationToken,
  });

  // أسماء المفاتيح تخمين (camelCase)، هنأكدها من الـ Backend وقت الربط.
  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'address': address,
    'gender': gender.code,
    'registrationToken': registrationToken,
  };
}