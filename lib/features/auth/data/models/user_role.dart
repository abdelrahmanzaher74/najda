enum UserRole {
  citizen('CITIZEN'),
  firstResponder('FIRST_RESPONDER'),
  ambulanceCrew('AMBULANCE_CREW'),
  firefighter('FIREFIGHTER'),
  police('POLICE'),
  dispatcher('DISPATCHER'),
  hospitalStaff('HOSPITAL_STAFF'),
  admin('ADMIN'),
  superAdmin('SUPER_ADMIN'),
  unknown('UNKNOWN');

  final String code;
  const UserRole(this.code);

  static UserRole fromCode(String? code) {
    final clean = code?.replaceFirst('ROLE_', '');
    return UserRole.values.firstWhere(
          (r) => r.code == clean,
      orElse: () => UserRole.unknown,
    );
  }

  /// الأدوار اللي بتستخدم تطبيق الموبايل
  bool get isMobileRole => const [
    UserRole.citizen,
    UserRole.firstResponder,
    UserRole.ambulanceCrew,
    UserRole.firefighter,
    UserRole.police,
  ].contains(this);

  /// الأدوار الميدانية (بتستقبل مهام)
  bool get isFieldRole => const [
    UserRole.firstResponder,
    UserRole.ambulanceCrew,
    UserRole.firefighter,
    UserRole.police,
  ].contains(this);
}