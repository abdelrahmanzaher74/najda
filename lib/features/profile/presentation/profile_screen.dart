import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/locale_controller.dart';
import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/models/app_user.dart';
import '../../auth/data/models/user_role.dart';
import '../../auth/presentation/session_controller.dart';
import 'widgets/change_password_sheet.dart';
import 'widgets/change_phone_sheet.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/language_sheet.dart';

const _verifiedColor = Color(0xFF1F9D8B);
const _warningColor = Color(0xFFB26A00);

String _roleLabel(AppLocalizations l10n, UserRole role) {
  return switch (role) {
    UserRole.citizen => l10n.roleCitizen,
    UserRole.firstResponder => l10n.roleFirstResponder,
    UserRole.ambulanceCrew => l10n.roleAmbulanceCrew,
    UserRole.firefighter => l10n.roleFirefighter,
    UserRole.police => l10n.rolePolice,
    _ => l10n.roleStaff,
  };
}

String _genderLabel(AppLocalizations l10n, String? code) {
  return switch (code?.toUpperCase()) {
    'MALE' => l10n.male,
    'FEMALE' => l10n.female,
    _ => '—',
  };
}

String _initials(AppUser user) {
  String first(String s) => s.trim().isEmpty ? '' : s.trim().characters.first;
  final text = '${first(user.firstName)}${first(user.lastName)}'.toUpperCase();
  return text.isEmpty ? '?' : text;
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _openSheet(
      BuildContext context,
      Widget sheet,
      String successMessage,
      ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => sheet,
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(successMessage)));
    }
  }

  Future<void> _openLink(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    if (!opened && context.mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.couldNotOpenLink)));
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // الـ router بيرجّعك للـ login تلقائي
      await ref.read(sessionProvider.notifier).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider);

    if (user == null) return const SizedBox.shrink();

    final languageName = switch (locale?.languageCode) {
      'en' => l10n.languageEnglish,
      'ar' => l10n.languageArabic,
      _ => l10n.languageSystem,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الهيدر: الصورة (الحروف الأولى) والاسم والدور
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                        child: Text(
                          _initials(user),
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.fullName,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _roleLabel(l10n, user.role),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // المعلومات الشخصية
                  _Section(
                    title: l10n.personalInfo,
                    action: TextButton(
                      onPressed: () => _openSheet(
                        context,
                        const EditProfileSheet(),
                        l10n.profileUpdated,
                      ),
                      child: Text(l10n.editLabel),
                    ),
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: l10n.fullNameLabel,
                        value: user.fullName,
                      ),
                      _InfoRow(
                        icon: Icons.wc_outlined,
                        label: l10n.gender,
                        value: _genderLabel(l10n, user.gender),
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: l10n.address,
                        value: (user.address?.isNotEmpty ?? false)
                            ? user.address!
                            : '—',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // بيانات التواصل
                  _Section(
                    title: l10n.contactInfo,
                    children: [
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.phone,
                        value: user.phone ?? '—',
                        textDirection: TextDirection.ltr,
                        badge: _Badge(
                          verified: user.phoneVerified,
                          label: user.phoneVerified
                              ? l10n.verifiedLabel
                              : l10n.notVerifiedLabel,
                        ),
                        trailing: TextButton(
                          onPressed: () => _openSheet(
                            context,
                            const ChangePhoneSheet(),
                            l10n.phoneVerifiedMessage,
                          ),
                          child: Text(
                            user.phoneVerified ? l10n.editLabel : l10n.verify,
                          ),
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.mail_outline,
                        label: l10n.email,
                        value: user.email ?? '—',
                        textDirection: TextDirection.ltr,
                        badge: _Badge(
                          verified: user.emailVerified,
                          label: user.emailVerified
                              ? l10n.verifiedLabel
                              : l10n.notVerifiedLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // الأمان
                  _Section(
                    title: l10n.security,
                    children: [
                      if (user.hasPassword)
                        _ActionTile(
                          icon: Icons.lock_outline,
                          title: l10n.changePassword,
                          onTap: () => _openSheet(
                            context,
                            const ChangePasswordSheet(),
                            l10n.passwordChanged,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l10n.googleAccountNote,
                            style: textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // مستجيب أول
                  _Section(
                    title: l10n.becomeFirstResponder,
                    children: [
                      _ActionTile(
                        icon: Icons.health_and_safety_outlined,
                        title: l10n.becomeFirstResponder,
                        subtitle: l10n.becomeFirstResponderHint,
                        onTap: () => context.push('/citizen/first-responder'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // التطبيق
                  _Section(
                    title: l10n.appSection,
                    children: [
                      _ActionTile(
                        icon: Icons.language,
                        title: l10n.language,
                        subtitle: languageName,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (_) => const LanguageSheet(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // قانوني
                  _Section(
                    title: l10n.legalSection,
                    children: [
                      _ActionTile(
                        icon: Icons.description_outlined,
                        title: l10n.termsConditions,
                        onTap: () => _openLink(context, AppConfig.termsUrl),
                      ),
                      _ActionTile(
                        icon: Icons.privacy_tip_outlined,
                        title: l10n.privacyPolicy,
                        onTap: () => _openLink(context, AppConfig.privacyUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: () => _confirmSignOut(context, ref),
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.signOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget? action;
  final List<Widget> children;

  const _Section({required this.title, this.action, required this.children});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.foreground,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? badge;
  final Widget? trailing;
  final TextDirection? textDirection;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
    this.trailing,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: Colors.black54),
                ),
                Text(
                  value,
                  textDirection: textDirection,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 4),
                  badge!,
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool verified;
  final String label;

  const _Badge({required this.verified, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = verified ? _verifiedColor : _warningColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          verified ? Icons.verified : Icons.error_outline,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}