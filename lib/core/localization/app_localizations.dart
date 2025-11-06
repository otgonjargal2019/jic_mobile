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
    return _localizedValues[code]?[key] ?? _localizedValues['en']![key] ?? key;
  }
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
