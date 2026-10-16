/// حالة المستجيب (متاح / مشغول / غير متصل).
/// القيم اقتراح من الدوكيومنت (FR26)، وهنتأكد منها من الـ Backend
/// (غالبًا بتتخزن في response_units.status).
enum ResponderAvailability {
  available('AVAILABLE'),
  busy('BUSY'),
  offline('OFFLINE');

  final String code;
  const ResponderAvailability(this.code);

  static ResponderAvailability fromCode(String? code) {
    for (final a in ResponderAvailability.values) {
      if (a.code == code?.toUpperCase()) return a;
    }
    return ResponderAvailability.offline;
  }
}