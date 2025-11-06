import 'package:flutter/material.dart';

/// Simple rectangular tag with small radius.
class AppTag extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const AppTag({
    super.key,
    required this.text,
    this.background = const Color(0xFFF4F6F8),
    this.foreground = const Color(0xFF4B4F57),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: foreground, fontSize: 12)),
    );
  }
}
