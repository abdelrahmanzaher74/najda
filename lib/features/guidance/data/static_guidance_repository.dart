import '../../incident/data/models/incident_category.dart';
import 'guidance_content.dart';
import 'guidance_repository.dart';
import 'models/guidance_card.dart';

class StaticGuidanceRepository implements GuidanceRepository {
  @override
  Future<List<GuidanceCard>> getGuidance(GuidanceRequest request) async {
    final lang = request.languageCode;

    final definitions = switch (request.category) {
      IncidentCategory.medical => [
        GuidanceContent.medicalGeneral,
        if (request.injuredCount >= 2) GuidanceContent.multipleInjured,
        ...GuidanceContent.medicalTopics,
      ],
      IncidentCategory.fire => [
        GuidanceContent.fireGeneral,
        ...GuidanceContent.fireTopics,
      ],
      IncidentCategory.police => [
        GuidanceContent.policeGeneral,
        ...GuidanceContent.policeTopics,
      ],
    };

    return definitions
        .map(
          (d) => GuidanceCard(
        id: d.id,
        title: d.title.of(lang),
        steps: d.steps.map((s) => s.of(lang)).toList(),
        warning: d.warning?.of(lang),
        isGeneral: d.isGeneral,
      ),
    )
        .toList();
  }
}