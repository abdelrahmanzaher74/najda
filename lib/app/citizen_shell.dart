import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'theme.dart';

/// الشاشات الرئيسية للمواطن (الرئيسية والبطاقة الطبية والبروفايل) مع الشريط السفلي.
/// شاشات البلاغ والتتبع والشات بتتفتح فوقه كاملة (من غير شريط).
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        elevation: 8,
        shadowColor: Colors.black,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // الضغط على الأيقونة الحالية بيرجّع لأول الشاشة
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medical_information_outlined),
            selectedIcon: const Icon(
              Icons.medical_information,
              color: AppColors.primary,
            ),
            label: l10n.navMedical,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}