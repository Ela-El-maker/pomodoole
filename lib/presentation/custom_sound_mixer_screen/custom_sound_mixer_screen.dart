import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:sizer/sizer.dart';
import './widgets/sound_card_widget.dart';
import './widgets/saved_mix_card_widget.dart';

class SoundMix {
  final String id;
  final String name;
  final Map<String, double> soundLevels;

  SoundMix({required this.id, required this.name, required this.soundLevels});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'soundLevels': soundLevels,
  };

  factory SoundMix.fromJson(Map<String, dynamic> json) => SoundMix(
    id: json['id'] as String,
    name: json['name'] as String,
    soundLevels: Map<String, double>.from(
      (json['soundLevels'] as Map).map(
        (k, v) => MapEntry(k as String, (v as num).toDouble()),
      ),
    ),
  );
}

class CustomSoundMixerScreen extends ConsumerStatefulWidget {
  const CustomSoundMixerScreen({super.key});

  @override
  ConsumerState<CustomSoundMixerScreen> createState() =>
      _CustomSoundMixerScreenState();
}

class _CustomSoundMixerScreenState extends ConsumerState<CustomSoundMixerScreen>
    with TickerProviderStateMixin {
  static const List<Map<String, dynamic>> _soundSources = [
    {'name': 'Rain', 'icon': Icons.water_drop_rounded, 'key': 'rain'},
    {'name': 'Forest', 'icon': Icons.forest_rounded, 'key': 'forest'},
    {'name': 'Cafe', 'icon': Icons.local_cafe_rounded, 'key': 'cafe'},
    {'name': 'White Noise', 'icon': Icons.waves_rounded, 'key': 'white_noise'},
    {'name': 'Birdsong', 'icon': Icons.flutter_dash_rounded, 'key': 'birdsong'},
    {
      'name': 'Fireplace',
      'icon': Icons.local_fire_department_rounded,
      'key': 'fireplace',
    },
  ];

  final Map<String, bool> _activeStates = {};
  final Map<String, double> _volumes = {};
  List<SoundMix> _savedMixes = [];
  String? _activeMixId;

  late AnimationController _saveCheckController;
  late Animation<double> _saveCheckAnimation;
  bool _showSaveCheck = false;

  @override
  void initState() {
    super.initState();
    for (final source in _soundSources) {
      _activeStates[source['key'] as String] = false;
      _volumes[source['key'] as String] = 0.5;
    }
    _saveCheckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _saveCheckAnimation = CurvedAnimation(
      parent: _saveCheckController,
      curve: Curves.easeInOut,
    );
    _loadData();
  }

  @override
  void dispose() {
    _saveCheckController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repository = ref.read(soundMixRepositoryProvider);
    await repository.migrateFromPreferencesIfNeeded();
    final mixes = await repository.fetchAll();

    setState(() {
      _savedMixes = mixes
          .map(
            (mix) => SoundMix(
              id: mix.id,
              name: mix.name,
              soundLevels: Map<String, double>.from(
                (jsonDecode(mix.levelsJson) as Map).map(
                  (key, value) =>
                      MapEntry(key as String, (value as num).toDouble()),
                ),
              ),
            ),
          )
          .toList();
      _activeMixId = mixes.where((mix) => mix.isActive).firstOrNull?.id;
    });

    if (_activeMixId != null) {
      final activeMix = _savedMixes
          .where((m) => m.id == _activeMixId)
          .firstOrNull;
      if (activeMix != null) {
        setState(() {
          for (final key in activeMix.soundLevels.keys) {
            _volumes[key] = activeMix.soundLevels[key]!;
            _activeStates[key] = activeMix.soundLevels[key]! > 0;
          }
        });
      }
    }
  }

  Future<void> _saveMixes() async {
    final repository = ref.read(soundMixRepositoryProvider);
    for (final mix in _savedMixes) {
      await repository.upsert(
        id: mix.id,
        name: mix.name,
        levels: mix.soundLevels,
        isActive: mix.id == _activeMixId,
      );
    }
    if (_activeMixId != null) {
      await repository.setActive(_activeMixId!);
    }
  }

  bool get _hasActiveSounds => _activeStates.values.any((active) => active);

  void _showSaveMixDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFF7F7F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name your mix',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F2F2F),
                ),
              ),
              SizedBox(height: 0.8.h),
              Text(
                'e.g. Rainy Library, Cozy Cafe',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF6F6F6F),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2F2F2F),
                ),
                decoration: InputDecoration(
                  hintText: 'Mix name...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFAAAAAA),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF0EFEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6F6F6F),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.of(ctx).pop();
                          _saveMix(name);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE76F6F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMix(String name) {
    final currentLevels = <String, double>{};
    for (final source in _soundSources) {
      final key = source['key'] as String;
      if (_activeStates[key] == true) {
        currentLevels[key] = _volumes[key]!;
      }
    }
    final mix = SoundMix(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      soundLevels: currentLevels,
    );
    setState(() {
      _savedMixes.add(mix);
      _activeMixId = mix.id;
      _showSaveCheck = true;
    });
    _saveMixes();
    _saveCheckController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _saveCheckController.reverse().then((_) {
            if (mounted) setState(() => _showSaveCheck = false);
          });
        }
      });
    });
  }

  void _applyMix(SoundMix mix) {
    setState(() {
      _activeMixId = mix.id;
      for (final source in _soundSources) {
        final key = source['key'] as String;
        _activeStates[key] = mix.soundLevels.containsKey(key);
        _volumes[key] = mix.soundLevels[key] ?? 0.5;
      }
    });
    _saveMixes();
  }

  void _deleteMix(String mixId) {
    setState(() {
      _savedMixes.removeWhere((m) => m.id == mixId);
      if (_activeMixId == mixId) _activeMixId = null;
    });
    unawaited(ref.read(soundMixRepositoryProvider).delete(mixId));
    _saveMixes();
  }

  void _showEditMixDialog(SoundMix mix) {
    final controller = TextEditingController(text: mix.name);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFF7F7F5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rename mix',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F2F2F),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2F2F2F),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF0EFEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 2.5.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6F6F6F),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.of(ctx).pop();
                          setState(() {
                            final idx = _savedMixes.indexWhere(
                              (m) => m.id == mix.id,
                            );
                            if (idx != -1) {
                              _savedMixes[idx] = SoundMix(
                                id: mix.id,
                                name: name,
                                soundLevels: mix.soundLevels,
                              );
                            }
                          });
                          _saveMixes();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE76F6F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF2F2F2F),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sound Mixer',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2F2F2F),
              ),
            ),
            Text(
              'Create your focus atmosphere',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF6F6F6F),
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sound source cards
                ...List.generate(_soundSources.length, (index) {
                  final source = _soundSources[index];
                  final key = source['key'] as String;
                  return SoundCardWidget(
                    soundName: source['name'] as String,
                    soundIcon: source['icon'] as IconData,
                    isActive: _activeStates[key] ?? false,
                    volume: _volumes[key] ?? 0.5,
                    onToggle: (val) {
                      setState(() => _activeStates[key] = val);
                    },
                    onVolumeChanged: (val) {
                      setState(() => _volumes[key] = val);
                    },
                  );
                }),

                SizedBox(height: 2.h),

                // Save Mix button
                if (_hasActiveSounds)
                  AnimatedOpacity(
                    opacity: _hasActiveSounds ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 350),
                    child: SizedBox(
                      width: double.infinity,
                      child: AnimatedBuilder(
                        animation: _saveCheckAnimation,
                        builder: (context, child) {
                          return ElevatedButton(
                            onPressed: _showSaveCheck
                                ? null
                                : _showSaveMixDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE76F6F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: _showSaveCheck
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Mix Saved!',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Save Mix',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),

                SizedBox(height: 3.h),

                // Saved Atmospheres section
                if (_savedMixes.isNotEmpty) ...[
                  Text(
                    'Saved Atmospheres',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2F2F2F),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  ..._savedMixes.map(
                    (mix) => SavedMixCardWidget(
                      mixName: mix.name,
                      soundLevels: mix.soundLevels,
                      isActive: _activeMixId == mix.id,
                      onApply: () => _applyMix(mix),
                      onEdit: () => _showEditMixDialog(mix),
                      onDelete: () => _deleteMix(mix.id),
                    ),
                  ),
                ],

                SizedBox(height: 4.h),
              ],
            ),
          ),

          // No active sounds hint
          if (!_hasActiveSounds && _savedMixes.isEmpty)
            Positioned(
              bottom: 4.h,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Toggle a sound to begin mixing 🎧',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF6F6F6F),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
