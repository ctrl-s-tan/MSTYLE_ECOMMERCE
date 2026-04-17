import 'package:flutter/material.dart';
import 'rider_dashboard.dart';
import 'rider_available_deliveries.dart';
import 'rider_active_deliveries.dart';
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

const _premiumGrad = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_primary, _accent]);
const _goldGrad    = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_gold, _goldLight]);

class RiderHistoryDeliveriesPage extends StatefulWidget {
  final String riderEmail;
  const RiderHistoryDeliveriesPage({super.key, required this.riderEmail});
  @override
  State<RiderHistoryDeliveriesPage> createState() => _RiderHistoryDeliveriesPageState();
}

class _RiderHistoryDeliveriesPageState extends State<RiderHistoryDeliveriesPage> {
  String _sortBy = 'newest';
  String _search = '';
  bool _loading = true;
  List<Map<String, dynamic>> _history = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    try {
      final data = await supabase
          .from('orders')
          .select()
          .eq('rider_email', widget.riderEmail)
          .eq('status', 'Completed')
          .order('date', ascending: false);
      if (mounted) setState(() { _history = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _history.where((d) =>
      _search.isEmpty ||
      (d['email'] as String? ?? '').toLowerCase().contains(_search.toLowerCase()) ||
      (d['name'] as String? ?? '').toLowerCase().contains(_search.toLowerCase())).toList();
    if (_sortBy == 'oldest') list = list.reversed.toList();
    if (_sortBy == 'fee_high') list.sort((a, b) => ((b['shipping_fee'] as num?) ?? 0).compareTo((a['shipping_fee'] as num?) ?? 0));
    if (_sortBy == 'fee_low')  list.sort((a, b) => ((a['shipping_fee'] as num?) ?? 0).compareTo((b['shipping_fee'] as num?) ?? 0));
    return list;
  }

  double get _totalEarnings => _history.fold(0.0, (s, d) => s + ((d['shipping_fee'] as num?)?.toDouble() ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: RiderBottomNavBar(riderEmail: widget.riderEmail, currentPage: RiderPage.history),
      body: CustomScrollView(slivers: [
        _appBar(),
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
              (_, i) => _historyCard(_filtered[i]), childCount: _filtered.length)),
          ),
      ]),
    );
  }

  Widget _appBar() => RiderAppBar(riderEmail: widget.riderEmail);

  Widget _pageHeader() => Container(
    width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Row(children: [
      Container(width: 52, height: 52,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)]),
        child: const Icon(Icons.history_outlined, color: _primary, size: 26)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Delivery History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('${_history.length} completed deliveries',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ])),
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
          suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 16, color: _textLight),
            onPressed: () => setState(() { _search = ''; _searchCtrl.clear(); })) : null,
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

  Widget _historyCard(Map<String, dynamic> d) {
    final fee = (d['shipping_fee'] as num?)?.toDouble() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade200)),
          child: Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _border)),
              child: Text('#${d['id']}', style: const TextStyle(color: _textLight, fontSize: 10, fontWeight: FontWeight.w700))),
            const SizedBox(width: 6),
            Expanded(child: Text(d['name'] as String? ?? '',
              style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Text(d['email'] as String? ?? '', style: const TextStyle(color: _textLight, fontSize: 11)),
          Text(d['date'] != null
            ? DateTime.tryParse(d['date'] as String)?.toLocal().toString().split(' ')[0] ?? ''
            : '', style: const TextStyle(color: _textLight, fontSize: 10)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(fee == 0 ? 'Free' : '₱${fee.toStringAsFixed(0)}',
            style: TextStyle(color: fee == 0 ? Colors.teal : Colors.green,
              fontWeight: FontWeight.w900, fontSize: 15)),
          Container(margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
            child: Text(d['status'] as String? ?? 'Completed',
              style: TextStyle(color: Colors.green.shade700, fontSize: 9, fontWeight: FontWeight.w700))),
        ]),
      ]),
    );
  }

  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.history_outlined, size: 72, color: _border),
    const SizedBox(height: 16),
    const Text('No Delivery History', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    const Text('Your completed deliveries will appear here.',
      style: TextStyle(color: _textLight, fontSize: 13)),
  ]));

}
