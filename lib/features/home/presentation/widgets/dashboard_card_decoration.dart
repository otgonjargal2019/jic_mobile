import 'package:flutter/material.dart';

BoxDecoration dashboardCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 4)),
    ],
  );
}
