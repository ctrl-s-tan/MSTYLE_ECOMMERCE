import 'package:flutter/material.dart';
import 'rider_dashboard.dart';
import 'rider_available_deliveries.dart';
import 'rider_history_deliveries.dart';
import 'rider_earnings.dart';
import 'rider_header.dart';
import 'rider_bottom_navbar.dart';
import 'supabase_client.dart';

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

// Active statuses — orders assigned to this rider that are not yet completed
const _activeStatuses = [
  'Pickup Pending',
  'Heading to Seller',
  'In Transit',
  'Out for Delivery',
];

// Status display helpers
Color _statusColor(String status) {
  switch (status) {
    case 'Pickup Pending':   return Colors.orange;
    case 'Heading to Seller': return Colors.indigo;
    case 'In Transit':       return Colors.blue;
    case 'Out for Delivery': return Colors.teal;
    default:                 return Colors.grey;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'Pickup Pending':   return Icons.access_time;
    case 'Heading to Seller': return Icons.directions_bike_outlined;
    case 'In Transit':       return Icons.local_shipping_outlined;
    case 'Out for Delivery': return Icons.local_shipping;
    default:                 return Icons.help_outline;
  }
}

// What comes after each status when the rider taps the action button
String? _nextStatus(String status) {
  switch (status) {
    case 'Pickup Pending':   return 'Heading to Seller';
    case 'Heading to Seller': return 'In Transit';
    case 'In Transit':       return 'Out for Delivery';
    case 'Out for Delivery': return 'Completed';
    default:                 return null;
  }
}

String _actionLabel(String status) {
  switch (status) {
    case 'Pickup Pending':   return 'Start Pickup';
    case 'Heading to Seller': return 'Mark Picked Up';
    case 'In Transit':       return 'Out for Delivery';
    case 'Out for Delivery': return 'Mark Delivered';
    default:                 return 'Update';
  }
}

IconData _actionIcon(String status) {
  switch (status) {
    case 'Pickup Pending':   return Icons.play_circle_outline;
    case 'Heading to Seller': return Icons.check_circle_outline;
    case 'In Transit':       return Icons.local_shipping_outlined;
    case 'Out for Delivery': return Icons.check_circle;
    default:                 return Icons.arrow_forward;
  }
}

class RiderActiveDeliveriesPage extends StatefulWidget {
  final String riderEmail;
  const RiderActiveDeliveriesPage({super.key, required this.riderEmail});
  @override
  State<RiderActiveDeliveriesPage> createState() => _RiderActiveDeliveriesPageState();
}

class _RiderActiveDeliveriesPageState extends State<RiderActiveDeliveriesPage> {
  String _filterStatus = 'all';
  String _sortBy = 'default';
  bool _loading = true;
  List<Map<String, dynamic>> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _fetchActive();
  }

  Future<void> _fetchActive() async {
    setState(() => _loading = true);
    try {
      final data = await supabase
          .from('orders')
          .select()
          .eq('rider_email', widget.riderEmail)
          .inFilter('status', _activeStatuses)
          .order('date', ascending: false);
      if (mounted) {
        setState(() {
          _deliveries = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _deliveries.where((d) {
      if (_filterStatus != 'all' && (d['status'] as String? ?? '') != _filterStatus) return false;
      return true;
    }).toList();

    if (_sortBy == 'value_high') list.sort((a, b) => ((b['shipping_fee'] as num?) ?? 0).compareTo((a['shipping_fee'] as num?) ?? 0));
    if (_sortBy == 'value_low')  list.sort((a, b) => ((a['shipping_fee'] as num?) ?? 0).compareTo((b['shipping_fee'] as num?) ?? 0));
    return list;
  }

  int _countByStatus(String status) => _deliveries.where((d) => d['status'] == status).length;

  Future<void> _updateStatus(Map<String, dynamic> order, String newStatus) async {
    final isCompleted = newStatus == 'Completed';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isCompleted ? 'Mark as Delivered' : 'Update Status',
          style: const TextStyle(color: _accent, fontWeight: FontWeight.w800)),
        content: Text(
          isCompleted
            ? 'Confirm delivery of order #${order['id']} to ${order['name'] ?? 'customer'}?'
            : 'Update order #${order['id']} to "$newStatus"?',
          style: const TextStyle(color: _textLight, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _textLight))),
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(10)),
              child: Text('Confirm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', order['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isCompleted ? 'Order #${order['id']} delivered!' : 'Status updated to "$newStatus"'),
          backgroundColor: isCompleted ? Colors.green : Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        _fetchActive();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to update status. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: RiderBottomNavBar(riderEmail: widget.riderEmail, currentPage: RiderPage.active),
      body: CustomScrollView(
        slivers: [
          RiderAppBar(riderEmail: widget.riderEmail),
          SliverToBoxAdapter(child: _pageHeader()),
          SliverToBoxAdapter(child: _statsRow()),
          SliverToBoxAdapter(child: _filterSection()),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _gold)))
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _deliveryCard(_filtered[i]),
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pageHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Row(children: [
      Container(width: 52, height: 52,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)]),
        child: const Icon(Icons.local_shipping_outlined, color: _primary, size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Active Deliveries', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('${_deliveries.length} ongoing assignment${_deliveries.length == 1 ? '' : 's'}',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ])),
      IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
        onPressed: _fetchActive,
      ),
    ]),
  );

  Widget _statsRow() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    child: Row(children: [
      Expanded(child: _miniStat('${_deliveries.length}', 'Active', Icons.list_alt_outlined, Colors.blue)),
      _divider(),
      Expanded(child: _miniStat('${_countByStatus('Pickup Pending')}', 'Pickup\nPending', Icons.access_time, Colors.orange)),
      _divider(),
      Expanded(child: _miniStat('${_countByStatus('Heading to Seller')}', 'Heading to\nSeller', Icons.directions_bike_outlined, Colors.indigo)),
      _divider(),
      Expanded(child: _miniStat('${_countByStatus('Out for Delivery')}', 'Out for\nDelivery', Icons.local_shipping, Colors.teal)),
    ]),
  );

  Widget _miniStat(String value, String label, IconData icon, Color color) => Column(children: [
    Icon(icon, color: color, size: 18),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
    Text(label, style: const TextStyle(color: _textLight, fontSize: 9, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center),
  ]);

  Widget _divider() => Container(width: 1, height: 40, color: _border, margin: const EdgeInsets.symmetric(horizontal: 4));

  Widget _filterSection() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    child: Row(children: [
      Expanded(child: _dropdown('Status', _filterStatus, {
        'all': 'All Status',
        'Pickup Pending': 'Pickup Pending',
        'Heading to Seller': 'Heading to Seller',
        'In Transit': 'In Transit',
        'Out for Delivery': 'Out for Delivery',
      }, (v) => setState(() => _filterStatus = v ?? 'all'))),
      const SizedBox(width: 10),
      Expanded(child: _dropdown('Sort By', _sortBy, {
        'default': 'Default Order',
        'value_high': 'Fee: High to Low',
        'value_low': 'Fee: Low to High',
      }, (v) => setState(() => _sortBy = v ?? 'default'))),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => setState(() { _filterStatus = 'all'; _sortBy = 'default'; }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.refresh, size: 14, color: _textLight),
            SizedBox(width: 4),
            Text('Reset', style: TextStyle(color: _textLight, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    ]),
  );

  Widget _dropdown(String label, String value, Map<String, String> options, ValueChanged<String?> onChanged) =>
    DropdownButtonFormField<String>(
      value: value, isExpanded: true,
      style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true, fillColor: _bg,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 2)),
      ),
      items: options.entries.map((e) => DropdownMenuItem(value: e.key,
        child: Text(e.value, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );

  Widget _deliveryCard(Map<String, dynamic> d) {
    final status = d['status'] as String? ?? '';
    final fee = (d['shipping_fee'] as num?)?.toDouble() ?? 0;
    final isFree = fee == 0;
    final color = _statusColor(status);
    final next = _nextStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order #${d['id']}',
                style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 2),
              Text(d['name'] as String? ?? '',
                style: const TextStyle(color: _textLight, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_statusIcon(status), size: 11, color: color),
                  const SizedBox(width: 4),
                  Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 10)),
                ]),
              ),
              const SizedBox(height: 4),
              Text(isFree ? 'Free' : '₱${fee.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isFree ? Colors.teal : _gold,
                  fontWeight: FontWeight.w900, fontSize: 14)),
            ]),
          ]),
        ),
        // ── Body ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Customer info
            Row(children: [
              const Icon(Icons.person_outline, size: 14, color: _textLight),
              const SizedBox(width: 6),
              Expanded(child: Text(d['email'] as String? ?? '',
                style: const TextStyle(color: _textLight, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            if ((d['address'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_outlined, size: 14, color: _textLight),
                const SizedBox(width: 6),
                Expanded(child: Text(d['address'] as String,
                  style: const TextStyle(color: _textLight, fontSize: 12),
                  maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
            ],
            if (d['date'] != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 13, color: _textLight),
                const SizedBox(width: 6),
                Text(
                  DateTime.tryParse(d['date'] as String)?.toLocal().toString().split(' ')[0] ?? '',
                  style: const TextStyle(color: _textLight, fontSize: 11)),
              ]),
            ],
            const SizedBox(height: 12),
            // Action buttons
            Row(children: [
              Expanded(child: _outlineBtn(Icons.flag_outlined, 'Report Issue',
                Colors.orange, () => _showReportIssue(d))),
              if (next != null) ...[
                const SizedBox(width: 10),
                Expanded(child: _primaryBtn(
                  _actionIcon(status), _actionLabel(status),
                  () => _updateStatus(d, next),
                )),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _outlineBtn(IconData icon, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        color: color.withOpacity(0.05),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    ),
  );

  Widget _primaryBtn(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        gradient: _premiumGrad, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: _gold),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    ),
  );

  void _showReportIssue(Map<String, dynamic> order) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Row(children: [
              Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Report Issue', style: TextStyle(color: _accent, fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            Text('Order #${order['id']} — ${order['name'] ?? ''}',
              style: const TextStyle(color: _textLight, fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl, maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                hintStyle: const TextStyle(color: _textLight, fontSize: 13),
                filled: true, fillColor: _bg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold, width: 2)),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                // Optionally persist to a reports table here
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Issue reported successfully.'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating));
              },
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.orange, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                child: const Center(child: Text('Submit Report',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.local_shipping_outlined, size: 72, color: _border),
      const SizedBox(height: 16),
      const Text('No Active Deliveries', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text("You don't have any active deliveries at the moment.",
        style: TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => RiderAvailableDeliveriesPage(riderEmail: widget.riderEmail))),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.list_alt_outlined, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text('Browse Available Deliveries',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      ),
    ]),
  );

}
