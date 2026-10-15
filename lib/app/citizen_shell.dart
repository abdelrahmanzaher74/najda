import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// الشاشات الرئيسية للمواطن (الرئيسية والبطاقة الطبية والبروفايل) مع الشريط السفلي.
/// شاشات البلاغ والتتبع والشات بتتفتح فوقه كاملة (من غير شريط).
/// ألوان الشريط بتيجي من الثيم (NavigationBarTheme في theme.dart).
class CitizenShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CitizenShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // الضغط على الأيقونة الحالية بيرجّع لأول الشاشة
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medical_information_outlined),
            selectedIcon: const Icon(Icons.medical_information),
            label: l10n.navMedical,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}