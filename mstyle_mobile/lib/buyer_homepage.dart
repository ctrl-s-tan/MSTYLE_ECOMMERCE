import 'dart:async';
import 'package:flutter/material.dart';
import 'activewear.dart';
import 'casual.dart';
import 'suits.dart';
import 'outerwear.dart';
import 'shoes.dart';
import 'grooming.dart';
import 'footer.dart';
import 'login.dart';
import 'buyer_cart.dart';
import 'buyer_orders.dart';
import 'buyer_wishlist.dart';
import 'profile.dart';
import 'buyer_viewproduct.dart';
import 'buyer_checkout.dart';
import 'buyer_notifications.dart';
import 'seller_register.dart';
import 'buyer_service.dart';
import 'buyer_header.dart';
import 'buyer_bottom_navbar.dart';
import 'product_image_carousel.dart';

// ─── Theme ───────────────────────────────────────────────────────────────────
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

// ─── Data ─────────────────────────────────────────────────────────────────────
const _heroSlides = [
  {'title': 'Craft Your', 'highlight': 'Signature Style'},
  {'title': 'Craft Your', 'highlight': 'Executive Look'},
  {'title': 'Craft Your', 'highlight': 'Premium Fashion'},
  {'title': 'Craft Your', 'highlight': 'Timeless Elegance'},
];

const _categories = [
  {'icon': Icons.person,         'label': 'Suits & Blazers',    'sub': 'Executive & Formal Wear'},
  {'icon': Icons.checkroom,      'label': 'Casual Wear',         'sub': 'Everyday Comfort'},
  {'icon': Icons.layers,         'label': 'Outerwear',           'sub': 'Stylish Protection'},
  {'icon': Icons.directions_run, 'label': 'Activewear',          'sub': 'Performance Gear'},
  {'icon': Icons.shopping_bag,   'label': 'Shoes & Accessories', 'sub': 'Premium Footwear'},
  {'icon': Icons.cut,            'label': 'Grooming',            'sub': 'Complete Care Collection'},
];

// ─── Page ─────────────────────────────────────────────────────────────────────
class BuyerHomePage extends StatefulWidget {
  final String userEmail;
  const BuyerHomePage({super.key, required this.userEmail});
  @override
  State<BuyerHomePage> createState() => _BuyerHomePageState();
}

class _BuyerHomePageState extends State<BuyerHomePage> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int _heroSlide = 0;
  int _cartCount = 0;
  int _notifCount = 0;
  int _navIndex = 0;
  Timer? _heroTimer;
  bool _navVisible = true;
  double _lastScrollOffset = 0;

  List<Map<String, dynamic>> _products = [];
  bool _productsLoading = true;
  String? _productsError;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() => _heroSlide = (_heroSlide + 1) % _heroSlides.length);
    });
    _scrollCtrl.addListener(_onScroll);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) setState(() { _productsLoading = true; _productsError = null; });
    try {
      final data = await BuyerService.getProducts(limit: 8);
      if (mounted) setState(() { _products = data; _productsLoading = false; });
    } catch (e) {
      debugPrint('_loadProducts error: $e');
      if (mounted) setState(() { _productsLoading = false; _productsError = e.toString(); });
    }
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    final diff = offset - _lastScrollOffset;
    if (diff > 6 && _navVisible) {
      setState(() => _navVisible = false);
    } else if (diff < -6 && !_navVisible) {
      setState(() => _navVisible = true);
    }
    _lastScrollOffset = offset;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _heroTimer?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                BuyerAppBar(
                  userEmail: widget.userEmail,
                  cartCount: _cartCount,
                  notifCount: _notifCount,
                ),
                SliverToBoxAdapter(child: _heroSection()),
                SliverToBoxAdapter(child: _featuresStrip()),
                SliverToBoxAdapter(child: _categoriesSection()),
                SliverToBoxAdapter(child: _productsSection()),
                SliverToBoxAdapter(child: _sellerSection()),
                const SliverToBoxAdapter(child: AppFooter()),
                // Extra bottom padding so content isn't hidden behind nav
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
          // Animated bottom nav overlay
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              offset: _navVisible ? Offset.zero : const Offset(0, 1),
              child: BuyerBottomNavBar(
                userEmail: widget.userEmail,
                currentPage: BuyerPage.home,
                onSearch: _showSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: _accent, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search for premium menswear...',
                hintStyle: const TextStyle(color: _textLight),
                prefixIcon: const Icon(Icons.search, color: _gold),
                filled: true, fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: _gold.withOpacity(0.3), width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: _gold, width: 2)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showWishlist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.favorite_border, color: _gold),
            SizedBox(width: 10),
            Text('Wishlist', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          const Center(child: Column(children: [
            Icon(Icons.favorite_border, size: 48, color: _border),
            SizedBox(height: 8),
            Text('Your wishlist is empty', style: TextStyle(color: _textLight, fontSize: 14)),
          ])),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.notifications_outlined, color: _gold),
            const SizedBox(width: 10),
            const Text('Notifications', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mark all read', style: TextStyle(color: _gold, fontSize: 12))),
          ]),
          const SizedBox(height: 16),
          const Center(child: Column(children: [
            Icon(Icons.notifications_none, size: 48, color: _border),
            SizedBox(height: 8),
            Text('No new notifications', style: TextStyle(color: _textLight, fontSize: 14)),
          ])),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showOrders() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.shopping_bag_outlined, color: _gold),
            SizedBox(width: 10),
            Text('My Orders', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          const Center(child: Column(children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: _border),
            SizedBox(height: 8),
            Text('No orders yet', style: TextStyle(color: _textLight, fontSize: 14)),
          ])),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.shopping_cart_outlined, color: _gold),
            SizedBox(width: 10),
            Text('Shopping Cart', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          const Center(child: Column(children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: _border),
            SizedBox(height: 8),
            Text('Your cart is empty', style: TextStyle(color: _textLight, fontSize: 14)),
          ])),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(14)),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('View Cart & Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          // Avatar
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(gradient: _premiumGrad, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(widget.userEmail, style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 20),
          _profileTile(Icons.person_outline, 'My Profile', () => Navigator.pop(context)),
          _profileTile(Icons.shopping_bag_outlined, 'My Orders', () => Navigator.pop(context)),
          _profileTile(Icons.favorite_border, 'Wishlist', () => Navigator.pop(context)),
          const Divider(height: 24),
          _profileTile(Icons.logout, 'Logout', () {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
          }, color: Colors.red.shade400),
        ]),
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Icon(icon, color: color ?? _accent, size: 20),
    title: Text(label, style: TextStyle(color: color ?? _accent, fontWeight: FontWeight.w600, fontSize: 14)),
    trailing: Icon(Icons.chevron_right, color: color ?? _textLight, size: 18),
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    onTap: onTap,
  );

  // ─── Hero Section ─────────────────────────────────────────────────────────
  Widget _heroSection() {
    final slide = _heroSlides[_heroSlide];
    return SizedBox(
      height: 420,
      child: Stack(children: [
        Row(children: [
          Expanded(
            flex: 58,
            child: Container(
              decoration: const BoxDecoration(gradient: _premiumGrad),
              padding: const EdgeInsets.fromLTRB(16, 20, 12, 28),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]),
                  child: const Text('NEW COLLECTION', style: TextStyle(color: _primary, fontWeight: FontWeight.w800, fontSize: 8, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 8),
                Text(slide['title']!, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim), child: child)),
                  child: ShaderMask(
                    key: ValueKey(_heroSlide),
                    shaderCallback: (b) => _goldGrad.createShader(b),
                    child: Text(slide['highlight']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1)),
                  ),
                ),
                const SizedBox(height: 6),
                Container(width: 40, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
                const SizedBox(height: 8),
                const Text('Premium menswear for the modern man.',
                  style: TextStyle(color: Colors.white60, fontSize: 10, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                _heroBtn('Shop Now', onTap: () {}),
              ]),
            ),
          ),
          Expanded(
            flex: 42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFECEFF1), Color(0xFFE9ECEF)]),
              ),
              child: Stack(alignment: Alignment.center, children: [
                Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [_gold.withOpacity(0.12), Colors.transparent]))),
                const Icon(Icons.storefront, size: 64, color: Color(0xFFCED4DA)),
                Positioned(top: 18, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
                    child: const Text('SPECIAL', style: TextStyle(color: _primary, fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 0.8)),
                  ),
                ),
                Positioned(bottom: 30, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: _primary.withOpacity(0.85), borderRadius: BorderRadius.circular(10), border: Border.all(color: _gold.withOpacity(0.3))),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Premium Item', style: TextStyle(color: Colors.white70, fontSize: 8)),
                      Text('₱1,299.00', style: TextStyle(color: _gold, fontWeight: FontWeight.w800, fontSize: 12)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ]),
        Positioned(bottom: 10, left: 0, right: 0,
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_heroSlides.length, (i) => GestureDetector(
              onTap: () => setState(() => _heroSlide = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _heroSlide == i ? 22 : 8, height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _heroSlide == i ? _gold : Colors.white38,
                  boxShadow: _heroSlide == i ? [BoxShadow(color: _gold.withOpacity(0.5), blurRadius: 6)] : [],
                ),
              ),
            )),
          ),
        ),
      ]),
    );
  }

  Widget _heroBtn(String label, {required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: _goldGrad,
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Text('Shop Now', style: TextStyle(color: _primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
        SizedBox(width: 6),
        Icon(Icons.arrow_forward, color: _primary, size: 14),
      ]),
    ),
  );

  // ─── Features Strip ───────────────────────────────────────────────────────
  Widget _featuresStrip() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _featureChip(Icons.local_shipping_outlined, 'Free Shipping'),
        _featureChip(Icons.verified_outlined, 'Premium Quality'),
        _featureChip(Icons.replay_outlined, 'Easy Returns'),
        _featureChip(Icons.lock_outlined, 'Secure Payment'),
      ]),
    ),
  );

  Widget _featureChip(IconData icon, String label) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: _border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(gradient: _goldGrad, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 6)]),
        child: Icon(icon, color: _primary, size: 15),
      ),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 12)),
    ]),
  );

  // ─── Categories Section ───────────────────────────────────────────────────
  Widget _categoriesSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(children: [
      _sectionTitle("Premium Men's Categories"),
      const SizedBox(height: 24),
      SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            return GestureDetector(
              onTap: () {
                final label = cat['label'] as String;
                if (label == 'Activewear') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ActivewearPage(userEmail: widget.userEmail)));
                } else if (label == 'Casual Wear') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CasualPage(userEmail: widget.userEmail)));
                } else if (label == 'Suits & Blazers') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SuitsPage(userEmail: widget.userEmail)));
                } else if (label == 'Outerwear') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OuterwearPage(userEmail: widget.userEmail)));
                } else if (label == 'Shoes & Accessories') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ShoesPage(userEmail: widget.userEmail)));
                } else if (label == 'Grooming') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GroomingPage(userEmail: widget.userEmail)));
                }
              },
              child: Container(
                width: 108,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]),
                    child: Icon(cat['icon'] as IconData, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(cat['label'] as String,
                      style: const TextStyle(color: _accent, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                      textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 4),
                  const Text('→', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == 0 ? 20 : 8, height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: i == 0 ? _gold : _accent.withOpacity(0.2),
          ),
        )),
      ),
    ]),
  );

  // ─── Featured Products ────────────────────────────────────────────────────
  Widget _productsSection() => Container(
    color: _bg,
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(children: [
      _sectionTitle('Featured Products'),
      const SizedBox(height: 24),
      if (_productsLoading)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(color: _gold),
        )
      else if (_productsError != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: _textLight),
            const SizedBox(height: 12),
            const Text('Could not load products', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text(_productsError!, style: const TextStyle(color: _textLight, fontSize: 11), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadProducts,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.refresh, color: _gold, size: 16),
                  SizedBox(width: 8),
                  Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
            ),
          ]),
        )
      else if (_products.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text('No products available', style: TextStyle(color: _textLight)),
        )
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.68,
          ),
          itemCount: _products.length,
          itemBuilder: (_, i) => _productCard(_products[i]),
        ),
    ]),
  );

  Widget _productCard(Map<String, dynamic> item) {
    final name       = item['name'] as String? ?? '';
    final price      = (item['price'] as num?)?.toDouble() ?? 0;
    final rating     = (item['rating'] as num?)?.toDouble() ?? 0;
    final sold       = (item['sold'] as num?)?.toInt() ?? 0;
    final qty        = (item['quantity'] as num?)?.toInt() ?? 0;
    final id         = item['id'];
    final inStock    = qty > 0;
    final variations = item['variations'] as String? ?? '';
    final sizes      = item['sizes'] as String? ?? '';
    final colorList  = variations.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final sizeList   = sizes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Image area ──────────────────────────────────────────────────────
        Expanded(
          child: Stack(children: [
            // Real product image / carousel
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) => ProductImageCarousel(
                  imageString: item['image'] as String?,
                  height: constraints.maxHeight.isInfinite ? 200 : constraints.maxHeight,
                  borderRadius: 18,
                ),
              ),
            ),
            // Out of stock overlay
            if (!inStock)
              Positioned.fill(child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.cancel_outlined, color: Colors.white70, size: 28),
                  SizedBox(height: 4),
                  Text('OUT OF STOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1)),
                ])),
              )),
            // Wishlist + Cart buttons
            if (inStock)
              Positioned(bottom: 8, right: 8,
                child: Row(children: [
                  _iconBtn(Icons.favorite_border, onTap: () async {
                    try {
                      await BuyerService.addToWishlist(widget.userEmail, id is int ? id : int.tryParse('$id') ?? 0);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to wishlist'), backgroundColor: _primary, behavior: SnackBarBehavior.floating));
                    } catch (_) {}
                  }),
                  const SizedBox(width: 6),
                  _iconBtn(Icons.shopping_cart_outlined, onTap: () async {
                    try {
                      await BuyerService.addToCart(
                        email: widget.userEmail,
                        productId: id is int ? id : int.tryParse('$id') ?? 0,
                        name: name,
                        price: price,
                        sellerEmail: item['seller_email'] as String? ?? '',
                        quantity: 1,
                      );
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart!'), backgroundColor: _primary, behavior: SnackBarBehavior.floating));
                    } catch (_) {}
                  }),
                ]),
              ),
            // View button
            Positioned(bottom: 8, left: 8,
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BuyerViewProductPage(
                    userEmail: widget.userEmail,
                    productId: id is int ? id : int.tryParse('$id'),
                  ),
                )),
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    gradient: _premiumGrad, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 6)],
                  ),
                  child: const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                ),
              ),
            ),
          ]),
        ),
        // ── Info ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
              style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(children: [
              ...List.generate(5, (s) => Icon(
                s < rating.floor() ? Icons.star : (s < rating ? Icons.star_half : Icons.star_border),
                color: _gold, size: 11)),
              const SizedBox(width: 4),
              Text('(${rating.toStringAsFixed(1)})', style: const TextStyle(color: _textLight, fontSize: 10)),
              const Spacer(),
              Text('$sold sold', style: const TextStyle(color: _textLight, fontSize: 10)),
            ]),
            const SizedBox(height: 6),
            Text('₱${price.toStringAsFixed(2)}',
              style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            inStock
              ? GestureDetector(
                  onTap: () => _showBuyNowModal(
                    name: name, price: price,
                    colors: colorList, sizes: sizeList,
                    productId: id is int ? id : int.tryParse('$id') ?? 0,
                    sellerEmail: item['seller_email'] as String? ?? '',
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.bolt, color: _gold, size: 14),
                      SizedBox(width: 4),
                      Text('Buy Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.3)),
                    ]),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(color: const Color(0xFFCED4DA), borderRadius: BorderRadius.circular(12)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.cancel_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Out of Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
          ]),
        ),
      ]),
    );
  }

  void _showBuyNowModal({
    required String name,
    required double price,
    required List<String> colors,
    required List<String> sizes,
    required int productId,
    required String sellerEmail,
  }) {
    String? selectedColor; String? selectedSize; int qty = 1;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.bolt, color: _gold, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text('₱${price.toStringAsFixed(2)}', style: const TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 14),
            if (colors.isNotEmpty) ...[
              const Text('Color', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: colors.map((c) {
                final sel = selectedColor == c;
                return GestureDetector(
                  onTap: () => setS(() => selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: sel ? _goldGrad : null, color: sel ? null : _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? _gold : _border, width: sel ? 2 : 1.5)),
                    child: Text(c, style: TextStyle(color: sel ? _primary : _accent, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 12))),
                );
              }).toList()),
              const SizedBox(height: 12),
            ],
            if (sizes.isNotEmpty) ...[
              const Text('Size', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: sizes.map((s) {
                final sel = selectedSize == s;
                return GestureDetector(
                  onTap: () => setS(() => selectedSize = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: sel ? _goldGrad : null, color: sel ? null : _bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? _gold : _border, width: sel ? 2 : 1.5)),
                    child: Text(s, style: TextStyle(color: sel ? _primary : _accent, fontWeight: sel ? FontWeight.w800 : FontWeight.w600, fontSize: 13))),
                );
              }).toList()),
              const SizedBox(height: 12),
            ],
            const Text('Quantity', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            Row(children: [
              _qtyBtn(Icons.remove, () { if (qty > 1) setS(() => qty--); }),
              Container(width: 48, alignment: Alignment.center,
                child: Text('$qty', style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 16))),
              _qtyBtn(Icons.add, () => setS(() => qty++)),
            ]),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (colors.isNotEmpty && selectedColor == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a color'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                  return;
                }
                if (sizes.isNotEmpty && selectedSize == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a size'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                  return;
                }
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => BuyerCheckoutPage(
                    userEmail: widget.userEmail,
                    items: [CheckoutItem(
                      id: '$productId', name: name, price: price,
                      quantity: qty, color: selectedColor, size: selectedSize,
                    )],
                  ),
                ));
              },
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.bolt, color: _gold, size: 16),
                  SizedBox(width: 8),
                  Text('Proceed to Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                ]),
              ),
            ),
          ]),
        ),
      )),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border), color: Colors.white),
      child: Icon(icon, size: 18, color: _accent),
    ),
  );

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92), shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
      ),
      child: Icon(icon, size: 14, color: _accent),
    ),
  );

  // ─── Seller Section ───────────────────────────────────────────────────────
  Widget _sellerSection() => Container(
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Stack(children: [
      Positioned(top: -30, right: -30,
        child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: _gold.withOpacity(0.07)))),
      Positioned(bottom: -20, left: -20,
        child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
      Padding(
        padding: const EdgeInsets.all(28),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withOpacity(0.3)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.store, color: _gold, size: 15),
              SizedBox(width: 6),
              Text('Become a Seller', style: TextStyle(color: _gold, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.3)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Start Your Premium\nFashion Business',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3, height: 1.2),
            textAlign: TextAlign.center),
          const SizedBox(height: 10),
          const Text('Join our exclusive network of premium fashion sellers. Access our curated marketplace and grow your business.',
            style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 22),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _benefitItem(Icons.bar_chart, 'Growth\nAnalytics'),
            _benefitItem(Icons.people_outline, 'Premium\nCustomers'),
            _benefitItem(Icons.handshake_outlined, 'Business\nSupport'),
          ]),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SellerRegisterPage())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
              decoration: BoxDecoration(
                gradient: _goldGrad,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 6))],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Start Selling Today',
                  style: TextStyle(color: _primary, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.3)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, color: _primary, size: 16),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Quick approval • Professional guidance • Marketing support',
            style: TextStyle(color: Colors.white38, fontSize: 10.5, letterSpacing: 0.2), textAlign: TextAlign.center),
        ]),
      ),
    ]),
  );

  Widget _benefitItem(IconData icon, String label) => Column(children: [
    Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _gold.withOpacity(0.25)),
      ),
      child: Icon(icon, color: _gold, size: 22),
    ),
    const SizedBox(height: 8),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10.5, fontWeight: FontWeight.w500, height: 1.4), textAlign: TextAlign.center),
  ]);

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _sectionTitle(String text) => Column(children: [
    Text(text,
      style: const TextStyle(color: _accent, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      textAlign: TextAlign.center),
    const SizedBox(height: 10),
    Container(
      width: 72, height: 4,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad,
        boxShadow: [BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 8)]),
    ),
  ]);
}
