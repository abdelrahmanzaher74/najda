import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/models/user_role.dart';
import '../features/auth/presentation/session_controller.dart';
import '../l10n/app_localizations.dart';

/// الشاشات الرئيسية للمواطن (والمستجيب الأول) مع الشريط السفلي:
/// الرئيسية، (المستجيب: للمستجيب الأول بس)، البطاقة الطبية، البروفايل.
/// شاشات البلاغ والتتبع والشات بتتفتح فوقه كاملة (من غير شريط).
/// ألوان الشريط بتيجي من الثيم (NavigationBarTheme في theme.dart).
class CitizenShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const CitizenShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isResponder = ref.watch(
      sessionProvider.select((u) => u?.role == UserRole.firstResponder),
    );

    // ترتيب الـ branches في الـ router: 0 الرئيسية، 1 المستجيب، 2 الطبية، 3 البروفايل
    final tabs = <({int branch, NavigationDestination destination})>[
      (
      branch: 0,
      destination: NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: l10n.navHome,
      ),
      ),
      if (isResponder)
        (
        branch: 1,
        destination: NavigationDestination(
          icon: const Icon(Icons.health_and_safety_outlined),
          selectedIcon: const Icon(Icons.health_and_safety),
          label: l10n.navResponder,
        ),
        ),
      (
      branch: 2,
      destination: NavigationDestination(
        icon: const Icon(Icons.medical_information_outlined),
        selectedIcon: const Icon(Icons.medical_information),
        label: l10n.navMedical,
      ),
      ),
      (
      branch: 3,
      destination: NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.navProfile,
      ),
      ),
    ];

    final selected =
    tabs.indexWhere((t) => t.branch == navigationShell.currentIndex);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => navigationShell.goBranch(
          tabs[index].branch,
          // الضغط على الأيقونة الحالية بيرجّع لأول الشاشة
          initialLocation: tabs[index].branch == navigationShell.currentIndex,
        ),
        destinations: [for (final t in tabs) t.destination],
      ),
    );
  }
}