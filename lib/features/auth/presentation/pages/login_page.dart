import 'package:flutter/material.dart';
import 'package:jic_mob/core/localization/app_localizations.dart';
import 'package:jic_mob/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:jic_mob/core/state/user_provider.dart';

/// A simple login page that mirrors the provided design.
/// Uses AppLocalizations for en/ko strings.
class LoginPage extends StatefulWidget {
  static const route = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final savedId = prefs.getString('remembered_id');
    if (savedId != null && mounted) {
      setState(() {
        _idController.text = savedId;
        _rememberId = true;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF1E202B); // deep navy/charcoal
    const accentGreen = Color(0xFF39BE8C);
    const inputFill = Color(0xFFF0F0F0);
    const hint = Color(0xFF9AA0A6);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const _LogoAndTitle(),
                    const SizedBox(height: 56),

                    // ID
                    _FieldLabel(text: loc.idLabel),
                    _TextField(
                      controller: _idController,
                      hintText: loc.idHint,
                      fillColor: inputFill,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _FieldLabel(text: loc.passwordLabel),
                    _TextField(
                      controller: _passwordController,
                      hintText: loc.passwordHint,
                      fillColor: inputFill,
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    // Checkboxes
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _autoLogin,
                            onChanged: (v) =>
                                setState(() => _autoLogin = v ?? false),
                            activeColor: accentGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.autoLogin,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberId,
                            onChanged: (v) =>
                                setState(() => _rememberId = v ?? false),
                            activeColor: accentGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.rememberId,
                          style: const TextStyle(color: Colors.white70),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textStyle: const WidgetStatePropertyAll(
                            TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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
                            : Text(loc.loginButton),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LinkText(label: loc.findId, onTap: () {}),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('|', style: TextStyle(color: hint)),
                        ),
                        _LinkText(label: loc.findPassword, onTap: () {}),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
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
      await api.login(loginId: id, password: pw, stayLoggedIn: _autoLogin);

      final prefs = await SharedPreferences.getInstance();
      if (_rememberId) {
        await prefs.setString('remembered_id', id);
      } else {
        await prefs.remove('remembered_id');
      }

      // Fetch user profile after successful authentication and store globally
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        final userProv = context.read<UserProvider>();
        try {
          await userProv.fetchMe();
        } catch (e) {
          // Non-fatal: proceed to home but inform the user
          messenger.showSnackBar(
            SnackBar(
              content: Text('${loc.appTitle}: Failed to load profile'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        navigator.pushReplacementNamed('/home');
      }
    } catch (e) {
      final msg = e.toString().contains('ADMIN_CONFIRMATION_NEEDED')
          ? 'ADMIN_CONFIRMATION_NEEDED'
          : (e is ApiException ? e.message : loc.loginError);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
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
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
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
      validator: (v) => (v == null || v.isEmpty) ? '필수 입력 항목입니다' : null,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
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
        const _SimpleLogo(size: 40),
        const SizedBox(width: 12),
        Expanded(child: _LocalizedTitle()),
      ],
    );
  }
}

class _LocalizedTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Text(
      loc.appTitle,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      maxLines: 2,
    );
  }
}

/// Draws a simple two-tile tilted mark similar to the screenshot.
class _SimpleLogo extends StatelessWidget {
  final double size;
  const _SimpleLogo({this.size = 36});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2E7BF6);
    const green = Color(0xFF39BE8C);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.6,
            child: _roundedTile(color: blue, size: size * 0.75),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Transform.rotate(
              angle: -0.6,
              child: _roundedTile(color: green, size: size * 0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedTile({required Color color, required double size}) {
    return Container(
      width: size,
      height: size * 0.55,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LinkText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white54,
        ),
      ),
    );
  }
}
