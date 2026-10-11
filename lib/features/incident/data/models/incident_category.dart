/// نوع البلاغ (حقل category في جدول incidents).
/// القيم مؤقتة (MEDICAL / FIRE / POLICE) لحد ما نتأكد منها من الـ Backend.
enum IncidentCategory {
  medical('MEDICAL'),
  fire('FIRE'),
  police('POLICE');

  final String code;
  const IncidentCategory(this.code);

  static IncidentCategory? tryFromCode(String? code) {
    for (final c in IncidentCategory.values) {
      if (c.code == code?.toUpperCase()) return c;
    }
    return null;
  }
}