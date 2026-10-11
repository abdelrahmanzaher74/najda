/// نتيجة طلب إرسال كود التأكيد.
/// بتطابق جدول email_verifications: expires_at و resend_available_at.
class EmailCodeInfo {
  final DateTime expiresAt;
  final DateTime resendAvailableAt;

  const EmailCodeInfo({
    required this.expiresAt,
    required this.resendAvailableAt,
  });
}

/// نتيجة تأكيد الكود. الـ Backend بيخزّن verified_until و hash للـ token،
/// واحنا بنحتفظ بالـ token نفسه ونبعته مع التسجيل.
class EmailVerification {
  final String registrationToken;
  final DateTime verifiedUntil;

  const EmailVerification({
    required this.registrationToken,
    required this.verifiedUntil,
  });
}