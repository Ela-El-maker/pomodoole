import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BotanicalIllustrationWidget extends StatefulWidget {
  const BotanicalIllustrationWidget({super.key});

  @override
  State<BotanicalIllustrationWidget> createState() =>
      _BotanicalIllustrationWidgetState();
}

class _BotanicalIllustrationWidgetState
    extends State<BotanicalIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
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
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _breathAnimation.value, child: child);
      },
      child: Container(
        width: 55.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(120.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA8C3A0).withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer petal ring
            ..._buildPetals(),
            // Center circle
            Container(
              width: 18.w,
              height: 9.h,
              decoration: const BoxDecoration(
                color: Color(0xFFE76F6F),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 28)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPetals() {
    final petalColors = [
      const Color(0xFFA8C3A0),
      const Color(0xFFB8D4B0),
      const Color(0xFFC8E0C0),
      const Color(0xFFA8C3A0),
      const Color(0xFFB8D4B0),
      const Color(0xFFC8E0C0),
    ];
    return List.generate(6, (i) {
      final angle = (i * 60.0) * (3.14159 / 180);
      return Positioned(
        left:
            55.w / 2 +
            12.w *
                (i < 3 ? 1 : -1) *
                (i % 3 == 0
                    ? 0.5
                    : i % 3 == 1
                    ? 0.9
                    : 0.5) -
            5.w,
        top:
            28.h / 2 +
            5.h *
                (i < 2
                    ? -1.2
                    : i < 4
                    ? 0.5
                    : 1.2) -
            2.5.h,
        child: Container(
          width: 10.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: petalColors[i].withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(50.0),
          ),
        ),
      );
    });
  }
}
