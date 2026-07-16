import 'package:flutter/material.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static const Color _success = Color(0xFF2E7D32);
  static const Color _error = Color(0xFFC62828);
  static const Color _warning = Color(0xFFE65100);
  static const Color _info = Color(0xFFD4B483);

  static const Duration _short = Duration(seconds: 3);
  static const Duration _long = Duration(seconds: 5);

  static void success(BuildContext context, String message,
      {Duration? duration}) {
    _show(context, message, _success, Icons.check_circle_outline,
        duration ?? _short);
  }

  static void error(BuildContext context, String message,
      {Duration? duration}) {
    _show(context, message, _error, Icons.error_outline, duration ?? _long);
  }

  static void warning(BuildContext context, String message,
      {Duration? duration}) {
    _show(context, message, _warning, Icons.warning_amber_outlined,
        duration ?? _short);
  }

  static void info(BuildContext context, String message, {Duration? duration}) {
    _show(context, message, _info, Icons.info_outline, duration ?? _short);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
      ),
    );
  }
}
