import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'buyer_homepage.dart';
import 'buyer_cart.dart';
import 'buyer_orders.dart';
import 'profile.dart';
import 'buyer_service.dart';
import 'notification_service.dart';
import 'supabase_client.dart' show supabase;

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
  RealtimeChannel? _channel;

  // ── Selection mode ──────────────────────────────────────────────────────
  bool _selecting = false;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _loadNotifications();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _subscribeRealtime() {
    _channel = supabase
        .channel('buyer_notifs_${widget.userEmail}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'buyer_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'buyer_email',
            value: widget.userEmail,
          ),
          callback: (payload) async {
            final row = payload.newRecord;
            if (row.isNotEmpty) {
              final msg = row['message'] as String? ?? 'You have a new notification';
              await NotificationService.show(
                id: (row['id'] as int?) ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'MStyle Order Update',
                body: msg,
              );
              if (mounted) await _loadNotifications();
            }
          },
        )
        .subscribe();
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

  // ── Selection helpers ────────────────────────────────────────────────────
  void _enterSelection(int id) {
    setState(() {
      _selecting = true;
      _selected.add(id);
    });
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _selecting = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selected.addAll(_filtered.map((n) => n['id'] as int));
    });
  }

  Future<void> _deleteSelected() async {
    final ids = List<int>.from(_selected);
    for (final id in ids) {
      await BuyerService.deleteNotification(id);
    }
    setState(() {
      _notifs.removeWhere((n) => ids.contains(n['id'] as int));
      _selecting = false;
      _selected.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${ids.length} notification${ids.length != 1 ? 's' : ''} deleted'),
      backgroundColor: _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

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

  // ── Helpers ──────────────────────────────────────────────────────────────
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
    return WillPopScope(
      onWillPop: () async {
        if (_selecting) { _exitSelection(); return false; }
        return true;
      },
      child: Scaffold(
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
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  SliverAppBar _appBar() {
    if (_selecting) {
      final allSelected = _selected.length == _filtered.length && _filtered.isNotEmpty;
      return SliverAppBar(
        pinned: true,
        backgroundColor: _primary,
        elevation: 6,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _exitSelection,
        ),
        title: Text('${_selected.length} selected',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: allSelected ? _exitSelection : _selectAll,
            child: Text(allSelected ? 'Deselect all' : 'Select all',
              style: const TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          if (_selected.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete selected',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Delete notifications',
                      style: TextStyle(color: _accent, fontWeight: FontWeight.w700)),
                    content: Text('Delete ${_selected.length} notification${_selected.length != 1 ? 's' : ''}?',
                      style: const TextStyle(color: _textLight)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: _textLight))),
                      TextButton(onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700))),
                    ],
                  ),
                );
                if (confirm == true) await _deleteSelected();
              },
            ),
        ],
      );
    }

    return SliverAppBar(
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
  }

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
    final id      = n['id'] as int;
    final type    = n['type'] as String?;
    final isRead  = n['is_read'] == true;
    final color   = _colorFor(type);
    final icon    = _iconFor(type);
    final label   = _labelFor(type);
    final message = n['message'] as String? ?? '';
    final time    = _timeAgo(n['created_at'] as String?);
    final isChecked = _selected.contains(id);

    return GestureDetector(
      onLongPress: () => _selecting ? null : _enterSelection(id),
      onTap: () {
        if (_selecting) {
          _toggleSelect(id);
        } else {
          _markRead(n);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isChecked
            ? _gold.withOpacity(0.08)
            : isRead ? Colors.white : color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isChecked
              ? _gold
              : isRead ? _border : color.withOpacity(0.25),
            width: isChecked ? 1.5 : isRead ? 1 : 1.5,
          ),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(isRead ? 0.04 : 0.07),
            blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Checkbox in selection mode, icon otherwise
          if (_selecting)
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? _gold : Colors.transparent,
                  border: Border.all(color: isChecked ? _gold : _border, width: 2),
                ),
                child: isChecked
                  ? const Icon(Icons.check, size: 14, color: _primary)
                  : null,
              ),
            )
          else
            Container(
              width: 44, height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12), shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2))),
              child: Icon(icon, color: color, size: 20),
            ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(label, style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Text(time, style: const TextStyle(color: _textLight, fontSize: 10)),
              if (!isRead && !_selecting) ...[
                const SizedBox(width: 6),
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              ],
            ]),
            const SizedBox(height: 6),
            Text(message,
              style: TextStyle(
                color: _accent,
                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                fontSize: 13)),
          ])),
        ]),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: _bg, shape: BoxShape.circle,
          border: Border.all(color: _border, width: 2)),
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
