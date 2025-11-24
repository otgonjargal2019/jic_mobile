import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final bool filled;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;
  final TextStyle? textStyle;

  const AppBadge({
    super.key,
    required this.text,
    this.filled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.background,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        background ?? (filled ? const Color(0xFFEFF1F5) : Colors.transparent);
    final border = Border.all(color: borderColor ?? const Color(0xFFE2E4EA));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: filled ? null : border,
      ),
      child: Text(
        text,
        style:
            textStyle ??
            const TextStyle(fontSize: 11, color: Color(0xFF60646B)),
      ),
    );
  }
}
