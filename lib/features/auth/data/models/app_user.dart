import 'user_role.dart';

/// بيطابق جدول users في الداتا بيز.
class AppUser {
  final int id;
  final String firebaseUid;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final bool phoneVerified;
  final String? address;
  final String? gender;
  final bool profileCompleted;
  final bool enabled;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.firebaseUid,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.phoneVerified = false,
    this.address,
    this.gender,
    this.profileCompleted = false,
    this.enabled = true,
    required this.role,
  });

  String get fullName => '$firstName $lastName'.trim();

  // أسماء مفاتيح الـ JSON هنا تخمين (camelCase)،
  // هنأكدها من رد حقيقي من الـ Backend ونعدّلها في المكان ده بس.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num).toInt(),
      firebaseUid: json['firebaseUid'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
      role: UserRole.fromCode(_roleName(json['role'])),
    );
  }

  static String? _roleName(dynamic role) {
    if (role is String) return role;
    if (role is Map) {
      return (role['roleName'] ?? role['name']) as String?;
    }
    return null;
  }
}