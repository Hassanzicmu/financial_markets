import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:financial_markets/l10n/app_localizations.dart';
import 'splash_screen.dart';
import 'locale_notifier.dart';
import 'theme_notifier.dart';
import 'theme.dart';
import 'country_notifier.dart';

final localeNotifier = LocaleNotifier();
final themeNotifier = ThemeNotifier();
final countryNotifier = CountryNotifier();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([localeNotifier, themeNotifier, countryNotifier]),
      builder: (context, _) {
        return MaterialApp(
          locale: localeNotifier.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          debugShowCheckedModeBanner: false,
          title: 'Financial Markets - أسعار السوق',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
