import 'package:flutter/widgets.dart';

/// Minimal, self-contained localization for English and Korean.
/// Replace with Flutter's gen_l10n when you prefer generated ARB workflow.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'JIC Investigation',
      'idLabel': 'ID',
      'passwordLabel': 'Password',
      'loginButton': 'Login',
      'loginError': 'Invalid ID or password',
      'idHint': 'Enter your ID',
      'passwordHint': 'Enter your password',
      'autoLogin': 'Auto login',
      'rememberId': 'Remember ID',
      'findId': 'Find ID',
      'findPassword': 'Find password',
      'recentCases': 'Recent cases',
      'myCases': 'My cases',
      'case_details.case_infringement_type.PLATFORMS_SITES': 'Platforms/Sites',
      'case_details.case_infringement_type.LINK_SITES': 'Link Sites',
      'case_details.case_infringement_type.WEBHARD_P2P': 'Webhard/P2P',
      'case_details.case_infringement_type.TORRENTS': 'Torrents',
      'case_details.case_infringement_type.SNS': 'SNS',
      'case_details.case_infringement_type.COMMUNITIES': 'Communities',
      'case_details.case_infringement_type.OTHER': 'Other (ISD, etc.)',
      'case_details.status.OPEN': 'Open',
      'case_details.status.ON_HOLD': 'On Hold',
      'case_details.status.CLOSED': 'Closed',
      'case_details.progressStatus.PRE_INVESTIGATION': 'pre investigation',
      'case_details.progressStatus.INVESTIGATION': 'investigation',
      'case_details.progressStatus.TRANSFER': 'transfer',
      'case_details.progressStatus.ANALYZING': 'analysing',
      'case_details.progressStatus.REPORT_INVESTIGATION':
          'report investigation',
      'case_details.progressStatus.DISPOSE': 'dispose',
      'case_details.progressStatus.ON_HOLD': 'on hold',
      'case_details.progressStatus.CLOSED': 'closed',
      'case_details.case_number': 'Case Number',
      'case_details.investigationDate': 'Investigation Start Date',
      'case_details.priority': 'Security level',
      'case_details.relatedCountries': 'Country concerned',
      'case_details.contentType': 'Content Type',
      'case_details.infringementType': 'Types of copyright infringement',
      'case_details.caseOutline': 'Case overview',
      'case_details.etc': 'Other matters',
      'case_details.caseInformation': 'Information',
      'case_details.invRecordsList': 'Investigation records',
      'inv_record.reviewStatus.WRITING': 'WRITING',
      'inv_record.reviewStatus.PENDING': 'PENDING',
      'inv_record.reviewStatus.REJECTED': 'REJECTED',
      'inv_record.reviewStatus.APPROVED': 'APPROVED',
    },
    'ko': {
      'appTitle': '국제공조수사플랫폼',
      'idLabel': '아이디',
      'passwordLabel': '비밀번호',
      'loginButton': '로그인',
      'loginError': '아이디 또는 비밀번호가 올바르지 않습니다',
      'idHint': '아이디를 입력하세요',
      'passwordHint': '비밀번호를 입력하세요',
      'autoLogin': '자동 로그인',
      'rememberId': '아이디 저장',
      'findId': '아이디 찾기',
      'findPassword': '비밀번호 찾기',
      'recentCases': '최근 수사한 사건',
      'myCases': '내사건 현황',
      'case_details.case_infringement_type.PLATFORMS_SITES': '플랫폼/사이트',
      'case_details.case_infringement_type.LINK_SITES': '링크 사이트',
      'case_details.case_infringement_type.WEBHARD_P2P': '웹하드/P2P',
      'case_details.case_infringement_type.TORRENTS': '토렌트',
      'case_details.case_infringement_type.SNS': 'SNS',
      'case_details.case_infringement_type.COMMUNITIES': '커뮤니티',
      'case_details.case_infringement_type.OTHER': '기타(ISD 등)',
      'case_details.status.OPEN': '진행중',
      'case_details.status.ON_HOLD': '미해결',
      'case_details.status.CLOSED': '수사종료',
      'case_details.progressStatus.PRE_INVESTIGATION': '사전조사',
      'case_details.progressStatus.INVESTIGATION': '디지털 증거물 수집중',
      'case_details.progressStatus.TRANSFER': '디지털 증거 이송',
      'case_details.progressStatus.ANALYZING': '디지털 증거 분석 중',
      'case_details.progressStatus.REPORT_INVESTIGATION': '디지털 증거 보고 조사',
      'case_details.progressStatus.DISPOSE': '디지털 증거물 파기',
      'case_details.progressStatus.ON_HOLD': '미해결',
      'case_details.progressStatus.CLOSED': '수사종료',
      'case_details.case_number': '사건 번호',
      'case_details.investigationDate': '발생 일시',
      'case_details.priority': '수사 대응 순위',
      'case_details.relatedCountries': '관련국가',
      'case_details.contentType': '콘텐츠 유형',
      'case_details.infringementType': '저작권 침해 유형',
      'case_details.caseOutline': '사건 개요',
      'case_details.etc': '기타사항',
      'case_details.caseInformation': '사건 정보',
      'case_details.invRecordsList': '수사기록 내역',
      'inv_record.reviewStatus.WRITING': '작성중',
      'inv_record.reviewStatus.PENDING': '검토 대기 중',
      'inv_record.reviewStatus.REJECTED': '반려',
      'inv_record.reviewStatus.APPROVED': '검토 완료',
      'user-role.PLATFORM_ADMIN': '플랫폼 관리자',
      'user-role.INV_ADMIN': '수사 관리자',
      'user-role.INVESTIGATOR': '수사관',
      'user-role.RESEARCHER': '조사관',
      'user-role.COPYRIGHT_HOLDER': '저작권자',
      'notification': '알림',
      'delete-whole-thing': '전체 삭제',
      'full-reading': '전체 읽음',
      'loading': '로딩 중...',
      'no-more-notification': '알람이 없습니다.',
      'incident.PROGRESS_STATUS.PRE_INVESTIGATION': '사전조사',
      'incident.PROGRESS_STATUS.INVESTIGATION': '디지털 증거물 수집중',
      'incident.PROGRESS_STATUS.TRANSFER': '디지털 증거 이송',
      'incident.PROGRESS_STATUS.ANALYZING': '디지털 증거 분석 중',
      'incident.PROGRESS_STATUS.REPORT_INVESTIGATION': '디지털 증거 보고 조사',
      'incident.PROGRESS_STATUS.DISPOSE': '디지털 증거물 파기',
      'incident.PROGRESS_STATUS.ON_HOLD': '미해결',
      'incident.PROGRESS_STATUS.CLOSED': '수사종료',
      'NOTIFICATION-KEY.ID': 'ID',
      'NOTIFICATION-KEY.NAME': '성명',
      'NOTIFICATION-KEY.REQUEST-DATE': '요청 일시',
      'NOTIFICATION-KEY.CASE-NUMBER': '사건번호',
      'NOTIFICATION-KEY.CASE-TITLE': '사건 명',
      'NOTIFICATION-KEY.ALLOCATION-DATE': '배정 일시',
      'NOTIFICATION-KEY.DEALLOCATION-DATE': '배정 해제 일시',
      'NOTIFICATION-KEY.APPROVED-DATE': '승인 일시',
      'NOTIFICATION-KEY.REJECTED-DATE': '반려 일시',
      'NOTIFICATION-KEY.UPDATED-DATE': '업데이트 일시',
      'NOTIFICATION-KEY.REQUESTED-TO-REVIEW-DATE': '등록 일시',
      'NOTIFICATION-KEY.PREVIOUS-PROGRESS': '이전 진행 상태',
      'NOTIFICATION-KEY.CURRENT-PROGRESS': '현재 진행 상태',
      'NOTIFICATION-KEY.PREVIOUS-ROLE': '이전 권한',
      'NOTIFICATION-KEY.CURRENT-ROLE': '현재 권한',
      'NOTIFICATION-KEY.APPROVAL-DATE': '승인 일시',
      'NOTIFICATION-KEY.REASON': '사유',
      'NOTIFICATION-KEY.CHANGE-DATE': '일시',
      'NOTIFICATION-KEY.TITLE.NEW-ACCOUNT-REGISTERED': '신규 계정 등록',
      'NOTIFICATION-KEY.TITLE.CASE-ASSIGNMENT': '신규 사건 배정',
      'NOTIFICATION-KEY.TITLE.CASE-DEALLOCATION': 'CASE DEALLOCATION',
      'NOTIFICATION-KEY.TITLE.CASE-CLOSED': '사건 종료',
      'NOTIFICATION-KEY.TITLE.REJECTED-INVESTIGATION-RECORD': '수사 기록 검토 반려',
      'NOTIFICATION-KEY.TITLE.APPROVED-INVESTIGATION-RECORD': '수사 기록 검토 승인',
      'NOTIFICATION-KEY.TITLE.NEW-INVESTIGATION-RECORD': '신규 수사 기록 등록',
      'NOTIFICATION-KEY.TITLE.PROGRESS-STATUS-CHANGED': '상세 진행 현황 변동',
      'NOTIFICATION-KEY.TITLE.REQUEST-TO-REVIEW': '신규 수사 기록 등록',
      'NOTIFICATION-KEY.TITLE.MEMBER-INFORMATION-CHANGE-APPROVAL':
          '회원 정보 변경 승인',
      'NOTIFICATION-KEY.TITLE.MEMBER-INFORMATION-CHANGE-REJECTION':
          '회원 정보 변경 거절',
      'NOTIFICATION-KEY.TITLE.ACCOUNT-PERMISSION-CHANGED': '계정 권한 변동',
    },
  };

  String get appTitle => _t('appTitle');
  String get idLabel => _t('idLabel');
  String get passwordLabel => _t('passwordLabel');
  String get loginButton => _t('loginButton');
  String get loginError => _t('loginError');
  String get idHint => _t('idHint');
  String get passwordHint => _t('passwordHint');
  String get autoLogin => _t('autoLogin');
  String get rememberId => _t('rememberId');
  String get findId => _t('findId');
  String get findPassword => _t('findPassword');
  String get recentCases => _t('recentCases');
  String get myCases => _t('myCases');

  String _t(String key) {
    final code = locale.languageCode;
    // debugPrint('Looking up localization for key="$key" in locale="$code"');
    final primary = _localizedValues[code];
    if (primary != null && primary.containsKey(key)) {
      return primary[key]!;
    }
    return _localizedValues['ko']?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String translate(String key) => _t(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
