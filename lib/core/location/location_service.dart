import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;

import '../error/failure.dart';
import 'app_location.dart';

/// الواجهة. الشاشات مش بتعرف إن Geolocator موجود.
abstract class LocationService {
  /// بترجّع الموقع الحقيقي من الجهاز، أو بترمي LocationFailure لو في مشكلة.
  Future<AppLocation> getCurrentLocation();

  Future<void> openLocationSettings();

  Future<void> openAppSettings();
}

class GeolocatorLocationService implements LocationService {
  /// موقع أحدث من 30 ثانية بنستخدمه فورًا (مسار سريع).
  static const _fastPathMaxAge = Duration(seconds: 30);

  /// لو التحديد الجديد فشل، نقبل آخر موقع عمره دقيقتين أو أقل.
  static const _fallbackMaxAge = Duration(minutes: 2);

  /// أسوأ دقة مقبولة. دقة أسوأ من كده معناها غالبًا إن المستخدم
  /// اختار "موقع تقريبي" (Approximate)، فبنمنع الإرسال.
  static const _maxAccuracyMeters = 1000.0;

  bool _isFresh(Position p, Duration maxAge) =>
      DateTime.now().difference(p.timestamp) <= maxAge;

  /// بتعرض نافذة أندرويد "تشغيل الموقع؟" (بضغطة واحدة).
  /// لو الجهاز مفيهوش Google Play Services، بنفتح إعدادات الموقع بدلها.
  Future<bool> _askToEnableService() async {
    try {
      return await loc.Location().requestService();
    } catch (e) {
      debugPrint('[Location] enable dialog unavailable: $e');
      await Geolocator.openLocationSettings();
      return false;
    }
  }

  @override
  Future<AppLocation> getCurrentLocation() async {
    // 1) الصلاحية أولًا: النافذة لازم تظهر حتى لو الـ GPS مقفول
    var permission = await Geolocator.checkPermission();
    debugPrint('[Location] permission (check) = $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('[Location] permission (request) = $permission');
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(LocationIssue.permissionDenied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationIssue.permissionDeniedForever);
    }

    // 2) الـ GPS شغال؟ لو لأ نطلب تشغيله بنافذة النظام
    var enabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[Location] service enabled = $enabled');
    if (!enabled) {
      enabled = await _askToEnableService();
      debugPrint('[Location] service enabled after dialog = $enabled');
    }
    if (!enabled) {
      throw const LocationFailure(LocationIssue.serviceDisabled);
    }

    // 3) مسار سريع: موقع حديث جدًا
    Position? position;
    final last = await Geolocator.getLastKnownPosition();
    if (last != null &&
        _isFresh(last, _fastPathMaxAge) &&
        last.accuracy <= _maxAccuracyMeters) {
      debugPrint('[Location] using fresh last-known position');
      position = last;
    }

    // 4) تحديد جديد بمهلة صارمة
    if (position == null) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        ).timeout(const Duration(seconds: 15));
        debugPrint('[Location] got current position');
      } catch (e) {
        debugPrint('[Location] current position failed: $e');
        if (last != null && _isFresh(last, _fallbackMaxAge)) {
          debugPrint('[Location] using recent last-known position');
          position = last;
        }
      }
    }

    if (position == null) {
      throw const LocationFailure(LocationIssue.unavailable);
    }

    // حماية: برامج تزييف الموقع (Fake GPS)
    if (position.isMocked) {
      throw const LocationFailure(LocationIssue.mockLocation);
    }

    // حماية: موقع غير دقيق (غالبًا اختيار "تقريبي")
    if (position.accuracy > _maxAccuracyMeters) {
      throw const LocationFailure(LocationIssue.imprecise);
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }

  @override
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}