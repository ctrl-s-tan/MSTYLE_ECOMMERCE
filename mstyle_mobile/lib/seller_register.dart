import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'supabase_client.dart';
import 'psgc_service.dart';
import 'login.dart';

const Color _primary   = Color(0xFF1a1a1a);
const Color _accent    = Color(0xFF2c3e50);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);
const Color _textLight = Color(0xFF6c757d);
const Color _bg        = Color(0xFFFAFBFC);

enum _SellerStep { email, otp, form }
enum _BusinessType { none, individual, business }

class SellerRegisterPage extends StatefulWidget {
  const SellerRegisterPage({super.key});
  @override
  State<SellerRegisterPage> createState() => _SellerRegisterPageState();
}

class _SellerRegisterPageState extends State<SellerRegisterPage> {
  _SellerStep _step = _SellerStep.email;
  _BusinessType _businessType = _BusinessType.none;

  // controllers
  final _emailCtrl        = TextEditingController();
  final _firstNameCtrl    = TextEditingController();
  final _lastNameCtrl     = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _houseCtrl        = TextEditingController();
  final _zipCtrl          = TextEditingController();
  final _passCtrl         = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode>             _otpFocus = List.generate(6, (_) => FocusNode());

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _termsAccepted  = false;

  // address
  List<Map<String, String>> _regions   = [];
  List<Map<String, String>> _provinces = [];
  List<Map<String, String>> _cities    = [];
  List<String>              _barangays = [];
  String? _selectedRegionCode;
  String? _selectedRegionName;
  String? _selectedProvinceCode;
  String? _selectedProvinceName;
  String? _selectedCityCode;
  String? _selectedCityName;
  String? _selectedBarangay;
  bool _loadingRegions   = false;
  bool _loadingProvinces = false;
  bool _loadingCities    = false;
  bool _loadingBarangays = false;

  bool _loading = false;
  String? _error;

  // documents
  final Map<String, File?> _docFiles     = {};
  final Map<String, bool> _docUploading  = {};
  final Map<String, String?> _docPaths   = {};

  @override
  void dispose() {
    for (final c in [_emailCtrl, _firstNameCtrl, _lastNameCtrl, _businessNameCtrl,
        _phoneCtrl, _houseCtrl, _zipCtrl, _passCtrl, _confirmPassCtrl]) {
      c.dispose();
    }
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  void _go(_SellerStep s) => setState(() { _step = s; _error = null; });

  // ─── Send OTP via Supabase ────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        emailRedirectTo: null,
      );
      if (!mounted) return;
      for (final c in _otpCtrls) c.clear();
      _go(_SellerStep.otp);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('banned')) {
        String? errorMsg;
        try {
          final approvedUser  = await supabase.from('users').select('id').eq('email', email);
          final pendingUser   = await supabase.from('pending_users').select('status').eq('email', email);
          final pendingSeller = await supabase.from('pending_sellers').select('status').eq('email', email);
          final auList = approvedUser  as List;
          final puList = pendingUser   as List;
          final psList = pendingSeller as List;
          if (auList.isNotEmpty) {
            errorMsg = 'This email is already registered. Please log in instead.';
          } else if (puList.isNotEmpty || psList.isNotEmpty) {
            final status = puList.isNotEmpty
                ? (puList.first['status'] as String? ?? 'pending')
                : (psList.first['status'] as String? ?? 'pending');
            if (status == 'pending') {
              errorMsg = 'Your account is pending admin approval. Please wait for approval before logging in.';
            } else if (status == 'rejected') {
              errorMsg = 'Your previous registration was rejected. Please contact support to re-register.';
            }
          }
        } catch (_) {}
        if (errorMsg != null) {
          setState(() => _error = errorMsg);
        } else {
          if (!mounted) return;
          for (final c in _otpCtrls) c.clear();
          _go(_SellerStep.otp);
        }
      } else {
        setState(() => _error = e.message);
      }
    } catch (e) {
      setState(() => _error = 'Failed to send OTP. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Verify OTP via Supabase ──────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final token = _otpCtrls.map((c) => c.text).join();
    if (token.length < 6) {
      setState(() => _error = 'Please enter the complete 6-digit code.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await supabase.auth.verifyOTP(
        email: _emailCtrl.text.trim(),
        token: token,
        type: OtpType.email,
      );
      if (!mounted) return;
      _loadRegions();
      _go(_SellerStep.form);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('banned')) {
        String? errorMsg;
        try {
          final approvedUser  = await supabase.from('users').select('id').eq('email', _emailCtrl.text.trim());
          final pendingUser   = await supabase.from('pending_users').select('status').eq('email', _emailCtrl.text.trim());
          final pendingSeller = await supabase.from('pending_sellers').select('status').eq('email', _emailCtrl.text.trim());
          final auList = approvedUser  as List;
          final puList = pendingUser   as List;
          final psList = pendingSeller as List;
          if (auList.isNotEmpty) {
            errorMsg = 'This email is already registered. Please log in instead.';
          } else if (puList.isNotEmpty || psList.isNotEmpty) {
            final status = puList.isNotEmpty
                ? (puList.first['status'] as String? ?? 'pending')
                : (psList.first['status'] as String? ?? 'pending');
            if (status == 'pending') {
              errorMsg = 'Your account is pending admin approval. Please wait for approval before logging in.';
            } else if (status == 'rejected') {
              errorMsg = 'Your previous registration was rejected. Please contact support to re-register.';
            }
          }
        } catch (_) {}
        setState(() => _error = errorMsg ?? 'Invalid or expired code. Please try again.');
      } else if (msg.contains('expired') || msg.contains('invalid') || msg.contains('otp')) {
        setState(() => _error = 'The code is invalid or has expired. Please tap "Resend OTP" to get a new code.');
      } else {
        setState(() => _error = e.message);
      }
    } catch (e) {
      setState(() => _error = 'Verification failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Pick & upload document ───────────────────────────────────────────────
  Future<void> _pickAndUploadDoc(String docKey) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _docFiles[docKey] = file;
      _docUploading[docKey] = true;
      _docPaths[docKey] = null;
      _error = null;
    });

    try {
      final uid = supabase.auth.currentUser?.id
          ?? _emailCtrl.text.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final ext = picked.path.split('.').last.toLowerCase();
      final safeKey = docKey.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
      final fileName = '${uid}_${safeKey}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final storagePath = '$uid/$fileName';
      final bytes = await file.readAsBytes();

      await supabase.storage.from('user-documents').uploadBinary(
        storagePath, bytes,
        fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
      );

      setState(() { _docPaths[docKey] = storagePath; _docUploading[docKey] = false; });
    } on StorageException catch (e) {
      setState(() { _docFiles[docKey] = null; _docUploading[docKey] = false; _error = 'Upload failed: ${e.message}'; });
    } catch (e) {
      setState(() { _docFiles[docKey] = null; _docUploading[docKey] = false; _error = 'Upload failed: ${e.toString()}'; });
    }
  }

  // ─── Submit seller registration ───────────────────────────────────────────
  Future<void> _submit() async {
    if (!_termsAccepted) {
      setState(() => _error = 'Please accept the Terms and Conditions.');
      return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (_businessType == _BusinessType.none) {
      setState(() => _error = 'Please select a business type.');
      return;
    }
    if (_docPaths['Valid Government ID'] == null) {
      setState(() => _error = 'Please upload your Valid Government ID.');
      return;
    }
    if (_businessType == _BusinessType.business) {
      if (_docPaths['DTI Certificate'] == null) {
        setState(() => _error = 'Please upload your DTI Certificate.');
        return;
      }
      if (_docPaths['BIR Certificate'] == null) {
        setState(() => _error = 'Please upload your BIR Certificate.');
        return;
      }
      if (_docPaths['Business Permit'] == null) {
        setState(() => _error = 'Please upload your Business Permit.');
        return;
      }
    }

    setState(() { _loading = true; _error = null; });

    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) throw Exception('Session expired. Please restart registration.');

      await supabase.auth.updateUser(UserAttributes(password: _passCtrl.text));

      await supabase.from('pending_sellers').upsert({
        'supabase_uid':        uid,
        'email':               _emailCtrl.text.trim(),
        'first_name':          _firstNameCtrl.text.trim(),
        'last_name':           _lastNameCtrl.text.trim(),
        'business_name':       _businessNameCtrl.text.trim(),
        'business_type':       _businessType == _BusinessType.individual ? 'individual' : 'business',
        'phone':               _phoneCtrl.text.trim(),
        'house_street':        _houseCtrl.text.trim(),
        'region':              _selectedRegionName,
        'province':            _selectedProvinceName,
        'city':                _selectedCityName,
        'barangay':            _selectedBarangay,
        'zip_code':            _zipCtrl.text.trim(),
        'valid_id_path':       _docPaths['Valid Government ID'],
        'dti_path':            _docPaths['DTI Certificate'],
        'bir_path':            _docPaths['BIR Certificate'],
        'business_permit_path': _docPaths['Business Permit'],
        'status':              'pending',
      }, onConflict: 'supabase_uid');

      await supabase.auth.signOut();

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Flexible(child: Text('Application Submitted!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          ]),
          content: const Text('Your seller application is pending admin approval. You will be notified once your account is approved.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on PostgrestException catch (e) {
      setState(() => _error = 'Database error: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Something went wrong: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadRegions() async {
    setState(() => _loadingRegions = true);
    final data = await PsgcService.getRegionsWithCode();
    setState(() { _regions = data; _loadingRegions = false; });
  }

  Future<void> _onRegionChanged(Map<String, String> r) async {
    setState(() {
      _selectedRegionCode = r['code']; _selectedRegionName = r['name'];
      _selectedProvinceCode = null; _selectedProvinceName = null;
      _selectedCityCode = null; _selectedCityName = null;
      _selectedBarangay = null;
      _provinces = []; _cities = []; _barangays = [];
      _loadingProvinces = true;
    });
    final data = await PsgcService.getProvinces(r['code']!);
    setState(() { _provinces = data; _loadingProvinces = false; });
  }

  Future<void> _onProvinceChanged(Map<String, String> p) async {
    setState(() {
      _selectedProvinceCode = p['code']; _selectedProvinceName = p['name'];
      _selectedCityCode = null; _selectedCityName = null;
      _selectedBarangay = null;
      _cities = []; _barangays = [];
      _loadingCities = true;
    });
    final data = await PsgcService.getCities(p['code']!);
    setState(() { _cities = data; _loadingCities = false; });
  }

  Future<void> _onCityChanged(Map<String, String> c) async {
    setState(() {
      _selectedCityCode = c['code']; _selectedCityName = c['name'];
      _selectedBarangay = null; _barangays = [];
      _loadingBarangays = true;
    });
    final data = await PsgcService.getBarangays(c['code']!);
    setState(() { _barangays = data; _loadingBarangays = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isWide ? _wideLayout() : _mobileLayout(),
    );
  }

  // ─── Layouts ──────────────────────────────────────────────────────────────
  Widget _wideLayout() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
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
      ),
    ),
  );

  // ─── Mobile: hero + overlapping white card ────────────────────────────────
  Widget _mobileLayout() => SingleChildScrollView(
    child: Column(children: [
      Stack(clipBehavior: Clip.none, children: [
        Container(
          width: double.infinity,
          height: 280,
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_primary, _accent]),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 8),
              _heroLogo(size: 90),
              const SizedBox(height: 14),
              const Text('Become a Seller',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              _goldBar(),
              const SizedBox(height: 8),
              Text("Start Your Premium Fashion Business",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                textAlign: TextAlign.center),
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
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 279),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: _rightPanel(noPadding: true),
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

  Widget _goldBar() => Center(child: Container(
    width: 55, height: 3,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      gradient: const LinearGradient(colors: [_gold, _goldLight]),
    ),
  ));

  // ─── Left branding panel (wide) ───────────────────────────────────────────
  Widget _leftPanel() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_primary, _accent]),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Stack(alignment: Alignment.center, children: [
        Container(width: 150, height: 150, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_gold, _accent]))),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset('assets/images/MStyle Logos/MStyle_logo1.png', width: 110, height: 110, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 110, height: 110,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.storefront, color: Colors.white, size: 55),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 28),
      const Text('Become a Seller', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Container(width: 65, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(colors: [_gold, _goldLight]))),
      const SizedBox(height: 20),
      // Benefits
      _benefitItem(Icons.bar_chart_rounded, 'Growth Analytics', 'Detailed sales reports and customer insights.'),
      const SizedBox(height: 16),
      _benefitItem(Icons.people_outline, 'Premium Customers', 'Connect with quality-conscious fashion buyers.'),
      const SizedBox(height: 16),
      _benefitItem(Icons.handshake_outlined, 'Business Support', 'Dedicated support to help you succeed.'),
      const SizedBox(height: 16),
      _benefitItem(Icons.shield_outlined, 'Secure Platform', 'Safe transactions with buyer & seller protection.'),
    ]),
  );

  Widget _benefitItem(IconData icon, String title, String desc) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withOpacity(0.15), border: Border.all(color: _gold.withOpacity(0.4))),
      child: Icon(icon, color: _gold, size: 20),
    ),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 2),
      Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
    ])),
  ]);

  // ─── Right form panel ─────────────────────────────────────────────────────
  Widget _rightPanel({bool noPadding = false}) => Container(
    color: _bg,
    padding: noPadding ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
    child: _buildStep(),
  );

  Widget _buildStep() {
    switch (_step) {
      case _SellerStep.email: return _stepEmail();
      case _SellerStep.otp:   return _stepOtp();
      case _SellerStep.form:  return _stepForm();
    }
  }

  // ─── Step 1: Email ────────────────────────────────────────────────────────
  Widget _stepEmail() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _formTitle('Start Your Seller Journey'),
    _formSubtitle('Enter your email to begin the seller registration process'),
    const SizedBox(height: 28),
    _inputField(controller: _emailCtrl, label: 'Email Address', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
    const SizedBox(height: 16),
    if (_error != null) ...[
      _errorBanner(_error!),
      const SizedBox(height: 12),
    ],
    _primaryButton(_loading ? 'SENDING...' : 'SEND OTP', _loading ? () {} : _sendOtp),
    const SizedBox(height: 28),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Already have an account? ", style: TextStyle(color: _textLight, fontSize: 14)),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
        child: const Text('Login here', style: TextStyle(color: _primary, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
      ),
    ]),
  ]);

  // ─── Step 2: OTP ──────────────────────────────────────────────────────────
  Widget _stepOtp() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _formTitle('Verify Your Email'),
    _formSubtitle("We've sent a 6-digit code to ${_emailCtrl.text}"),
    const SizedBox(height: 28),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => SizedBox(
        width: 44, height: 52,
        child: TextField(
          controller: _otpCtrls[i],
          focusNode: _otpFocus[i],
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _accent),
          decoration: InputDecoration(
            counterText: '',
            filled: true, fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200, width: 2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
          ),
          onChanged: (v) {
            if (v.isNotEmpty && i < 5) _otpFocus[i + 1].requestFocus();
            if (v.isEmpty && i > 0) _otpFocus[i - 1].requestFocus();
          },
        ),
      )),
    ),
    const SizedBox(height: 16),
    if (_error != null) ...[
      _errorBanner(_error!),
      const SizedBox(height: 12),
    ],
    _primaryButton(_loading ? 'VERIFYING...' : 'VERIFY & CONTINUE', _loading ? () {} : _verifyOtp),
    const SizedBox(height: 16),
    Center(child: GestureDetector(
      onTap: _loading ? null : _sendOtp,
      child: RichText(text: const TextSpan(
        text: "Didn't receive the code? ",
        style: TextStyle(color: _textLight, fontSize: 14),
        children: [TextSpan(text: 'Resend OTP', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600))],
      )),
    )),
  ]);

  // ─── Step 3: Seller Form ──────────────────────────────────────────────────
  Widget _stepForm() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _formTitle('Complete Your Seller Application'),
    _formSubtitle('Fill in your business details to complete registration'),
    const SizedBox(height: 24),
    // Name row
    Row(children: [
      Expanded(child: _inputField(controller: _firstNameCtrl, label: 'First Name', prefixIcon: Icons.person_outline)),
      const SizedBox(width: 12),
      Expanded(child: _inputField(controller: _lastNameCtrl, label: 'Last Name', prefixIcon: Icons.person_outline)),
    ]),
    const SizedBox(height: 16),
    _inputField(controller: _businessNameCtrl, label: 'Business Name', prefixIcon: Icons.storefront_outlined),
    const SizedBox(height: 16),
    // Phone
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.phone_outlined, color: _gold, size: 20),
        ),
        Container(width: 1, height: 28, color: Colors.grey.shade200),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('+63', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        Container(width: 1, height: 28, color: Colors.grey.shade200),
        Expanded(child: TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w500),
          decoration: const InputDecoration(counterText: '', hintText: 'Phone Number', hintStyle: TextStyle(color: _textLight), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
        )),
      ]),
    ),
    const SizedBox(height: 16),
    _inputField(controller: _houseCtrl, label: 'House No. & Street Name', prefixIcon: Icons.home_outlined),
    const SizedBox(height: 16),
    // Region
    _loadingRegions
        ? const Center(child: CircularProgressIndicator())
        : _dropdownField(
            label: 'Region', value: _selectedRegionName,
            prefixIcon: Icons.public_outlined,
            items: _regions.map((r) => r['name']!).toList(),
            onChanged: _regions.isEmpty ? null : (v) {
              final r = _regions.firstWhere((e) => e['name'] == v);
              _onRegionChanged(r);
            },
          ),
    const SizedBox(height: 16),
    Row(children: [
      Expanded(child: _loadingProvinces
          ? const Center(child: CircularProgressIndicator())
          : _dropdownField(
              label: 'Province', value: _selectedProvinceName,
              prefixIcon: Icons.location_on_outlined,
              items: _provinces.map((p) => p['name']!).toList(),
              onChanged: _provinces.isEmpty ? null : (v) {
                final p = _provinces.firstWhere((e) => e['name'] == v);
                _onProvinceChanged(p);
              },
            )),
      const SizedBox(width: 12),
      Expanded(child: _loadingCities
          ? const Center(child: CircularProgressIndicator())
          : _dropdownField(
              label: 'City/Municipality', value: _selectedCityName,
              prefixIcon: Icons.location_city_outlined,
              items: _cities.map((c) => c['name']!).toList(),
              onChanged: _cities.isEmpty ? null : (v) {
                final c = _cities.firstWhere((e) => e['name'] == v);
                _onCityChanged(c);
              },
            )),
    ]),
    const SizedBox(height: 16),
    _loadingBarangays
        ? const Center(child: CircularProgressIndicator())
        : _dropdownField(
            label: 'Barangay', value: _selectedBarangay,
            prefixIcon: Icons.place_outlined,
            items: _barangays,
            onChanged: _barangays.isEmpty ? null : (v) => setState(() => _selectedBarangay = v),
          ),
    const SizedBox(height: 16),
    _inputField(controller: _zipCtrl, label: 'ZIP Code', keyboardType: TextInputType.number, prefixIcon: Icons.markunread_mailbox_outlined),
    const SizedBox(height: 16),
    // Passwords
    Row(children: [
      Expanded(child: _inputField(
        controller: _passCtrl, label: 'Password', obscureText: _obscurePass,
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textLight, size: 20),
          onPressed: () => setState(() => _obscurePass = !_obscurePass),
        ),
      )),
      const SizedBox(width: 12),
      Expanded(child: _inputField(
        controller: _confirmPassCtrl, label: 'Confirm Password', obscureText: _obscureConfirm,
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: _textLight, size: 20),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      )),
    ]),
    const SizedBox(height: 16),
    // Business type
    _dropdownField(
      label: 'Business Type', value: _businessType == _BusinessType.none ? null
          : _businessType == _BusinessType.individual ? 'Individual Seller' : 'Business Seller',
      prefixIcon: Icons.business_center_outlined,
      items: const ['Individual Seller', 'Business Seller'],
      onChanged: (v) => setState(() {
        _businessType = v == 'Individual Seller' ? _BusinessType.individual : _BusinessType.business;
      }),
    ),
    const SizedBox(height: 20),
    // Documents
    if (_businessType == _BusinessType.individual) ...[
      _sectionLabel('Individual Seller Documents'),
      const SizedBox(height: 12),
      _docUploadTile(label: 'Valid Government ID', hint: "Driver's License, Passport, UMID, etc."),
    ],
    if (_businessType == _BusinessType.business) ...[
      _sectionLabel('Business Seller Documents'),
      const SizedBox(height: 12),
      _docUploadTile(label: 'DTI Certificate', hint: 'Department of Trade and Industry Certificate'),
      const SizedBox(height: 12),
      _docUploadTile(label: 'BIR Certificate', hint: 'Bureau of Internal Revenue Certificate'),
      const SizedBox(height: 12),
      _docUploadTile(label: 'Business Permit', hint: 'Business Permit from your local government'),
      const SizedBox(height: 12),
      _docUploadTile(label: 'Valid Government ID', hint: "Driver's License, Passport, UMID, etc."),
    ],
    if (_businessType != _BusinessType.none) const SizedBox(height: 20),
    // Terms
    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withOpacity(0.25)),
        color: const Color(0xFFF8F9FA),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => _termsAccepted = !_termsAccepted),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: _termsAccepted ? _gold : Colors.white,
              border: Border.all(color: _termsAccepted ? _gold : Colors.grey.shade300, width: 2),
              boxShadow: _termsAccepted ? [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 8)] : [],
            ),
            child: _termsAccepted ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: RichText(text: const TextSpan(
          style: TextStyle(color: _accent, fontSize: 14, height: 1.5),
          children: [
            TextSpan(text: 'I agree to the '),
            TextSpan(text: 'Terms and Conditions', style: TextStyle(color: _gold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
            TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', style: TextStyle(color: _gold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
          ],
        ))),
      ]),
    ),
    const SizedBox(height: 28),
    if (_error != null) ...[
      _errorBanner(_error!),
      const SizedBox(height: 12),
    ],
    _primaryButton(_loading ? 'SUBMITTING...' : 'SUBMIT APPLICATION', _loading ? () {} : _submit),
  ]);

  // ─── Shared UI helpers ────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _gold.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _gold.withOpacity(0.25)),
    ),
    child: Row(children: [
      const Icon(Icons.folder_outlined, color: _gold, size: 18),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 14)),
    ]),
  );

  Widget _docUploadTile({required String label, required String hint}) {
    final file = _docFiles[label];
    final isUploading = _docUploading[label] == true;
    final isUploaded = _docPaths[label] != null;

    return GestureDetector(
      onTap: isUploading ? null : () => _pickAndUploadDoc(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUploaded ? Colors.green.shade400 : isUploading ? _gold.withOpacity(0.5) : Colors.grey.shade200,
            width: 2,
          ),
          color: isUploaded ? Colors.green.shade50 : isUploading ? _gold.withOpacity(0.04) : Colors.white,
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isUploaded ? Colors.green.shade100 : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isUploading
                ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2, color: _gold))
                : file != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(file, fit: BoxFit.cover))
                    : Icon(isUploaded ? Icons.check_circle : Icons.upload_file_outlined,
                        color: isUploaded ? Colors.green.shade600 : _accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: isUploaded ? Colors.green.shade700 : _accent, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 3),
            Text(
              isUploading ? 'Uploading...' : isUploaded ? 'Uploaded successfully ✓' : hint,
              style: TextStyle(color: isUploaded ? Colors.green.shade600 : _textLight, fontSize: 12)),
          ])),
          if (!isUploading)
            Icon(isUploaded ? Icons.edit_outlined : Icons.chevron_right,
              color: isUploaded ? Colors.green.shade400 : _textLight, size: 20),
        ]),
      ),
    );
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

  Widget _formTitle(String text) => Column(children: [
    Text(text, style: const TextStyle(color: _accent, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5), textAlign: TextAlign.center),
    const SizedBox(height: 10),
    Center(child: Container(width: 45, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(colors: [_gold, _primary])))),
  ]);

  Widget _formSubtitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Text(text, style: const TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
  );

  Widget _inputField({required TextEditingController controller, required String label, TextInputType keyboardType = TextInputType.text, bool obscureText = false, Widget? suffixIcon, int? maxLength, IconData? prefixIcon}) =>
    TextField(
      controller: controller, keyboardType: keyboardType, obscureText: obscureText, maxLength: maxLength,
      style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label, counterText: '',
        labelStyle: const TextStyle(color: _textLight, fontSize: 15),
        floatingLabelStyle: const TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        filled: true, fillColor: Colors.white, suffixIcon: suffixIcon,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _gold, size: 20) : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _primary, width: 2)),
      ),
    );

  Widget _dropdownField({required String label, required String? value, required List<String> items, required ValueChanged<String?>? onChanged, IconData? prefixIcon}) =>
    DropdownButtonFormField<String>(
      value: value, isExpanded: true,
      hint: Text(label, style: const TextStyle(color: _textLight, fontSize: 15), overflow: TextOverflow.ellipsis),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        filled: true, fillColor: onChanged == null ? const Color(0xFFF0F2F5) : Colors.white,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: _gold, size: 20) : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _primary, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200, width: 2)),
      ),
    );

  Widget _primaryButton(String label, VoidCallback onPressed) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_primary, _accent]),
      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 8))],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    ),
  );
}
