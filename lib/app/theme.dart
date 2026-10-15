import 'package:flutter/material.dart';

/// ألوان العلامة التجارية (ثابتة في الوضعين).
class AppColors {
  AppColors._();

  static const primary = Color(0xFFD32F2F);
  static const background = Color(0xFFF5F5F5);
  static const foreground = Color(0xFF424242);
  static const card = Color(0xFFF9F9F9);
  static const accent = Color(0xFF00BCD4);
}

/// ألوان بتتغيّر مع الثيم (فاتح/داكن). الاستخدام: context.najda.card
@immutable
class NajdaColors extends ThemeExtension<NajdaColors> {
  /// خلفية الكروت والحقول والنوافذ
  final Color card;

  /// حدود خفيفة وحدود أقوى
  final Color border;
  final Color borderStrong;

  /// النص: أساسي / ثانوي / خافت
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// خلفية حقول الإدخال
  final Color fieldFill;

  /// نجاح (تركواز) وتحذير (برتقالي) وخلفياتهم
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;

  const NajdaColors({
    required this.card,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.fieldFill,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
  });

  static const light = NajdaColors(
    card: Colors.white,
    border: Color(0x1F000000),
    borderStrong: Color(0x42000000),
    textPrimary: Color(0xFF424242),
    textSecondary: Color(0x8A000000),
    textTertiary: Color(0x61000000),
    fieldFill: Colors.white,
    success: Color(0xFF1F9D8B),
    successBg: Color(0xFFE3F1EE),
    warning: Color(0xFFB26A00),
    warningBg: Color(0xFFFFF4E0),
  );

  static const dark = NajdaColors(
    card: Color(0xFF1E1E1E),
    border: Color(0xFF333333),
    borderStrong: Color(0xFF4D4D4D),
    textPrimary: Color(0xFFECECEC),
    textSecondary: Color(0xFFB3B3B3),
    textTertiary: Color(0xFF8C8C8C),
    fieldFill: Color(0xFF262626),
    success: Color(0xFF3DBBA8),
    successBg: Color(0xFF153530),
    warning: Color(0xFFFFB74D),
    warningBg: Color(0xFF3A2D14),
  );

  @override
  NajdaColors copyWith({
    Color? card,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? fieldFill,
    Color? success,
    Color? successBg,
    Color? warning,
    Color? warningBg,
  }) {
    return NajdaColors(
      card: card ?? this.card,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      fieldFill: fieldFill ?? this.fieldFill,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
    );
  }

  @override
  NajdaColors lerp(ThemeExtension<NajdaColors>? other, double t) {
    if (other is! NajdaColors) return this;

    return NajdaColors(
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
    );
  }
}

extension NajdaContext on BuildContext {
  NajdaColors get najda =>
      Theme.of(this).extension<NajdaColors>() ?? NajdaColors.light;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final n = isDark ? NajdaColors.dark : NajdaColors.light;
    final scaffold = isDark ? const Color(0xFF121212) : AppColors.background;

    // أحمر أفتح شوية في الدارك للنصوص الصغيرة والروابط (تباين أحسن)
    final linkColor = isDark ? const Color(0xFFEF5350) : AppColors.primary;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: isDark ? n.card : AppColors.card,
      onSurface: n.textPrimary,
      onSurfaceVariant: n.textSecondary,
      outlineVariant: n.border,
    );

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final baseText = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    ).textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: baseText.apply(
        bodyColor: n.textPrimary,
        displayColor: n.textPrimary,
      ),
      extensions: [n],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: n.textPrimary,
      ),
      dividerTheme: DividerThemeData(color: n.border),
      dialogTheme: DialogThemeData(
        backgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: n.borderStrong,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: n.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor:
        AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
        elevation: 8,
        shadowColor: Colors.black,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? linkColor : n.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? linkColor : n.textSecondary);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: n.fieldFill,
        hintStyle: TextStyle(color: n.textTertiary),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: inputBorder(n.border),
        enabledBorder: inputBorder(n.border),
        focusedBorder: inputBorder(AppColors.primary, width: 1.5),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(64, 52),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          minimumSize: const Size(64, 52),
          foregroundColor: linkColor,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: linkColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}