import 'package:flutter/material.dart';

class SegmentedTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;
  final Color backgroundColor;
  final Color selectedColor;
  final Color textColor;

  const SegmentedTabs({
    super.key,
    required this.index,
    required this.labels,
    required this.onChanged,
    this.backgroundColor = const Color(0xFFF0F2F5),
    this.selectedColor = const Color(0xFF39BE8C),
    this.textColor = const Color(0xB3363249),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            _pill(
              selected: index == i,
              label: labels[i],
              onTap: () => onChanged(i),
              textColor: textColor,
            ),
            if (i != labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _pill({
    required bool selected,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border(
            top: BorderSide(
              color: textColor,
              width: 1,
            ),
            left: BorderSide(
              color: textColor,
              width: 1,
            ),
            right: BorderSide(
              color: textColor,
              width: 1,
            ),
            bottom: BorderSide(
              color: textColor,
              width: 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: selected ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }
}
