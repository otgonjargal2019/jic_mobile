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
      'case_details.progressStatus.REPORT_INVESTIGATION': 'report investigation',
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
    return _localizedValues['ko']?[key] ?? _localizedValues['ko']![key] ?? '';
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
