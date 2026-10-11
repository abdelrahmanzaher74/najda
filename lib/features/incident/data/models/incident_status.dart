/// حالة البلاغ (حقل status في جدول incidents).
/// القيم تخمين لحد ما نتأكد منها من الـ Backend.
enum IncidentStatus {
  pending('PENDING'),
  assigned('ASSIGNED'),
  enRoute('EN_ROUTE'),
  onScene('ON_SCENE'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  final String code;
  const IncidentStatus(this.code);

  static IncidentStatus fromCode(String? code) {
    for (final s in IncidentStatus.values) {
      if (s.code == code?.toUpperCase()) return s;
    }
    return IncidentStatus.unknown;
  }

  /// قرار الفريق: المواطن يقدر يلغي طول ما مفيش حد قبل الحالة
  /// (يعني لسه Pending). السيرفر لازم يطبّق القاعدة دي كمان.
  bool get canCancel => this == IncidentStatus.pending;

  bool get isFinished =>
      this == IncidentStatus.completed || this == IncidentStatus.cancelled;

  /// ترتيب الخطوة في الـ timeline (0 إلى 4)، و -1 لغيرها
  int get stepIndex => switch (this) {
    IncidentStatus.pending => 0,
    IncidentStatus.assigned => 1,
    IncidentStatus.enRoute => 2,
    IncidentStatus.onScene => 3,
    IncidentStatus.completed => 4,
    _ => -1,
  };
}