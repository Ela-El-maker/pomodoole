import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class WeeklyGoalStepWidget extends StatefulWidget {
  const WeeklyGoalStepWidget({
    super.key,
    required this.selectedGoal,
    required this.isEditable,
    required this.isLoading,
    required this.lockMessage,
    required this.onGoalSelected,
  });

  final int selectedGoal;
  final bool isEditable;
  final bool isLoading;
  final String? lockMessage;
  final ValueChanged<int> onGoalSelected;

  @override
  State<WeeklyGoalStepWidget> createState() => _WeeklyGoalStepWidgetState();
}

class _WeeklyGoalStepWidgetState extends State<WeeklyGoalStepWidget> {
  bool _showCustomInput = false;
  final _customController = TextEditingController();
  final _customFocusNode = FocusNode();
  String? _customError;

  @override
  void dispose() {
    _customController.dispose();
    _customFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4 of 5',
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA8C3A0),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set your weekly\nfocus goal',
          style: GoogleFonts.dmSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
            height: 1.3,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          widget.isEditable
              ? 'Pick how many focus sessions you want to complete this week.'
              : 'Your weekly goal is locked until you reach it or this week ends.',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
          ),
        ),
        SizedBox(height: 3.h),
        if (!widget.isEditable)
          _buildReadOnlyCard(context)
        else ...[
          _buildOptionCard(20, '20 sessions', 'Steady baseline'),
          SizedBox(height: 1.5.h),
          _buildOptionCard(30, '30 sessions', 'Ambitious weekly rhythm'),
          SizedBox(height: 1.5.h),
          _buildOptionCard(40, '40 sessions', 'Power-user pace'),
          SizedBox(height: 1.5.h),
          _buildCustomCard(),
        ],
      ],
    );
  }

  Widget _buildReadOnlyCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE0DED8), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current goal',
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6F6F6F),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${widget.selectedGoal} sessions/week',
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2F2F2F),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            widget.lockMessage ??
                'Goal can be edited after reaching it or when this week ends.',
            style: GoogleFonts.dmSans(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6F6F6F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(int sessions, String label, String subtitle) {
    final isSelected = widget.selectedGoal == sessions && !_showCustomInput;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showCustomInput = false;
          _customError = null;
        });
        widget.onGoalSelected(sessions);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8C3A0).withValues(alpha: 0.12)
              : const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? const Color(0xFFA8C3A0) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFA8C3A0)
                    : const Color(0xFFE0DED8),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F2F2F),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF6F6F6F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCustomInput = true;
          _customError = null;
          _customController.text = widget.selectedGoal.toString();
          _customController.selection = TextSelection.collapsed(
            offset: _customController.text.length,
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _customFocusNode.requestFocus();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        decoration: BoxDecoration(
          color: _showCustomInput
              ? const Color(0xFFA8C3A0).withValues(alpha: 0.12)
              : const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: _showCustomInput
                ? const Color(0xFFA8C3A0)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 5.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _showCustomInput
                        ? const Color(0xFFA8C3A0)
                        : const Color(0xFFE0DED8),
                  ),
                  child: _showCustomInput
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _showCustomInput
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customController,
                                focusNode: _customFocusNode,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                autofocus: true,
                                textInputAction: TextInputAction.done,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2F2F2F),
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Sessions/week',
                                  hintStyle: GoogleFonts.dmSans(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFF6F6F6F),
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _applyCustom(),
                              ),
                            ),
                            GestureDetector(
                              onTap: _applyCustom,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA8C3A0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Set',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custom',
                              style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2F2F2F),
                              ),
                            ),
                            Text(
                              'Choose your own target',
                              style: GoogleFonts.dmSans(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w300,
                                color: const Color(0xFF6F6F6F),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            if (_customError != null) ...[
              SizedBox(height: 0.8.h),
              Text(
                _customError!,
                style: GoogleFonts.dmSans(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE76F6F),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _applyCustom() {
    final value = int.tryParse(_customController.text.trim());
    if (value == null || value < 1 || value > 200) {
      setState(() {
        _customError = 'Enter a value between 1 and 200.';
      });
      return;
    }
    setState(() => _customError = null);
    widget.onGoalSelected(value);
    FocusScope.of(context).unfocus();
  }
}
