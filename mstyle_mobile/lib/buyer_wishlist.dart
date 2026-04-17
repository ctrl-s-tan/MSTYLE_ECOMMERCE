import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'buyer_homepage.dart';
import 'buyer_cart.dart';
import 'buyer_orders.dart';
import 'profile.dart';
import 'buyer_notifications.dart';
import 'buyer_service.dart';
import 'supabase_client.dart';
import 'buyer_header.dart';
import 'buyer_bottom_navbar.dart';

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

class WishlistItem {
  final String id;
  final String name;
  final double price;
  final double? salePrice;
  bool inWishlist;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    this.salePrice,
    this.inWishlist = true,
  });
}

class BuyerWishlistPage extends StatefulWidget {
  final String userEmail;
  const BuyerWishlistPage({super.key, required this.userEmail});
  @override
  State<BuyerWishlistPage> createState() => _BuyerWishlistPageState();
}

class _BuyerWishlistPageState extends State<BuyerWishlistPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _loading = true);
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid != null) {
        final data = await BuyerService.getWishlist(uid);
        if (mounted) setState(() { _items = data; _loading = false; });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    final productId = item['product_id'] as int?;
    if (productId == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove from Wishlist',
          style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Remove this item from your wishlist?',
          style: const TextStyle(color: _textLight, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await BuyerService.removeFromWishlist(uid, productId);
              await _loadWishlist();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    final name = product?['name'] as String? ?? 'Item';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('"$name" added to cart'),
      backgroundColor: _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: SnackBarAction(
        label: 'View Cart',
        textColor: _gold,
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => BuyerCartPage(userEmail: widget.userEmail))),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: BuyerBottomNavBar(userEmail: widget.userEmail, currentPage: BuyerPage.wishlist),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: _gold))
        : CustomScrollView(
            slivers: [
              BuyerAppBar(userEmail: widget.userEmail),
              SliverToBoxAdapter(child: _header()),
              if (_items.isEmpty)
                SliverFillRemaining(child: _emptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _productCard(_items[i]),
                      childCount: _items.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.68,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _header() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 16)],
        ),
        child: const Icon(Icons.favorite, color: _primary, size: 30),
      ),
      const SizedBox(height: 14),
      const Text('My Wishlist',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      const SizedBox(height: 6),
      Text('Save your favorite items for later',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
    ]),
  );

  Widget _productCard(Map<String, dynamic> item) {
    final product   = item['products'] as Map<String, dynamic>?;
    final name      = product?['name'] as String? ?? 'Product';
    final price     = double.tryParse(product?['price']?.toString() ?? '0') ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFECEFF1), Color(0xFFE9ECEF)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: const Center(child: Icon(Icons.image_outlined, size: 48, color: Color(0xFFADB5BD))),
            ),
            Positioned(bottom: 8, right: 8,
              child: Row(children: [
                _overlayBtn(Icons.visibility_outlined, () {}),
                const SizedBox(width: 6),
                _overlayBtn(Icons.favorite, () => _removeItem(item), color: Colors.red.shade400),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Text('₱${price.toStringAsFixed(2)}',
              style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _addToCart(item),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _overlayBtn(IconData icon, VoidCallback onTap, {Color? color}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92), shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6)],
      ),
      child: Icon(icon, size: 14, color: color ?? _accent),
    ),
  );

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.favorite_border, size: 80, color: _border),
      const SizedBox(height: 20),
      const Text('Your wishlist is empty',
        style: TextStyle(color: _accent, fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text("You haven't added any items yet.",
        style: TextStyle(color: _textLight, fontSize: 13)),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => BuyerHomePage(userEmail: widget.userEmail)), (_) => false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
          child: const Text('Continue Shopping',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ),
    ]),
  );

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(width: 64, height: 64,
            decoration: const BoxDecoration(gradient: _premiumGrad, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: Colors.white, size: 32)),
          const SizedBox(height: 12),
          Text(widget.userEmail,
            style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person_outline, color: _accent, size: 20),
            title: const Text('My Profile', style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: _textLight, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            onTap: () => Navigator.pop(context)),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined, color: _accent, size: 20),
            title: const Text('My Orders', style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, color: _textLight, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BuyerOrdersPage(userEmail: widget.userEmail)));
            }),
          const Divider(height: 24),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400, size: 20),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600, fontSize: 14)),
            trailing: Icon(Icons.chevron_right, color: Colors.red.shade300, size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
            }),
        ]),
      ),
    );
  }
}
