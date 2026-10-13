import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اللغة اللي اختارها المستخدم. null = لغة الجهاز.
class LocaleController extends Notifier<Locale?> {
  static const _key = 'najda_locale';

  @override
  Locale? build() {
    Future.microtask(_load);
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (!ref.mounted) return;
    if (code != null) state = Locale(code);
  }

  Future<void> set(Locale? locale) async {
    state = locale;

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeProvider =
NotifierProvider<LocaleController, Locale?>(LocaleController.new);