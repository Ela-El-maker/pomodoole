import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../state/app/data_providers.dart';
import './widgets/atmosphere_step_widget.dart';
import './widgets/break_duration_step_widget.dart';
import './widgets/focus_duration_step_widget.dart';
import './widgets/ready_step_widget.dart';
import './widgets/step_progress_indicator_widget.dart';
import './widgets/weekly_goal_step_widget.dart';

class OnboardingSetupFlowScreen extends ConsumerStatefulWidget {
  const OnboardingSetupFlowScreen({super.key});

  @override
  ConsumerState<OnboardingSetupFlowScreen> createState() =>
      _OnboardingSetupFlowScreenState();
}

class _OnboardingSetupFlowScreenState
    extends ConsumerState<OnboardingSetupFlowScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  int _selectedFocusDuration = 25;
  int _selectedBreakDuration = 5;
  String _selectedAtmosphere = 'Silent';
  int _selectedWeeklyGoal = 40;
  bool _weeklyGoalInitialized = false;
  bool _canEditWeeklyGoal = true;
  String? _weeklyGoalLockMessage;
  bool _isGoalLoading = true;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );
    _slideController.forward();
    unawaited(_loadWeeklyGoalState());
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (!_canProceedCurrentStep()) {
      return;
    }

    if (_currentStep < 4) {
      await _slideController.reverse();
      setState(() => _currentStep++);
      unawaited(_slideController.forward());
    } else {
      await _savePreferences();
      if (mounted) {
        context.go(AppRoutes.timer);
      }
    }
  }

  void _prevStep() async {
    if (_currentStep > 0) {
      await _slideController.reverse();
      setState(() => _currentStep--);
      unawaited(_slideController.forward());
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('work_duration', _selectedFocusDuration);
    await prefs.setInt('short_break_duration', _selectedBreakDuration);
    await prefs.setString('atmosphere', _selectedAtmosphere);
    if (!_weeklyGoalInitialized || _canEditWeeklyGoal) {
      await ref
          .read(statisticsRepositoryProvider)
          .setWeeklyGoalSessions(_selectedWeeklyGoal);
    }
    await prefs.setBool('onboarding_complete', true);
  }

  Future<void> _loadWeeklyGoalState() async {
    final state = await ref
        .read(statisticsRepositoryProvider)
        .getWeeklyGoalSetupState();
    if (!mounted) return;
    setState(() {
      _selectedWeeklyGoal = state.weeklyGoalSessions;
      _weeklyGoalInitialized = state.initialized;
      _canEditWeeklyGoal = state.canEdit;
      _weeklyGoalLockMessage = state.lockMessage;
      _isGoalLoading = false;
    });
  }

  bool _canProceedCurrentStep() {
    if (_currentStep == 3 && _isGoalLoading) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, keyboardInset + 2.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    SizedBox(height: 3.h),
                    // Back button + progress
                    Row(
                      children: [
                        if (_currentStep > 0)
                          GestureDetector(
                            onTap: _prevStep,
                            child: Container(
                              width: 10.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EFEA),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: Color(0xFF6F6F6F),
                              ),
                            ),
                          )
                        else
                          SizedBox(width: 10.w),
                        Expanded(
                          child: StepProgressIndicatorWidget(
                            currentStep: _currentStep,
                            totalSteps: 5,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildCurrentStep(),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Next button
                    _buildNextButton(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return FocusDurationStepWidget(
          selectedDuration: _selectedFocusDuration,
          onDurationSelected: (d) => setState(() => _selectedFocusDuration = d),
        );
      case 1:
        return BreakDurationStepWidget(
          selectedDuration: _selectedBreakDuration,
          onDurationSelected: (d) => setState(() => _selectedBreakDuration = d),
        );
      case 2:
        return AtmosphereStepWidget(
          selectedAtmosphere: _selectedAtmosphere,
          onAtmosphereSelected: (a) => setState(() => _selectedAtmosphere = a),
        );
      case 3:
        return WeeklyGoalStepWidget(
          selectedGoal: _selectedWeeklyGoal,
          isEditable: _canEditWeeklyGoal,
          isLoading: _isGoalLoading,
          lockMessage: _weeklyGoalLockMessage,
          onGoalSelected: (value) =>
              setState(() => _selectedWeeklyGoal = value),
        );
      case 4:
        return ReadyStepWidget(
          focusDuration: _selectedFocusDuration,
          breakDuration: _selectedBreakDuration,
          atmosphere: _selectedAtmosphere,
          weeklyGoal: _selectedWeeklyGoal,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildNextButton() {
    final isLastStep = _currentStep == 4;
    final canProceed = _canProceedCurrentStep();
    return GestureDetector(
      onTap: canProceed ? _nextStep : null,
      child: Container(
        width: double.infinity,
        height: 7.h,
        decoration: BoxDecoration(
          color:
              (isLastStep ? const Color(0xFFA8C3A0) : const Color(0xFFE76F6F))
                  .withValues(alpha: canProceed ? 1.0 : 0.5),
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            BoxShadow(
              color:
                  (isLastStep
                          ? const Color(0xFFA8C3A0)
                          : const Color(0xFFE76F6F))
                      .withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            isLastStep ? 'Start First Session' : 'Next',
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
