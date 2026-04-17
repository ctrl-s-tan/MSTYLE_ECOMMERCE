import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'buyer_homepage.dart';
import 'buyer_cart.dart';
import 'buyer_orders.dart';
import 'profile.dart';
import 'buyer_service.dart';

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

// ─── Notification types ───────────────────────────────────────────────────────
enum _NotifType { order, promo, delivery, system }

class _Notif {
  final String id;
  final _NotifType type;
  final String title;
  final String body;
  final String time;
  bool isRead;

  _Notif({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case _NotifType.order:    return Icons.shopping_bag_outlined;
      case _NotifType.promo:    return Icons.local_offer_outlined;
      case _NotifType.delivery: return Icons.local_shipping_outlined;
      case _NotifType.system:   return Icons.info_outline;
    }
  }

  Color get color {
    switch (type) {
      case _NotifType.order:    return Colors.blue;
      case _NotifType.promo:    return _gold;
      case _NotifType.delivery: return Colors.green;
      case _NotifType.system:   return _textLight;
    }
  }

  String get typeLabel {
    switch (type) {
      case _NotifType.order:    return 'Order';
      case _NotifType.promo:    return 'Promo';
      case _NotifType.delivery: return 'Delivery';
      case _NotifType.system:   return 'System';
    }
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class BuyerNotificationsPage extends StatefulWidget {
  final String userEmail;
  const BuyerNotificationsPage({super.key, required this.userEmail});
  @override
  State<BuyerNotificationsPage> createState() => _BuyerNotificationsPageState();
}

class _BuyerNotificationsPageState extends State<BuyerNotificationsPage> {
  String _filter = 'all';
  bool _loading = true;
  List<Map<String, dynamic>> _notifs = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final data = await BuyerService.getNotifications(widget.userEmail);
      if (mounted) setState(() { _notifs = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'all') return _notifs;
    if (_filter == 'unread') return _notifs.where((n) => n['is_read'] == false).toList();
    final typeMap = {
      'order': 'status_update', 'promo': 'promo',
      'delivery': 'delivered', 'system': 'system',
    };
    return _notifs.where((n) => n['type'] == typeMap[_filter]).toList();
  }

  int get _unreadCount => _notifs.where((n) => n['is_read'] == false).length;

  Future<void> _markAllRead() async {
    await BuyerService.markAllNotificationsRead(widget.userEmail);
    await _loadNotifications();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('All notifications marked as read'),
      ]),
      backgroundColor: _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _markRead(Map<String, dynamic> n) async {
    if (n['is_read'] == true) return;
    await BuyerService.markNotificationRead(n['id'] as int);
    setState(() => n['is_read'] = true);
  }

  Future<void> _deleteNotif(Map<String, dynamic> n) async {
    await BuyerService.deleteNotification(n['id'] as int);
    setState(() => _notifs.remove(n));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Notification removed'),
      backgroundColor: _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Helper: map Supabase type to icon/color ────────────────────────────────
  IconData _iconFor(String? type) {
    switch (type) {
      case 'status_update': return Icons.local_shipping_outlined;
      case 'delivered':     return Icons.check_circle_outline;
      case 'promo':         return Icons.local_offer_outlined;
      case 'system':        return Icons.info_outline;
      default:              return Icons.shopping_bag_outlined;
    }
  }

  Color _colorFor(String? type) {
    switch (type) {
      case 'status_update': return Colors.blue;
      case 'delivered':     return Colors.green;
      case 'promo':         return _gold;
      case 'system':        return _textLight;
      default:              return Colors.blue;
    }
  }

  String _labelFor(String? type) {
    switch (type) {
      case 'status_update': return 'Order';
      case 'delivered':     return 'Delivery';
      case 'promo':         return 'Promo';
      case 'system':        return 'System';
      default:              return 'Order';
    }
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '';
    final date = DateTime.tryParse(createdAt);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: _gold))
        : CustomScrollView(
            slivers: [
              _appBar(),
              SliverToBoxAdapter(child: _filterRow()),
              if (_filtered.isEmpty)
                SliverFillRemaining(child: _emptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _notifCard(_filtered[i]),
                      childCount: _filtered.length,
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  SliverAppBar _appBar() => SliverAppBar(
    pinned: true,
    backgroundColor: _primary,
    elevation: 6,
    titleSpacing: 16,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text('Notifications',
      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
    actions: [
      if (_unreadCount > 0)
        TextButton(
          onPressed: _markAllRead,
          child: const Text('Mark all read',
            style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
    ],
  );

  // ─── Page Header ──────────────────────────────────────────────────────────
  Widget _pageHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)],
        ),
        child: const Icon(Icons.notifications_outlined, color: _primary, size: 26),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notifications',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(
          _unreadCount > 0
            ? '$_unreadCount unread notification${_unreadCount != 1 ? 's' : ''}'
            : 'All caught up!',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ])),
    ]),
  );

  // ─── Filter Row ───────────────────────────────────────────────────────────
  Widget _filterRow() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _filterChip('all', 'All'),
        const SizedBox(width: 8),
        _filterChip('unread', 'Unread${_unreadCount > 0 ? ' ($_unreadCount)' : ''}'),
        const SizedBox(width: 8),
        _filterChip('order', 'Orders'),
        const SizedBox(width: 8),
        _filterChip('delivery', 'Delivery'),
        const SizedBox(width: 8),
        _filterChip('promo', 'Promos'),
        const SizedBox(width: 8),
        _filterChip('system', 'System'),
      ]),
    ),
  );

  Widget _filterChip(String value, String label) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? _goldGrad : null,
          color: active ? null : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _gold : _border),
        ),
        child: Text(label, style: TextStyle(
          color: active ? _primary : _textLight,
          fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }

  // ─── Notification Card ────────────────────────────────────────────────────
  Widget _notifCard(Map<String, dynamic> n) {
    final type    = n['type'] as String?;
    final isRead  = n['is_read'] == true;
    final color   = _colorFor(type);
    final icon    = _iconFor(type);
    final label   = _labelFor(type);
    final title   = n['message'] as String? ?? '';
    final time    = _timeAgo(n['created_at'] as String?);

    return Dismissible(
      key: Key('${n['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(14)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => _deleteNotif(n),
      child: GestureDetector(
        onTap: () => _markRead(n),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isRead ? _border : color.withOpacity(0.25), width: isRead ? 1 : 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isRead ? 0.04 : 0.07), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2))),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                Text(time, style: const TextStyle(color: _textLight, fontSize: 10)),
                if (!isRead) ...[
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ],
              ]),
              const SizedBox(height: 6),
              Text(title,
                style: TextStyle(color: _accent, fontWeight: isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 13)),
            ])),
          ]),
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: _bg, shape: BoxShape.circle, border: Border.all(color: _border, width: 2)),
        child: const Icon(Icons.notifications_off_outlined, size: 36, color: _border),
      ),
      const SizedBox(height: 16),
      const Text('No Notifications',
        style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(
        _filter == 'unread' ? 'You have no unread notifications.' : 'Nothing here yet.',
        style: const TextStyle(color: _textLight, fontSize: 13)),
    ]),
  );

}
