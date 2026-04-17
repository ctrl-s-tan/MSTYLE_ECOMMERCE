import 'package:flutter/material.dart';

// ─── Theme (matches homepage/login palette) ───────────────────────────────────
const Color _primary   = Color(0xFF1a1a1a);
const Color _accent    = Color(0xFF2c3e50);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);

const _premiumGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_primary, _accent],
);
const _goldGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_gold, _goldLight],
);

// ─── Footer Widget ────────────────────────────────────────────────────────────
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _premiumGrad),
      child: Stack(children: [
        // Decorative radial glow (matches CSS ::before)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.4, 0.4),
                radius: 1.2,
                colors: [_gold.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── 4-column grid (stacked on mobile) ──────────────────────────
            _buildGrid(),
            const SizedBox(height: 36),
            // ── Divider ────────────────────────────────────────────────────
            Container(height: 1, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 24),
            // ── Bottom copyright ───────────────────────────────────────────
            const Center(
              child: Text(
                '© 2025 MSTYLE - Premium Men\'s Fashion. All rights reserved.',
                style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.3, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(builder: (_, constraints) {
      final isWide = constraints.maxWidth > 600;
      if (isWide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _aboutSection()),
          const SizedBox(width: 32),
          Expanded(child: _categoriesSection()),
          const SizedBox(width: 32),
          Expanded(child: _customerCareSection()),
          const SizedBox(width: 32),
          Expanded(child: _connectSection()),
        ]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _aboutSection(),
        const SizedBox(height: 32),
        _categoriesSection(),
        const SizedBox(height: 32),
        _customerCareSection(),
        const SizedBox(height: 32),
        _connectSection(),
      ]);
    });
  }

  // ─── About Section ────────────────────────────────────────────────────────
  Widget _aboutSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Logo + brand name
    Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          gradient: _goldGrad,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Icon(Icons.storefront, color: _primary, size: 20),
      ),
      const SizedBox(width: 10),
      ShaderMask(
        shaderCallback: (b) => _goldGrad.createShader(b),
        child: const Text('MSTYLE',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
    ]),
    const SizedBox(height: 18),
    _sectionTitle('About MSTYLE'),
    const SizedBox(height: 14),
    const Text(
      "Premium men's fashion destination offering curated collections of suits, casual wear, outerwear, and luxury accessories for the modern gentleman.",
      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.7, fontWeight: FontWeight.w400),
    ),
  ]);

  // ─── Categories Section ───────────────────────────────────────────────────
  Widget _categoriesSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionTitle("Men's Categories"),
    const SizedBox(height: 14),
    ...[
      ("Suits & Blazers",        "/suits"),
      ("Casual Shirts & Pants",  "/casual"),
      ("Outerwear & Jackets",    "/outerwear"),
      ("Activewear & Fitness",   "/activewear"),
      ("Shoes & Accessories",    "/shoes"),
      ("Grooming Products",      "/grooming"),
    ].map((e) => _footerLink(e.$1)),
  ]);

  // ─── Customer Care Section ────────────────────────────────────────────────
  Widget _customerCareSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionTitle('Customer Care'),
    const SizedBox(height: 14),
    ...[
      ("About Us",              "/about"),
      ("Terms and Conditions",  "/terms_conditions"),
      ("Privacy Policy",        "/privacy_policy"),
    ].map((e) => _footerLink(e.$1)),
  ]);

  // ─── Connect Section ──────────────────────────────────────────────────────
  Widget _connectSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionTitle('Connect With Us'),
    const SizedBox(height: 14),
    _contactRow(Icons.email_outlined,    'stylemens2025@gmail.com'),
    const SizedBox(height: 10),
    _contactRow(Icons.phone_outlined,    '(555) 123-STYLE'),
    const SizedBox(height: 10),
    _contactRow(Icons.style_outlined,    'Follow us for style inspiration'),
    const SizedBox(height: 20),
    // Social icons row
    Row(children: [
      _socialBtn(Icons.facebook_outlined),
      const SizedBox(width: 10),
      _socialBtn(Icons.camera_alt_outlined),
      const SizedBox(width: 10),
      _socialBtn(Icons.alternate_email),
    ]),
  ]);

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _sectionTitle(String text) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(text,
      style: const TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    const SizedBox(height: 8),
    Container(
      width: 32, height: 2,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), gradient: _goldGrad),
    ),
  ]);

  Widget _footerLink(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(children: [
      ShaderMask(
        shaderCallback: (b) => _goldGrad.createShader(b),
        child: const Text('→ ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
      Expanded(
        child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.2)),
      ),
    ]),
  );

  Widget _contactRow(IconData icon, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: _gold, size: 15),
    const SizedBox(width: 8),
    Expanded(
      child: Text(text,
        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400, height: 1.4)),
    ),
  ]);

  Widget _socialBtn(IconData icon) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      shape: BoxShape.circle,
      border: Border.all(color: _gold.withOpacity(0.3)),
    ),
    child: Icon(icon, color: _gold, size: 17),
  );
}
