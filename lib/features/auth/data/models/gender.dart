/// القيم مؤقتة (MALE / FEMALE) لحد ما نتأكد منها من الـ Backend.
enum Gender {
  male('MALE'),
  female('FEMALE');

  final String code;
  const Gender(this.code);
}