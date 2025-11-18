import 'package:flutter/material.dart';

import 'package:jic_mob/core/models/dashboard/dashboard_data.dart';
import 'package:jic_mob/core/provider/dashboard_provider.dart';
import 'package:jic_mob/features/home/presentation/widgets/case_status_donut.dart';

import 'dashboard_card_decoration.dart';
import 'dashboard_common_cards.dart';

const _openColor = Color(0xFF3EB491);
const _onHoldColor = Color(0xFF85D685);
const _closedColor = Color(0xFF656565);

class CaseStatusSection extends StatelessWidget {
  final DashboardProvider provider;
  final Future<void> Function()? onRetry;

  const CaseStatusSection({super.key, required this.provider, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final data = provider.data;

    if (provider.loading && data == null) {
      return const DashboardLoadingCard();
    }

    if (provider.error != null && data == null) {
      return DashboardErrorCard(
        message: '대시보드 정보를 불러오지 못했습니다.',
        detail: provider.error,
        onRetry: onRetry,
      );
    }

    final summary =
        data?.summary ??
        const DashboardCaseSummary(open: 0, onHold: 0, closed: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CaseStatusCard(summary: summary, isRefreshing: provider.loading),
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _InlineMessage(
              message: '최신 데이터를 불러오지 못했습니다. 다시 시도해 주세요.',
              onRetry: onRetry,
            ),
          ),
      ],
    );
  }
}

class _CaseStatusCard extends StatelessWidget {
  final DashboardCaseSummary summary;
  final bool isRefreshing;

  const _CaseStatusCard({required this.summary, this.isRefreshing = false});

  static const double _leftStop = 5 / 11;

  @override
  Widget build(BuildContext context) {
    const borderRadiusValue = 16.0;
    final borderRadius = BorderRadius.circular(borderRadiusValue);

    final card = Container(
      decoration: dashboardCardDecoration(),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, _leftStop, _leftStop, 1.0],
              colors: [
                Color(0xFFF2F2F2),
                Color(0xFFF2F2F2),
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: CaseStatusDonut(
                      summary: summary,
                      openColor: _openColor,
                      onHoldColor: _onHoldColor,
                      closedColor: _closedColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatusRow(
                        label: '진행 중인 사건',
                        value: summary.open,
                        color: _openColor,
                        hasDivider: true,
                      ),
                      const SizedBox(height: 12),
                      _StatusRow(
                        label: '미해결 사건',
                        value: summary.onHold,
                        color: _onHoldColor,
                        hasDivider: true,
                      ),
                      const SizedBox(height: 12),
                      _StatusRow(
                        label: '종료된 사건',
                        value: summary.closed,
                        color: _closedColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        card,
        if (isRefreshing)
          const Positioned(
            right: 16,
            top: 16,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool hasDivider;
  const _StatusRow({
    required this.label,
    required this.value,
    required this.color,
    this.hasDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Color(0xFF464A50)),
              ),
            ),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        if (hasDivider) ...[
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFD7D7D7), height: 1, thickness: 1),
        ],
      ],
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _InlineMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 16, color: Color(0xFF9AA0A6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF9AA0A6), fontSize: 12),
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: () => onRetry?.call(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
            child: const Text('다시 시도', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}
