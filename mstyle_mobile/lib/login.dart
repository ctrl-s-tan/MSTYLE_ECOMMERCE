import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';
import 'forgotpassword.dart';
import 'register.dart';
import 'buyer_homepage.dart';
import 'seller_dashboard.dart';
import 'rider_dashboard.dart';
import 'buyer_service.dart';
import 'notification_service.dart';

const Color _primary   = Color(0xFF1a1a1a);
const Color _accent    = Color(0xFF2c3e50);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);
const Color _textLight = Color(0xFF6c757d);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _hasPass    = false;
  bool _loading    = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() => _hasPass = _passCtrl.text.isNotEmpty));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;

    setState(() { _loading = true; _error = null; });

    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: pass);
      final uid = res.user?.id;
      if (uid == null) throw Exception('Login failed');

      // Fetch profile — if row is missing the account has been archived/deleted
      final List<dynamic> rows = await supabase
          .from('users')
          .select('role')
          .eq('id', uid);

      if (rows.isEmpty) {
        // Check if user is in pending_users or pending_sellers (registered but not yet approved)
        final List<dynamic> pendingUserRows = await supabase
            .from('pending_users')
            .select('status')
            .eq('supabase_uid', uid);

        final List<dynamic> pendingSellerRows = await supabase
            .from('pending_sellers')
            .select('status')
            .eq('supabase_uid', uid);

        await supabase.auth.signOut();

        String? pendingMsg;

        if (pendingUserRows.isNotEmpty) {
          final status = pendingUserRows.first['status'] as String? ?? 'pending';
          if (status == 'pending') {
            pendingMsg = 'Your account is pending admin approval. Please wait for approval before logging in.';
          } else if (status == 'rejected') {
            pendingMsg = 'Your registration was rejected. Please contact support for assistance.';
          }
        } else if (pendingSellerRows.isNotEmpty) {
          final status = pendingSellerRows.first['status'] as String? ?? 'pending';
          if (status == 'pending') {
            pendingMsg = 'Your seller account is pending admin approval. Please wait for approval before logging in.';
          } else if (status == 'rejected') {
            pendingMsg = 'Your seller registration was rejected. Please contact support for assistance.';
          }
        }

        setState(() => _error = pendingMsg ?? 'Your account no longer exists.');
        return;
      }

      final role = rows.first['role'] as String;

      if (!mounted) return;
      if (role == 'rider') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => RiderDashboardPage(riderEmail: email)));
      } else if (role == 'seller') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => SellerDashboardPage(sellerEmail: email)));
      } else {
        // Save OneSignal player ID for this buyer so push notifications work
        final playerId = await NotificationService.getPlayerId();
        if (playerId != null) {
          await BuyerService.savePlayerID(email, playerId);
        }
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => BuyerHomePage(userEmail: email)));
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('banned')) {
        // Account is banned — could be pending approval or admin-imposed ban.
        // Query pending tables (anon SELECT is allowed via RLS policy) to decide
        // which message to show.
        final emailToCheck = _emailCtrl.text.trim();
        String? bannedMsg;
        try {
          final pendingUserRows = await supabase
              .from('pending_users')
              .select('status')
              .eq('email', emailToCheck);
          final pendingSellerRows = await supabase
              .from('pending_sellers')
              .select('status')
              .eq('email', emailToCheck);

          if ((pendingUserRows as List).isNotEmpty) {
            final status = pendingUserRows.first['status'] as String? ?? 'pending';
            if (status == 'pending') {
              bannedMsg = 'Your account is pending admin approval. Please wait for approval before logging in.';
            } else if (status == 'rejected') {
              bannedMsg = 'Your registration was rejected. Please contact support for assistance.';
            }
          } else if ((pendingSellerRows as List).isNotEmpty) {
            final status = pendingSellerRows.first['status'] as String? ?? 'pending';
            if (status == 'pending') {
              bannedMsg = 'Your seller account is pending admin approval. Please wait for approval before logging in.';
            } else if (status == 'rejected') {
              bannedMsg = 'Your seller registration was rejected. Please contact support for assistance.';
            }
          }
        } catch (_) {}

        setState(() => _error = bannedMsg ?? 'Your account no longer exists.');
      } else {
        setState(() => _error = e.message);
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isWide ? _wideLayout() : _mobileLayout(),
    );
  }

  // ─── Wide layout (tablet/web) ─────────────────────────────────────────────
  Widget _wideLayout() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 50, offset: const Offset(0, 20))],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(children: [
            Expanded(child: _wideHeader()),
            Expanded(child: _formPanel()),
          ]),
        ),
      ),
    ),
  );

  Widget _wideHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [_primary, _accent],
      ),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _logo(size: 120),
      const SizedBox(height: 28),
      const Text('Welcome to MStyle',
        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        textAlign: TextAlign.center),
      const SizedBox(height: 10),
      _goldBar(),
      const SizedBox(height: 14),
      Text("Premium Men's Fashion & Style",
        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
        textAlign: TextAlign.center),
    ]),
  );

  // ─── Mobile layout — hero + overlapping card ──────────────────────────────
  Widget _mobileLayout() => Container(
    color: Colors.white,
    child: SingleChildScrollView(
      child: Column(children: [
        // Hero section
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Dark gradient hero
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, _accent],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 8),
                  _logo(size: 90),
                  const SizedBox(height: 16),
                  const Text('Welcome to MStyle',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  _goldBar(),
                  const SizedBox(height: 8),
                  Text("Premium Men's Fashion & Style",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    textAlign: TextAlign.center),
                ]),
              ),
            ),
            // Overlapping rounded white tab
            Positioned(
              bottom: -1,
              left: 0, right: 0,
              child: Container(
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
              ),
            ),
          ],
        ),
        // Form card body — white, no gap
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: _formContent(),
        ),
      ]),
    ),
  );

  // ─── Form panel (wide) ────────────────────────────────────────────────────
  Widget _formPanel() => Container(
    color: const Color(0xFFFAFBFC),
    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_formContent()],
    ),
  );

  // ─── Shared form content ──────────────────────────────────────────────────
  Widget _formContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
    // Title
    const Text('Sign In',
      style: TextStyle(color: _accent, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      textAlign: TextAlign.center),
    const SizedBox(height: 6),
    Center(child: Container(
      width: 40, height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(colors: [_gold, _goldLight]),
      ),
    )),
    const SizedBox(height: 8),
    const Text('Enter your credentials to continue',
      style: TextStyle(color: _textLight, fontSize: 13),
      textAlign: TextAlign.center),
    const SizedBox(height: 28),

    // Email field
    _field(controller: _emailCtrl, label: 'Email Address', keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined),
    const SizedBox(height: 14),

    // Password field
    _field(
      controller: _passCtrl, label: 'Password', obscure: _obscure,
      prefixIcon: Icons.lock_outline,
      suffix: _hasPass
          ? IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _textLight, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          : null,
    ),

    // Forgot password — tight spacing right below password field
    Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text('Forgot Password?',
          style: TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    ),
    const SizedBox(height: 10),

    // Error banner
    if (_error != null) ...[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ]),
      ),
      const SizedBox(height: 14),
    ],

    // Login button
    _btn('LOGIN', _loading ? null : _login),
    const SizedBox(height: 20),

    // Register link
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Don't have an account? ", style: TextStyle(color: _textLight, fontSize: 13)),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
        child: const Text('Register here',
          style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline)),
      ),
    ]),
  ]);

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _logo({required double size}) => Stack(alignment: Alignment.center, children: [
    Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_gold, _accent],
        ),
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
      ),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.15),
      child: Image.asset(
        'assets/images/MStyle Logos/MStyle_logo1.png',
        width: size * 0.7, height: size * 0.7, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.storefront, color: Colors.white, size: size * 0.4),
      ),
    ),
  ]);

  Widget _goldBar() => Center(child: Container(
    width: 55, height: 3,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      gradient: const LinearGradient(colors: [_gold, _goldLight]),
    ),
  ));

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    IconData? prefixIcon,
  }) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _textLight, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _gold, size: 20) : null,
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    ),
  );

  Widget _btn(String label, VoidCallback? onTap) => Container(
    height: 54,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: onTap == null
          ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
          : const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_primary, _accent]),
      boxShadow: onTap == null ? [] : [
        BoxShadow(color: _primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6)),
      ],
    ),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _loading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
          : Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
    ),
  );
}
