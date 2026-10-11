import 'cancellation_category.dart';
import 'incident_category.dart';
import 'incident_status.dart';

/// بيطابق جدول incidents.
class Incident {
  final int id;
  final IncidentCategory category;
  final String? description;
  final int injuredCount;
  final double? latitude;
  final double? longitude;
  final String? locationSource;
  final String? address;
  final IncidentStatus status;
  final DateTime? createdAt;
  final CancellationCategory? cancellationCategory;
  final String? cancellationReason;
  final DateTime? cancelledAt;

  const Incident({
    required this.id,
    required this.category,
    this.description,
    this.injuredCount = 0,
    this.latitude,
    this.longitude,
    this.locationSource,
    this.address,
    required this.status,
    this.createdAt,
    this.cancellationCategory,
    this.cancellationReason,
    this.cancelledAt,
  });

  Incident copyWith({
    IncidentStatus? status,
    CancellationCategory? cancellationCategory,
    String? cancellationReason,
    DateTime? cancelledAt,
  }) {
    return Incident(
      id: id,
      category: category,
      description: description,
      injuredCount: injuredCount,
      latitude: latitude,
      longitude: longitude,
      locationSource: locationSource,
      address: address,
      status: status ?? this.status,
      createdAt: createdAt,
      cancellationCategory: cancellationCategory ?? this.cancellationCategory,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  // أسماء المفاتيح تخمين (camelCase)، هنأكدها من رد حقيقي من الـ Backend.
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: (json['id'] as num).toInt(),
      category: IncidentCategory.tryFromCode(json['category'] as String?) ??
          IncidentCategory.medical,
      description: json['description'] as String?,
      injuredCount: (json['injuredCount'] as num?)?.toInt() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationSource: json['locationSource'] as String?,
      address: json['address'] as String?,
      status: IncidentStatus.fromCode(json['status'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      cancellationCategory: CancellationCategory.tryFromCode(
        json['cancellationCategory'] as String?,
      ),
      cancellationReason: json['cancellationReason'] as String?,
      cancelledAt: DateTime.tryParse(json['cancelledAt'] as String? ?? ''),
    );
  }
}