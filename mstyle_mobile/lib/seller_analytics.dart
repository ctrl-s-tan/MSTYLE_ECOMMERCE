import 'package:flutter/material.dart';
import 'seller_dashboard.dart';
import 'seller_products.dart';
import 'seller_orderlists.dart';
import 'seller_notifications.dart';
import 'profile.dart';
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

// ─── No more mock data needed ─────────────────────────────────────────────────

enum _AnalyticsSection { topProducts, orders, promotions, financial }

class SellerAnalyticsPage extends StatefulWidget {
  final String sellerEmail;
  const SellerAnalyticsPage({super.key, required this.sellerEmail});
  @override
  State<SellerAnalyticsPage> createState() => _SellerAnalyticsPageState();
}

class _SellerAnalyticsPageState extends State<SellerAnalyticsPage> {
  final int _navIndex = 3;
  _AnalyticsSection _section = _AnalyticsSection.topProducts;
  String _search = '';
  String _businessName = '';
  final _searchCtrl = TextEditingController();

  double _totalRevenue  = 0;
  double _netEarnings   = 0;
  int    _totalOrders   = 0;
  double _avgOrderValue = 0;
  bool   _loadingStats  = true;

  // Live section data
  List<Map<String, dynamic>> _topProducts   = [];
  List<Map<String, dynamic>> _orderDetails  = [];
  List<Map<String, dynamic>> _promotions    = [];
  List<Map<String, dynamic>> _financialRows = [];
  bool _loadingSection = true;

  @override
  void initState() {
    super.initState();
    _fetchBusinessName();
    _fetchStats();
    _fetchSectionData();
  }

  Future<void> _fetchBusinessName() async {
    try {
      final res = await supabase
          .from('users')
          .select('business_name')
          .eq('email', widget.sellerEmail)
          .maybeSingle();
      if (mounted && res != null) {
        setState(() => _businessName = res['business_name'] as String? ?? '');
      }
    } catch (_) {}
  }

  Future<void> _fetchStats() async {
    try {
      final orders = await supabase
          .from('orders')
          .select('total_price')
          .eq('seller_email', widget.sellerEmail)
          .eq('status', 'Completed');
      if (!mounted) return;
      final list    = orders as List;
      final revenue = list.fold(0.0, (s, o) => s + ((o['total_price'] as num?)?.toDouble() ?? 0));
      setState(() {
        _totalRevenue  = revenue;
        _netEarnings   = revenue * 0.95;
        _totalOrders   = list.length;
        _avgOrderValue = list.isEmpty ? 0 : revenue / list.length;
        _loadingStats  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _fetchSectionData() async {
    try {
      // Top products: aggregate sold + revenue from orders, join product name
      final prodData = await supabase
          .from('products')
          .select('id, name, quantity, sold, rating')
          .eq('seller_email', widget.sellerEmail)
          .eq('is_active', true)
          .order('sold', ascending: false)
          .limit(10);

      // Orders for analytics tab
      final orderData = await supabase
          .from('orders')
          .select('id, name, quantity, total_price, status, date, email')
          .eq('seller_email', widget.sellerEmail)
          .order('date', ascending: false)
          .limit(20);

      // Promotions
      final promoData = await supabase
          .from('promotions')
          .select('name, type, discount_value, start_date, end_date, current_usage_count, is_active')
          .eq('seller_email', widget.sellerEmail)
          .order('created_at', ascending: false);

      // Financial: completed orders
      final finData = await supabase
          .from('orders')
          .select('id, name, total_price, shipping_fee, date')
          .eq('seller_email', widget.sellerEmail)
          .eq('status', 'Completed')
          .order('date', ascending: false)
          .limit(20);

      if (!mounted) return;

      final products = prodData as List;
      final orders   = orderData as List;
      final promos   = promoData as List;
      final fin      = finData as List;

      setState(() {
        _topProducts = products.asMap().entries.map((e) => {
          'rank':    e.key + 1,
          'name':    e.value['name'] ?? '',
          'sold':    (e.value['sold'] as num?)?.toInt() ?? 0,
          'revenue': ((e.value['sold'] as num?)?.toDouble() ?? 0) * 0,
          'stock':   (e.value['quantity'] as num?)?.toInt() ?? 0,
          'rating':  (e.value['rating'] as num?)?.toDouble() ?? 0.0,
          'reviews': 0,
        }).toList();

        _orderDetails = orders.map((o) => {
          'product':   o['name'] ?? '',
          'qty':       (o['quantity'] as num?)?.toInt() ?? 1,
          'status':    o['status'] ?? '',
          'orderDate': o['date'] != null
              ? DateTime.parse(o['date']).toLocal().toString().split(' ')[0]
              : '',
          'amount':    (o['total_price'] as num?)?.toDouble() ?? 0.0,
          'buyer':     o['email'] ?? '',
        }).toList();

        _promotions = promos.map((p) {
          final isActive = p['is_active'] as bool? ?? false;
          final endDate  = p['end_date'] != null ? DateTime.tryParse(p['end_date']) : null;
          final ended    = endDate != null && endDate.isBefore(DateTime.now());
          return {
            'name':     p['name'] ?? '',
            'type':     p['type'] ?? '',
            'discount': p['discount_value'] != null ? '₱${p['discount_value']}' : '-',
            'start':    p['start_date'] ?? '',
            'end':      p['end_date'] ?? '',
            'uses':     (p['current_usage_count'] as num?)?.toInt() ?? 0,
            'revenue':  0.0,
            'status':   (!isActive || ended) ? 'ended' : 'active',
          };
        }).toList();

        _financialRows = fin.map((f) {
          final total      = (f['total_price'] as num?)?.toDouble() ?? 0;
          final shipping   = (f['shipping_fee'] as num?)?.toDouble() ?? 50;
          final commission = total * 0.05;
          final earnings   = total - commission;
          return {
            'orderId':  f['id'],
            'date':     f['date'] != null
                ? DateTime.parse(f['date']).toLocal().toString().split(' ')[0]
                : '',
            'product':  f['name'] ?? '',
            'sales':    total,
            'discount': 0.0,
            'netSales': total,
            'shipping': shipping,
            'commission': commission,
            'earnings': earnings,
          };
        }).toList();

        _loadingSection = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingSection = false);
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: _bottomNav(),
      body: CustomScrollView(
        slivers: [
          _appBar(),
          SliverToBoxAdapter(child: _pageHeader()),
          SliverToBoxAdapter(child: _statsCards()),
          SliverToBoxAdapter(child: _filterBar()),
          SliverToBoxAdapter(child: _sectionTabs()),
          SliverToBoxAdapter(child: _sectionContent()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
    automaticallyImplyLeading: false,
    title: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.3), blurRadius: 6)],
        ),
        child: const Icon(Icons.store, color: _primary, size: 18),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: ShaderMask(
          shaderCallback: (b) => _goldGrad.createShader(b),
          child: Text(
            _businessName.isNotEmpty ? _businessName : widget.sellerEmail.split('@').first,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ]),
    actions: [
      IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SellerNotificationsPage(sellerEmail: widget.sellerEmail)))),
      IconButton(
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Messages coming soon'), behavior: SnackBarBehavior.floating)),
      ),
      IconButton(
        icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProfilePage(userEmail: widget.sellerEmail))),
      ),
    ],
  );

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
        child: const Icon(Icons.bar_chart_outlined, color: _primary, size: 26),
      ),
      const SizedBox(height: 12),
      const Text('Reports & Analytics',
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text('Track your business performance and insights',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
    ]),
  );

  // ─── Stats Cards ──────────────────────────────────────────────────────────
  Widget _statsCards() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
    child: _loadingStats
      ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: _gold)))
      : Column(children: [
          Row(children: [
            Expanded(child: _statCard('₱${_totalRevenue.toStringAsFixed(0)}', 'Total Revenue', Icons.currency_exchange, Colors.blue, 'Completed orders')),
            const SizedBox(width: 12),
            Expanded(child: _statCard('₱${_netEarnings.toStringAsFixed(0)}', 'Net Earnings', Icons.account_balance_wallet, Colors.green, 'After 5% platform fee')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('$_totalOrders', 'Total Orders', Icons.shopping_bag_outlined, _gold, 'Completed orders')),
            const SizedBox(width: 12),
            Expanded(child: _statCard('₱${_avgOrderValue.toStringAsFixed(0)}', 'Avg Order Value', Icons.trending_up, Colors.purple, 'Per completed order')),
          ]),
        ]),
  );

  Widget _statCard(String value, String label, IconData icon, Color color, String desc) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: _accent, fontWeight: FontWeight.w900, fontSize: 16),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 11)),
        Text(desc, style: const TextStyle(color: _textLight, fontSize: 10)),
      ])),
    ]),
  );

  // ─── Filter Bar ───────────────────────────────────────────────────────────
  Widget _filterBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
    child: Column(children: [
      Row(children: [
        const Icon(Icons.tune, color: _gold, size: 16),
        const SizedBox(width: 6),
        const Text('Filter & Search Reports', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
        const Spacer(),
        // Export button
        GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Export feature — connect to backend'), behavior: SnackBarBehavior.floating)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.file_download_outlined, size: 13, color: Colors.green.shade600),
              const SizedBox(width: 4),
              Text('Export', style: TextStyle(color: Colors.green.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: _accent, fontSize: 13),
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search products, orders, buyers...',
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
    ]),
  );

  // ─── Section Tabs ─────────────────────────────────────────────────────────
  Widget _sectionTabs() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _tab(_AnalyticsSection.topProducts, Icons.emoji_events_outlined, 'Top Products'),
        const SizedBox(width: 8),
        _tab(_AnalyticsSection.orders, Icons.bar_chart_outlined, 'Orders'),
        const SizedBox(width: 8),
        _tab(_AnalyticsSection.promotions, Icons.local_offer_outlined, 'Promotions'),
        const SizedBox(width: 8),
        _tab(_AnalyticsSection.financial, Icons.account_balance_outlined, 'Financial'),
      ]),
    ),
  );

  Widget _tab(_AnalyticsSection s, IconData icon, String label) {
    final active = _section == s;
    return GestureDetector(
      onTap: () => setState(() => _section = s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? _goldGrad : null,
          color: active ? null : _bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? _gold : _border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: active ? _primary : _textLight),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: active ? _primary : _textLight,
            fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }

  // ─── Section Content ──────────────────────────────────────────────────────
  Widget _sectionContent() {
    if (_loadingSection) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }
    switch (_section) {
      case _AnalyticsSection.topProducts:  return _topProductsSection();
      case _AnalyticsSection.orders:       return _ordersSection();
      case _AnalyticsSection.promotions:   return _promotionsSection();
      case _AnalyticsSection.financial:    return _financialSection();
    }
  }

  // ─── Top Products ─────────────────────────────────────────────────────────
  Widget _topProductsSection() {
    final filtered = _topProducts.where((p) =>
      _search.isEmpty || (p['name'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

    return _sectionCard(
      title: 'Top Selling Products',
      icon: Icons.emoji_events_outlined,
      child: filtered.isEmpty ? _emptySearch() : Column(
        children: filtered.asMap().entries.map((e) {
          final p = e.value;
          final stock = p['stock'] as int;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
            child: Row(children: [
              // Rank
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: e.key < 3 ? _goldGrad : null,
                  color: e.key >= 3 ? _border : null,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('${p['rank']}',
                  style: TextStyle(color: e.key < 3 ? _primary : _textLight,
                    fontWeight: FontWeight.w800, fontSize: 11))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['name'] as String, style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  _miniChip('${p['sold']} sold', Colors.blue),
                  const SizedBox(width: 6),
                  _miniChip('₱${(p['revenue'] as double).toStringAsFixed(0)}', Colors.green),
                  const SizedBox(width: 6),
                  _miniChip(stock <= 0 ? 'Out of Stock' : stock <= 5 ? 'Low: $stock' : 'Stock: $stock',
                    stock <= 0 ? Colors.red : stock <= 5 ? Colors.orange : Colors.teal),
                ]),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  const Icon(Icons.star, color: _gold, size: 12),
                  const SizedBox(width: 3),
                  Text('${p['rating']}', style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
                Text('(${p['reviews']})', style: const TextStyle(color: _textLight, fontSize: 10)),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ─── Orders Analytics ─────────────────────────────────────────────────────
  Widget _ordersSection() {
    final filtered = _orderDetails.where((o) =>
      _search.isEmpty ||
      (o['product'] as String).toLowerCase().contains(_search.toLowerCase()) ||
      (o['buyer'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

    return _sectionCard(
      title: 'Orders Analytics',
      icon: Icons.bar_chart_outlined,
      badge: '${filtered.length} orders',
      child: filtered.isEmpty ? _emptySearch() : Column(
        children: filtered.asMap().entries.map((e) {
          final o = e.value;
          final status = o['status'] as String;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text('${e.key + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(o['product'] as String,
                  style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                _statusBadge(status),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _detailItem(Icons.person_outline, o['buyer'] as String),
                const SizedBox(width: 12),
                _detailItem(Icons.inventory_2_outlined, 'Qty: ${o['qty']}'),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                _detailItem(Icons.calendar_today_outlined, o['orderDate'] as String),
                const Spacer(),
                Text('₱${(o['amount'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(color: _accent, fontWeight: FontWeight.w900, fontSize: 14)),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ─── Promotions ───────────────────────────────────────────────────────────
  Widget _promotionsSection() {
    final filtered = _promotions.where((p) =>
      _search.isEmpty || (p['name'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

    return _sectionCard(
      title: 'Promotion Performance',
      icon: Icons.local_offer_outlined,
      child: filtered.isEmpty ? _emptySearch() : Column(
        children: filtered.map((p) {
          final status = p['status'] as String;
          Color statusColor = status == 'active' ? Colors.green : status == 'ended' ? _textLight : Colors.red;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(p['name'] as String,
                  style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3))),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _miniChip(p['type'] as String, Colors.blue),
                const SizedBox(width: 6),
                _miniChip(p['discount'] as String, Colors.orange),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                _detailItem(Icons.calendar_today_outlined, '${p['start']} – ${p['end']}'),
                const Spacer(),
                _miniChip('${p['uses']} uses', Colors.purple),
                const SizedBox(width: 6),
                Text('₱${(p['revenue'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800, fontSize: 13)),
              ]),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ─── Financial Summary ────────────────────────────────────────────────────
  Widget _financialSection() {
    final filtered = _financialRows.where((f) =>
      _search.isEmpty || (f['product'] as String).toLowerCase().contains(_search.toLowerCase())).toList();

    final totalEarnings = filtered.fold(0.0, (s, f) => s + (f['earnings'] as double));

    return _sectionCard(
      title: 'Financial Summary',
      icon: Icons.account_balance_outlined,
      badge: '${filtered.length} transactions',
      child: filtered.isEmpty ? _emptySearch() : Column(children: [
        ...filtered.asMap().entries.map((e) {
          final f = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('#${f['orderId']}', style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 10)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(f['product'] as String,
                  style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 8),
              _detailItem(Icons.calendar_today_outlined, f['date'] as String),
              const SizedBox(height: 8),
              // Financial breakdown
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: _border)),
                child: Column(children: [
                  _finRow('Product Sales', '₱${(f['sales'] as double).toStringAsFixed(2)}', Colors.green),
                  _finRow('Discounts', '-₱${(f['discount'] as double).toStringAsFixed(2)}', Colors.red),
                  _finRow('Net Sales', '₱${(f['netSales'] as double).toStringAsFixed(2)}', Colors.blue),
                  _finRow('Shipping Fee', '₱${(f['shipping'] as double).toStringAsFixed(2)}', Colors.teal),
                  _finRow('Platform Fee (5%)', '-₱${(f['commission'] as double).toStringAsFixed(2)}', Colors.orange),
                  const Divider(height: 12),
                  _finRow('Net Earnings', '₱${(f['earnings'] as double).toStringAsFixed(2)}', Colors.green, bold: true),
                ]),
              ),
            ]),
          );
        }),
        // Total summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total Net Earnings', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
            ShaderMask(
              shaderCallback: (b) => _goldGrad.createShader(b),
              child: Text('₱${totalEarnings.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _finRow(String label, String value, Color color, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: _textLight, fontSize: 11)),
      Text(value, style: TextStyle(color: color, fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontSize: bold ? 13 : 11)),
    ]),
  );

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _sectionCard({required String title, required IconData icon, required Widget child, String? badge}) =>
    Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: _gold, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w800)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(10)),
              child: Text(badge, style: const TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        const SizedBox(height: 4),
        Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
        const SizedBox(height: 14),
        child,
      ]),
    );

  Widget _miniChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );

  Widget _detailItem(IconData icon, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: _textLight),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: _textLight, fontSize: 11)),
  ]);

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':   color = Colors.orange; break;
      case 'confirmed': color = Colors.blue; break;
      case 'shipped':   color = Colors.teal; break;
      case 'delivered': color = Colors.green.shade600; break;
      case 'completed': color = Colors.green; break;
      case 'rejected':  color = Colors.red; break;
      default:          color = _textLight;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _emptySearch() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        const Icon(Icons.search_off, size: 48, color: _border),
        const SizedBox(height: 8),
        const Text('No results found', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() { _search = ''; _searchCtrl.clear(); }),
          child: const Text('Clear search', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
  Widget _bottomNav() => Container(
    decoration: BoxDecoration(
      color: _primary,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, -4))],
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(children: [
          _navItem(0, Icons.speed, Icons.speed, 'Dashboard'),
          _navItem(1, Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
          _navItem(2, Icons.list_alt_outlined, Icons.list_alt, 'Orders'),
          _navItem(3, Icons.bar_chart_outlined, Icons.bar_chart, 'Analytics'),
        ]),
      ),
    ),
  );

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final active = _navIndex == index;
    return Expanded(
      child: GestureDetector(
      onTap: () {
        if (index == 0) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => SellerDashboardPage(sellerEmail: widget.sellerEmail)));
        if (index == 1) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => SellerProductsPage(sellerEmail: widget.sellerEmail)));
        if (index == 2) Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => SellerOrderListsPage(sellerEmail: widget.sellerEmail)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(active ? activeIcon : icon, color: active ? _gold : Colors.white54, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(
            color: active ? _gold : Colors.white54,
            fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ]),
      ),
    ),
  );
  }
}
