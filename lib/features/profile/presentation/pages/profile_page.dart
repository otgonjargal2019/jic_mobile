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
    const background = Color(0xFFF7F7F5);
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
      backgroundColor: Color(0xFFF7F7F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(99),
        child: Container(
          decoration: const BoxDecoration(
            color: background,
            border: Border(
              bottom: BorderSide(color: Color(0xFFDCDCDC), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          height: 99,
          child: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Icon(Icons.arrow_back_ios, size: 22),
                ),
              ),
            ),
            elevation: 0,
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 99,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: const Text(
              '마이페이지',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFFF7F7F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFE8E8E8),
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? const Icon(
                          Icons.person,
                          size: 30,
                          color: Color(0xFF9EA3AA),
                        )
                      : null,
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                Text(
                  loginId,
                  style: const TextStyle(
                    color: Color(0xFF6F7177),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: const Color(0xFFEAEAEA),
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  label: '국가',
                  value: country,
                  showBottomBorder: false,
                  bottomPadding: 4,
                ),
                _InfoRow(
                  label: '소속 본부',
                  value: org,
                  showBottomBorder: false,
                  bottomPadding: 4,
                ),
                _InfoRow(
                  label: '소속 부서',
                  value: dept,
                  showBottomBorder: false,
                  bottomPadding: 4,
                ),
                _InfoRow(
                  label: '이메일',
                  value: email,
                  showBottomBorder: false,
                  bottomPadding: 4,
                ),
                _InfoRow(
                  label: '연락처',
                  value: phone,
                  showBottomBorder: false,
                  bottomPadding: 0,
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: 12,
            color: const Color(0xFFEAEAEA),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(left: 24),
            child: const Text(
              '* 정보 수정은 PC에서만 가능합니다.',
              style: TextStyle(color: Color(0xFF363249), fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => _showLogoutSheet(context),
              style:
                  TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: const Color(0xFF363249),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
              child: const Text('로그아웃'),
            ),
          ),
          //const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  final bool showBottomBorder;
  final double bottomPadding;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showBottomBorder = true,
    this.bottomPadding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 6, 24, bottomPadding),
      decoration: BoxDecoration(
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE3E5EA), width: 1),
              )
            : null,
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
    isScrollControlled: true, // ⬅ доод талын system inset устгана
    useSafeArea: false, // ⬅ SafeArea padding арилгана
    builder: (sheetContext) {
      return Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFD9D9D9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 45),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '로그아웃 하시겠어요?',
                style: TextStyle(
                  fontSize: 20,
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 45),
                        side: const BorderSide(color: Color(0xFF6D6A7C)),
                        foregroundColor: const Color(0xFF4E5055),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
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
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 45),
                        backgroundColor: const Color(0xFF6D6A7C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
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
