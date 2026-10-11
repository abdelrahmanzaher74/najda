import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'fake_auth_repository.dart';

/// ده المكان الوحيد اللي هنغيّره وقت الربط الحقيقي:
/// FakeAuthRepository() ← RealAuthRepository(...)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository();
});