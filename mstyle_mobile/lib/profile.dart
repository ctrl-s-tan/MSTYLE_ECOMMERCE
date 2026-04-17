import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'supabase_client.dart';
import 'home_page.dart';

// ─── Theme constants ──────────────────────────────────────────────────────────
const Color _primary   = Color(0xFF1a1a1a);
const Color _accent    = Color(0xFF2c3e50);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);
const Color _textLight = Color(0xFF6c757d);
const Color _bg        = Color(0xFFF8F9FA);
const Color _border    = Color(0xFFE9ECEF);

const _premiumGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_primary, _accent],
);
const _goldGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_gold, _goldLight],
);

// ─── Unified Profile Page ─────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  final String userEmail;
  const ProfilePage({super.key, required this.userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── State ──────────────────────────────────────────────────────────────────
  bool _loading       = true;
  bool _editing       = false;
  bool _savingProfile = false;
  bool _savingPass    = false;
  String _role        = 'buyer'; // buyer | seller | rider

  // Profile controllers
  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _businessCtrl;

  // Rider vehicle controllers
  late final TextEditingController _vehicleModelCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _yearCtrl;
  String _vehicleType = 'motorcycle';

  // Password controllers
  final _oldPassCtrl     = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureOld     = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  // Supabase user id (UUID)
  String? _userId;
  File?   _avatarFile; // locally picked image

  @override
  void initState() {
    super.initState();
    _firstCtrl        = TextEditingController();
    _lastCtrl         = TextEditingController();
    _emailCtrl        = TextEditingController(text: widget.userEmail);
    _phoneCtrl        = TextEditingController();
    _addressCtrl      = TextEditingController();
    _businessCtrl     = TextEditingController();
    _vehicleModelCtrl = TextEditingController();
    _plateCtrl        = TextEditingController();
    _yearCtrl         = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    for (final c in [
      _firstCtrl, _lastCtrl, _emailCtrl, _phoneCtrl, _addressCtrl,
      _businessCtrl, _vehicleModelCtrl, _plateCtrl, _yearCtrl,
      _oldPassCtrl, _newPassCtrl, _confirmPassCtrl,
    ]) c.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      // Fetch user profile from Supabase users table
      final res = await supabase
          .from('users')
          .select('id, first_name, last_name, email, phone, role, business_name, '
                  'house_street, barangay, city, province, region, zip_code')
          .eq('email', widget.userEmail)
          .maybeSingle();

      if (res != null) {
        _userId = res['id'] as String?;
        _role   = (res['role'] as String? ?? 'buyer').toLowerCase();

        _firstCtrl.text    = res['first_name'] as String? ?? '';
        _lastCtrl.text     = res['last_name']  as String? ?? '';
        _emailCtrl.text    = res['email']      as String? ?? widget.userEmail;
        _phoneCtrl.text    = res['phone']      as String? ?? '';
        _businessCtrl.text = res['business_name'] as String? ?? '';

        // Build address from parts
        final parts = [
          res['house_street'] as String? ?? '',
          res['barangay']     as String? ?? '',
          res['city']         as String? ?? '',
          res['province']     as String? ?? '',
          res['region']       as String? ?? '',
          res['zip_code']     as String? ?? '',
        ].where((p) => p.isNotEmpty).toList();
        _addressCtrl.text = parts.join(', ');

        // Fetch vehicle info for riders from rider_vehicles table
        if (_role == 'rider' && _userId != null) {
          try {
            final rv = await supabase
                .from('rider_vehicles')
                .select('vehicle_type, vehicle_model, plate_number, year_model')
                .eq('user_id', _userId!)
                .maybeSingle();
            if (rv != null) {
              _vehicleType          = rv['vehicle_type']  as String? ?? 'motorcycle';
              _vehicleModelCtrl.text = rv['vehicle_model'] as String? ?? '';
              _plateCtrl.text        = rv['plate_number']  as String? ?? '';
              _yearCtrl.text         = rv['year_model']    as String? ?? '';
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      _snack('Failed to load profile: $e', success: false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Save profile ───────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() => _savingProfile = true);
    try {
      if (_userId == null) throw Exception('User not found');

      final update = <String, dynamic>{
        'first_name':    _firstCtrl.text.trim(),
        'last_name':     _lastCtrl.text.trim(),
        'phone':         _phoneCtrl.text.trim(),
      };
      if (_role == 'seller') {
        update['business_name'] = _businessCtrl.text.trim();
      }

      await supabase.from('users').update(update).eq('id', _userId!);

      // Update rider vehicle info
      if (_role == 'rider') {
        await supabase.from('rider_vehicles').upsert({
          'user_id':       _userId!,
          'vehicle_type':  _vehicleType,
          'vehicle_model': _vehicleModelCtrl.text.trim(),
          'plate_number':  _plateCtrl.text.trim(),
          'year_model':    _yearCtrl.text.trim(),
        });
      }

      setState(() => _editing = false);
      _snack('Profile updated successfully!', success: true);
    } catch (e) {
      _snack('Failed to save profile: $e', success: false);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  // ── Change password ────────────────────────────────────────────────────────
  Future<void> _savePassword() async {
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      _snack('Please fill in all password fields.', success: false); return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      _snack('New password and confirm password do not match.', success: false); return;
    }
    setState(() => _savingPass = true);
    try {
      // Verify old password by re-signing in
      await supabase.auth.signInWithPassword(
        email: widget.userEmail,
        password: _oldPassCtrl.text,
      );
      // Update to new password
      await supabase.auth.updateUser(UserAttributes(password: _newPassCtrl.text));
      _oldPassCtrl.clear(); _newPassCtrl.clear(); _confirmPassCtrl.clear();
      _snack('Password updated successfully!', success: true);
    } on AuthException catch (e) {
      _snack(e.message, success: false);
    } catch (e) {
      _snack('Failed to update password: $e', success: false);
    } finally {
      if (mounted) setState(() => _savingPass = false);
    }
  }

  // ── Pick avatar image ──────────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked != null && mounted) {
      setState(() => _avatarFile = File(picked.path));
    }
  }

  void _snack(String msg, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? Icons.check_circle : Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: success ? _primary : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(child: CircularProgressIndicator(color: _gold)),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(slivers: [
        _appBar(),
        SliverToBoxAdapter(child: _avatarSection()),
        SliverToBoxAdapter(child: _personalCard()),
        if (_role == 'rider') SliverToBoxAdapter(child: _vehicleCard()),
        SliverToBoxAdapter(child: _passwordCard()),
        SliverToBoxAdapter(child: _logoutBtn()),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }

  // ─── App Bar ───────────────────────────────────────────────────────────────
  SliverAppBar _appBar() => SliverAppBar(
    pinned: true,
    backgroundColor: _primary,
    elevation: 6,
    titleSpacing: 16,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text('My Profile',
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
  );

  // ─── Profile Header ────────────────────────────────────────────────────────
  Widget _profileHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Column(children: [
      // Avatar with initials
      Stack(children: [
        Container(
          width: 86, height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: _goldGrad,
            boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 16)],
          ),
          child: Center(
            child: Text(
              _initials(),
              style: const TextStyle(color: _primary, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 1),
            ),
          ),
        ),
        Positioned(bottom: 0, right: 0,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              border: Border.all(color: _primary, width: 2),
            ),
            child: const Icon(Icons.camera_alt, size: 14, color: _primary),
          ),
        ),
      ]),
      const SizedBox(height: 14),
      const Text('Profile Information',
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      const SizedBox(height: 6),
      Text('Manage your personal information and preferences',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        textAlign: TextAlign.center),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(12)),
        child: Text(_roleLabel(),
          style: const TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 11)),
      ),
    ]),
  );

  String _initials() {
    final f = _firstCtrl.text.isNotEmpty ? _firstCtrl.text[0].toUpperCase() : '';
    final l = _lastCtrl.text.isNotEmpty  ? _lastCtrl.text[0].toUpperCase()  : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }

  String _roleLabel() {
    switch (_role) {
      case 'seller': return 'Seller Account';
      case 'rider':  return 'Rider Account';
      default:       return 'Buyer Account';
    }
  }

  // ─── Avatar Section ────────────────────────────────────────────────────────
  Widget _avatarSection() => Container(
    color: _primary,
    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
    child: Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Stack(children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _avatarFile == null ? _goldGrad : null,
              boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 16)],
            ),
            child: _avatarFile != null
              ? ClipOval(child: Image.file(_avatarFile!, fit: BoxFit.cover, width: 90, height: 90))
              : Center(
                  child: Text(
                    _initials(),
                    style: const TextStyle(color: _primary, fontWeight: FontWeight.w900, fontSize: 30, letterSpacing: 1),
                  ),
                ),
          ),
          Positioned(bottom: 0, right: 0,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: _primary, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: _primary),
            ),
          ),
        ]),
      ),
    ),
  );

  // ─── Personal Info Card ────────────────────────────────────────────────────
  Widget _personalCard() => _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Icon(Icons.person_outline, color: _gold, size: 18),
      const SizedBox(width: 8),
      const Text('Personal Information',
        style: TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w800)),
      const Spacer(),
      if (!_editing)
        _outlineBtn(Icons.edit_outlined, 'Edit Profile', () => setState(() => _editing = true))
      else
        _outlineBtn(Icons.close, 'Cancel', () => setState(() => _editing = false), color: _textLight),
    ]),
    const SizedBox(height: 4),
    _divider(),
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: _field('First Name', Icons.person_outline, _firstCtrl)),
      const SizedBox(width: 12),
      Expanded(child: _field('Last Name', Icons.person_outline, _lastCtrl)),
    ]),
    const SizedBox(height: 14),
    _field('Email Address', Icons.email_outlined, _emailCtrl,
      type: TextInputType.emailAddress, readOnly: true), // email not editable
    const SizedBox(height: 14),
    _field('Phone Number', Icons.phone_outlined, _phoneCtrl, type: TextInputType.phone),
    if (_role == 'seller') ...[
      const SizedBox(height: 14),
      _field('Business Name', Icons.store_outlined, _businessCtrl),
    ],
    const SizedBox(height: 14),
    _field('Address', Icons.location_on_outlined, _addressCtrl, maxLines: 2),
    const SizedBox(height: 6),
    Row(children: [
      const Icon(Icons.info_outline, size: 13, color: _textLight),
      const SizedBox(width: 5),
      const Expanded(child: Text('Make sure to save your changes before leaving this page.',
        style: TextStyle(color: _textLight, fontSize: 11))),
    ]),
    if (_editing) ...[
      const SizedBox(height: 18),
      _actionBtn('Save Changes', _savingProfile, _saveProfile),
    ],
  ]));

  // ─── Vehicle Card (rider only) ─────────────────────────────────────────────
  Widget _vehicleCard() => _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [
      Icon(Icons.directions_bike_outlined, color: _gold, size: 18),
      SizedBox(width: 8),
      Text('Vehicle Information',
        style: TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w800)),
    ]),
    const SizedBox(height: 4),
    _divider(),
    const SizedBox(height: 18),
    DropdownButtonFormField<String>(
      value: _vehicleType,
      style: TextStyle(color: _editing ? _accent : _textLight, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Vehicle Type',
        labelStyle: const TextStyle(color: _textLight, fontSize: 13),
        prefixIcon: const Icon(Icons.two_wheeler_outlined, color: _gold, size: 18),
        filled: true, fillColor: _editing ? Colors.white : _bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border.withOpacity(0.5), width: 1.5)),
      ),
      items: const [
        DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle')),
        DropdownMenuItem(value: 'bicycle',    child: Text('Bicycle')),
        DropdownMenuItem(value: 'car',        child: Text('Car')),
        DropdownMenuItem(value: 'scooter',    child: Text('Scooter')),
      ],
      onChanged: _editing ? (v) => setState(() => _vehicleType = v ?? 'motorcycle') : null,
    ),
    const SizedBox(height: 12),
    _field('Vehicle Model', Icons.directions_car_outlined, _vehicleModelCtrl),
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: _field('Plate Number', Icons.confirmation_number_outlined, _plateCtrl)),
      const SizedBox(width: 12),
      Expanded(child: _field('Year Model', Icons.calendar_today_outlined, _yearCtrl,
        type: TextInputType.number)),
    ]),
    if (_editing) ...[
      const SizedBox(height: 16),
      _actionBtn('Save Changes', _savingProfile, _saveProfile),
    ],
  ]));

  // ─── Password Card ─────────────────────────────────────────────────────────
  Widget _passwordCard() => _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [
      Icon(Icons.key_outlined, color: _gold, size: 18),
      SizedBox(width: 8),
      Text('Change Password',
        style: TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w800)),
    ]),
    const SizedBox(height: 4),
    _divider(),
    const SizedBox(height: 18),
    _passField('Current Password', Icons.lock_outline, _oldPassCtrl, _obscureOld,
      () => setState(() => _obscureOld = !_obscureOld)),
    const SizedBox(height: 14),
    _passField('New Password', Icons.key_outlined, _newPassCtrl, _obscureNew,
      () => setState(() => _obscureNew = !_obscureNew)),
    const SizedBox(height: 14),
    _passField('Confirm New Password', Icons.check_circle_outline, _confirmPassCtrl, _obscureConfirm,
      () => setState(() => _obscureConfirm = !_obscureConfirm)),
    const SizedBox(height: 18),
    _actionBtn('Update Password', _savingPass, _savePassword),
  ]));

  // ─── Logout Button ─────────────────────────────────────────────────────────
  Widget _logoutBtn() => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    child: GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.logout, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text('Logout', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 18)),
          ]),
          content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: _textLight, fontSize: 14)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _textLight))),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.logout, color: Colors.red.shade500, size: 20),
          const SizedBox(width: 10),
          Text('Logout',
            style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      ),
    ),
  );

  // ─── Shared widget helpers ─────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: child,
  );

  Widget _divider() => Container(
    width: 36, height: 3,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad),
  );

  Widget _field(
    String label, IconData icon, TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) =>
    TextField(
      controller: ctrl,
      enabled: _editing && !readOnly,
      readOnly: readOnly,
      keyboardType: type,
      maxLines: maxLines,
      style: TextStyle(
        color: (_editing && !readOnly) ? _accent : _textLight,
        fontSize: 14, fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textLight, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: _gold, size: 18),
        filled: true,
        fillColor: (_editing && !readOnly) ? Colors.white : _bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border.withOpacity(0.5), width: 1.5)),
      ),
    );

  Widget _passField(
    String label, IconData icon, TextEditingController ctrl,
    bool obscure, VoidCallback toggle,
  ) =>
    TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textLight, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: _accent, size: 18),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: _textLight, size: 20),
          onPressed: toggle,
        ),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2)),
      ),
    );

  Widget _actionBtn(String label, bool loading, VoidCallback onTap) => GestureDetector(
    onTap: loading ? null : onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: loading ? null : _premiumGrad,
        color: loading ? const Color(0xFFCED4DA) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: loading ? [] : [
          BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (loading)
          const SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        else
          const Icon(Icons.save_outlined, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(loading ? 'Saving...' : label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
    ),
  );

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap, {Color? color}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: (color ?? _gold).withOpacity(0.5)),
          color: (color ?? _gold).withOpacity(0.06),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color ?? _gold),
          const SizedBox(width: 5),
          Text(label,
            style: TextStyle(color: color ?? _gold, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
}
