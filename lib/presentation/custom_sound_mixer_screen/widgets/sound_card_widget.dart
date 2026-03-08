import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SoundCardWidget extends StatefulWidget {
  final String soundName;
  final IconData soundIcon;
  final bool isActive;
  final double volume;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onVolumeChanged;

  const SoundCardWidget({
    super.key,
    required this.soundName,
    required this.soundIcon,
    required this.isActive,
    required this.volume,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  @override
  State<SoundCardWidget> createState() => _SoundCardWidgetState();
}

class _SoundCardWidgetState extends State<SoundCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
    if (widget.isActive) _glowController.forward();
  }

  @override
  void didUpdateWidget(SoundCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.only(bottom: 1.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFEA),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFFE76F6F).withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isActive
                    ? const Color(
                        0xFFE76F6F,
                      ).withValues(alpha: 0.15 * _glowAnimation.value)
                    : const Color(0x0A000000),
                blurRadius: widget.isActive ? 12.0 * _glowAnimation.value : 4.0,
                spreadRadius: widget.isActive
                    ? 2.0 * _glowAnimation.value
                    : 0.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.isActive
                            ? const Color(0xFFE76F6F).withValues(alpha: 0.12)
                            : const Color(0xFFE8E7E2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        widget.soundIcon,
                        color: widget.isActive
                            ? const Color(0xFFE76F6F)
                            : const Color(0xFF6F6F6F),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        widget.soundName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2F2F2F),
                        ),
                      ),
                    ),
                    Switch(
                      value: widget.isActive,
                      onChanged: widget.onToggle,
                      activeThumbColor: const Color(0xFFE76F6F),
                      activeTrackColor: const Color(
                        0xFFE76F6F,
                      ).withValues(alpha: 0.3),
                      inactiveThumbColor: const Color(0xFFBBBBBB),
                      inactiveTrackColor: const Color(0xFFDDDDDD),
                    ),
                  ],
                ),
                if (widget.isActive) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        Icons.volume_down_rounded,
                        size: 16,
                        color: const Color(0xFF6F6F6F),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: const Color(0xFFE76F6F),
                            thumbColor: const Color(0xFFE76F6F),
                            overlayColor: const Color(
                              0xFFE76F6F,
                            ).withValues(alpha: 0.15),
                            inactiveTrackColor: const Color(
                              0xFFE76F6F,
                            ).withValues(alpha: 0.2),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                          ),
                          child: Slider(
                            value: widget.volume,
                            min: 0.0,
                            max: 1.0,
                            onChanged: widget.onVolumeChanged,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up_rounded,
                        size: 16,
                        color: const Color(0xFF6F6F6F),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
