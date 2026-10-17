import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/services/fcm_service.dart';

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

  runApp(
    const ProviderScope(
      child: GoldenHourApp(),
    ),
  );
}

class GoldenHourApp extends ConsumerWidget {
  const GoldenHourApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Golden Hour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
