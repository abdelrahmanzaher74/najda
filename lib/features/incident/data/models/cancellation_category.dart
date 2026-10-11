/// سبب الإلغاء (حقل cancellation_category في جدول incidents).
/// القيم تخمين لحد ما نتأكد منها من الـ Backend.
enum CancellationCategory {
  mistake('MISTAKE'),
  resolved('RESOLVED'),
  notNeeded('NOT_NEEDED'),
  other('OTHER');

  final String code;
  const CancellationCategory(this.code);

  static CancellationCategory? tryFromCode(String? code) {
    for (final c in CancellationCategory.values) {
      if (c.code == code?.toUpperCase()) return c;
    }
    return null;
  }
}