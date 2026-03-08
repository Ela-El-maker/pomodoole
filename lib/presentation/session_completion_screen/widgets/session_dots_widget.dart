import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SessionDotsWidget extends StatefulWidget {
  final int completedSessions;
  final int totalSessions;

  const SessionDotsWidget({
    super.key,
    required this.completedSessions,
    required this.totalSessions,
  });

  @override
  State<SessionDotsWidget> createState() => _SessionDotsWidgetState();
}

class _SessionDotsWidgetState extends State<SessionDotsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.totalSessions, (index) {
        final isCompleted = index < widget.completedSessions;
        final isJustCompleted = index == widget.completedSessions - 1;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: isJustCompleted
              ? ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildDot(isCompleted),
                )
              : _buildDot(isCompleted),
        );
      }),
    );
  }

  Widget _buildDot(bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCompleted ? 12 : 10,
      height: isCompleted ? 12 : 10,
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFE76F6F)
            : const Color(0xFFE76F6F).withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
    );
  }
}
