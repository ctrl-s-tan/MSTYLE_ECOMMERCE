import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login.dart';
import 'seller_products.dart';
import 'seller_add_product.dart';
import 'seller_orderlists.dart';
import 'seller_analytics.dart';
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

class SellerDashboardPage extends StatefulWidget {
  final String sellerEmail;
  const SellerDashboardPage({super.key, required this.sellerEmail});
  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  int _navIndex = 0;
  String _businessName = '';

  // Stats
  double _totalSales    = 0;
  double _totalEarnings = 0;
  int    _itemsSold     = 0;
  double _avgOrderValue = 0;
  int    _totalProducts = 0;
  bool   _loadingStats  = true;

  // Charts
  List<Map<String, dynamic>> _orderStatusData = [];
  List<double> _monthlySales = [];
  bool _loadingCharts = true;

  @override
  void initState() {
    super.initState();
    _fetchBusinessName();
    _fetchStats();
    _fetchChartData();
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
      // Completed orders
      final orders = await supabase
          .from('orders')
          .select('total_price, quantity')
          .eq('seller_email', widget.sellerEmail)
          .eq('status', 'Completed');

      // All orders for sold count
      final allOrders = await supabase
          .from('orders')
          .select('quantity')
          .eq('seller_email', widget.sellerEmail);

      // Product count
      final products = await supabase
          .from('products')
          .select('id')
          .eq('seller_email', widget.sellerEmail)
          .eq('is_active', true);

      if (!mounted) return;

      final completedList = orders as List;
      final allList       = allOrders as List;
      final productList   = products as List;

      final sales   = completedList.fold(0.0, (s, o) => s + ((o['total_price'] as num?)?.toDouble() ?? 0));
      final sold    = allList.fold(0, (s, o) => s + ((o['quantity'] as num?)?.toInt() ?? 0));
      final avg     = completedList.isEmpty ? 0.0 : sales / completedList.length;
      // 5% platform fee
      final earnings = sales * 0.95;

      setState(() {
        _totalSales    = sales;
        _totalEarnings = earnings;
        _itemsSold     = sold;
        _avgOrderValue = avg;
        _totalProducts = productList.length;
        _loadingStats  = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _fetchChartData() async {
    try {
      // Order status distribution
      final allOrders = await supabase
          .from('orders')
          .select('status')
          .eq('seller_email', widget.sellerEmail);

      // Monthly sales (last 12 months)
      final now = DateTime.now();
      final monthlySales = <double>[];
      for (int i = 11; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final nextMonth = DateTime(now.year, now.month - i + 1, 1);
        final orders = await supabase
            .from('orders')
            .select('total_price')
            .eq('seller_email', widget.sellerEmail)
            .eq('status', 'Completed')
            .gte('date', month.toIso8601String())
            .lt('date', nextMonth.toIso8601String());
        final total = (orders as List).fold(0.0, (s, o) => s + ((o['total_price'] as num?)?.toDouble() ?? 0));
        monthlySales.add(total);
      }

      if (!mounted) return;

      // Count by status
      final statusMap = <String, int>{};
      for (final o in allOrders as List) {
        final status = o['status'] as String? ?? 'Pending';
        statusMap[status] = (statusMap[status] ?? 0) + 1;
      }

      final statusColors = {
        'Pending':   const Color(0xFFFF9800),
        'Confirmed': const Color(0xFF2196F3),
        'For Pickup': const Color(0xFF9C27B0),
        'Shipped':   const Color(0xFF3F51B5),
        'Delivered': const Color(0xFF8BC34A),
        'Completed': const Color(0xFF4CAF50),
        'Cancelled': const Color(0xFFF44336),
      };

      setState(() {
        _orderStatusData = statusMap.entries.map((e) => {
          'label': e.key,
          'value': e.value,
          'color': statusColors[e.key] ?? const Color(0xFF6c757d),
        }).toList();
        _monthlySales = monthlySales;
        _loadingCharts = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingCharts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: _bottomNav(),
      body: CustomScrollView(
        slivers: [
          _appBar(),
          SliverToBoxAdapter(child: _statsGrid()),
          SliverToBoxAdapter(child: _salesChart()),
          SliverToBoxAdapter(child: _orderStatusChart()),
          SliverToBoxAdapter(child: _quickActions()),
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
      IconButton(
        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => SellerNotificationsPage(sellerEmail: widget.sellerEmail))),
      ),
      IconButton(
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
        onPressed: _showMessages,
      ),
      IconButton(
        icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProfilePage(userEmail: widget.sellerEmail))),
      ),
    ],
  );

  // ─── Dashboard Header ─────────────────────────────────────────────────────
  Widget _dashboardHeader() => Container(
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
        child: const Icon(Icons.speed, color: _primary, size: 30),
      ),
      const SizedBox(height: 14),
      const Text('Seller Dashboard',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      const SizedBox(height: 6),
      Text('Overview of your store performance',
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
    ]),
  );

  // ─── Stats Grid ───────────────────────────────────────────────────────────
  Widget _statsGrid() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
    child: _loadingStats
      ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: _gold)))
      : Column(children: [
          Row(children: [
            Expanded(child: _statCard('₱${_totalSales.toStringAsFixed(0)}', 'Total Sales', Icons.currency_exchange, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('₱${_totalEarnings.toStringAsFixed(0)}', 'Total Earnings', Icons.account_balance_wallet, Colors.green)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('$_itemsSold', 'Items Sold', Icons.shopping_bag_outlined, _gold)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('₱${_avgOrderValue.toStringAsFixed(0)}', 'Avg Order Value', Icons.trending_up, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('$_totalProducts', 'Total Products', Icons.inventory_2_outlined, Colors.teal)),
          ]),
        ]),
  );

  Widget _statCard(String value, String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 10),
      Text(value, style: const TextStyle(color: _accent, fontWeight: FontWeight.w900, fontSize: 16),
        maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: _textLight, fontSize: 11, fontWeight: FontWeight.w500)),
    ]),
  );

  // ─── Sales Chart ──────────────────────────────────────────────────────────
  Widget _salesChart() => _chartCard(
    title: 'Total Sales (Last 12 Months)',
    icon: Icons.show_chart,
    child: _loadingCharts
      ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: _gold)))
      : _monthlySales.isEmpty
        ? const SizedBox(height: 180, child: Center(child: Text('No sales data yet', style: TextStyle(color: _textLight))))
        : SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _LineChartPainter(
                data: _monthlySales,
                labels: _buildMonthLabels(),
                color: Colors.blue,
              ),
              child: Container(),
            ),
          ),
  );

  List<String> _buildMonthLabels() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final now = DateTime.now();
    return List.generate(12, (i) {
      final month = DateTime(now.year, now.month - 11 + i, 1);
      return months[month.month - 1];
    });
  }

  // ─── Order Status Chart ───────────────────────────────────────────────────
  Widget _orderStatusChart() => _chartCard(
    title: 'Order Status Distribution',
    icon: Icons.pie_chart,
    child: _loadingCharts
      ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: _gold)))
      : _orderStatusData.isEmpty
        ? const SizedBox(height: 180, child: Center(child: Text('No orders yet', style: TextStyle(color: _textLight))))
        : Column(children: [
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _DonutChartPainter(data: _orderStatusData),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 12, runSpacing: 8,
              children: _orderStatusData.map((item) => Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('${item['label']} (${item['value']})',
                  style: const TextStyle(color: _textLight, fontSize: 11)),
              ])).toList(),
            ),
          ]),
  );

  Widget _chartCard({required String title, required IconData icon, required Widget child}) => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: _gold, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 4),
      Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
      const SizedBox(height: 16),
      child,
    ]),
  );

  // ─── Quick Actions ────────────────────────────────────────────────────────
  Widget _quickActions() => Container(
    margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.grid_view_rounded, color: _gold, size: 18),
        SizedBox(width: 8),
        Text('Quick Actions', style: TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 4),
      Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
      const SizedBox(height: 16),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
        children: [
          _actionTile(Icons.inventory_2_outlined, 'Products', Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerProductsPage(sellerEmail: widget.sellerEmail)))),
          _actionTile(Icons.add_box_outlined, 'Add Product', Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerAddProductPage(sellerEmail: widget.sellerEmail)))),
          _actionTile(Icons.list_alt_outlined, 'Orders', _gold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerOrderListsPage(sellerEmail: widget.sellerEmail)))),
          _actionTile(Icons.history_outlined, 'History', Colors.purple, () {}),
          _actionTile(Icons.local_offer_outlined, 'Promotions', Colors.orange, () {}),
          _actionTile(Icons.star_outline, 'Reviews', Colors.teal, () {}),
        ],
      ),
    ]),
  );

  Widget _actionTile(IconData icon, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center),
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
          setState(() => _navIndex = index);
          if (index == 1) Navigator.push(context,
            MaterialPageRoute(builder: (_) => SellerProductsPage(sellerEmail: widget.sellerEmail)));
          if (index == 2) Navigator.push(context,
            MaterialPageRoute(builder: (_) => SellerOrderListsPage(sellerEmail: widget.sellerEmail)));
          if (index == 3) Navigator.push(context,
            MaterialPageRoute(builder: (_) => SellerAnalyticsPage(sellerEmail: widget.sellerEmail)));
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

  // ─── Bottom Sheets ────────────────────────────────────────────────────────
  void _showNotifications() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _sheet('Notifications', Icons.notifications_outlined, 'No new notifications'),
    );
  }

  void _showMessages() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => _sheet('Messages', Icons.chat_bubble_outline, 'No new messages'),
    );
  }

  Widget _sheet(String title, IconData icon, String emptyMsg) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    decoration: const BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 16),
      Row(children: [
        Icon(icon, color: _gold),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 16),
      Center(child: Column(children: [
        Icon(icon, size: 48, color: _border),
        const SizedBox(height: 8),
        Text(emptyMsg, style: const TextStyle(color: _textLight, fontSize: 14)),
      ])),
      const SizedBox(height: 16),
    ]),
  );

  void _showProfile() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(width: 64, height: 64,
            decoration: const BoxDecoration(gradient: _premiumGrad, shape: BoxShape.circle),
            child: const Icon(Icons.store, color: Colors.white, size: 32)),
          const SizedBox(height: 12),
          Text(widget.sellerEmail, style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(12)),
            child: const Text('Seller Account', style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          const SizedBox(height: 20),
          _profileTile(Icons.person_outline, 'My Profile', () => Navigator.pop(context)),
          _profileTile(Icons.inventory_2_outlined, 'My Products', () => Navigator.pop(context)),
          _profileTile(Icons.list_alt_outlined, 'Order Lists', () => Navigator.pop(context)),
          const Divider(height: 24),
          _profileTile(Icons.logout, 'Logout', () {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
          }, color: Colors.red.shade400),
        ]),
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Icon(icon, color: color ?? _accent, size: 20),
    title: Text(label, style: TextStyle(color: color ?? _accent, fontWeight: FontWeight.w600, fontSize: 14)),
    trailing: Icon(Icons.chevron_right, color: color ?? _textLight, size: 18),
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    onTap: onTap,
  );
}

// ─── Line Chart Painter ───────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color color;

  _LineChartPainter({required this.data, required this.labels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double padL = 48, padR = 12, padT = 12, padB = 32;
    final double chartW = size.width - padL - padR;
    final double chartH = size.height - padT - padB;

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = 0;
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    // Grid lines
    final gridPaint = Paint()..color = const Color(0xFFE9ECEF)..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = padT + chartH - (i / 4) * chartH;
      canvas.drawLine(Offset(padL, y), Offset(padL + chartW, y), gridPaint);
      // Y labels
      final val = (minVal + (i / 4) * range);
      final tp = TextPainter(
        text: TextSpan(text: '₱${(val / 1000).toStringAsFixed(0)}k',
          style: const TextStyle(color: Color(0xFF6c757d), fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Line path
    final linePaint = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * chartW;
      final y = padT + chartH - ((data[i] - minVal) / range) * chartH;
      if (i == 0) { path.moveTo(x, y); fillPath.moveTo(x, padT + chartH); fillPath.lineTo(x, y); }
      else { path.lineTo(x, y); fillPath.lineTo(x, y); }
    }
    fillPath.lineTo(padL + chartW, padT + chartH);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Dots + X labels
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    final dotBorder = Paint()..color = Colors.white..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = padL + (i / (data.length - 1)) * chartW;
      final y = padT + chartH - ((data[i] - minVal) / range) * chartH;
      canvas.drawCircle(Offset(x, y), 5, dotBorder);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);

      // X label (every 2nd)
      if (i % 2 == 0) {
        final tp = TextPainter(
          text: TextSpan(text: labels[i], style: const TextStyle(color: Color(0xFF6c757d), fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, padT + chartH + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Donut Chart Painter ──────────────────────────────────────────────────────
class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  _DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.fold<int>(0, (s, d) => s + (d['value'] as int));
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.85;
    const strokeWidth = 36.0;

    double startAngle = -1.5708; // -90 degrees

    for (final item in data) {
      final sweep = (item['value'] as int) / total * 6.2832;
      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep, false, paint,
      );
      startAngle += sweep;
    }

    // Center text
    final tp = TextPainter(
      text: TextSpan(children: [
        TextSpan(text: '$total\n', style: const TextStyle(color: Color(0xFF2c3e50), fontSize: 22, fontWeight: FontWeight.w900)),
        const TextSpan(text: 'Orders', style: TextStyle(color: Color(0xFF6c757d), fontSize: 11)),
      ]),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
