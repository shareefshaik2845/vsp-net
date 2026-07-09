import 'package:flutter/material.dart';
import '../../domain/entities.dart';
import '../screens/splash_screen.dart';
import '../screens/install_screen.dart';
import '../screens/login_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/portal_shell_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static String routeForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return RouteNames.admin;
      case UserRole.staff:
        return RouteNames.staff;
      case UserRole.accountant:
        return RouteNames.accountant;
      case UserRole.superAdmin:
        return RouteNames.superAdmin;
      default:
        return RouteNames.customer;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(const VspNestSplashScreen(), settings);
      case RouteNames.install:
        return _buildRoute(const InstallationScreen(), settings);
      case RouteNames.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case RouteNames.login:
        return _buildRoute(const LoginScreen(), settings);
      case RouteNames.admin:
      case RouteNames.staff:
      case RouteNames.accountant:
      case RouteNames.superAdmin:
      case RouteNames.customer:
        return _buildRoute(const ResortPortalShell(), settings);
      default:
        return _buildRoute(const VspNestSplashScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
