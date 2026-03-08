import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class BreakSuggestionsWidget extends StatefulWidget {
  final bool isLongBreak;

  const BreakSuggestionsWidget({super.key, required this.isLongBreak});

  @override
  State<BreakSuggestionsWidget> createState() => _BreakSuggestionsWidgetState();
}

class _BreakSuggestionsWidgetState extends State<BreakSuggestionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _suggestions {
    if (widget.isLongBreak) {
      return [
        'Take a walk',
        'Have a snack',
        'Rest your eyes',
        'Breathe deeply',
      ];
    }
    return ['Stretch', 'Drink water', 'Look away from screens'];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF6F6F6F);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _suggestions.asMap().entries.map((entry) {
              final isLast = entry.key == _suggestions.length - 1;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '·',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: 1.h),
          Text(
            widget.isLongBreak
                ? 'You\'ve earned a longer rest 🌿'
                : 'Take a moment for yourself',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
