import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmbientSoundWidget extends StatefulWidget {
  const AmbientSoundWidget({super.key});

  @override
  State<AmbientSoundWidget> createState() => _AmbientSoundWidgetState();
}

class _AmbientSoundWidgetState extends State<AmbientSoundWidget> {
  bool _isExpanded = false;
  String? _selectedSound;
  double _volume = 0.5;

  final List<Map<String, dynamic>> _sounds = [
    {'name': 'Rain', 'icon': Icons.water_drop_outlined},
    {'name': 'Forest', 'icon': Icons.forest_outlined},
    {'name': 'White Noise', 'icon': Icons.waves_outlined},
    {'name': 'Cafe', 'icon': Icons.coffee_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E7E2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8C3A0).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.headphones_outlined,
                    color: Color(0xFF6A9E62),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedSound ?? 'Ambient Sounds',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2F2F2F),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6F6F6F),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _sounds.map((sound) {
                    final isSelected = _selectedSound == sound['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSound = isSelected
                              ? null
                              : sound['name'] as String;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFA8C3A0).withValues(alpha: 0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFA8C3A0)
                                : const Color(0xFFDDDCD8),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              sound['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF6A9E62)
                                  : const Color(0xFF6F6F6F),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              sound['name'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF6A9E62)
                                    : const Color(0xFF6F6F6F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedSound != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.volume_down_rounded,
                        size: 16,
                        color: Color(0xFF6F6F6F),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFFA8C3A0),
                            thumbColor: const Color(0xFFA8C3A0),
                            inactiveTrackColor: const Color(0xFFDDDCD8),
                            overlayColor: const Color(
                              0xFFA8C3A0,
                            ).withValues(alpha: 0.15),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _volume,
                            onChanged: (v) => setState(() => _volume = v),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.volume_up_rounded,
                        size: 16,
                        color: Color(0xFF6F6F6F),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
