import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodorofocus/data/models/catalog_item.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:sizer/sizer.dart';
import './widgets/mood_chip_widget.dart';
import './widgets/reflection_prompt_widget.dart';
import '../../routes/app_routes.dart';

class PostSessionReflectionScreen extends ConsumerStatefulWidget {
  const PostSessionReflectionScreen({super.key});

  @override
  ConsumerState<PostSessionReflectionScreen> createState() =>
      _PostSessionReflectionScreenState();
}

class _PostSessionReflectionScreenState
    extends ConsumerState<PostSessionReflectionScreen>
    with TickerProviderStateMixin {
  String? _selectedMood;
  final TextEditingController _wentWellController = TextEditingController();
  final TextEditingController _distractedController = TextEditingController();
  final TextEditingController _nextFocusController = TextEditingController();
  final TextEditingController _freeNotesController = TextEditingController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _saveOverlayController;
  late Animation<double> _saveOverlayAnimation;
  bool _showSaveOverlay = false;
  bool _hasChanges = false;

  bool get _hasAnyContent =>
      _selectedMood != null ||
      _wentWellController.text.isNotEmpty ||
      _distractedController.text.isNotEmpty ||
      _nextFocusController.text.isNotEmpty ||
      _freeNotesController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();

    _saveOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _saveOverlayAnimation = CurvedAnimation(
      parent: _saveOverlayController,
      curve: Curves.easeInOut,
    );

    _wentWellController.addListener(() => _hasChanges = true);
    _distractedController.addListener(() => _hasChanges = true);
    _nextFocusController.addListener(() => _hasChanges = true);
    _freeNotesController.addListener(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _saveOverlayController.dispose();
    _wentWellController.dispose();
    _distractedController.dispose();
    _nextFocusController.dispose();
    _freeNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveReflection() async {
    await ref
        .read(reflectionsRepositoryProvider)
        .addReflection(
          mood: _selectedMood,
          wentWell: _wentWellController.text,
          distractedBy: _distractedController.text,
          nextFocus: _nextFocusController.text,
          notes: _freeNotesController.text,
        );

    // Show save overlay
    setState(() => _showSaveOverlay = true);
    unawaited(
      _saveOverlayController.forward().then((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        unawaited(
          _saveOverlayController.reverse().then((_) {
            if (mounted) {
              setState(() => _showSaveOverlay = false);
              _navigateAway();
            }
          }),
        );
      }),
    );
  }

  void _skipReflection() async {
    if (_hasChanges) {
      final save = await _showUnsavedDialog();
      if (save == true) {
        await _saveReflection();
        return;
      } else if (save == null) {
        return; // cancelled
      }
    }
    _navigateAway();
  }

  Future<bool?> _showUnsavedDialog() {
    return showDialog<bool>(
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
            children: [
              Text(
                'Save your reflection?',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2F2F2F),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'You have unsaved thoughts. Would you like to save them before leaving?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF6F6F6F),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.5.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        'Discard',
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
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE76F6F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
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

  Future<bool> _onWillPop() async {
    if (!_hasAnyContent) return true;
    // Show inline bottom sheet guard
    final result = await _showReflectionGuardSheet();
    if (result == 'save') {
      await _saveReflection();
      return false; // _saveReflection handles navigation
    } else if (result == 'discard') {
      return true;
    }
    return false; // 'keep' or dismissed
  }

  Future<String?> _showReflectionGuardSheet() {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
        decoration: const BoxDecoration(
          color: Color(0xFFF7F7F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Save your reflection? 🌿',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2F2F2F),
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              "You've started a reflection. Would you like to save it before leaving?",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF6F6F6F),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.5.h),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                label: 'Save reflection and leave screen',
                button: true,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop('save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE76F6F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                  child: Text(
                    'Save & Leave',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Discard reflection and leave',
                    button: true,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop('discard'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6F6F6F),
                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Color(0xFFD0D0D0)),
                        ),
                      ),
                      child: Text(
                        'Discard',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Semantics(
                    label: 'Keep writing reflection',
                    button: true,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop('keep'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6F6F6F),
                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(color: Color(0xFFD0D0D0)),
                        ),
                      ),
                      child: Text(
                        'Keep Writing',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateAway() {
    if (!mounted) return;
    context.go(AppRoutes.timer);
  }

  @override
  Widget build(BuildContext context) {
    final moodsAsync = ref.watch(catalogItemsProvider(CatalogType.mood));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canLeave = await _onWillPop();
        if (canLeave && mounted) {
          _navigateAway();
        }
      },
      child: Stack(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7F5),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 3.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Session Complete 🌿',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF2F2F2F),
                                    ),
                                  ),
                                  SizedBox(height: 0.8.h),
                                  Text(
                                    'Take a moment to reflect.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFF6F6F6F),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 3.5.h),

                            // Mood Tracker
                            Text(
                              'How do you feel?',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2F2F2F),
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                            moodsAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stackTrace) => Text(
                                'Unable to load moods',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF6F6F6F),
                                ),
                              ),
                              data: (moods) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: moods.map((mood) {
                                  return MoodChipWidget(
                                    emoji: mood.emoji ?? '🙂',
                                    label: mood.label,
                                    isSelected: _selectedMood == mood.value,
                                    onTap: () {
                                      setState(() {
                                        _selectedMood =
                                            _selectedMood == mood.value
                                            ? null
                                            : mood.value;
                                        _hasChanges = true;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                            SizedBox(height: 3.h),

                            // Reflection Prompts
                            Text(
                              'Reflection Prompts',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2F2F2F),
                              ),
                            ),
                            Text(
                              'Optional — tap to expand',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF6F6F6F),
                              ),
                            ),
                            SizedBox(height: 1.5.h),
                            ReflectionPromptWidget(
                              prompt: 'What went well during this session?',
                              hintText: 'Share what worked for you...',
                              controller: _wentWellController,
                            ),
                            ReflectionPromptWidget(
                              prompt: 'What distracted you?',
                              hintText: 'Any interruptions or distractions...',
                              controller: _distractedController,
                            ),
                            ReflectionPromptWidget(
                              prompt: 'What will you focus on next?',
                              hintText: 'Your next intention...',
                              controller: _nextFocusController,
                            ),

                            SizedBox(height: 2.h),

                            // Free Notes
                            Text(
                              'Session Notes',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF2F2F2F),
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EFEA),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: TextField(
                                controller: _freeNotesController,
                                maxLines: 5,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF2F2F2F),
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Write anything about this session...',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ),

                    // Bottom action buttons
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _skipReflection,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                'Skip Reflection',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6F6F6F),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _saveReflection,
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
                              child: Text(
                                'Save & Continue',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Save confirmation overlay
          if (_showSaveOverlay)
            AnimatedBuilder(
              animation: _saveOverlayAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _saveOverlayAnimation.value * 0.3,
                  child: Container(
                    color: const Color(0xFFA8C3A0),
                    child: Center(
                      child: Opacity(
                        opacity: _saveOverlayAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Reflection saved 🌿',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
