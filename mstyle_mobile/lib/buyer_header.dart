import 'package:flutter/material.dart';
import 'buyer_notifications.dart';
import 'buyer_cart.dart';
import 'profile.dart';

// ─── Theme constants ──────────────────────────────────────────────────────────
const Color _primary   = Color(0xFF1a1a1a);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);

const _goldGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_gold, _goldLight],
);

// ─── BuyerAppBar ──────────────────────────────────────────────────────────────
/// Shared pinned SliverAppBar for all main buyer pages.
/// Shows the MStyle logo + "Style" title, with notification badge,
/// cart badge, and profile icon in the actions.
///
/// Usage inside a CustomScrollView:
///   BuyerAppBar(userEmail: widget.userEmail, cartCount: _cartCount, notifCount: _notifCount)
class BuyerAppBar extends StatelessWidget {
  final String userEmail;
  final int cartCount;
  final int notifCount;

  const BuyerAppBar({
    super.key,
    required this.userEmail,
    this.cartCount = 0,
    this.notifCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _primary,
      elevation: 6,
      shadowColor: Colors.black45,
      titleSpacing: 12,
      automaticallyImplyLeading: false,
      title: Row(children: [
        // ── Logo ──────────────────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/MStyle Logos/MStyle_logo1.png',
            height: 30, width: 30, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.storefront, color: _gold, size: 26),
          ),
        ),
        const SizedBox(width: 8),
        // ── "Style" text ──────────────────────────────────────────────────
        ShaderMask(
          shaderCallback: (b) => _goldGrad.createShader(b),
          child: const Text(
            'Style',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ]),
      actions: [
        // ── Notifications with badge ───────────────────────────────────────
        Stack(clipBehavior: Clip.none, children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BuyerNotificationsPage(userEmail: userEmail),
              ),
            ),
          ),
          if (notifCount > 0)
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$notifCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ]),
        // ── Cart with badge ────────────────────────────────────────────────
        Stack(clipBehavior: Clip.none, children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerCartPage(userEmail: userEmail),
              ),
            ),
          ),
          if (cartCount > 0)
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ]),
        // ── Profile ────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.person_outline,
              color: Colors.white, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(userEmail: userEmail),
            ),
          ),
        ),
      ],
    );
  }
}
