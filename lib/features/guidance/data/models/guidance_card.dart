/// كارت إرشادات جاهز للعرض (النص بالفعل مترجم).
/// الـ id ثابت، عشان بعدين الـ AI أو الـ Backend يقدر يختار الكروت بالـ id بس.
class GuidanceCard {
  final String id;
  final String title;
  final List<String> steps;

  /// تحذير مهم يظهر بلون مختلف (اختياري).
  final String? warning;

  /// الكارت العام (الأهم) اللي بيظهر أول حاجة.
  final bool isGeneral;

  const GuidanceCard({
    required this.id,
    required this.title,
    required this.steps,
    this.warning,
    this.isGeneral = false,
  });
}