import '../../incident/data/models/incident_category.dart';
import 'models/guidance_card.dart';

/// طلب الإرشادات: نوع البلاغ وعدد المصابين واللغة.
typedef GuidanceRequest = ({
IncidentCategory category,
int injuredCount,
String languageCode,
});

/// الواجهة اللي الشاشات بتتعامل معاها.
/// دلوقتي بروتوكولات ثابتة. بعدين الـ AI/الـ Backend يختار الكروت المناسبة،
/// والتطبيق يعرض نصها من المكتبة المحلية (فتشتغل حتى من غير نت).
abstract class GuidanceRepository {
  Future<List<GuidanceCard>> getGuidance(GuidanceRequest request);
}