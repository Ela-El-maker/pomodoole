import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TaskItemWidget extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onSetActive;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onSetActive,
  });

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkScale;
  double _dragOffset = 0.0;

  static const Color _accentRed = Color(0xFFE76F6F);
  static const Color _sageGreen = Color(0xFFA8C3A0);
  static const Color _cardBg = Color(0xFFF0EFEA);
  static const Color _primaryText = Color(0xFF2F2F2F);
  static const Color _secondaryText = Color(0xFF6F6F6F);

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );
    if (widget.task['isCompleted'] == true) {
      _checkController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.lightImpact();
    if (widget.task['isCompleted'] == true) {
      _checkController.reverse();
    } else {
      _checkController.forward();
    }
    widget.onToggleComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task['isCompleted'] == true;
    final isActive = widget.task['isActive'] == true;
    final estimated = (widget.task['estimatedPomodoros'] as int? ?? 1);
    final completed = (widget.task['completedPomodoros'] as int? ?? 0);
    final remaining = (estimated - completed).clamp(0, estimated);

    return GestureDetector(
      onHorizontalDragUpdate: (d) {
        setState(
          () => _dragOffset = (_dragOffset + d.delta.dx).clamp(-80.0, 80.0),
        );
      },
      onHorizontalDragEnd: (_) {
        if (_dragOffset < -60) {
          HapticFeedback.mediumImpact();
          widget.onDelete();
        } else if (_dragOffset > 60) {
          _handleToggle();
        }
        setState(() {
          _dragOffset = 0.0;
        });
      },
      child: Stack(
        children: [
          // Background hint for swipe
          if (_dragOffset < -20)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 22,
                ),
              ),
            ),
          if (_dragOffset > 20)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: _sageGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: Icon(
                  Icons.check_circle_outline,
                  color: _sageGreen,
                  size: 22,
                ),
              ),
            ),
          // Main card
          Transform.translate(
            offset: Offset(_dragOffset * 0.4, 0),
            child: GestureDetector(
              onTap: widget.onSetActive,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive
                      ? _accentRed.withValues(alpha: 0.08)
                      : _cardBg,
                  borderRadius: BorderRadius.circular(16.0),
                  border: isActive
                      ? Border.all(
                          color: _accentRed.withValues(alpha: 0.3),
                          width: 1.5,
                        )
                      : Border.all(color: Colors.transparent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Check circle
                    GestureDetector(
                      onTap: _handleToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? _sageGreen : Colors.transparent,
                          border: Border.all(
                            color: isCompleted
                                ? _sageGreen
                                : _secondaryText.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: isCompleted
                            ? ScaleTransition(
                                scale: _checkScale,
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Task info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task['title'] as String? ?? '',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? _secondaryText
                                  : _primaryText,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: _secondaryText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Text(
                                '$remaining session${remaining != 1 ? 's' : ''} remaining',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: _secondaryText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              // Tomato icons
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    estimated.clamp(0, 6),
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Text(
                                        i < completed ? '🍅' : '🍅',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: i < completed
                                              ? null
                                              : Colors.black.withValues(
                                                  alpha: 0.25,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Active indicator
                    if (isActive)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _accentRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
