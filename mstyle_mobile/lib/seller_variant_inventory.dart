import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class SellerVariantInventoryPage extends StatefulWidget {
  final String sellerEmail;
  final int productId;
  final String productName;
  final String productCategory;
  final List<String> colors;
  final List<String> sizes;

  const SellerVariantInventoryPage({
    super.key,
    required this.sellerEmail,
    required this.productId,
    required this.productName,
    required this.productCategory,
    required this.colors,
    required this.sizes,
  });

  @override
  State<SellerVariantInventoryPage> createState() => _SellerVariantInventoryPageState();
}

class _SellerVariantInventoryPageState extends State<SellerVariantInventoryPage> {
  bool _loading = true;
  bool _saving  = false;

  // variant key = "color|size" → TextEditingController
  final Map<String, TextEditingController> _controllers = {};
  final _thresholdCtrl = TextEditingController(text: '5');
  final _bulkCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    _thresholdCtrl.dispose();
    _bulkCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVariants() async {
    setState(() => _loading = true);
    try {
      // Init all controllers to 0
      for (final color in widget.colors) {
        for (final size in widget.sizes) {
          final key = '${color.toLowerCase()}|${size.toLowerCase()}';
          _controllers[key] = TextEditingController(text: '0');
        }
      }

      // Fetch existing variant_inventory rows
      final rows = await supabase
          .from('variant_inventory')
          .select('color, size, stock_quantity, low_stock_threshold')
          .eq('product_id', widget.productId);

      int threshold = 5;
      for (final row in (rows as List)) {
        final color = (row['color'] as String? ?? '').toLowerCase();
        final size  = (row['size']  as String? ?? '').toLowerCase();
        final qty   = (row['stock_quantity'] as num?)?.toInt() ?? 0;
        final t     = (row['low_stock_threshold'] as num?)?.toInt() ?? 5;
        final key   = '$color|$size';
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = '$qty';
        }
        threshold = t;
      }
      _thresholdCtrl.text = '$threshold';
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint('_loadVariants error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final threshold = int.tryParse(_thresholdCtrl.text.trim()) ?? 5;
      int totalStock = 0;

      for (final color in widget.colors) {
        for (final size in widget.sizes) {
          final key = '${color.toLowerCase()}|${size.toLowerCase()}';
          final qty = int.tryParse(_controllers[key]?.text.trim() ?? '0') ?? 0;
          totalStock += qty;

          await supabase.from('variant_inventory').upsert({
            'product_id':          widget.productId,
            'color':               color,
            'size':                size,
            'stock_quantity':      qty,
            'low_stock_threshold': threshold,
          }, onConflict: 'product_id,color,size');
        }
      }

      // Sync products.quantity = sum of all variants
      await supabase.from('products').update({
        'quantity':            totalStock,
        'low_stock_threshold': threshold,
      }).eq('id', widget.productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Variants saved! Total stock: $totalStock'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context, true); // return true = refreshed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _applyBulk({String? onlyColor, String? onlySize}) {
    final val = _bulkCtrl.text.trim();
    if (val.isEmpty) return;
    setState(() {
      for (final color in widget.colors) {
        for (final size in widget.sizes) {
          if (onlyColor != null && color.toLowerCase() != onlyColor.toLowerCase()) continue;
          if (onlySize  != null && size.toLowerCase()  != onlySize.toLowerCase())  continue;
          final key = '${color.toLowerCase()}|${size.toLowerCase()}';
          _controllers[key]?.text = val;
        }
      }
    });
  }

  Color _stockColor(int qty, int threshold) {
    if (qty <= 0) return Colors.red;
    if (qty <= threshold) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel(int qty, int threshold) {
    if (qty <= 0) return 'Out of Stock';
    if (qty <= threshold) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    final threshold = int.tryParse(_thresholdCtrl.text) ?? 5;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 6,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (b) => _goldGrad.createShader(b),
          child: const Text('Variant Inventory',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, color: _gold, size: 18),
              label: const Text('Save', style: TextStyle(color: _gold, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: _gold))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Product info ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: _premiumGrad,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(gradient: _goldGrad, shape: BoxShape.circle),
                    child: const Icon(Icons.inventory_2_outlined, color: _primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.productName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(widget.productCategory,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),
              // ── Low stock threshold ───────────────────────────────────
              _card(
                title: 'Low Stock Threshold',
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _thresholdCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '5',
                      hintStyle: const TextStyle(color: _textLight),
                      filled: true, fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 2)),
                    ),
                  )),
                  const SizedBox(width: 12),
                  const Expanded(flex: 2, child: Text(
                    'Variants at or below this quantity will be marked as Low Stock',
                    style: TextStyle(color: _textLight, fontSize: 11),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              // ── Bulk update ───────────────────────────────────────────
              _card(
                title: 'Bulk Update',
                icon: Icons.bolt,
                iconColor: _gold,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Set stock quantity for multiple variants at once',
                    style: TextStyle(color: _textLight, fontSize: 12)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bulkCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: _accent, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
                      hintStyle: const TextStyle(color: _textLight),
                      prefixIcon: const Icon(Icons.inventory_2_outlined, color: _textLight, size: 18),
                      filled: true, fillColor: _bg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _bulkBtn('All Variants', Icons.check_circle_outline, () => _applyBulk()),
                    ...widget.colors.map((c) => _bulkBtn(c, Icons.palette_outlined,
                      () => _applyBulk(onlyColor: c))),
                    ...widget.sizes.map((s) => _bulkBtn('Size $s', Icons.straighten_outlined,
                      () => _applyBulk(onlySize: s))),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              // ── Variants table ────────────────────────────────────────
              _card(
                title: 'Stock per Variant',
                icon: Icons.table_chart_outlined,
                iconColor: Colors.blue,
                child: widget.colors.isEmpty || widget.sizes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text(
                        'No color/size variants defined for this product.\nAdd colors and sizes in the product editor first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _textLight, fontSize: 13),
                      )),
                    )
                  : Column(children: [
                      // Header row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Expanded(flex: 2, child: Text('Color', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12))),
                          const Expanded(flex: 1, child: Text('Size', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12))),
                          const Expanded(flex: 2, child: Text('Stock', textAlign: TextAlign.center, style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12))),
                          const Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12))),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      ...widget.colors.expand((color) => widget.sizes.map((size) {
                        final key = '${color.toLowerCase()}|${size.toLowerCase()}';
                        final ctrl = _controllers[key] ?? TextEditingController(text: '0');
                        final qty = int.tryParse(ctrl.text) ?? 0;
                        final stockColor = _stockColor(qty, threshold);
                        final stockLabel = _stockLabel(qty, threshold);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Expanded(flex: 2, child: Text(color,
                              style: const TextStyle(color: _accent, fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 1, child: Text(size,
                              style: const TextStyle(color: _textLight, fontSize: 12))),
                            Expanded(flex: 2, child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w700),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  isDense: true,
                                  filled: true, fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _border)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _gold, width: 1.5)),
                                ),
                              ),
                            )),
                            Expanded(flex: 2, child: Center(child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: stockColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: stockColor.withOpacity(0.3)),
                              ),
                              child: Text(stockLabel,
                                style: TextStyle(color: stockColor, fontSize: 9, fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center),
                            ))),
                          ]),
                        );
                      })).toList(),
                    ]),
              ),
              const SizedBox(height: 24),
              // ── Save button ───────────────────────────────────────────
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _saving ? null : _premiumGrad,
                    color: _saving ? const Color(0xFFCED4DA) : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _saving ? [] : [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (_saving)
                      const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    else
                      const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(_saving ? 'Saving...' : 'Save Changes',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
    );
  }

  Widget _card({required String title, required IconData icon, required Color iconColor, required Widget child}) =>
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 7),
          Text(title, style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        Container(width: 32, height: 3, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
        const SizedBox(height: 12),
        child,
      ]),
    );

  Widget _bulkBtn(String label, IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _gold.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: _gold),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}
