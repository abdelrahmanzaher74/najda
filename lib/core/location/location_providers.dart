import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/failure.dart';
import 'app_location.dart';
import 'location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

/// الموقع الحالي. الشاشة بتراقبه، وبتعمل invalidate لما المستخدم يضغط على زر المحاولة.
/// لو الفشل سببه إعدادات لازم المستخدم يغيّرها بنفسه (صلاحية محظورة أو دقة)،
/// وبعدين رجع للتطبيق من الإعدادات، بيعيد المحاولة تلقائيًا.
final currentLocationProvider =
FutureProvider.autoDispose<AppLocation>((ref) async {
  var retryOnResume = false;

  final listener = AppLifecycleListener(
    onResume: () {
      if (retryOnResume) ref.invalidateSelf();
    },
  );
  ref.onDispose(listener.dispose);

  try {
    return await ref.read(locationServiceProvider).getCurrentLocation();
  } catch (e) {
    retryOnResume = e is LocationFailure &&
        (e.issue == LocationIssue.permissionDeniedForever ||
            e.issue == LocationIssue.imprecise);
    rethrow;
  }
});

/// تجهيز مسبق: أول ما المواطن يدخل، بنطلب الصلاحية ونشغّل الـ GPS
/// ونبدأ تحديد الموقع، فلما يضغط SOS يكون جاهز. الأخطاء هنا بتتجاهل،
/// وشاشة البلاغ هي اللي بتعرضها.
final locationPrepProvider = FutureProvider<void>((ref) async {
  try {
    await ref.read(locationServiceProvider).getCurrentLocation();
  } catch (_) {}
});