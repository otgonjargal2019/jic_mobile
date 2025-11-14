import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jic_mob/core/network/api_client.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:jic_mob/core/state/notification_provider.dart';
import 'package:jic_mob/core/state/chat_provider.dart';

class ProfilePage extends StatelessWidget {
  static const route = '/profile';
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().profile;
    final name = user?.name ?? '---';
    final extra = user?.extra;

    final loginIdCandidate = _readField(extra, ['loginId', 'userId']);
    final loginId = loginIdCandidate != '---'
        ? loginIdCandidate
        : (user?.id.isNotEmpty == true ? user!.id : (user?.email ?? '---'));

    final emailCandidate = _readField(extra, ['email']);
    final email =
        user?.email ?? (emailCandidate != '---' ? emailCandidate : '---');

    final phone = _readField(extra, [
      'phone',
      'phoneNumber',
      'contact',
      'contactNumber',
      'mobile',
    ]);

    final country = _readField(extra, ['country', 'countryName', 'nationName']);

    final org = _readField(extra, [
      'headquarters',
      'headquarterName',
      'hqName',
      'organization',
      'organizationName',
    ]);

    final dept = _readField(extra, [
      'department',
      'departmentName',
      'deptName',
    ]);

    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F5),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF111111),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFE8E8E8),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 36,
                          color: Color(0xFF9EA3AA),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loginId,
                  style: const TextStyle(
                    color: Color(0xFF6F7177),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFE3E5EA)),
                _InfoRow(label: '국가', value: country),
                _InfoRow(label: '소속 본부', value: org),
                _InfoRow(label: '소속 부서', value: dept),
                _InfoRow(label: '이메일', value: email),
                _InfoRow(label: '연락처', value: phone),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '* 정보 수정은 PC에서만 가능합니다.',
            style: TextStyle(color: Color(0xFF6F7177), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => _showLogoutSheet(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: const Color(0xFF2F4C9F),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('로그아웃'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE3E5EA), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9AA0A6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 13,
                fontWeight: FontWeight.w600,
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

Future<void> _showLogoutSheet(BuildContext context) async {
  final shouldLogout = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '로그아웃 하시겠어요?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE1E3E8)),
                        foregroundColor: const Color(0xFF4E5055),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2F4C9F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('로그아웃'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (shouldLogout != true) return;

  try {
    final api = await ApiClient.create();
    await api.logout();
  } catch (_) {}

  if (context.mounted) {
    context.read<UserProvider>().clear();
    context.read<ChatProvider>().disconnect();
    context.read<NotificationProvider>().disconnect();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
