import 'package:flutter/material.dart';

class BreakBackgroundWidget extends StatefulWidget {
  final Widget child;

  const BreakBackgroundWidget({super.key, required this.child});

  @override
  State<BreakBackgroundWidget> createState() => _BreakBackgroundWidgetState();
}

class _BreakBackgroundWidgetState extends State<BreakBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.08, end: 0.18).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F5);

    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(
                  baseBg,
                  const Color(0xFFA8C3A0),
                  _breathAnimation.value,
                )!,
                baseBg,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
