import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/routing/route_names.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VspNestApp(),
    ),
  );
}

class VspNestApp extends StatelessWidget {
  const VspNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSP Nest Portal',
      theme: ResortTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
