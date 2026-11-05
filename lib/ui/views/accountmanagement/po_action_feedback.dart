import 'package:flutter/material.dart';

/// Visual feedback only; the original InkWell still owns the action.
class PoActionFeedback extends StatefulWidget {
  const PoActionFeedback({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  State<PoActionFeedback> createState() => _PoActionFeedbackState();
}

class _PoActionFeedbackState extends State<PoActionFeedback> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final duration = Duration(milliseconds: reducedMotion ? 0 : 120);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: duration,
          scale: _pressed ? 0.96 : 1,
          child: AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _hovered ? const Color(0x08000000) : Colors.transparent,
              boxShadow: const [],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
