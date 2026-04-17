import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'rider_dashboard.dart';
import 'rider_active_deliveries.dart';
import 'rider_history_deliveries.dart';
import 'rider_earnings.dart';
import 'rider_header.dart';
import 'rider_bottom_navbar.dart';
import 'supabase_client.dart';
import 'product_image_carousel.dart' show kFlaskBaseUrl;

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

class RiderAvailableDeliveriesPage extends StatefulWidget {
  final String riderEmail;
  const RiderAvailableDeliveriesPage({super.key, required this.riderEmail});
  @override
  State<RiderAvailableDeliveriesPage> createState() => _RiderAvailableDeliveriesPageState();
}

class _RiderAvailableDeliveriesPageState extends State<RiderAvailableDeliveriesPage> {
  String _sortBy = 'newest';
  String _search = '';
  bool _loading = true;
  List<Map<String, dynamic>> _orders = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAvailable();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailable() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$kFlaskBaseUrl/api/mobile/available_deliveries');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _orders = body['success'] == true
              ? List<Map<String, dynamic>>.from(body['orders'] as List)
              : [];
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('_fetchAvailable error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _orders.where((d) =>
      _search.isEmpty ||
      (d['email'] as String? ?? '').toLowerCase().contains(_search.toLowerCase()) ||
      (d['name'] as String? ?? '').toLowerCase().contains(_search.toLowerCase())).toList();
    if (_sortBy == 'oldest') list = list.reversed.toList();
    if (_sortBy == 'fee_high') list.sort((a, b) => ((b['shipping_fee'] as num?) ?? 0).compareTo((a['shipping_fee'] as num?) ?? 0));
    if (_sortBy == 'fee_low')  list.sort((a, b) => ((a['shipping_fee'] as num?) ?? 0).compareTo((b['shipping_fee'] as num?) ?? 0));
    return list;
  }

  Future<void> _acceptDelivery(Map<String, dynamic> order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Accept Delivery', style: TextStyle(color: _accent, fontWeight: FontWeight.w800)),
        content: Text(
          'Accept order #${order['id']} for ${order['name'] ?? 'this customer'}?\n\n'
          'Delivery fee: ${(order['shipping_fee'] as num?) == 0 ? 'Free' : '₱${(order['shipping_fee'] as num?)?.toStringAsFixed(0)}'}',
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
              child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final uri = Uri.parse('$kFlaskBaseUrl/api/mobile/accept_delivery');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_id': order['id'], 'rider_email': widget.riderEmail}),
      ).timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted) {
        if (body['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Order #${order['id']} accepted!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
          _fetchAvailable();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(body['error'] ?? 'Failed to accept delivery.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to accept delivery. Please try again.'),
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
      bottomNavigationBar: RiderBottomNavBar(riderEmail: widget.riderEmail, currentPage: RiderPage.available),
      body: CustomScrollView(slivers: [
        RiderAppBar(riderEmail: widget.riderEmail),
        SliverToBoxAdapter(child: _pageHeader()),
        SliverToBoxAdapter(child: _filterSection()),
        if (_loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: _gold)))
        else if (_filtered.isEmpty)
          SliverFillRemaining(child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            sliver: SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _orderCard(_filtered[i]),
              childCount: _filtered.length,
            )),
          ),
      ]),
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
        child: const Icon(Icons.list_alt_outlined, color: _primary, size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Available Deliveries', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('${_orders.length} order${_orders.length == 1 ? '' : 's'} waiting for pickup',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ])),
      IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
        onPressed: _fetchAvailable,
      ),
    ]),
  );

  Widget _filterSection() => Container(
    color: Colors.white, padding: const EdgeInsets.all(14),
    child: Column(children: [
      TextField(
        controller: _searchCtrl, style: const TextStyle(color: _accent, fontSize: 13),
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search by customer or product...',
          hintStyle: const TextStyle(color: _textLight, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: _textLight, size: 18),
          suffixIcon: _search.isNotEmpty
            ? IconButton(icon: const Icon(Icons.close, size: 16, color: _textLight),
                onPressed: () => setState(() { _search = ''; _searchCtrl.clear(); }))
            : null,
          filled: true, fillColor: _bg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 2)),
        ),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        value: _sortBy, isExpanded: true,
        style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true, fillColor: _bg,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 2)),
        ),
        items: const [
          DropdownMenuItem(value: 'newest',   child: Text('Newest First')),
          DropdownMenuItem(value: 'oldest',   child: Text('Oldest First')),
          DropdownMenuItem(value: 'fee_high', child: Text('Fee: High to Low')),
          DropdownMenuItem(value: 'fee_low',  child: Text('Fee: Low to High')),
        ],
        onChanged: (v) => setState(() => _sortBy = v ?? 'newest'),
      ),
    ]),
  );

  Widget _orderCard(Map<String, dynamic> d) {
    final fee = (d['shipping_fee'] as num?)?.toDouble() ?? 0;
    final isFree = fee == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
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
              Text(isFree ? 'Free' : '₱${fee.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isFree ? Colors.teal : _gold,
                  fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200)),
                child: Text('Ready', style: TextStyle(
                  color: Colors.orange.shade700, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
        // Body
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
            const SizedBox(height: 14),
            // Accept button
            GestureDetector(
              onTap: () => _acceptDelivery(d),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: _premiumGrad, borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle_outline, size: 16, color: _gold),
                  SizedBox(width: 8),
                  Text('Accept Delivery',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.list_alt_outlined, size: 72, color: _border),
    const SizedBox(height: 16),
    const Text('No Available Deliveries', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('Check back soon for new delivery requests.',
      style: TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
    const SizedBox(height: 20),
    GestureDetector(
      onTap: _fetchAvailable,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.refresh, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ),
    ),
  ]));

}
