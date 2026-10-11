import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/models/user_role.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/session_controller.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/home/presentation/citizen_home_screen.dart';
import '../features/home/presentation/field_home_screen.dart';
import '../features/home/presentation/web_only_screen.dart';
import '../features/incident/data/incident_providers.dart';
import '../features/incident/data/models/incident_category.dart';
import '../features/incident/presentation/active_report.dart';
import '../features/incident/presentation/pending_report_controller.dart';
import '../features/incident/presentation/report_screen.dart';
import '../features/incident/presentation/tracking_screen.dart';
import '../features/medical/data/medical_providers.dart';
import '../features/medical/presentation/medical_history_screen.dart';

const _publicRoutes = ['/', '/login', '/register', '/forgot-password'];
const _medicalHistoryRoute = '/citizen/medical-history';

String _homeFor(UserRole role) {
  if (role == UserRole.citizen) return '/citizen';
  if (role.isFieldRole) return '/field';
  return '/web-only';
}

final routerProvider = Provider<GoRouter>((ref) {
  // لما المستخدم يتغيّر (دخول/خروج) أو علم التاريخ الطبي يتغيّر،
  // الـ router بيعيد حساب التوجيه
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, __) => refresh.value++);
  ref.listen(needsMedicalHistoryProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(sessionProvider);
      final location = state.matchedLocation;
      final isPublic = _publicRoutes.contains(location);

      // مش مسجّل دخول: يرجع للـ login
      if (user == null) return isPublic ? null : '/login';

      // مواطن جديد: لازم يعدّي على التاريخ الطبي الأول
      final needsMedical =
          user.role == UserRole.citizen && ref.read(needsMedicalHistoryProvider);
      if (needsMedical) {
        return location == _medicalHistoryRoute ? null : _medicalHistoryRoute;
      }

      // مسجّل دخول: يروح لشاشته حسب الـ role
      final home = _homeFor(user.role);
      if (isPublic || location == '/home') return home;

      // حماية الشاشات حسب الـ role
      if (location.startsWith('/citizen') && user.role != UserRole.citizen) {
        return home;
      }
      if (location.startsWith('/field') && !user.role.isFieldRole) {
        return home;
      }
      if (location == '/web-only' && user.role.isMobileRole) return home;

      // قاعدة: بلاغ واحد نشط في المرة
      if (location == '/citizen/report') {
        // في بلاغ محفوظ بانتظار الإرسال: نرجع للرئيسية (كارته هناك)
        if (ref.read(pendingReportControllerProvider).report != null) {
          return '/citizen';
        }
        // في بلاغ نشط: نروح لتتبعه
        final activeId = ref.read(activeIncidentIdProvider);
        if (activeId != null && ref.read(hasActiveIncidentProvider)) {
          return '/citizen/incident/$activeId';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // الشاشات اللي بتنادي context.go('/home') بتتحوّل تلقائي من الـ redirect فوق
      GoRoute(
        path: '/home',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/citizen',
        builder: (context, state) => const CitizenHomeScreen(),
      ),
      GoRoute(
        path: _medicalHistoryRoute,
        builder: (context, state) => const MedicalHistoryScreen(),
      ),
      GoRoute(
        path: '/citizen/report',
        builder: (context, state) {
          final category = IncidentCategory.tryFromCode(
            state.uri.queryParameters['category'],
          );
          return ReportScreen(
            initialCategory: category ?? IncidentCategory.medical,
          );
        },
      ),
      GoRoute(
        path: '/citizen/incident/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return TrackingScreen(incidentId: id);
        },
      ),
      GoRoute(
        path: '/field',
        builder: (context, state) => const FieldHomeScreen(),
      ),
      GoRoute(
        path: '/web-only',
        builder: (context, state) => const WebOnlyScreen(),
      ),
    ],
  );
});