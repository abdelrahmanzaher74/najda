import '../../../l10n/app_localizations.dart';
import '../data/models/medical_profile.dart';

String allergyLabel(AppLocalizations l10n, Allergy a) {
  return switch (a) {
    Allergy.penicillin => l10n.allergyPenicillin,
    Allergy.peanuts => l10n.allergyPeanuts,
    Allergy.latex => l10n.allergyLatex,
    Allergy.aspirin => l10n.allergyAspirin,
    Allergy.beeStings => l10n.allergyBeeStings,
    Allergy.shellfish => l10n.allergyShellfish,
  };
}

String conditionLabel(AppLocalizations l10n, MedicalCondition c) {
  return switch (c) {
    MedicalCondition.asthma => l10n.conditionAsthma,
    MedicalCondition.diabetes => l10n.conditionDiabetes,
    MedicalCondition.epilepsy => l10n.conditionEpilepsy,
    MedicalCondition.heartDisease => l10n.conditionHeartDisease,
    MedicalCondition.hypertension => l10n.conditionHypertension,
  };
}