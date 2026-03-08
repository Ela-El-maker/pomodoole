import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../services/app_state_service.dart';

class SessionRecoveryDialog extends StatelessWidget {
  final String sessionType;
  final int remainingSeconds;
  final VoidCallback onResume;
  final VoidCallback onStartFresh;

  const SessionRecoveryDialog({
    super.key,
    required this.sessionType,
    required this.remainingSeconds,
    required this.onResume,
    required this.onStartFresh,
  });

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Session recovery dialog. Your last $sessionType session was interrupted.',
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFEA),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Soft icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE76F6F).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌿', style: TextStyle(fontSize: 30)),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Your session is still running 🌿',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F2F2F),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'It looks like your last session was interrupted. Would you like to resume?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF6F6F6F),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              // Session info card
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          sessionType,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6F6F6F),
                          ),
                        ),
                        Text(
                          'Session Type',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF9F9F9F),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      color: const Color(0xFFD0D0D0),
                    ),
                    Column(
                      children: [
                        Text(
                          _formattedTime,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE76F6F),
                          ),
                        ),
                        Text(
                          'Time Remaining',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFF9F9F9F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label:
                      'Resume interrupted $sessionType session with $_formattedTime remaining',
                  button: true,
                  child: ElevatedButton(
                    onPressed: onResume,
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
                      'Resume Session',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: 'Discard interrupted session and start fresh',
                  button: true,
                  child: TextButton(
                    onPressed: onStartFresh,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6F6F6F),
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                    ),
                    child: Text(
                      'Start Fresh',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the session recovery dialog if there's an interrupted session.
void showSessionRecoveryIfNeeded(
  BuildContext context, {
  required VoidCallback onResume,
  required VoidCallback onStartFresh,
}) {
  final appState = AppStateService();
  if (!appState.hasInterruptedSession) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SessionRecoveryDialog(
        sessionType: appState.interruptedSessionType,
        remainingSeconds: appState.interruptedRemainingSeconds,
        onResume: () {
          Navigator.of(context).pop();
          onResume();
        },
        onStartFresh: () {
          Navigator.of(context).pop();
          appState.clearInterruptedSession();
          onStartFresh();
        },
      ),
    );
  });
}
