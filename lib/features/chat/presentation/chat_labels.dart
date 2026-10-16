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

/// لون خلفية شارة الدور (الشارة نصها أبيض، فالألوان دي ثابتة في الوضعين).
Color chatRoleColor(UserRole role) {
  return switch (role) {
    UserRole.dispatcher => const Color(0xFF3949AB),
    UserRole.admin || UserRole.superAdmin => const Color(0xFF7B1FA2),
    _ => Colors.black54,
  };
}

/// لون الدور لما بيتكتب نص أو حدود على خلفية الثيم (أفتح في الدارك).
Color chatRoleAccent(UserRole role, {required bool dark}) {
  return switch (role) {
    UserRole.dispatcher =>
    dark ? const Color(0xFF9FA8DA) : const Color(0xFF3949AB),
    UserRole.admin || UserRole.superAdmin =>
    dark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
    _ => dark ? const Color(0xFFB3B3B3) : Colors.black54,
  };
}