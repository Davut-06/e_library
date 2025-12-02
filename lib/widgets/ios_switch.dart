import 'dart:ui';
import 'package:flutter/material.dart';

class IOS7Switch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const IOS7Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 52,
    this.height = 30,
  });

  @override
  State<IOS7Switch> createState() => _IOS7SwitchState();
}

class _IOS7SwitchState extends State<IOS7Switch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(IOS7Switch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.animateTo(widget.value ? 1 : 0, curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF34C759); // iOS green

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _controller.value;

          return Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Color.lerp(Colors.grey.shade300, activeColor, t),
              borderRadius: BorderRadius.circular(widget.height),
            ),
            child: Align(
              alignment: Alignment(lerpDouble(-1, 1, t)!, 0),
              child: Container(
                width: widget.height - 4,
                height: widget.height - 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
