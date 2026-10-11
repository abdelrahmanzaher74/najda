import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/pending_report.dart';

/// الواجهة. لو احتجنا نبدّل التخزين (Hive مثلًا) بنغيّر التنفيذ بس.
abstract class PendingReportStore {
  Future<PendingReport?> load();
  Future<void> save(PendingReport report);
  Future<void> clear();
}

class SharedPrefsPendingReportStore implements PendingReportStore {
  static const _key = 'najda_pending_report';

  @override
  Future<PendingReport?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    try {
      return PendingReport.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      // بيانات تالفة: نمسحها بدل ما نعلّق عليها
      debugPrint('[Pending] corrupt stored report: $e');
      await prefs.remove(_key);
      return null;
    }
  }

  @override
  Future<void> save(PendingReport report) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(report.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final pendingStoreProvider = Provider<PendingReportStore>((ref) {
  return SharedPrefsPendingReportStore();
});