import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = false,
    this.backgroundColor,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar ??
          (title != null || showBackButton || actions != null
              ? AppBar(
                  title: title != null
                      ? Text(title!, style: AppTextStyles.titleMd)
                      : null,
                  leading:
                      leading ?? (showBackButton ? const BackButton() : null),
                  actions: actions,
                  automaticallyImplyLeading: showBackButton,
                )
              : null),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
