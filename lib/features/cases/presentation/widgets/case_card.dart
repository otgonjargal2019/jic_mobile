import 'package:flutter/material.dart';
import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';
import 'package:jic_mob/core/widgets/app_tag.dart';

class CaseCard extends StatelessWidget {
  final Case item;
  final VoidCallback? onTap;
  const CaseCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppBadge(text: '유형'),
              const SizedBox(width: 6),
              AppBadge(text: item.id, filled: false),
              const Spacer(),
              Text(
                item.id,
                style: const TextStyle(color: Color(0xFF8D93A1), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: item.chips.map((c) => AppTag(text: c)).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFF39BE8C)),
              const SizedBox(width: 6),
              Text(
                item.status,
                style: const TextStyle(
                  color: Color(0xFF39BE8C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                item.date,
                style: const TextStyle(color: Color(0xFF8D93A1), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}
