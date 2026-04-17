import 'package:flutter/material.dart';
import 'seller_products.dart';

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

const _categories = {
  '': 'Select Category',
  'SUITS': '🤵 Suits',
  'BLAZERS': '🧥 Blazers',
  'SHIRTS': '👔 Shirts',
  'PANTS': '👖 Pants',
  'OUTERWEAR': '🧥 Outerwear',
  'JACKETS': '🧥 Jackets',
  'ACTIVEWEAR': '🏃 Activewear',
  'FITNESS': '💪 Fitness',
  'SHOES': '👟 Shoes',
  'ACCESSORIES': '👜 Accessories',
  'GROOMING': '🧴 Grooming Products',
};

const _clothingSizes  = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL'];
const _shoeSizesUS    = ['6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '12', '13'];
const _shoeSizesEU    = ['39', '40', '41', '42', '43', '44', '45', '46', '47'];
const _pantsSizes     = ['26×28', '27×30', '28×30', '29×30', '30×30', '31×30', '32×30', '33×30', '34×30', '36×30', '38×30', '40×30', '42×32', '44×32'];
const _specialSizes   = ['One Size', 'Free Size'];

class SellerAddProductPage extends StatefulWidget {
  final String sellerEmail;
  const SellerAddProductPage({super.key, required this.sellerEmail});
  @override
  State<SellerAddProductPage> createState() => _SellerAddProductPageState();
}

class _SellerAddProductPageState extends State<SellerAddProductPage> {
  final _nameCtrl        = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _priceCtrl       = TextEditingController();
  final _stockCtrl       = TextEditingController();
  final _thresholdCtrl   = TextEditingController(text: '5');
  final _customSizeCtrl  = TextEditingController();

  String _category    = '';
  String _colorOption = '';
  final Set<String> _selectedSizes = {};
  final List<String> _customSizes  = [];
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _stockCtrl.dispose(); _thresholdCtrl.dispose(); _customSizeCtrl.dispose();
    super.dispose();
  }

  List<String> get _allSelectedSizes => [..._selectedSizes, ..._customSizes];

  void _addCustomSize() {
    final s = _customSizeCtrl.text.trim();
    if (s.isNotEmpty && !_customSizes.contains(s) && !_selectedSizes.contains(s)) {
      setState(() { _customSizes.add(s); _customSizeCtrl.clear(); });
    }
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Product name is required'); return; }
    if (_descCtrl.text.trim().isEmpty) { _snack('Description is required'); return; }
    if (_category.isEmpty) { _snack('Please select a category'); return; }
    if (_priceCtrl.text.trim().isEmpty) { _snack('Price is required'); return; }
    if (_stockCtrl.text.trim().isEmpty) { _snack('Stock quantity is required'); return; }
    if (_colorOption.isEmpty) { _snack('Please select a color option'); return; }
    if (_allSelectedSizes.isEmpty) { _snack('Please select at least one size'); return; }

    setState(() => _submitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Product added successfully!'),
        backgroundColor: _primary, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    });
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg), backgroundColor: Colors.red.shade600,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          _card(child: Column(children: [
            _field('Product Name', _nameCtrl, Icons.inventory_2_outlined,
              hint: 'Enter product name'),
            const SizedBox(height: 14),
            _textArea('Description', _descCtrl, Icons.chat_outlined,
              hint: 'Describe your product...'),
            const SizedBox(height: 14),
            _categoryDropdown(),
          ])),
          const SizedBox(height: 12),
          _card(child: _sizesSection()),
          const SizedBox(height: 12),
          _card(child: Column(children: [
            _field('Stock Quantity', _stockCtrl, Icons.numbers,
              hint: '0', type: TextInputType.number),
            const SizedBox(height: 14),
            _field('Low Stock Threshold', _thresholdCtrl, Icons.notifications_outlined,
              hint: '5', type: TextInputType.number),
            const SizedBox(height: 6),
            const Row(children: [
              Icon(Icons.info_outline, size: 12, color: _textLight),
              SizedBox(width: 5),
              Expanded(child: Text("You'll be notified when stock falls below this level",
                style: TextStyle(color: _textLight, fontSize: 11))),
            ]),
            const SizedBox(height: 14),
            _field('Price (₱)', _priceCtrl, Icons.currency_exchange,
              hint: '0.00', type: TextInputType.number),
          ])),
          const SizedBox(height: 12),
          _card(child: _colorOptionSection()),
          const SizedBox(height: 12),
          _card(child: _imageUploadSection()),
          const SizedBox(height: 24),
          _actionButtons(),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

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
      child: const Text('Add New Product',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
    ),
  );

  Widget _pageHeader() => Container(
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
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: _goldGrad,
          boxShadow: [BoxShadow(color: _gold.withOpacity(0.4), blurRadius: 12)]),
        child: const Icon(Icons.add_circle_outline, color: _primary, size: 26),
      ),
      const SizedBox(width: 14),
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Add New Product',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        SizedBox(height: 3),
        Text('Fill in the details below to list a new product',
          style: TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    ]),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: child,
  );

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {String hint = '', TextInputType type = TextInputType.text}) =>
    TextField(
      controller: ctrl, keyboardType: type,
      style: const TextStyle(color: _accent, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        labelStyle: const TextStyle(color: _textLight, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: _gold, size: 18),
        filled: true, fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
      ),
    );

  Widget _textArea(String label, TextEditingController ctrl, IconData icon, {String hint = ''}) =>
    TextField(
      controller: ctrl, maxLines: 4,
      style: const TextStyle(color: _accent, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        labelStyle: const TextStyle(color: _textLight, fontSize: 13),
        floatingLabelStyle: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700),
        prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 60), child: Icon(icon, color: _gold, size: 18)),
        filled: true, fillColor: _bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
      ),
    );

  Widget _categoryDropdown() => DropdownButtonFormField<String>(
    value: _category.isEmpty ? null : _category,
    isExpanded: true,
    hint: const Text('Select Category', style: TextStyle(color: _textLight, fontSize: 14)),
    style: const TextStyle(color: _accent, fontSize: 14),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.grid_view_rounded, color: _gold, size: 18),
      filled: true, fillColor: _bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary, width: 2)),
    ),
    items: _categories.entries.where((e) => e.key.isNotEmpty).map((e) =>
      DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
    onChanged: (v) => setState(() => _category = v ?? ''),
  );

  // ─── Sizes Section ────────────────────────────────────────────────────────
  Widget _sizesSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [
      Icon(Icons.straighten_outlined, color: _gold, size: 16),
      SizedBox(width: 6),
      Text('Available Sizes', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
    const SizedBox(height: 4),
    Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
    const SizedBox(height: 14),
    _sizeGroup('Clothing Sizes', _clothingSizes),
    const SizedBox(height: 12),
    _sizeGroup('Shoe Sizes (US)', _shoeSizesUS),
    const SizedBox(height: 12),
    _sizeGroup('Shoe Sizes (EU)', _shoeSizesEU),
    const SizedBox(height: 12),
    _sizeGroup('Pants Sizes (Waist × Length)', _pantsSizes),
    const SizedBox(height: 12),
    _sizeGroup('One Size / Custom', _specialSizes),
    const SizedBox(height: 14),
    // Custom size input
    const Text('Custom Sizes', style: TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 12)),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(child: TextField(
        controller: _customSizeCtrl,
        style: const TextStyle(color: _accent, fontSize: 13),
        onSubmitted: (_) => _addCustomSize(),
        decoration: InputDecoration(
          hintText: 'e.g., 28W, Medium-Tall, 42R',
          hintStyle: const TextStyle(color: _textLight, fontSize: 12),
          filled: true, fillColor: _bg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 2)),
        ),
      )),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: _addCustomSize,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(10)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, color: _primary, size: 16),
            SizedBox(width: 4),
            Text('Add', style: TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      ),
    ]),
    if (_customSizes.isNotEmpty) ...[
      const SizedBox(height: 10),
      Wrap(spacing: 6, runSpacing: 6,
        children: _customSizes.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(gradient: _goldGrad, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s, style: const TextStyle(color: _primary, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _customSizes.remove(s)),
              child: const Icon(Icons.close, size: 14, color: _primary),
            ),
          ]),
        )).toList(),
      ),
    ],
    const SizedBox(height: 12),
    // Selected sizes summary
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Selected Sizes: ', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12)),
        Expanded(child: Text(
          _allSelectedSizes.isEmpty ? 'None' : _allSelectedSizes.join(', '),
          style: TextStyle(color: _allSelectedSizes.isEmpty ? _textLight : _gold,
            fontWeight: FontWeight.w600, fontSize: 12),
        )),
      ]),
    ),
  ]);

  Widget _sizeGroup(String title, List<String> sizes) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: _accent, fontWeight: FontWeight.w600, fontSize: 12)),
    const SizedBox(height: 8),
    Wrap(spacing: 6, runSpacing: 6,
      children: sizes.map((s) {
        final selected = _selectedSizes.contains(s);
        return GestureDetector(
          onTap: () => setState(() => selected ? _selectedSizes.remove(s) : _selectedSizes.add(s)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: selected ? _goldGrad : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: selected ? _gold : _border, width: selected ? 2 : 1.5),
            ),
            child: Text(s, style: TextStyle(
              color: selected ? _primary : _accent,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 12,
            )),
          ),
        );
      }).toList(),
    ),
  ]);

  // ─── Color Option Section ─────────────────────────────────────────────────
  Widget _colorOptionSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [
      Icon(Icons.palette_outlined, color: _gold, size: 16),
      SizedBox(width: 6),
      Text('Product Color Options', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
    const SizedBox(height: 4),
    Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
    const SizedBox(height: 14),
    _colorOptionTile('has_colors', 'Product has different colors/variations',
      Icons.color_lens_outlined, 'Each image will have a color name'),
    const SizedBox(height: 10),
    _colorOptionTile('no_colors', 'Product has no color variations',
      Icons.invert_colors_off_outlined, 'Single standard variant'),
  ]);

  Widget _colorOptionTile(String value, String label, IconData icon, String sub) {
    final selected = _colorOption == value;
    return GestureDetector(
      onTap: () => setState(() => _colorOption = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _gold.withOpacity(0.06) : _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _gold : _border, width: selected ? 2 : 1.5),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: selected ? _gold.withOpacity(0.15) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? _gold : _border),
            ),
            child: Icon(icon, color: selected ? _gold : _textLight, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: selected ? _accent : _textLight,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: _textLight, fontSize: 11)),
          ])),
          if (selected)
            Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(gradient: _goldGrad, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: _primary, size: 13),
            ),
        ]),
      ),
    );
  }

  // ─── Image Upload Section ─────────────────────────────────────────────────
  Widget _imageUploadSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [
      Icon(Icons.photo_library_outlined, color: _gold, size: 16),
      SizedBox(width: 6),
      Text('Product Images', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 13)),
    ]),
    const SizedBox(height: 4),
    Container(width: 36, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: _goldGrad)),
    const SizedBox(height: 14),
    GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Image picker — connect to image_picker package'),
        behavior: SnackBarBehavior.floating)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 2, style: BorderStyle.solid),
        ),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.1), shape: BoxShape.circle,
              border: Border.all(color: _gold.withOpacity(0.3)),
            ),
            child: const Icon(Icons.cloud_upload_outlined, color: _gold, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('Upload Product Images',
            style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 6),
          const Text('Tap to browse your gallery',
            style: TextStyle(color: _textLight, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Supports: JPG, PNG, GIF (Max: 10MB each)',
            style: TextStyle(color: _textLight, fontSize: 11)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(gradient: _premiumGrad, borderRadius: BorderRadius.circular(10)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.folder_open_outlined, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('Choose Files', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
        ]),
      ),
    ),
  ]);

  // ─── Action Buttons ───────────────────────────────────────────────────────
  Widget _actionButtons() => GestureDetector(
    onTap: _submitting ? null : _submit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: _submitting ? null : _premiumGrad,
        color: _submitting ? const Color(0xFFCED4DA) : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _submitting ? [] : [BoxShadow(color: _primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (_submitting)
          const SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        else
          const Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text(_submitting ? 'Adding...' : 'Add Product',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
      ]),
    ),
  );
}
