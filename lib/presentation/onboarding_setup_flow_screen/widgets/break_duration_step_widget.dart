import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class BreakDurationStepWidget extends StatefulWidget {
  final int selectedDuration;
  final ValueChanged<int> onDurationSelected;

  const BreakDurationStepWidget({
    super.key,
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  @override
  State<BreakDurationStepWidget> createState() =>
      _BreakDurationStepWidgetState();
}

class _BreakDurationStepWidgetState extends State<BreakDurationStepWidget> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2 of 5',
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA8C3A0),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'How long should\nyour breaks be?',
          style: GoogleFonts.dmSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
            height: 1.3,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Short breaks help you recharge gently.',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
          ),
        ),
        SizedBox(height: 4.h),
        _buildOptionCard(5, '5 min', 'Quick refresh', isDefault: true),
        SizedBox(height: 2.h),
        _buildOptionCard(10, '10 min', 'Relaxed pause'),
        SizedBox(height: 2.h),
        _buildCustomCard(),
      ],
    );
  }

  Widget _buildOptionCard(
    int duration,
    String label,
    String subtitle, {
    bool isDefault = false,
  }) {
    final isSelected = widget.selectedDuration == duration && !_showCustomInput;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showCustomInput = false;
          _customError = null;
        });
        widget.onDurationSelected(duration);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F2F2F),
                        ),
                      ),
                      if (isDefault) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFA8C3A0,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'default',
                            style: GoogleFonts.dmSans(
                              fontSize: 8.sp,
                              color: const Color(0xFFA8C3A0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
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
          _customController.text = widget.selectedDuration.toString();
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
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                                  hintText: 'Enter minutes',
                                  hintStyle: GoogleFonts.dmSans(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF6F6F6F),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (val) {
                                  final parsed = int.tryParse(val);
                                  if (val.trim().isEmpty) {
                                    setState(
                                      () =>
                                          _customError = 'Enter minutes (1-60)',
                                    );
                                    return;
                                  }
                                  if (parsed == null ||
                                      parsed <= 0 ||
                                      parsed > 60) {
                                    setState(
                                      () => _customError =
                                          'Use a value from 1 to 60',
                                    );
                                    return;
                                  }
                                  setState(() => _customError = null);
                                  widget.onDurationSelected(parsed);
                                },
                                onSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                              ),
                            ),
                            Text(
                              'min',
                              style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                color: const Color(0xFF6F6F6F),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Custom',
                          style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2F2F2F),
                          ),
                        ),
                ),
              ],
            ),
            if (_showCustomInput && _customError != null) ...[
              SizedBox(height: 0.8.h),
              Text(
                _customError!,
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  color: const Color(0xFFE76F6F),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
