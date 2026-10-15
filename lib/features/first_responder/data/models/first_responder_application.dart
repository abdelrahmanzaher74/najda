import '../../../../core/files/document_picker.dart';

/// حالة الطلب (حقل status في first_responder_applications).
/// القيم تخمين لحد ما نتأكد منها من الـ Backend.
enum ApplicationStatus {
  submitted('SUBMITTED'),
  approved('APPROVED'),
  rejected('REJECTED'),
  unknown('UNKNOWN');

  final String code;
  const ApplicationStatus(this.code);

  static ApplicationStatus fromCode(String? code) {
    for (final s in ApplicationStatus.values) {
      if (s.code == code?.toUpperCase()) return s;
    }
    return ApplicationStatus.unknown;
  }
}

/// مستند مرفوع (جدول first_responder_application_documents).
class ApplicationDocument {
  final String fileName;

  const ApplicationDocument(this.fileName);
}

/// طلب الانضمام كمستجيب أول. بيطابق جدول first_responder_applications.
class FirstResponderApplication {
  final int id;
  final ApplicationStatus status;
  final String motivation;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final List<ApplicationDocument> documents;

  const FirstResponderApplication({
    required this.id,
    required this.status,
    required this.motivation,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
    this.documents = const [],
  });

  // أسماء المفاتيح تخمين (camelCase)، هنأكدها من رد حقيقي من الـ Backend.
  factory FirstResponderApplication.fromJson(Map<String, dynamic> json) {
    final docs = (json['documents'] as List?) ?? const [];

    return FirstResponderApplication(
      id: (json['id'] as num).toInt(),
      status: ApplicationStatus.fromCode(json['status'] as String?),
      motivation: json['motivation'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '')
          ?.toLocal() ??
          DateTime.now(),
      reviewedAt:
      DateTime.tryParse(json['reviewedAt'] as String? ?? '')?.toLocal(),
      reviewNotes: json['reviewNotes'] as String?,
      documents: [
        for (final d in docs)
          if (d is Map)
            ApplicationDocument(d['originalFileName'] as String? ?? ''),
      ],
    );
  }
}

/// بيانات التقديم. الملفات بتترفع الأول (رابط موقّع) وبعدين بنبعت الطلب.
class ApplyRequest {
  final String motivation;
  final List<PickedDocument> documents;

  const ApplyRequest({required this.motivation, required this.documents});
}