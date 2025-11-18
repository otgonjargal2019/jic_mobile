import 'package:flutter/material.dart';

import 'dashboard_card_decoration.dart';

class DashboardLoadingCard extends StatelessWidget {
  final double minHeight;
  const DashboardLoadingCard({super.key, this.minHeight = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: dashboardCardDecoration(),
      alignment: Alignment.center,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class DashboardErrorCard extends StatelessWidget {
  final String message;
  final String? detail;
  final Future<void> Function()? onRetry;

  const DashboardErrorCard({
    super.key,
    required this.message,
    this.detail,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: dashboardCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF363249),
            ),
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              detail!,
              style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 12),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onRetry?.call(),
                child: const Text('다시 시도'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
