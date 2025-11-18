import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/features/profile/presentation/pages/profile_page.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final name = user?.name ?? 'Guest';
    final avatarUrl = user?.avatarUrl;
    final extra = user?.extra;
    final org = _readField(extra, ['headquarterName']);
    final dept = _readField(extra, ['departmentName']);

    final headAndDeptWidget = Row(
      children: [
        Flexible(
          child: Text(
            org,
            style: const TextStyle(
              color: Color(0xFFBFC0CA),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 1,
          height: 16,
          color: const Color(0xFF707070),
        ),
        Flexible(
          child: Text(
            dept,
            style: const TextStyle(
              color: Color(0xFFBFC0CA),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF363249),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFBDBDBD),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    headAndDeptWidget,
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF6D6A7C),
                  size: 22,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfilePage.route);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _readField(Map<String, dynamic>? extra, List<String> keys) {
  if (extra == null) return '---';
  for (final key in keys) {
    final value = extra[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '---';
}
