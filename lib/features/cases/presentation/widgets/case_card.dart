import 'package:flutter/material.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
import 'package:jic_mob/core/models/case/case.dart';
import 'package:jic_mob/core/widgets/app_badge.dart';

class CaseCard extends StatelessWidget {
  final Case item;
  final VoidCallback? onTap;
  const CaseCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    AppLocalizations? _loc = AppLocalizations.of(context)!;
    final card = Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            offset: Offset(1, 1),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(
                text: _loc.translate('case_details.case_infringement_type.${item.infringementType}'),
                filled: true,
                background: const Color(0xFF5C5C5C),
                borderColor: Color(0xFF5C5C5C),
                textStyle: const TextStyle(fontSize: 11, color: Color(0xFFFFFFFF)),
              ),
              const SizedBox(width: 6),
              AppBadge(
                text: item.relatedCountries,
                filled: false,
                textStyle: const TextStyle(fontSize: 11, color: Color(0xFF60646B)),
                borderColor: Color(0xFF60646B),
              ),
              const Spacer(),
              Text(
                item.number,
                style: const TextStyle(color: Color(0xFF8D93A1), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 0),
          Text(item.manager, style: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF60646B), fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFF39BE8C)),
              const SizedBox(width: 6),
              Text(
                _loc.translate('case_details.status.${item.status}'),
                style: const TextStyle(
                  color: Color(0xFF39BE8C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              item.progressStatus.trim().isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        '|',
                        style: const TextStyle(
                          color: Color(0xFFD4D4D4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              Text(
                _loc.translate('case_details.progressStatus.${item.progressStatus}'),
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: Text(
                  '|',
                  style: const TextStyle(
                    color: Color(0xFFD4D4D4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                item.date,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      radius: 6,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: card,
    );
  }
}
