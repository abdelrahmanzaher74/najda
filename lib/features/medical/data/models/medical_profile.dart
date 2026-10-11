/// فصيلة الدم
enum BloodType {
  aPos('A+'),
  aNeg('A-'),
  bPos('B+'),
  bNeg('B-'),
  abPos('AB+'),
  abNeg('AB-'),
  oPos('O+'),
  oNeg('O-');

  final String code;
  const BloodType(this.code);
}

/// الحساسية الجاهزة (أي حاجة تانية بتتكتب في "Other")
enum Allergy {
  penicillin('PENICILLIN'),
  peanuts('PEANUTS'),
  latex('LATEX'),
  aspirin('ASPIRIN'),
  beeStings('BEE_STINGS'),
  shellfish('SHELLFISH');

  final String code;
  const Allergy(this.code);
}

/// الأمراض الجاهزة (أي حاجة تانية بتتكتب في "Other")
enum MedicalCondition {
  asthma('ASTHMA'),
  diabetes('DIABETES'),
  epilepsy('EPILEPSY'),
  heartDisease('HEART_DISEASE'),
  hypertension('HYPERTENSION');

  final String code;
  const MedicalCondition(this.code);
}

class EmergencyContact {
  final String name;

  /// بصيغة دولية (+20...)
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'name': name, 'phone': phone};
}

/// التاريخ الطبي للمواطن.
/// ملحوظة: الجداول دي لسه مش في الداتا بيز. الشكل ده مؤقت لحد ما
/// صاحبك يضيفها، وهنعدّله وقت الربط (fromJson هنكتبه وقتها).
class MedicalProfile {
  final BloodType? bloodType;
  final List<Allergy> allergies;
  final List<String> otherAllergies;
  final List<MedicalCondition> conditions;
  final List<String> otherConditions;
  final String? medications;
  final EmergencyContact? emergencyContact;

  const MedicalProfile({
    this.bloodType,
    this.allergies = const [],
    this.otherAllergies = const [],
    this.conditions = const [],
    this.otherConditions = const [],
    this.medications,
    this.emergencyContact,
  });

  Map<String, dynamic> toJson() => {
    'bloodType': bloodType?.code,
    'allergies': allergies.map((a) => a.code).toList(),
    'otherAllergies': otherAllergies,
    'conditions': conditions.map((c) => c.code).toList(),
    'otherConditions': otherConditions,
    'medications': medications,
    'emergencyContact': emergencyContact?.toJson(),
  };
}