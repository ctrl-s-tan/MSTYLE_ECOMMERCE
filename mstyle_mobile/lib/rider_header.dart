import 'package:flutter/material.dart';
import 'rider_notifications.dart';
import 'profile.dart';
import 'supabase_client.dart';

// ─── Theme constants (shared) ─────────────────────────────────────────────────
const Color _primary   = Color(0xFF1a1a1a);
const Color _gold      = Color(0xFFd4af37);
const Color _goldLight = Color(0xFFF4D03F);

const _goldGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_gold, _goldLight],
);

// ─── RiderAppBar ──────────────────────────────────────────────────────────────
// A pinned SliverAppBar that fetches and displays the rider's name + avatar.
// Usage:
//   CustomScrollView(slivers: [
//     RiderAppBar(riderEmail: widget.riderEmail),
//     ...
//   ])
class RiderAppBar extends StatefulWidget {
  final String riderEmail;

  /// Optional extra action widgets placed before the standard icons.
  final List<Widget> extraActions;

  const RiderAppBar({
    super.key,
    required this.riderEmail,
    this.extraActions = const [],
  });

  @override
  State<RiderAppBar> createState() => _RiderAppBarState();
}

class _RiderAppBarState extends State<RiderAppBar> {
  String _riderName = '';

  @override
  void initState() {
    super.initState();
    _fetchRiderName();
  }

  Future<void> _fetchRiderName() async {
    try {
      final res = await supabase
          .from('users')
          .select('first_name, last_name')
          .eq('email', widget.riderEmail)
          .maybeSingle();
      if (res != null && mounted) {
        setState(() {
          _riderName =
              '${res['first_name'] ?? ''} ${res['last_name'] ?? ''}'.trim();
        });
      }
    } catch (_) {}
  }

  String get _initials {
    if (_riderName.isEmpty) return '?';
    return _riderName
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .take(2)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _primary,
      elevation: 6,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(children: [
        // ── Avatar circle ──────────────────────────────────────────────────
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _goldGrad,
            boxShadow: [BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 8)],
          ),
          child: Center(
            child: Text(
              _initials,
              style: const TextStyle(
                color: _primary, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // ── Rider name ─────────────────────────────────────────────────────
        Flexible(
          child: Text(
            _riderName.isNotEmpty ? _riderName : widget.riderEmail,
            style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
      actions: [
        ...widget.extraActions,
        // ── Messages ───────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Messages feature coming soon'),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
        // ── Notifications ──────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RiderNotificationsPage(riderEmail: widget.riderEmail),
            ),
          ),
        ),
        // ── Profile ────────────────────────────────────────────────────────
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(userEmail: widget.riderEmail),
            ),
          ),
        ),
      ],
    );
  }
}
