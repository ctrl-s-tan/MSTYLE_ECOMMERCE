import 'package:flutter/material.dart';
import 'login.dart';
import 'buyer_homepage.dart';
import 'buyer_cart.dart';
import 'buyer_orders.dart';
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

class CheckoutItem {
  final String id;
  final String name;
  final double price;          // effective price (sale price if promo applies)
  final double? originalPrice; // original price before discount (null if no promo)
  final String? promoType;     // 'percentage', 'fixed', 'buy_one_get_one', 'free_shipping'
  final double? promoDiscount;
  final int quantity;
  final String? color;
  final String? size;
  final bool freeShipping;
  final String? image;
  final int? productId;

  const CheckoutItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.promoType,
    this.promoDiscount,
    required this.quantity,
    this.color,
    this.size,
    this.freeShipping = false,
    this.image,
    this.productId,
  });

  double get subtotal => price * quantity;
  // Per-item shipping flag — used only to determine if this item qualifies for free shipping
  bool get hasFreeShipping => freeShipping;
  double get shippingFee => freeShipping ? 0 : 50; // kept for legacy; order-level fee used in checkout
  bool get hasPromo => promoType != null && promoType!.isNotEmpty;

  String get promoBadgeLabel {
    if (!hasPromo) return '';
    final d = promoDiscount?.toInt() ?? 0;
    switch (promoType) {
      case 'percentage':      return '$d% OFF';
      case 'fixed':           return '₱$d OFF';
      case 'buy_one_get_one': return 'BOGO';
      case 'free_shipping':   return 'FREE SHIP';
      default:                return 'SALE';
    }
  }
}

class BuyerCheckoutPage extends StatefulWidget {
  final String userEmail;
  final List<CheckoutItem> items;

  const BuyerCheckoutPage({
    super.key,
    required this.userEmail,
    required this.items,
  });

  @override
  State<BuyerCheckoutPage> createState() => _BuyerCheckoutPageState();
}

class _BuyerCheckoutPageState extends State<BuyerCheckoutPage> {
  String _paymentMethod = 'cod';
  String _address = '';
  bool _addressLoading = true;
  bool _placing = false;

  // Structured address fields
  String _houseStreet = '';
  String _barangay    = '';
  String _city        = '';
  String _province    = '';
  String _region      = '';
  String _zipCode     = '';

  // ── Zone-Based Shipping Rates (Philippine regions) ────────────────────────
  // Zone 1 — NCR / Metro Manila                        ₱50
  // Zone 2 — Luzon (nearby provinces)                  ₱80
  // Zone 3 — Visayas                                   ₱120
  // Zone 4 — Mindanao                                  ₱150
  // Zone 5 — Remote / Island provinces (BARMM, CARAGA) ₱180
  static const Map<String, double> _zoneRates = {
    'zone1': 50,
    'zone2': 80,
    'zone3': 120,
    'zone4': 150,
    'zone5': 180,
  };

  static const Map<String, String> _zoneLabels = {
    'zone1': 'Metro Manila',
    'zone2': 'Luzon',
    'zone3': 'Visayas',
    'zone4': 'Mindanao',
    'zone5': 'Remote / Island',
  };

  /// Maps a region string (from the user's address) to a shipping zone.
  /// Matches against region names, numbers, abbreviations, provinces, and major cities.
  static String _regionToZone(String region) {
    final r = region.toLowerCase().trim();

    // ── Zone 1: NCR / Metro Manila ──────────────────────────────────────────
    if (r.contains('ncr') || r.contains('metro manila') ||
        r.contains('national capital region') ||
        r.contains('manila') || r.contains('quezon city') ||
        r.contains('makati') || r.contains('pasig') || r.contains('taguig') ||
        r.contains('marikina') || r.contains('caloocan') || r.contains('malabon') ||
        r.contains('navotas') || r.contains('valenzuela') || r.contains('pasay') ||
        r.contains('parañaque') || r.contains('paranaque') || r.contains('las piñas') ||
        r.contains('las pinas') || r.contains('muntinlupa') || r.contains('mandaluyong') ||
        r.contains('san juan') || r.contains('pateros')) return 'zone1';

    // ── Zone 2: Luzon ────────────────────────────────────────────────────────
    // CAR — Cordillera Administrative Region
    if (r.contains('cordillera') || r.contains('car') ||
        r.contains('abra') || r.contains('apayao') || r.contains('benguet') ||
        r.contains('ifugao') || r.contains('kalinga') || r.contains('mountain province') ||
        r.contains('baguio')) return 'zone2';

    // Region I — Ilocos
    if (r.contains('ilocos') || r.contains('region i') || r.contains('region 1') ||
        r.contains('ilocos norte') || r.contains('ilocos sur') ||
        r.contains('la union') || r.contains('pangasinan') ||
        r.contains('laoag') || r.contains('vigan') || r.contains('san fernando') ||
        r.contains('dagupan')) return 'zone2';

    // Region II — Cagayan Valley
    if (r.contains('cagayan valley') || r.contains('region ii') || r.contains('region 2') ||
        r.contains('cagayan') || r.contains('isabela') || r.contains('nueva vizcaya') ||
        r.contains('quirino') || r.contains('batanes') ||
        r.contains('tuguegarao') || r.contains('ilagan') || r.contains('bayombong')) return 'zone2';

    // Region III — Central Luzon
    if (r.contains('central luzon') || r.contains('region iii') || r.contains('region 3') ||
        r.contains('aurora') || r.contains('bataan') || r.contains('bulacan') ||
        r.contains('nueva ecija') || r.contains('pampanga') || r.contains('tarlac') ||
        r.contains('zambales') ||
        r.contains('balanga') || r.contains('malolos') || r.contains('cabanatuan') ||
        r.contains('san fernando') || r.contains('tarlac city') || r.contains('olongapo') ||
        r.contains('angeles')) return 'zone2';

    // Region IV-A — CALABARZON
    if (r.contains('calabarzon') || r.contains('region iv-a') || r.contains('region iva') ||
        r.contains('region 4a') || r.contains('region 4-a') ||
        r.contains('cavite') || r.contains('laguna') || r.contains('batangas') ||
        r.contains('rizal') || r.contains('quezon') ||
        r.contains('bacoor') || r.contains('dasmariñas') || r.contains('dasmarinas') ||
        r.contains('calamba') || r.contains('antipolo') || r.contains('lipa') ||
        r.contains('lucena')) return 'zone2';

    // Region IV-B — MIMAROPA
    if (r.contains('mimaropa') || r.contains('region iv-b') || r.contains('region ivb') ||
        r.contains('region 4b') || r.contains('region 4-b') ||
        r.contains('marinduque') || r.contains('occidental mindoro') ||
        r.contains('oriental mindoro') || r.contains('palawan') || r.contains('romblon') ||
        r.contains('calapan') || r.contains('puerto princesa')) return 'zone2';

    // Region V — Bicol
    if (r.contains('bicol') || r.contains('region v') || r.contains('region 5') ||
        r.contains('albay') || r.contains('camarines norte') || r.contains('camarines sur') ||
        r.contains('catanduanes') || r.contains('masbate') || r.contains('sorsogon') ||
        r.contains('legazpi') || r.contains('naga') || r.contains('iriga') ||
        r.contains('masbate city') || r.contains('sorsogon city')) return 'zone2';

    // ── Zone 3: Visayas ──────────────────────────────────────────────────────
    // Region VI — Western Visayas
    if (r.contains('western visayas') || r.contains('region vi') || r.contains('region 6') ||
        r.contains('aklan') || r.contains('antique') || r.contains('capiz') ||
        r.contains('guimaras') || r.contains('iloilo') || r.contains('negros occidental') ||
        r.contains('kalibo') || r.contains('roxas city') || r.contains('iloilo city') ||
        r.contains('bacolod')) return 'zone3';

    // Region VII — Central Visayas
    if (r.contains('central visayas') || r.contains('region vii') || r.contains('region 7') ||
        r.contains('bohol') || r.contains('cebu') || r.contains('negros oriental') ||
        r.contains('siquijor') ||
        r.contains('tagbilaran') || r.contains('cebu city') || r.contains('mandaue') ||
        r.contains('lapu-lapu') || r.contains('lapu lapu') || r.contains('dumaguete')) return 'zone3';

    // Region VIII — Eastern Visayas
    if (r.contains('eastern visayas') || r.contains('region viii') || r.contains('region 8') ||
        r.contains('biliran') || r.contains('eastern samar') || r.contains('leyte') ||
        r.contains('northern samar') || r.contains('samar') || r.contains('southern leyte') ||
        r.contains('tacloban') || r.contains('ormoc') || r.contains('calbayog') ||
        r.contains('catbalogan') || r.contains('maasin')) return 'zone3';

    // Catch-all Visayas
    if (r.contains('visayas')) return 'zone3';

    // ── Zone 4: Mindanao ─────────────────────────────────────────────────────
    // Region IX — Zamboanga Peninsula
    if (r.contains('zamboanga peninsula') || r.contains('region ix') || r.contains('region 9') ||
        r.contains('zamboanga del norte') || r.contains('zamboanga del sur') ||
        r.contains('zamboanga sibugay') || r.contains('city of isabela') ||
        r.contains('zamboanga city') || r.contains('pagadian') || r.contains('dipolog')) return 'zone4';

    // Region X — Northern Mindanao
    if (r.contains('northern mindanao') || r.contains('region x') || r.contains('region 10') ||
        r.contains('bukidnon') || r.contains('camiguin') || r.contains('lanao del norte') ||
        r.contains('misamis occidental') || r.contains('misamis oriental') ||
        r.contains('cagayan de oro') || r.contains('iligan') || r.contains('malaybalay') ||
        r.contains('oroquieta') || r.contains('ozamiz') || r.contains('tangub')) return 'zone4';

    // Region XI — Davao
    if (r.contains('davao region') || r.contains('region xi') || r.contains('region 11') ||
        r.contains('davao del norte') || r.contains('davao del sur') ||
        r.contains('davao occidental') || r.contains('davao oriental') ||
        r.contains('davao de oro') || r.contains('compostela valley') ||
        r.contains('davao city') || r.contains('tagum') || r.contains('digos') ||
        r.contains('mati') || r.contains('panabo')) return 'zone4';

    // Region XII — SOCCSKSARGEN
    if (r.contains('soccsksargen') || r.contains('region xii') || r.contains('region 12') ||
        r.contains('cotabato') || r.contains('sarangani') ||
        r.contains('south cotabato') || r.contains('sultan kudarat') ||
        r.contains('general santos') || r.contains('koronadal') ||
        r.contains('kidapawan') || r.contains('tacurong')) return 'zone4';

    // Catch-all Mindanao
    if (r.contains('mindanao')) return 'zone4';

    // ── Zone 5: Remote / Island (BARMM, CARAGA) ──────────────────────────────
    // BARMM — Bangsamoro Autonomous Region in Muslim Mindanao
    if (r.contains('barmm') || r.contains('bangsamoro') || r.contains('armm') ||
        r.contains('basilan') || r.contains('lanao del sur') ||
        r.contains('maguindanao') || r.contains('sulu') || r.contains('tawi-tawi') ||
        r.contains('tawi tawi') || r.contains('cotabato city') ||
        r.contains('marawi') || r.contains('jolo') || r.contains('bongao')) return 'zone5';

    // CARAGA — Region XIII
    if (r.contains('caraga') || r.contains('region xiii') || r.contains('region 13') ||
        r.contains('agusan del norte') || r.contains('agusan del sur') ||
        r.contains('dinagat islands') || r.contains('surigao del norte') ||
        r.contains('surigao del sur') ||
        r.contains('butuan') || r.contains('surigao city') || r.contains('bislig') ||
        r.contains('cabadbaran') || r.contains('tandag')) return 'zone5';

    // Default — unknown region treated as Luzon rate
    return 'zone2';
  }

  double _getZoneShippingFee() {
    if (_allFreeShipping) return 0;
    final zone = _regionToZone(_region);
    return _zoneRates[zone] ?? 80;
  }

  String _getZoneLabel() {
    final zone = _regionToZone(_region);
    return _zoneLabels[zone] ?? 'Standard';
  }

  /// Returns the zone rate regardless of free shipping (for strikethrough display)
  double _getZoneRateForDisplay() {
    final zone = _regionToZone(_region);
    return _zoneRates[zone] ?? 80;
  }

  double get _subtotal => widget.items.fold(0, (s, i) => s + i.subtotal);
  bool get _allFreeShipping => widget.items.isNotEmpty && widget.items.every((i) => i.freeShipping);
  double get _shippingFee => _getZoneShippingFee();
  double get _total => _subtotal + _shippingFee;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final fields = await BuyerService.getUserAddressFields(widget.userEmail);
    if (mounted) {
      setState(() {
        _houseStreet = fields['house_street'] ?? '';
        _barangay    = fields['barangay']     ?? '';
        _city        = fields['city']         ?? '';
        _province    = fields['province']     ?? '';
        _region      = fields['region']       ?? '';
        _zipCode     = fields['zip_code']     ?? '';
        _address     = _buildAddress();
        _addressLoading = false;
      });
    }
  }

  String _buildAddress() {
    return [_houseStreet, _barangay, _city, _province, _region, _zipCode]
        .where((p) => p.trim().isNotEmpty)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _orderSummaryCard(),
          const SizedBox(height: 16),
          _addressCard(),
          const SizedBox(height: 16),
          _paymentCard(),
          const SizedBox(height: 24),
          _actionButtons(),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  PreferredSizeWidget _appBar() => AppBar(
    backgroundColor: _primary,
    elevation: 6,
    titleSpacing: 16,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    title: ShaderMask(
      shaderCallback: (b) => _goldGrad.createShader(b),
      child: const Text('Checkout',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    ),
  );

  // ─── Hero Header ──────────────────────────────────────────────────────────
  Widget _heroHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
      gradient: _premiumGrad,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)],
        ),
        child: const Icon(Icons.shopping_bag_outlined, color: _primary, size: 26),
      ),
      const SizedBox(width: 14),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        SizedBox(height: 3),
        Text('Review your order and place it', style: TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    ]),
  );

  // ─── Order Summary Card ───────────────────────────────────────────────────
  Widget _orderSummaryCard() => _card(
    title: 'Order Summary',
    icon: Icons.receipt_long_outlined,
    child: Column(children: [
      ...widget.items.map((item) => _itemRow(item)),
      const Divider(height: 24),
      _totalRow('Subtotal', '₱${_subtotal.toStringAsFixed(2)}'),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Shipping Fee', style: TextStyle(color: _textLight, fontSize: 13)),
          if (_region.isNotEmpty)
            Text('${_getZoneLabel()} zone',
              style: const TextStyle(color: _textLight, fontSize: 10, fontStyle: FontStyle.italic)),
        ]),
        _allFreeShipping
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              Text('₱${_getZoneRateForDisplay().toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _textLight, fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: _textLight)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Text('Free', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ])
          : Text('₱${_shippingFee.toStringAsFixed(2)}',
              style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
      const Divider(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Amount', style: TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 16)),
        ShaderMask(
          shaderCallback: (b) => _goldGrad.createShader(b),
          child: Text('₱${_total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      ]),
    ]),
  );

  Widget _itemRow(CheckoutItem item) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Product image
      Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: item.image != null && item.image!.isNotEmpty
            ? Image.network(
                item.image!,
                width: 60, height: 60, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
        ),
        // Promo badge on image
        if (item.hasPromo)
          Positioned(
            top: 0, left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE74C3C), Color(0xFFc0392b)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Text(item.promoBadgeLabel,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.4)),
            ),
          ),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name,
            style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          // Price row — show sale + strikethrough original if promo
          if (item.hasPromo && item.originalPrice != null &&
              (item.promoType == 'percentage' || item.promoType == 'fixed'))
            Row(children: [
              Text('₱${item.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFFE74C3C), fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(width: 6),
              Text('₱${item.originalPrice!.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _textLight, fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: _textLight)),
            ])
          else if (item.freeShipping)
            Row(children: [
              Text('₱${item.price.toStringAsFixed(2)}',
                style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Text('Free Shipping', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ])
          else if (item.hasPromo && item.promoType == 'buy_one_get_one')
            Row(children: [
              Text('₱${item.price.toStringAsFixed(2)}',
                style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text('BOGO', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ])
          else
            Text('₱${item.price.toStringAsFixed(2)}',
              style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          // Specs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              if (item.color != null) ...[
                _specChip(Icons.palette_outlined, 'Color: ${item.color}'),
                const SizedBox(width: 6),
              ],
              if (item.size != null) ...[
                _specChip(Icons.straighten_outlined, 'Size: ${item.size}'),
                const SizedBox(width: 6),
              ],
              _specChip(Icons.inventory_2_outlined, 'Qty: ${item.quantity}'),
            ]),
          ),
        ]),
      ),
      Text('₱${item.subtotal.toStringAsFixed(2)}',
        style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  );

  Widget _imagePlaceholder() => Container(
    width: 60, height: 60,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFECEFF1), Color(0xFFE9ECEF)],
      ),
    ),
    child: const Center(child: Icon(Icons.image_outlined, color: Color(0xFFADB5BD), size: 26)),
  );

  Widget _specChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: _border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: _textLight),
      const SizedBox(width: 3),
      Text(label, style: const TextStyle(color: _textLight, fontSize: 10, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _totalRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: _textLight, fontSize: 13)),
      Text(value, style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 13)),
    ],
  );

  // ─── Address Card ─────────────────────────────────────────────────────────
  Widget _addressCard() => _card(
    title: 'Delivery Address',
    icon: Icons.location_on_outlined,
    trailing: GestureDetector(
      onTap: _showAddressModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _gold.withOpacity(0.4)),
          color: _gold.withOpacity(0.08),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_outlined, size: 13, color: _gold),
          SizedBox(width: 4),
          Text('Change', style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
    child: _addressLoading
      ? const Center(child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
        ))
      : Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _address.isEmpty ? Colors.orange.shade200 : _border),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.home_outlined, color: _address.isEmpty ? Colors.orange : _gold, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _address.isEmpty ? 'No address saved — tap Change to add one' : _address,
                style: TextStyle(
                  color: _address.isEmpty ? Colors.orange.shade700 : _accent,
                  fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
              ),
              const SizedBox(height: 4),
              const Text('Ensure your address is complete for on-time delivery',
                style: TextStyle(color: _textLight, fontSize: 11)),
            ])),
          ]),
        ),
  );

  // ─── Payment Card ─────────────────────────────────────────────────────────
  Widget _paymentCard() => _card(
    title: 'Payment Method',
    icon: Icons.credit_card_outlined,
    child: Column(children: [
      Row(children: [
        const Icon(Icons.lock_outline, size: 13, color: _textLight),
        const SizedBox(width: 5),
        const Text('Payments are secured and encrypted',
          style: TextStyle(color: _textLight, fontSize: 11)),
      ]),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () => setState(() => _paymentMethod = 'cod'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _paymentMethod == 'cod' ? _gold : _border,
              width: _paymentMethod == 'cod' ? 2 : 1,
            ),
            color: _paymentMethod == 'cod' ? _gold.withOpacity(0.06) : Colors.white,
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _paymentMethod == 'cod' ? _gold.withOpacity(0.15) : _bg,
              ),
              child: Icon(Icons.payments_outlined,
                color: _paymentMethod == 'cod' ? _gold : _textLight, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cash on Delivery', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 14)),
              SizedBox(height: 2),
              Text('Pay when you receive your items', style: TextStyle(color: _textLight, fontSize: 12)),
            ])),
            if (_paymentMethod == 'cod')
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(gradient: _goldGrad, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: _primary, size: 13),
              ),
          ]),
        ),
      ),
    ]),
  );

  // ─── Action Buttons ───────────────────────────────────────────────────────
  Widget _actionButtons() => Column(children: [
    // Place Order
    GestureDetector(
      onTap: _placing ? null : _placeOrder,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _placing ? null : _premiumGrad,
          color: _placing ? const Color(0xFFCED4DA) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _placing ? [] : [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_placing)
            const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          else
            const Icon(Icons.check, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(_placing ? 'Processing...' : 'Place Order',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.3)),
        ]),
      ),
    ),
  ]);

  // ─── Shared card wrapper ──────────────────────────────────────────────────
  Widget _card({required String title, required IconData icon, required Widget child, Widget? trailing}) => Container(
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
        Text(title, style: const TextStyle(color: _accent, fontSize: 15, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (trailing != null) trailing,
      ]),
      const SizedBox(height: 4),
      Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
      const SizedBox(height: 16),
      child,
    ]),
  );

  // ─── Address Modal ────────────────────────────────────────────────────────
  void _showAddressModal() {
    final houseCtrl    = TextEditingController(text: _houseStreet);
    final barangayCtrl = TextEditingController(text: _barangay);
    final cityCtrl     = TextEditingController(text: _city);
    final provinceCtrl = TextEditingController(text: _province);
    final regionCtrl   = TextEditingController(text: _region);
    final zipCtrl      = TextEditingController(text: _zipCode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Row(children: [
                Icon(Icons.location_on_outlined, color: _gold),
                SizedBox(width: 8),
                Text('Delivery Address', style: TextStyle(color: _accent, fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 4),
              const Text('This will be saved to your profile',
                style: TextStyle(color: _textLight, fontSize: 11)),
              const SizedBox(height: 16),
              _addressField('House No. / Street', houseCtrl, Icons.home_outlined),
              const SizedBox(height: 10),
              _addressField('Barangay', barangayCtrl, Icons.location_city_outlined),
              const SizedBox(height: 10),
              _addressField('City / Municipality', cityCtrl, Icons.apartment_outlined),
              const SizedBox(height: 10),
              _addressField('Province', provinceCtrl, Icons.map_outlined),
              const SizedBox(height: 10),
              _addressField('Region', regionCtrl, Icons.public_outlined),
              const SizedBox(height: 10),
              _addressField('ZIP Code', zipCtrl, Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border), color: Colors.white),
                    child: const Center(child: Text('Cancel',
                      style: TextStyle(color: _textLight, fontWeight: FontWeight.w600))),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
                  onTap: () async {
                    final hs  = houseCtrl.text.trim();
                    final br  = barangayCtrl.text.trim();
                    final ct  = cityCtrl.text.trim();
                    final pr  = provinceCtrl.text.trim();
                    final rg  = regionCtrl.text.trim();
                    final zp  = zipCtrl.text.trim();
                    // At least city must be filled
                    if (ct.isEmpty) return;
                    setState(() {
                      _houseStreet = hs;
                      _barangay    = br;
                      _city        = ct;
                      _province    = pr;
                      _region      = rg;
                      _zipCode     = zp;
                      _address     = _buildAddress();
                    });
                    Navigator.pop(context);
                    // Save to Supabase in background
                    try {
                      await BuyerService.updateUserAddress(
                        widget.userEmail,
                        houseStreet: hs,
                        barangay:    br,
                        city:        ct,
                        province:    pr,
                        region:      rg,
                        zipCode:     zp,
                      );
                    } catch (_) {}
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Save Address',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                )),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _addressField(String label, TextEditingController ctrl, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) =>
    TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: _accent, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textLight, fontSize: 12),
        prefixIcon: Icon(icon, size: 16, color: _textLight),
        filled: true, fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _gold, width: 1.5)),
      ),
    );

  // ─── Place Order ──────────────────────────────────────────────────────────
  void _placeOrder() {
    if (_paymentMethod.isEmpty) return;
    setState(() => _placing = true);
    _doPlaceOrder();
  }

  Future<void> _doPlaceOrder() async {
    if (_address.trim().isEmpty) {
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add a delivery address before placing your order.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    try {
      for (final item in widget.items) {
        // Resolve productId — try numeric id first, then look up by name
        int resolvedProductId = item.productId ?? int.tryParse(item.id) ?? 0;
        String resolvedSellerEmail = '';

        if (resolvedProductId == 0) {
          // Look up product by name to get real id + seller_email
          try {
            final res = await BuyerService.findProductByName(item.name);
            if (res != null) {
              resolvedProductId = res['id'] as int? ?? 0;
              resolvedSellerEmail = res['seller_email'] as String? ?? '';
            }
          } catch (_) {}
        }

        await BuyerService.placeOrder(
          email:         widget.userEmail,
          name:          item.name,
          productId:     resolvedProductId,
          totalPrice:    item.subtotal + (_shippingFee / widget.items.length),
          quantity:      item.quantity,
          address:       _address,
          sellerEmail:   resolvedSellerEmail,
          paymentMethod: _paymentMethod,
          color:         item.color,
          size:          item.size,
          image:         item.image,
          shippingFee:   _shippingFee / widget.items.length,
        );
      }
      if (!mounted) return;
      setState(() => _placing = false);
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to place order: $e'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(gradient: _goldGrad, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 16)]),
              child: const Icon(Icons.check, color: _primary, size: 36),
            ),
            const SizedBox(height: 18),
            const Text('Order Placed!',
              style: TextStyle(color: _accent, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Your order has been placed successfully.',
              style: TextStyle(color: _textLight, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            // Go to Orders
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => BuyerOrdersPage(userEmail: widget.userEmail)),
                  (_) => false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('View My Orders',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
              ),
            ),
            const SizedBox(height: 10),
            // Continue Shopping
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => BuyerHomePage(userEmail: widget.userEmail)),
                  (_) => false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border), color: Colors.white),
                child: const Center(child: Text('Continue Shopping',
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 14))),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
