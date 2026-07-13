import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/ssl_pinning_stub.dart'
    if (dart.library.io) 'core/ssl_pinning.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/routing/route_names.dart';
import 'presentation/providers/theme_provider.dart';

void main() {
  configureSslPinning();
  runApp(
    const ProviderScope(
      child: VspNestApp(),
    ),
  );
}

class VspNestApp extends ConsumerWidget {
  const VspNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'VSP Nest Portal',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
