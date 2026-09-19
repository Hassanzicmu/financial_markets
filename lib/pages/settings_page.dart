import 'package:flutter/material.dart';
import 'package:financial_markets/widgets/design_system.dart';
import 'package:financial_markets/theme.dart';
import 'package:financial_markets/l10n/app_localizations.dart';
import '../main.dart'; // To access localeNotifier

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return TradingPlatformLayout(
      title: Text(l10n.settings, style: AppTypography.titleMd.copyWith(color: context.ink)),
      leading: const BackButton(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.hairline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: context.primary),
                  title: Text(l10n.notifications, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: context.inkMute),
                  onTap: () {},
                ),
                Divider(height: 1, color: context.hairline),
                ListTile(
                  leading: Icon(Icons.language, color: context.primary),
                  title: Text(l10n.language, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                  trailing: DropdownButton<String>(
                    value: isArabic ? 'ar' : 'en',
                    underline: const SizedBox(),
                    dropdownColor: context.surfaceCard,
                    icon: Icon(Icons.arrow_drop_down, color: context.inkMute),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.english, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(l10n.arabic, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        localeNotifier.changeLocale(Locale(newValue));
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: context.hairline),
                ListTile(
                  leading: Icon(Icons.public, color: context.primary),
                  title: Text(l10n.country, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                  trailing: DropdownButton<String>(
                    value: countryNotifier.country,
                    underline: const SizedBox(),
                    dropdownColor: context.surfaceCard,
                    icon: Icon(Icons.arrow_drop_down, color: context.inkMute),
                    items: [
                      DropdownMenuItem(
                        value: 'eg',
                        child: Text(l10n.egypt, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        countryNotifier.changeCountry(newValue);
                      }
                    },
                  ),
                ),
                Divider(height: 1, color: context.hairline),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: context.primary),
                  title: Text(l10n.darkMode, style: AppTypography.bodyMd.copyWith(color: context.ink)),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    activeTrackColor: context.primary.withValues(alpha: 0.5),
                    onChanged: (v) {
                      themeNotifier.toggleTheme(v);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
