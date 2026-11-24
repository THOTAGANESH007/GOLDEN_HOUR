import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes/app_router.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_customizer.dart';
import 'core/theme/theme_provider.dart';
import 'features/notifications/services/fcm_service.dart';
import 'l10n/app_localizations.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables if available
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Falls back gracefully to default API endpoints if .env is missing in dev
  }

  // Initialize FCM background & push handlers
  try {
    final fcmService = FCMService();
    await fcmService.initialize();
  } catch (_) {}

  final sentryDsn = dotenv.env['SENTRY_DSN'] ??
      const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue:
            'https://115c6e3dfb5ca35288da3072188b6ccb@o4512252566372352.ingest.de.sentry.io/4512252583739472',
      );

  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
        options.environment = 'production';
      },
      appRunner: () => runApp(
        const ProviderScope(
          child: GoldenHourApp(),
        ),
      ),
    );
  } else {
    runApp(
      const ProviderScope(
        child: GoldenHourApp(),
      ),
    );
  }
}

class GoldenHourApp extends ConsumerWidget {
  const GoldenHourApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final accentColor = ref.watch(accentColorProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Golden Hour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(accentColor),
      darkTheme: AppTheme.buildDarkTheme(accentColor),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
