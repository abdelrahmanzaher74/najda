import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/session_controller.dart';
import '../features/incident/presentation/pending_report_controller.dart';

/// بيحاول يبعت البلاغ المحفوظ لما:
/// النت يرجع، أو كل 30 ثانية، أو لما المستخدم يرجع للتطبيق.
class PendingSync extends ConsumerStatefulWidget {
  final Widget child;

  const PendingSync({super.key, required this.child});

  @override
  ConsumerState<PendingSync> createState() => _PendingSyncState();
}

class _PendingSyncState extends ConsumerState<PendingSync>
    with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) _sync();
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _sync());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  void _sync() {
    final user = ref.read(sessionProvider);
    if (user == null || !user.role.usesCitizenApp) return;
    ref.read(pendingReportControllerProvider.notifier).trySend();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    if (user != null && user.role.usesCitizenApp) {
      // بنراقبه عشان يفضل شغال ويحمّل البلاغ المحفوظ
      ref.watch(pendingReportControllerProvider);
    }
    return widget.child;
  }
}