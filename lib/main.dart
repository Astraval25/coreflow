import 'package:coreflow/data/services/push_notification_service.dart';
import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/routing/app_routinf.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (kDebugMode) {
    debugPrint('BASE_URL(raw): ${dotenv.env['BASE_URL']}');
    debugPrint('BASE_URL(resolved): ${AppConfig.baseUrl}');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await PushNotificationService().initialize();
  } catch (e) {
    debugPrint('Push notification initialization failed: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      routerConfig: router,
      title: 'CoreFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}
