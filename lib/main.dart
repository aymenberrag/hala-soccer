import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env holds the API-Sports key (API_KEY). It's git-ignored — see
  // README for how to obtain one. If it's missing, dotenv.env simply
  // stays empty and FootballApiClient's API key resolves to "", which
  // surfaces as a clean 401/error state in the UI rather than a crash.
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // No .env present — continue with an empty env map.
  }

  runApp(const ProviderScope(child: HalaSoccerApp()));
}

class HalaSoccerApp extends ConsumerWidget {
  const HalaSoccerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "Hala Soccer",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
