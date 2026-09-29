import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'repositories/expense_repository.dart';
import 'providers/expense_provider.dart';
import 'providers/app_settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';

/// Enables drag scrolling for desktop mouse & trackpad in addition to touch
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Initialization note: $e');
  }
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(repository: ExpenseRepository()),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Expense Tracker',
            debugShowCheckedModeBanner: false,
            scrollBehavior: AppScrollBehavior(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.selectedLanguage.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppSettingsProvider.availableLanguages
                .map((l) => l.locale)
                .toList(),
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

/// Alias for IDE run configuration templates expecting `MyApp`
typedef MyApp = ExpenseTrackerApp;
