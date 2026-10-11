import 'incident_category.dart';

/// بيانات إرسال البلاغ. الحقول بتطابق جدول incidents.
class CreateIncidentRequest {
  final IncidentCategory category;
  final String? description;
  final int injuredCount;
  final double latitude;
  final double longitude;
  final String locationSource;

  const CreateIncidentRequest({
    required this.category,
    this.description,
    this.injuredCount = 0,
    required this.latitude,
    required this.longitude,
    this.locationSource = 'GPS',
  });

  // أسماء المفاتيح وقيمة locationSource تخمين، هنأكدهم من الـ Backend وقت الربط.
  Map<String, dynamic> toJson() => {
    'category': category.code,
    'description': description,
    'injuredCount': injuredCount,
    'latitude': latitude,
    'longitude': longitude,
    'locationSource': locationSource,
  };

  /// بنستخدمه لقراءة البلاغ المحفوظ في الطابور الأوفلاين.
  factory CreateIncidentRequest.fromJson(Map<String, dynamic> json) {
    return CreateIncidentRequest(
      category: IncidentCategory.tryFromCode(json['category'] as String?) ??
          IncidentCategory.medical,
      description: json['description'] as String?,
      injuredCount: (json['injuredCount'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationSource: json['locationSource'] as String? ?? 'GPS',
    );
  }
}