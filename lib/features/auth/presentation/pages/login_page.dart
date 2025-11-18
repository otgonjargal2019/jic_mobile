import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
import 'package:jic_mob/core/network/api_client.dart';
import 'package:jic_mob/core/state/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _rememberedIdKey = 'remembered_id';
  static const _stayLoggedInKey = 'stay_logged_in';

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _autoLogin = false;
  bool _rememberId = false;
  bool _loading = false;

  Future<ApiClient>? _apiFuture;

  @override
  void initState() {
    super.initState();
    _apiFuture = ApiClient.create();
    _loadRememberedId();
  }

  Future<void> _loadRememberedId() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedId = prefs.getString(_rememberedIdKey);
    final stayLoggedIn = prefs.getBool(_stayLoggedInKey) ?? false;

    if (!mounted) return;

    setState(() {
      if (rememberedId != null && rememberedId.isNotEmpty) {
        _idController.text = rememberedId;
        _rememberId = true;
      }
      _autoLogin = stayLoggedIn;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1F1E2E);
    const accentGreen = Color(0xFF3EB491);
    const inputFill = Color(0xFFF5F5F5);
    final media = MediaQuery.of(context);
    final double topPadding = (120.0 - media.padding.top).clamp(
      0.0,
      double.infinity,
    );

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const double bottomPadding = 16.0;
            final double minContentHeight = math.max(
              constraints.maxHeight - topPadding - bottomPadding,
              0.0,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(45.0, 0, 45.0, bottomPadding),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    minHeight: minContentHeight,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LogoAndTitle(),
                        const SizedBox(height: 56),

                        // ID
                        const _FieldLabel(text: '아이디'),
                        _TextField(
                          controller: _idController,
                          hintText: '아이디를 입력하세요',
                          fillColor: inputFill,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        const _FieldLabel(text: '비밀번호'),
                        _TextField(
                          controller: _passwordController,
                          hintText: '비밀번호를 입력하세요',
                          fillColor: inputFill,
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),

                        // Checkboxes
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            _CheckboxWithLabel(
                              value: _autoLogin,
                              onChanged: (value) =>
                                  setState(() => _autoLogin = value ?? false),
                              label: '자동 로그인',
                              accentColor: accentGreen,
                            ),
                            _CheckboxWithLabel(
                              value: _rememberId,
                              onChanged: (value) =>
                                  setState(() => _rememberId = value ?? false),
                              label: '아이디 저장',
                              accentColor: accentGreen,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: const WidgetStatePropertyAll(
                                accentGreen,
                              ),
                              foregroundColor: const WidgetStatePropertyAll(
                                Colors.white,
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              textStyle: const WidgetStatePropertyAll(
                                TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            onPressed: _loading ? null : _onLoginPressed,
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('로그인'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onLoginPressed() async {
    if (_formKey.currentState?.validate() != true) return;

    final id = _idController.text.trim();
    final pw = _passwordController.text;
    final loc = AppLocalizations.of(context)!;

    setState(() => _loading = true);
    try {
      final api = await _apiFuture!;
      final loginResponse = await api.login(
        loginId: id,
        password: pw,
        stayLoggedIn: _autoLogin,
      );
      final accessToken = loginResponse.accessToken;

      final prefs = await SharedPreferences.getInstance();
      if (_rememberId) {
        await prefs.setString(_rememberedIdKey, id);
      } else {
        await prefs.remove(_rememberedIdKey);
      }

      if (_autoLogin) {
        await prefs.setBool(_stayLoggedInKey, true);
      } else {
        await prefs.remove(_stayLoggedInKey);
      }

      // Fetch user profile after successful authentication and store globally
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        final userProv = context.read<UserProvider>();
        try {
          if (accessToken != null && accessToken.isNotEmpty) {
            userProv.setAccessToken(accessToken);
          }
          await userProv.fetchMe();
        } catch (error) {
          // Non-fatal: proceed to home but inform the user.
          messenger.showSnackBar(
            SnackBar(
              content: Text('${loc.appTitle}: Failed to load profile'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        navigator.pushReplacementNamed('/home');
      }
    } catch (error) {
      final message = error.toString().contains('ADMIN_CONFIRMATION_NEEDED')
          ? 'ADMIN_CONFIRMATION_NEEDED'
          : (error is ApiException ? error.message : loc.loginError);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xD9FFFFFF),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color fillColor;

  const _TextField({
    required this.controller,
    required this.hintText,
    required this.fillColor,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) =>
          (value == null || value.isEmpty) ? '필수 입력 항목입니다' : null,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}

class _CheckboxWithLabel extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final Color accentColor;

  const _CheckboxWithLabel({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: accentColor,
            side: const BorderSide(color: Color(0xFFB1B1B1)),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB1B1B1), fontSize: 14),
        ),
      ],
    );
  }
}

class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icons/logo.svg', width: 40, height: 40),
        const SizedBox(width: 12),
        Expanded(
          child: const Text(
            '국제공조수사플랫폼',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.5,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
