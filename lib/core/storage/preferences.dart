import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// بيتحمّل مرة واحدة في main() قبل ما التطبيق يفتح،
/// عشان المظهر واللغة يتطبقوا من أول إطار (من غير وميض).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});