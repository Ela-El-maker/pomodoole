import 'package:flutter/material.dart';

import '../services/app_state_service.dart';
import '../theme/app_theme.dart';

/// Wraps the app with AnimatedTheme that responds to high contrast mode changes.
class HighContrastThemeWrapper extends StatefulWidget {
  final Widget child;
  const HighContrastThemeWrapper({super.key, required this.child});

  @override
  State<HighContrastThemeWrapper> createState() =>
      _HighContrastThemeWrapperState();
}

class _HighContrastThemeWrapperState extends State<HighContrastThemeWrapper> {
  final AppStateService _appState = AppStateService();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  ThemeData get _activeTheme {
    if (_appState.highContrastMode) {
      return AppTheme.highContrastTheme;
    }
    return AppTheme.lightTheme;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: _activeTheme,
      duration: const Duration(milliseconds: 300),
      child: widget.child,
    );
  }
}
