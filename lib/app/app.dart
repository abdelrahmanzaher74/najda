import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'location_prewarm.dart';
import 'pending_sync.dart';
import 'router.dart';
import 'theme.dart';

class NajdaApp extends ConsumerWidget {
  const NajdaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NAJDA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => PendingSync(
        child: LocationPrewarm(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}