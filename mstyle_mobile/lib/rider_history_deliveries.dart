import 'package:flutter/material.dart';
import 'rider_dashboard.dart';
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
const _greenGrad = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFF27ae60), Color(0xFF2ecc71)],
);

class RiderHistoryDeliveriesPage extends StatefulWidget {
  final String riderEmail;
  const RiderHistoryDeliveriesPage({super.key, required this.riderEmail});
  @override
  State<RiderHistoryDeliveriesPage> createState() => _RiderHistoryDeliveriesPageState();
}

class _RiderHistoryDeliveriesPageState extends State<RiderHistoryDeliveriesPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _history = [];

  // Summary stats
  double get _totalEarnings => _history.fold(0, (s, d) => s + ((d['shipping_fee'] as num?)?.toDouble() ?? 0));
  int get _totalDeliveries  => _history.length;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    try {
      // Fetch both 'Delivered' and 'Completed' statuses to catch all finished orders
      final res = await supabase
          .from('orders')
          .select('*')
          .eq('rider_email', widget.riderEmail)
          .inFilter('status', ['Delivered', 'Completed', 'delivered', 'completed'])
          .order('date', ascending: false);

      final list = List<Map<String, dynamic>>.from(res as List);
      // Sort by delivered_at first, fall back to date — latest first
      list.sort((a, b) {
        final aStr = (a['delivered_at'] ?? a['date'] ?? '') as String;
        final bStr = (b['delivered_at'] ?? b['date'] ?? '') as String;
        return bStr.compareTo(aStr);
      });
      if (mounted) setState(() { _history = list; _loading = false; });
    } catch (e) {
      debugPrint('fetchHistory error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    DateTime? dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    // Supabase stores timestamps as UTC. If the string has no timezone suffix,
    // treat it as UTC explicitly before converting to PH time (UTC+8).
    if (!raw.contains('+') && !raw.toUpperCase().contains('Z')) {
      dt = DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
    }
    // Convert to Philippine Time (UTC+8)
    dt = dt.toUtc().add(const Duration(hours: 8));
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour24 = dt.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final ampm   = hour24 < 12 ? 'am' : 'pm';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour12:$minute $ampm';
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(slivers: [
        // ── App Bar ──────────────────────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          backgroundColor: _primary,
          elevation: 6,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Delivery History',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            Text('Your completed deliveries',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        ),

        // ── Stats Banner ─────────────────────────────────────────────────────
        if (!_loading && _history.isNotEmpty)
          SliverToBoxAdapter(child: _statsBanner()),

        // ── Content ──────────────────────────────────────────────────────────
        if (_loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _gold)))
        else if (_history.isEmpty)
          SliverFillRemaining(child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
            sliver: SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _historyCard(_history[i], i + 1),
              childCount: _history.length,
            )),
          ),
      ]),
    );
  }

  // ── Stats Banner ─────────────────────────────────────────────────────────────
  Widget _statsBanner() => Container(
    margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: _premiumGrad,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Expanded(child: _statItem(
        Icons.local_shipping_outlined,
        '$_totalDeliveries',
        'Total Deliveries',
        Colors.white,
      )),
      Container(width: 1, height: 44, color: Colors.white.withOpacity(0.15)),
      Expanded(child: _statItem(
        Icons.payments_outlined,
        '₱${_totalEarnings.toStringAsFixed(0)}',
        'Total Earnings',
        _goldLight,
      )),
    ]),
  );

  Widget _statItem(IconData icon, String value, String label, Color color) => Column(children: [
    Icon(icon, color: color.withOpacity(0.8), size: 18),
    const SizedBox(height: 6),
    Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
    Text(label, style: TextStyle(color: color.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w500)),
  ]);

  // ── History Card ─────────────────────────────────────────────────────────────
  Widget _historyCard(Map<String, dynamic> d, int index) {
    final fee     = (d['shipping_fee'] as num?)?.toDouble() ?? 0;
    final isFree  = fee == 0;
    final dateStr = _formatDate(d['delivered_at'] as String? ?? d['date'] as String?);

    return GestureDetector(
      onTap: () => _showDetailModal(d),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Card Header ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              gradient: _premiumGrad,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('$index',
                  style: const TextStyle(color: _primary, fontWeight: FontWeight.w900, fontSize: 13))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Order #${d['id']}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text(d['name'] as String? ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(isFree ? 'Free' : '₱${fee.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: isFree ? Colors.greenAccent.shade200 : _goldLight,
                    fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, size: 9, color: Colors.greenAccent),
                    SizedBox(width: 4),
                    Text('Delivered',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ]),
          ),

          // ── Card Body ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (dateStr.isNotEmpty)
                _infoRow(Icons.calendar_today_outlined, 'Delivered', dateStr, Colors.indigo),
              if ((d['email'] as String?)?.isNotEmpty == true)
                _infoRow(Icons.person_outline, 'Buyer', d['email'] as String, Colors.blue),
              if ((d['address'] as String?)?.isNotEmpty == true)
                _infoRow(Icons.location_on_outlined, 'Address', d['address'] as String, Colors.red),
            ]),
          ),

          // ── Card Footer ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.04),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              border: Border(top: BorderSide(color: Colors.green.withOpacity(0.12))),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              Text(isFree ? 'Free delivery' : '+₱${fee.toStringAsFixed(0)} earned',
                style: TextStyle(
                  color: isFree ? Colors.teal : _gold,
                  fontSize: 11, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: _premiumGrad,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('View Details',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 10, color: _gold),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Detail Bottom Sheet Modal ─────────────────────────────────────────────────
  void _showDetailModal(Map<String, dynamic> d) {
    final fee      = (d['shipping_fee'] as num?)?.toDouble() ?? 0;
    final isFree   = fee == 0;
    final proofUrl = d['proof_of_delivery_url'] as String?;
    final hasProof = proofUrl != null && proofUrl.isNotEmpty;
    final dateStr  = _formatDate(d['delivered_at'] as String? ?? d['date'] as String?);
    final orderDateStr = _formatDate(d['date'] as String?);
    final unitPrice = (d['total_price'] as num?)?.toDouble() ?? 0.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Drag handle
            Center(child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
            )),

            // Modal header
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12), shape: BoxShape.circle,
                    border: Border.all(color: _gold.withOpacity(0.5))),
                  child: const Icon(Icons.receipt_long_outlined, color: _gold, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order #${d['id']}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(d['name'] as String? ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(isFree ? 'Free' : '₱${fee.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isFree ? Colors.greenAccent.shade200 : _goldLight,
                      fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.5))),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle, size: 9, color: Colors.greenAccent),
                      SizedBox(width: 4),
                      Text('Delivered',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
              ]),
            ),

            // Scrollable content
            Expanded(child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [

                // ── Order Info ─────────────────────────────────────────────
                _modalSection('Order Information', Icons.info_outline, Colors.indigo),
                if (orderDateStr.isNotEmpty)
                  _modalInfoRow(Icons.calendar_today_outlined, 'Order Date', orderDateStr, Colors.indigo),
                if (dateStr.isNotEmpty)
                  _modalInfoRow(Icons.check_circle_outline, 'Delivered At', dateStr, Colors.green),
                _modalInfoRow(Icons.payment_outlined, 'Payment',
                  (d['payment_method'] as String? ?? 'N/A').toUpperCase(), Colors.purple),
                const SizedBox(height: 12),

                // ── Product Info ───────────────────────────────────────────
                _modalSection('Product Details', Icons.inventory_2_outlined, Colors.orange),
                _modalInfoRow(Icons.shopping_bag_outlined, 'Product', d['name'] as String? ?? 'N/A', Colors.orange),
                if ((d['variations'] as String?)?.isNotEmpty == true)
                  _modalInfoRow(Icons.palette_outlined, 'Color', d['variations'] as String, Colors.orange),
                if ((d['size'] as String?)?.isNotEmpty == true)
                  _modalInfoRow(Icons.straighten_outlined, 'Size', d['size'] as String, Colors.teal),
                if (d['quantity'] != null)
                  _modalInfoRow(Icons.numbers_outlined, 'Quantity', '${d['quantity']}', Colors.teal),
                const SizedBox(height: 12),

                // ── Buyer Info ─────────────────────────────────────────────
                _modalSection('Buyer Information', Icons.person_outline, Colors.blue),
                if ((d['email'] as String?)?.isNotEmpty == true)
                  _modalInfoRow(Icons.email_outlined, 'Email', d['email'] as String, Colors.blue),
                if ((d['address'] as String?)?.isNotEmpty == true)
                  _modalInfoRow(Icons.location_on_outlined, 'Delivery Address', d['address'] as String, Colors.red),
                const SizedBox(height: 12),

                // ── Pricing ────────────────────────────────────────────────
                _modalSection('Payment Summary', Icons.payments_outlined, _gold),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold.withOpacity(0.2)),
                  ),
                  child: Column(children: [
                    _priceRow('Order Total', unitPrice > 0 ? '₱${unitPrice.toStringAsFixed(2)}' : 'N/A', _accent, false),
                    const Divider(height: 14),
                    _priceRow('Delivery Fee', isFree ? 'Free' : '₱${fee.toStringAsFixed(2)}', Colors.teal, false),
                    const Divider(height: 14),
                    _priceRow('Your Earnings', isFree ? 'Free delivery' : '+₱${fee.toStringAsFixed(2)}', _gold, true),
                  ]),
                ),
                const SizedBox(height: 16),

                // ── Proof of Delivery ──────────────────────────────────────
                _modalSection('Proof of Delivery', Icons.camera_alt_outlined, Colors.indigo),
                if (hasProof) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      proofUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 200,
                            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2)),
                          ),
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border)),
                        child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.broken_image_outlined, color: _textLight, size: 18),
                          SizedBox(width: 8),
                          Text('Photo unavailable', style: TextStyle(color: _textLight, fontSize: 12)),
                        ])),
                      ),
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _bg, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.camera_alt_outlined, color: _textLight, size: 18),
                      SizedBox(width: 8),
                      Text('No proof photo was taken for this delivery',
                        style: TextStyle(color: _textLight, fontSize: 12)),
                    ]),
                  ),
                const SizedBox(height: 20),

                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _bg, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border)),
                    child: const Center(child: Text('Close',
                      style: TextStyle(color: _textLight, fontWeight: FontWeight.w700, fontSize: 14))),
                  ),
                ),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  Widget _modalSection(String title, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 14, color: color)),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
      const SizedBox(width: 8),
      Expanded(child: Container(height: 1, color: color.withOpacity(0.15))),
    ]),
  );

  Widget _modalInfoRow(IconData icon, String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 15, color: color)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _textLight, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w600)),
      ])),
    ]),
  );

  Widget _priceRow(String label, String value, Color color, bool bold) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(
        color: bold ? _accent : _textLight,
        fontSize: bold ? 14 : 13,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
      Text(value, style: TextStyle(
        color: color,
        fontSize: bold ? 16 : 13,
        fontWeight: bold ? FontWeight.w900 : FontWeight.w600)),
    ],
  );

  Widget _infoRow(IconData icon, String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 13, color: color),
      ),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _textLight, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 1),
        Text(value,
          style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      ])),
    ]),
  );

  // ── Empty State ───────────────────────────────────────────────────────────────
  Widget _emptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      width: 90, height: 90,
      decoration: BoxDecoration(
        gradient: _premiumGrad,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: const Icon(Icons.history_outlined, size: 40, color: _gold),
    ),
    const SizedBox(height: 20),
    const Text('No Delivery History',
      style: TextStyle(color: _accent, fontSize: 20, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    const Text('Your completed deliveries will appear here.',
      style: TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
    const SizedBox(height: 24),
    GestureDetector(
      onTap: _fetchHistory,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: _premiumGrad,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.refresh, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      ),
    ),
  ]));
}
