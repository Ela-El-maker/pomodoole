import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodorofocus/data/models/catalog_item.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:pomodorofocus/state/sound/mixer_controller.dart';
import 'package:sizer/sizer.dart';

import 'widgets/saved_mix_card_widget.dart';
import 'widgets/sound_card_widget.dart';

class CustomSoundMixerScreen extends ConsumerStatefulWidget {
  const CustomSoundMixerScreen({super.key});

  @override
  ConsumerState<CustomSoundMixerScreen> createState() =>
      _CustomSoundMixerScreenState();
}

class _CustomSoundMixerScreenState extends ConsumerState<CustomSoundMixerScreen>
    with TickerProviderStateMixin {
  late final MixerController _mixerController;
  late final AnimationController _saveCheckController;
  late final Animation<double> _saveCheckAnimation;
  bool _showSaveCheck = false;

  @override
  void initState() {
    super.initState();
    _mixerController = ref.read(mixerControllerProvider);
    _saveCheckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _saveCheckAnimation = CurvedAnimation(
      parent: _saveCheckController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_mixerController.attachMixerPreview());
    });
  }

  @override
  void dispose() {
    unawaited(_mixerController.detachMixerPreview());
    _saveCheckController.dispose();
    super.dispose();
  }

  void _showSaveMixDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFF7F7F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        Navigator.of(ctx).pop();
                        await ref.read(mixerControllerProvider).saveMix(name);
                        if (!mounted) return;
                        setState(() => _showSaveCheck = true);
                        await _saveCheckController.forward();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 800),
                        );
                        if (!mounted) return;
                        await _saveCheckController.reverse();
                        if (!mounted) return;
                        setState(() => _showSaveCheck = false);
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

  void _showEditMixDialog(SavedSoundMix mix) {
    final controller = TextEditingController(text: mix.name);
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFF7F7F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        Navigator.of(ctx).pop();
                        await ref
                            .read(mixerControllerProvider)
                            .renameMix(mix.id, name);
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

  IconData _iconFromToken(String? token) {
    switch (token) {
      case 'water_drop_rounded':
        return Icons.water_drop_rounded;
      case 'forest_rounded':
        return Icons.forest_rounded;
      case 'local_cafe_rounded':
        return Icons.local_cafe_rounded;
      case 'waves_rounded':
        return Icons.waves_rounded;
      case 'flutter_dash_rounded':
        return Icons.flutter_dash_rounded;
      case 'local_fire_department_rounded':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final soundsAsync = ref.watch(
      catalogItemsProvider(CatalogType.soundSource),
    );
    final mixer = ref.watch(mixerControllerProvider);

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
      body: soundsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load sounds')),
        data: (soundSources) {
          final sourceByValue = {
            for (final source in soundSources) source.value: source,
          };
          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...soundSources.map((source) {
                      final key = source.value;
                      final isEvent = mixer.isEventSound(key);
                      return SoundCardWidget(
                        soundName: source.label,
                        soundIcon: _iconFromToken(source.iconToken),
                        isActive: mixer.isEnabled(key),
                        volume: mixer.volumeFor(key),
                        showDensityControl: isEvent,
                        density: mixer.densityFor(key),
                        onToggle: (val) async {
                          final message = await ref
                              .read(mixerControllerProvider)
                              .toggleSound(key, val);
                          if (message != null && context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                        onVolumeChanged: (val) {
                          unawaited(
                            ref
                                .read(mixerControllerProvider)
                                .setVolume(key, val),
                          );
                        },
                        onSolo: () async {
                          final message = await ref
                              .read(mixerControllerProvider)
                              .soloSound(key);
                          if (message != null && context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          }
                        },
                        onDensityChanged: isEvent
                            ? (density) {
                                unawaited(
                                  ref
                                      .read(mixerControllerProvider)
                                      .setEventDensity(key, density),
                                );
                              }
                            : null,
                      );
                    }),
                    SizedBox(height: 2.h),
                    if (mixer.hasActiveSounds && !mixer.isLoading)
                      AnimatedOpacity(
                        opacity: mixer.hasActiveSounds ? 1.0 : 0.0,
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  elevation: 0,
                                ),
                                child: _showSaveCheck
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                    if (mixer.savedMixes.isNotEmpty) ...[
                      Text(
                        'Saved Atmospheres',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2F2F2F),
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      ...mixer.savedMixes.map((mix) {
                        final displayLevels = <String, double>{};
                        for (final soundId in mix.payload.enabledSoundIds) {
                          final source = sourceByValue[soundId];
                          if (source == null) continue;
                          displayLevels[source.label] =
                              mix.payload.levels[soundId] ?? 0.0;
                        }
                        return SavedMixCardWidget(
                          mixName: mix.name,
                          soundLevels: displayLevels,
                          isActive: mixer.activeMixId == mix.id,
                          onApply: () async {
                            final message = await ref
                                .read(mixerControllerProvider)
                                .applySavedMix(mix.id);
                            if (message != null && context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            }
                          },
                          onEdit: () => _showEditMixDialog(mix),
                          onDelete: () {
                            unawaited(
                              ref
                                  .read(mixerControllerProvider)
                                  .deleteMix(mix.id),
                            );
                          },
                        );
                      }),
                    ],
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
              if (!mixer.hasActiveSounds && mixer.savedMixes.isEmpty)
                Positioned(
                  bottom: 4.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Toggle a sound to begin mixing',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF6F6F6F),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
