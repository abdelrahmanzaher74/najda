import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guidance_repository.dart';
import 'models/guidance_card.dart';
import 'static_guidance_repository.dart';

/// وقت إضافة الـ AI: StaticGuidanceRepository() ← AiGuidanceRepository(...)
final guidanceRepositoryProvider = Provider<GuidanceRepository>((ref) {
  return StaticGuidanceRepository();
});

final guidanceProvider = FutureProvider.autoDispose
    .family<List<GuidanceCard>, GuidanceRequest>((ref, request) {
  return ref.read(guidanceRepositoryProvider).getGuidance(request);
});