import 'package:flutter/material.dart';

import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/features/cases/presentation/widgets/case_card.dart';

import 'dashboard_card_decoration.dart';
import 'dashboard_common_cards.dart';

class RecentCasesSection extends StatelessWidget {
  final List<Case> items;
  final bool isLoading;
  final String? error;
  final Future<void> Function()? onRetry;

  const RecentCasesSection({
    super.key,
    required this.items,
    this.isLoading = false,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const DashboardLoadingCard(minHeight: 120);
    }

    if (error != null && items.isEmpty) {
      return DashboardErrorCard(
        message: '최근 사건 정보를 불러오지 못했습니다.',
        detail: error,
        onRetry: onRetry,
      );
    }

    if (items.isEmpty) {
      return const _RecentCasesEmpty();
    }

    return Column(
      children: items.take(3).map((e) => CaseCard(item: e)).toList(),
    );
  }
}

class _RecentCasesEmpty extends StatelessWidget {
  const _RecentCasesEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: dashboardCardDecoration(),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: const Text(
        '최근 수사한 사건이 없습니다.',
        style: TextStyle(color: Color(0xFF60646B)),
      ),
    );
  }
}
