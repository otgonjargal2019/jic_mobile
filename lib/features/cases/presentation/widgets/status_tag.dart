import 'package:flutter/material.dart';

class StatusTag extends StatelessWidget {
  final String status;
  final bool border;

  const StatusTag({super.key, required this.status, this.border = false});

  @override
  Widget build(BuildContext context) {
    String text = "";
    Color ellipseColor = Colors.transparent;
    Color textColor = Colors.black;
    Color? borderColor;
    Color bgColor = Colors.white;

    // Text болон color-г тогтоох
    switch (status) {
      case "OPEN":
        text =
            "Open"; // Танд localization хэрэгтэй бол Intl package ашиглаж болно
        ellipseColor = Colors.green;
        if (border) borderColor = Colors.green;
        textColor = Colors.black;
        break;
      case "ON_HOLD":
        text = "On Hold";
        ellipseColor = Colors.grey.shade400;
        if (border) borderColor = Colors.grey.shade400;
        textColor = Colors.black;
        break;
      case "CLOSED":
        text = "Closed";
        ellipseColor = Colors.grey.shade400;
        if (border) borderColor = Colors.grey.shade400;
        textColor = Colors.black;
        break;
      default:
        text = "";
        ellipseColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        border: borderColor != null ? Border.all(color: borderColor) : null,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: ellipseColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
