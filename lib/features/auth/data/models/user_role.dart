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

  /// يقدر يبلّغ عن طوارئ لنفسه: المواطن، والمستجيب الأول (هو مواطن كمان).
  bool get canReport =>
      this == UserRole.citizen || this == UserRole.firstResponder;

  /// بيستخدم شاشات المواطن (الشريط السفلي).
  bool get usesCitizenApp => canReport;

  /// موظف ميداني بس (إسعاف / إطفاء / شرطة): شاشاته /field من غير شاشات المواطن.
  bool get isFieldOnly => isFieldRole && this != UserRole.firstResponder;
}