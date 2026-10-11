class AppConfig {
  AppConfig._();

  // مؤقت: هنغيّره لما نعرف الـ base URL الحقيقي للـ Backend.
  // 10.0.2.2 هو عنوان جهازك من جوه الـ Android emulator.
  static const String baseUrl = 'http://10.0.2.2:8080';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // روابط الشروط والخصوصية (نفس اللي في الويب)
  static const String termsUrl = 'https://najda-test.vercel.app/terms';
  static const String privacyUrl = 'https://najda-test.vercel.app/privacy';
}