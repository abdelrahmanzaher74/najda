import 'create_incident_request.dart';

/// بلاغ محفوظ على الموبايل وبانتظار الإرسال.
class PendingReport {
  /// بعد المدة دي بنسأل المستخدم قبل الإرسال (الموقع ممكن يكون اتغيّر).
  static const staleAfter = Duration(minutes: 30);

  final String id;

  /// صاحب البلاغ، عشان مستخدم تاني على نفس الموبايل ما يبعتوش.
  final int userId;
  final CreateIncidentRequest request;
  final DateTime capturedAt;

  const PendingReport({
    required this.id,
    required this.userId,
    required this.request,
    required this.capturedAt,
  });

  bool get isStale => DateTime.now().difference(capturedAt) > staleAfter;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'capturedAt': capturedAt.toIso8601String(),
    'request': request.toJson(),
  };

  factory PendingReport.fromJson(Map<String, dynamic> json) {
    return PendingReport(
      id: json['id'] as String,
      userId: (json['userId'] as num).toInt(),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      request: CreateIncidentRequest.fromJson(
        json['request'] as Map<String, dynamic>,
      ),
    );
  }
}