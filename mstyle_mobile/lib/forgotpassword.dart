import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

// ─── Theme (same as login/register) ──────────────────────────────────────────
const Color _primary   = Color(0xFF1a1a1a);
const Color _accent    = Color(0xFF2c3e50);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);
const Color _textLight = Color(0xFF6c757d);

const _premiumGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_primary, _accent],
);
const _goldGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_gold, _goldLight],
);

// ─── Steps ────────────────────────────────────────────────────────────────────
enum _ForgotStep { email, code, newPassword }

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  _ForgotStep _step = _ForgotStep.email;

  final _emailCtrl       = TextEditingController();
  final _codeCtrl        = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  // 6-box OTP for reset code — same as register.dart
  final List<TextEditingController> _codeCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode>             _codeFocus = List.generate(6, (_) => FocusNode());

  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    for (final c in _codeCtrls) c.dispose();
    for (final f in _codeFocus) f.dispose();
    super.dispose();
  }

  // ─── Step titles / subtitles ────────────────────────────────────────────
  String get _title {
    switch (_step) {
      case _ForgotStep.email:       return 'Forgot Password?';
      case _ForgotStep.code:        return 'Enter Reset Code';
      case _ForgotStep.newPassword: return 'Reset Your Password';
    }
  }

  String get _subtitle {
    switch (_step) {
      case _ForgotStep.email:       return 'Enter your email to receive a reset code';
      case _ForgotStep.code:        return 'Enter the reset code sent to your email';
      case _ForgotStep.newPassword: return 'Enter your new password';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isWide
          ? Center(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _wideLayout()))
          : _narrowLayout(),
    );
  }

  // ─── Layouts ──────────────────────────────────────────────────────────────
  Widget _wideLayout() => Container(
    constraints: const BoxConstraints(maxWidth: 900),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 20))],
    ),
    clipBehavior: Clip.hardEdge,
    child: IntrinsicHeight(
      child: Row(children: [
        Expanded(child: _leftPanel()),
        Expanded(child: _rightPanel()),
      ]),
    ),
  );

  // ─── Mobile: hero + overlapping white card ────────────────────────────────
  Widget _narrowLayout() => SingleChildScrollView(
    child: Column(children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: const BoxDecoration(gradient: _premiumGrad),
          child: SafeArea(
            bottom: false,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _heroLogo(size: 80),
              const SizedBox(height: 12),
              const Text('Reset Password',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Center(child: Container(
                width: 50, height: 3,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad),
              )),
              const SizedBox(height: 6),
              Text("Premium Men's Fashion & Style",
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _stepIndicator(),
            ]),
          ),
        ),
        Positioned(
          bottom: -1, left: 0, right: 0,
          child: Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
          ),
        ),
      ]),
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 319),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _rightPanel(mobile: true),
        ),
      ),
    ]),
  );

  Widget _heroLogo({required double size}) => Stack(alignment: Alignment.center, children: [
    Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_gold, _accent]),
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.15),
      child: Image.asset('assets/images/MStyle Logos/MStyle_logo1.png',
        width: size * 0.7, height: size * 0.7, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.storefront, color: Colors.white, size: size * 0.4)),
    ),
  ]);
  // ─── Left branding panel (wide layout only) ──────────────────────────────
  Widget _leftPanel({double minHeight = 0}) => Container(
    constraints: BoxConstraints(minHeight: minHeight),
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Logo with glow circle
      Stack(alignment: Alignment.center, children: [
        Container(
          width: 150, height: 150,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_gold, _accent],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/images/MStyle Logos/MStyle_logo1.png',
            width: 110, height: 110, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 110, height: 110,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.storefront, color: Colors.white, size: 55),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 28),
      const Text('Reset Password',
        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Container(
        width: 65, height: 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: _goldGrad,
        ),
      ),
      const SizedBox(height: 14),
      Text("Premium Men's Fashion & Style",
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
        textAlign: TextAlign.center),
      const SizedBox(height: 28),
      // Step indicator
      _stepIndicator(),
    ]),
  );

  Widget _stepIndicator() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    _stepDot(0, Icons.email_outlined, 'Email'),
    _stepLine(_step.index >= 1),
    _stepDot(1, Icons.lock_open_outlined, 'Verify'),
    _stepLine(_step.index >= 2),
    _stepDot(2, Icons.lock_outlined, 'Reset'),
  ]);

  Widget _stepDot(int index, IconData icon, String label) {
    final active = _step.index == index;
    final done   = _step.index > index;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: (active || done) ? _goldGrad : null,
          color: (active || done) ? null : Colors.white.withOpacity(0.12),
          border: Border.all(
            color: (active || done) ? _gold : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: active ? [BoxShadow(color: _gold.withOpacity(0.5), blurRadius: 12)] : [],
        ),
        child: Icon(
          done ? Icons.check_rounded : icon,
          color: (active || done) ? _primary : Colors.white.withOpacity(0.6),
          size: 18,
        ),
      ),
      const SizedBox(height: 5),
      Text(label,
        style: TextStyle(
          color: (active || done) ? _gold : Colors.white.withOpacity(0.5),
          fontSize: 10,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: 0.3,
        )),
    ]);
  }

  Widget _stepLine(bool filled) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Container(
      width: 36, height: 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        gradient: filled ? _goldGrad : null,
        color: filled ? null : Colors.white.withOpacity(0.2),
      ),
    ),
  );

  // ─── Right form panel ─────────────────────────────────────────────────────
  Widget _rightPanel({bool mobile = false}) => Container(
    padding: EdgeInsets.symmetric(horizontal: mobile ? 0 : 40, vertical: mobile ? 0 : 56),
    color: mobile ? null : const Color(0xFFFAFBFC),
    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(height: mobile ? 20 : 0),
      // Title
      Column(children: [
        Text(_title,
          style: const TextStyle(color: _accent, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Container(
          width: 45, height: 3,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad),
        ),
      ]),
      const SizedBox(height: 10),
      Text(_subtitle,
        style: const TextStyle(color: _textLight, fontSize: 13),
        textAlign: TextAlign.center),
      const SizedBox(height: 24),

      // Step content
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_step), child: _stepContent()),
      ),

      const SizedBox(height: 28),
      // Back to login
      Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('← Back to Login',
            style: TextStyle(color: _primary, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
        ),
      ),
    ]),
  );

  // ─── Step content ─────────────────────────────────────────────────────────
  Widget _stepContent() {
    switch (_step) {
      case _ForgotStep.email:
        return _emailStep();
      case _ForgotStep.code:
        return _codeStep();
      case _ForgotStep.newPassword:
        return _newPasswordStep();
    }
  }

  // Step 1 — Email
  Widget _emailStep() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _inputField(controller: _emailCtrl, label: 'Email Address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
    const SizedBox(height: 16),
    if (_error != null) ...[_errorBanner(_error!), const SizedBox(height: 12)],
    _primaryButton(_loading ? 'SENDING...' : 'SEND RESET CODE', _loading ? () {} : _sendResetCode),
  ]);

  // Step 2 — Reset code (6-box OTP, same style as register.dart)
  Widget _codeStep() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    // Email hint banner
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _gold.withOpacity(0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.email_outlined, color: _gold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Code sent to ${_emailCtrl.text}',
            style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
        ),
      ]),
    ),
    const SizedBox(height: 24),
    // 6 individual OTP boxes
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => SizedBox(
        width: 44, height: 52,
        child: TextField(
          controller: _codeCtrls[i],
          focusNode: _codeFocus[i],
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _accent),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 2),
            ),
          ),
          onChanged: (v) {
            if (v.isNotEmpty && i < 5) _codeFocus[i + 1].requestFocus();
            if (v.isEmpty && i > 0) _codeFocus[i - 1].requestFocus();
          },
        ),
      )),
    ),
    const SizedBox(height: 16),
    if (_error != null) ...[_errorBanner(_error!), const SizedBox(height: 12)],
    _primaryButton(_loading ? 'VERIFYING...' : 'VERIFY CODE', _loading ? () {} : _verifyCode),
    const SizedBox(height: 16),
    Center(
      child: GestureDetector(
        onTap: _loading ? null : _sendResetCode,
        child: RichText(text: const TextSpan(
          text: "Didn't receive the code? ",
          style: TextStyle(color: _textLight, fontSize: 13),
          children: [TextSpan(text: 'Resend', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))],
        )),
      ),
    ),
  ]);

  // Step 3 — New password
  Widget _newPasswordStep() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _inputField(
      controller: _newPassCtrl,
      label: 'New Password',
      obscureText: _obscureNew,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(_obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textLight, size: 22),
        onPressed: () => setState(() => _obscureNew = !_obscureNew),
      ),
    ),
    const SizedBox(height: 18),
    _inputField(
      controller: _confirmPassCtrl,
      label: 'Confirm Password',
      obscureText: _obscureConfirm,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textLight, size: 22),
        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
      ),
    ),
    const SizedBox(height: 16),
    if (_error != null) ...[_errorBanner(_error!), const SizedBox(height: 12)],
    _primaryButton(_loading ? 'RESETTING...' : 'RESET PASSWORD', _loading ? () {} : _resetPassword),
  ]);

  // ─── Supabase actions ────────────────────────────────────────────────────
  Future<void> _sendResetCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await supabase.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      for (final c in _codeCtrls) c.clear();
      setState(() => _step = _ForgotStep.code);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to send reset code. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeCtrls.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _error = 'Please enter the 6-digit reset code.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await supabase.auth.verifyOTP(
        email: _emailCtrl.text.trim(),
        token: code,
        type: OtpType.recovery,
      );
      if (!mounted) return;
      setState(() => _step = _ForgotStep.newPassword);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Invalid or expired code. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;
    if (newPass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPass));
      await supabase.auth.signOut();
      if (!mounted) return;
      _showSuccessDialog();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to reset password. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _errorBanner(String msg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Row(children: [
      Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
    ]),
  );

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(gradient: _goldGrad, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 16)]),
              child: const Icon(Icons.check, color: _primary, size: 32),
            ),
            const SizedBox(height: 18),
            const Text('Password Reset!',
              style: TextStyle(color: _accent, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Your password has been reset successfully.',
              style: TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _primaryButton('BACK TO LOGIN', () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to login
            }),
          ]),
        ),
      ),
    );
  }

  // ─── Shared UI helpers ────────────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textLight, fontSize: 15),
      floatingLabelStyle: const TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      filled: true, fillColor: Colors.white,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _gold, size: 20) : null,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    ),
  );

  Widget _primaryButton(String label, VoidCallback onPressed) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: _premiumGrad,
      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 8))],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    ),
  );
}
