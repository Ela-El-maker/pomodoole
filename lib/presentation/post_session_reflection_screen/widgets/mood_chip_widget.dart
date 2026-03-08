import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodChipWidget extends StatefulWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodChipWidget({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<MoodChipWidget> createState() => _MoodChipWidgetState();
}

class _MoodChipWidgetState extends State<MoodChipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    if (widget.isSelected) _scaleController.forward();
  }

  @override
  void didUpdateWidget(MoodChipWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFFA8C3A0).withValues(alpha: 0.2)
                : const Color(0xFFF0EFEA),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFA8C3A0)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFA8C3A0).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: widget.isSelected
                      ? FontWeight.w500
                      : FontWeight.w300,
                  color: widget.isSelected
                      ? const Color(0xFF4A7A42)
                      : const Color(0xFF6F6F6F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
