import '../../../l10n/app_localizations.dart';
import '../data/models/cancellation_category.dart';
import '../data/models/incident_category.dart';
import '../data/models/incident_status.dart';

String incidentCategoryLabel(AppLocalizations l10n, IncidentCategory c) {
  return switch (c) {
    IncidentCategory.medical => l10n.medical,
    IncidentCategory.fire => l10n.fire,
    IncidentCategory.police => l10n.police,
  };
}

String cancellationLabel(AppLocalizations l10n, CancellationCategory c) {
  return switch (c) {
    CancellationCategory.mistake => l10n.cancelMistake,
    CancellationCategory.resolved => l10n.cancelResolved,
    CancellationCategory.notNeeded => l10n.cancelNotNeeded,
    CancellationCategory.other => l10n.cancelOther,
  };
}

String statusLabel(AppLocalizations l10n, IncidentStatus s) {
  return switch (s) {
    IncidentStatus.pending => l10n.statusPending,
    IncidentStatus.assigned => l10n.statusAssigned,
    IncidentStatus.enRoute => l10n.statusEnRoute,
    IncidentStatus.onScene => l10n.statusOnScene,
    IncidentStatus.completed => l10n.statusCompleted,
    IncidentStatus.cancelled => l10n.statusCancelled,
    IncidentStatus.unknown => l10n.statusUnknown,
  };
}