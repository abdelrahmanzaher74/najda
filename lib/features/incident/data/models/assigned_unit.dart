import 'dart:math';

/// نوع الوحدة المعيّنة على البلاغ.
/// الأكواد تخمين (بتقابل unit_type في response_units) لحد ما نتأكد من الـ Backend.
enum ResponderType {
  ambulance('AMBULANCE', 40.0),
  firstResponder('FIRST_RESPONDER', 20.0),
  police('POLICE', 40.0),
  fire('FIRE', 35.0);

  final String code;

  /// سرعة افتراضية (كم/س) لحساب الوقت المتوقع للوصول بشكل تقريبي.
  final double assumedSpeedKmh;

  const ResponderType(this.code, this.assumedSpeedKmh);

  static ResponderType? tryFromCode(String? code) {
    for (final t in ResponderType.values) {
      if (t.code == code?.toUpperCase()) return t;
    }
    return null;
  }

  /// الوقت المتوقع بالدقايق (تقريبي، من مسافة مباشرة).
  int etaMinutes(double meters) {
    return max(1, (meters / 1000 / assumedSpeedKmh * 60).ceil());
  }
}

/// حالة الوحدة من وجهة نظر المواطن (بعد ما تقبل الحالة بس).
enum UnitStatus { accepted, enRoute, arrived }

/// وحدة معيّنة على البلاغ (من missions و response_units).
/// الخصوصية: بنعرض النوع والاسم الأول بس، من غير تليفون.
class AssignedUnit {
  final int id;
  final ResponderType type;
  final String? firstName;
  final UnitStatus status;
  final double latitude;
  final double longitude;

  const AssignedUnit({
    required this.id,
    required this.type,
    this.firstName,
    required this.status,
    required this.latitude,
    required this.longitude,
  });
}