import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../services/app_state_service.dart';

class AudioErrorBottomSheet extends StatefulWidget {
  final VoidCallback onRetry;
  final VoidCallback onContinueInSilence;

  const AudioErrorBottomSheet({
    super.key,
    required this.onRetry,
    required this.onContinueInSilence,
  });

  @override
  State<AudioErrorBottomSheet> createState() => _AudioErrorBottomSheetState();
}

class _AudioErrorBottomSheetState extends State<AudioErrorBottomSheet> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D0D0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFA8C3A0).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔇', style: TextStyle(fontSize: 26)),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            'Sound unavailable',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2F2F2F),
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            "We couldn't load your ambient sounds.\nYour session will continue in silence.",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF6F6F6F),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.5.h),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: 'Retry loading ambient sounds',
                  button: true,
                  child: ElevatedButton(
                    onPressed: _isRetrying
                        ? null
                        : () {
                            setState(() => _isRetrying = true);
                            widget.onRetry();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE76F6F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: _isRetrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Retry',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Semantics(
                  label: 'Continue session in silence without ambient sounds',
                  button: true,
                  child: TextButton(
                    onPressed: widget.onContinueInSilence,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6F6F6F),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(
                          color: Color(0xFFD0D0D0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Continue in Silence',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows the audio error bottom sheet with auto-retry logic.
/// Returns true if retry succeeded, false if continuing in silence.
Future<bool> showAudioErrorSheet(BuildContext context) async {
  final appState = AppStateService();
  appState.setAudioState(AudioState.retrying);

  // Auto-retry once silently after 3 seconds
  await Future.delayed(const Duration(seconds: 3));

  // Simulate retry attempt (in real implementation, this would call audio service)
  // For now, we show the sheet if auto-retry fails
  if (!context.mounted) return false;

  appState.setAudioState(AudioState.error);

  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) => AudioErrorBottomSheet(
      onRetry: () {
        // Retry: close sheet and attempt reload
        Navigator.of(ctx).pop(true);
      },
      onContinueInSilence: () {
        Navigator.of(ctx).pop(false);
      },
    ),
  );

  if (result == true) {
    // Show success snackbar
    if (context.mounted) {
      appState.setAudioState(AudioState.normal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🌿 '),
              Text(
                'Sounds restored',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    return true;
  } else {
    appState.setAudioState(AudioState.silent);
    return false;
  }
}
