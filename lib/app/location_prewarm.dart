import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/location/location_providers.dart';
import '../features/auth/data/models/user_role.dart';
import '../features/auth/presentation/session_controller.dart';

/// بيسخّن الموقع أول ما المواطن يسجّل دخول.
class LocationPrewarm extends ConsumerWidget {
  final Widget child;

  const LocationPrewarm({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    if (user != null && user.role == UserRole.citizen) {
      ref.watch(locationPrepProvider);
    }
    return child;
  }
}