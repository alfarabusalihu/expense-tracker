import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Settings'),
      body: ListView(
        children: [
          // ─── APPEARANCE ────────────────────────────────────────────
          _sectionHeader(context, 'Appearance', Icons.palette_outlined),
          _settingsTile(
            context: context,
            isDark: isDark,
            title: 'Dark Mode',
            subtitle: _themeSubtitle(settings.themeMode),
            leading: Icon(
              settings.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : settings.themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
              color: AppColors.primary,
            ),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (mode) {
                if (mode != null) settings.setThemeMode(mode);
              },
            ),
          ),

          // ─── CURRENCY ──────────────────────────────────────────────
          _sectionHeader(context, 'Currency', Icons.currency_exchange),
          _settingsTile(
            context: context,
            isDark: isDark,
            title: 'Display Currency',
            subtitle: settings.selectedCurrency.label,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                settings.selectedCurrency.symbol,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            trailing: DropdownButton<CurrencyOption>(
              value: settings.selectedCurrency,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: AppSettingsProvider.availableCurrencies
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.code),
                      ))
                  .toList(),
              onChanged: (c) {
                if (c != null) settings.setCurrency(c);
              },
            ),
          ),

          // ─── LANGUAGE ──────────────────────────────────────────────
          _sectionHeader(context, 'Language', Icons.language),
          _settingsTile(
            context: context,
            isDark: isDark,
            title: 'App Language',
            subtitle: settings.selectedLanguage.label,
            leading: const Icon(Icons.translate, color: AppColors.accent),
            trailing: DropdownButton<LanguageOption>(
              value: settings.selectedLanguage,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              items: AppSettingsProvider.availableLanguages
                  .map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l.code.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (l) {
                if (l != null) settings.setLanguage(l);
              },
            ),
          ),

          // ─── ABOUT ─────────────────────────────────────────────────
          _sectionHeader(context, 'About', Icons.info_outline),
          _settingsTile(
            context: context,
            isDark: isDark,
            title: 'App Version',
            subtitle: '1.0.0',
            leading: const Icon(Icons.verified_outlined, color: AppColors.info),
          ),
        ],
      ),
    );
  }

  String _themeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Always dark';
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required Widget leading,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: leading,
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)),
        trailing: trailing,
      ),
    );
  }
}
