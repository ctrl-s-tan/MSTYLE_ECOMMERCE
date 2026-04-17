import 'package:flutter/material.dart';
import 'home_page.dart';
import 'rider_available_deliveries.dart';
import 'rider_active_deliveries.dart';
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

class RiderDashboardPage extends StatefulWidget {
  final String riderEmail;
  const RiderDashboardPage({super.key, required this.riderEmail});
  @override
  State<RiderDashboardPage> createState() => _RiderDashboardPageState();
}

class _RiderDashboardPageState extends State<RiderDashboardPage> {
  int    _availableCount = 0;
  int    _activeCount    = 0;
  double _totalEarnings  = 0;
  bool   _loadingStats   = true;
  List<Map<String, dynamic>> _recentHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final available = await supabase
          .from('orders')
          .select('id')
          .inFilter('status', ['Confirmed', 'For Pickup'])
          .isFilter('rider_email', null);

      final active = await supabase
          .from('orders')
          .select('id')
          .eq('rider_email', widget.riderEmail)
          .inFilter('status', ['Heading to Seller', 'Shipped', 'Out for Delivery']);

      final completed = await supabase
          .from('orders')
          .select('shipping_fee')
          .eq('rider_email', widget.riderEmail)
          .eq('status', 'Completed');

      final history = await supabase
          .from('orders')
          .select('id, name, email, shipping_fee, date, status')
          .eq('rider_email', widget.riderEmail)
          .eq('status', 'Completed')
          .order('date', ascending: false)
          .limit(2);

      if (!mounted) return;

      final earnings = (completed as List).fold(0.0,
          (s, o) => s + ((o['shipping_fee'] as num?)?.toDouble() ?? 0));

      setState(() {
        _availableCount = (available as List).length;
        _activeCount    = (active as List).length;
        _totalEarnings  = earnings;
        _recentHistory  = List<Map<String, dynamic>>.from(history as List);
        _loadingStats   = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: RiderBottomNavBar(riderEmail: widget.riderEmail, currentPage: RiderPage.dashboard),
      body: CustomScrollView(slivers: [
        RiderAppBar(riderEmail: widget.riderEmail),
        SliverToBoxAdapter(child: _pageHeader()),
        SliverToBoxAdapter(child: _statsGrid()),
        SliverToBoxAdapter(child: _recentSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }

  // ─── Page Header ──────────────────────────────────────────────────────────
  Widget _pageHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    decoration: const BoxDecoration(gradient: _premiumGrad),
    child: Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)]),
        child: const Icon(Icons.speed, color: _primary, size: 26),
      ),
      const SizedBox(height: 12),
      const Text('Rider Dashboard',
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text('Track your deliveries and earnings',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
    ]),
  );

  // ─── Stats Grid ───────────────────────────────────────────────────────────
  Widget _statsGrid() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
    child: _loadingStats
      ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: _gold)))
      : Row(children: [
          Expanded(child: _statCard('$_availableCount', 'Available\nDeliveries', Icons.list_alt_outlined, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('$_activeCount', 'Active\nDeliveries', Icons.local_shipping_outlined, Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('₱${_totalEarnings.toStringAsFixed(0)}', 'Total\nEarnings', Icons.currency_exchange, Colors.green)),
        ]),
  );

  Widget _statCard(String value, String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(color: _accent, fontWeight: FontWeight.w900, fontSize: 18)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: _textLight, fontSize: 10, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center),
    ]),
  );

  // ─── Recent Section ───────────────────────────────────────────────────────
  Widget _recentSection() => Container(
    margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.history_outlined, color: _gold, size: 16),
        const SizedBox(width: 6),
        const Text('Recent Deliveries', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => RiderHistoryDeliveriesPage(riderEmail: widget.riderEmail))),
          child: const Text('See all', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 12),
      if (_recentHistory.isEmpty)
        const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No completed deliveries yet', style: TextStyle(color: _textLight, fontSize: 12)),
        ))
      else
        ..._recentHistory.map((d) => _historyTile(d)),
    ]),
  );

  Widget _historyTile(Map<String, dynamic> d) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _bg, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle,
          border: Border.all(color: Colors.green.shade200)),
        child: Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(d['name'] as String? ?? '',
          style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(d['email'] as String? ?? '',
          style: const TextStyle(color: _textLight, fontSize: 10)),
      ])),
      Text('₱${((d['shipping_fee'] as num?)?.toStringAsFixed(0)) ?? '0'}',
        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  );

}
