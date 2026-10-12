import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/data/models/user_role.dart';

/// اسم دور المرسل في شارة الشات.
String chatRoleLabel(AppLocalizations l10n, UserRole role) {
  return switch (role) {
    UserRole.dispatcher => l10n.roleDispatcher,
    UserRole.admin || UserRole.superAdmin => l10n.roleAdmin,
    _ => l10n.roleStaff,
  };
}

/// لون شارة الدور.
Color chatRoleColor(UserRole role) {
  return switch (role) {
    UserRole.dispatcher => const Color(0xFF3949AB),
    UserRole.admin || UserRole.superAdmin => const Color(0xFF7B1FA2),
    _ => Colors.black54,
  };
}