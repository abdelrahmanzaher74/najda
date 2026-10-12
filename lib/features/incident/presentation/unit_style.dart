import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/assigned_unit.dart';

Color unitColor(ResponderType type) {
  return switch (type) {
    ResponderType.ambulance => AppColors.primary,
    ResponderType.firstResponder => AppColors.accent,
    ResponderType.police => const Color(0xFF1E6FD9),
    ResponderType.fire => const Color(0xFFF57C00),
  };
}

IconData unitIcon(ResponderType type) {
  return switch (type) {
    ResponderType.ambulance => Icons.local_hospital,
    ResponderType.firstResponder => Icons.health_and_safety,
    ResponderType.police => Icons.local_police,
    ResponderType.fire => Icons.local_fire_department,
  };
}

String unitTypeLabel(AppLocalizations l10n, ResponderType type) {
  return switch (type) {
    ResponderType.ambulance => l10n.unitAmbulance,
    ResponderType.firstResponder => l10n.unitFirstResponder,
    ResponderType.police => l10n.unitPolice,
    ResponderType.fire => l10n.unitFire,
  };
}

String unitStatusLabel(AppLocalizations l10n, UnitStatus status) {
  return switch (status) {
    UnitStatus.accepted => l10n.unitAccepted,
    UnitStatus.enRoute => l10n.unitEnRoute,
    UnitStatus.arrived => l10n.unitArrived,
  };
}