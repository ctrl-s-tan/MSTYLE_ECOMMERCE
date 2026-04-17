import 'package:flutter/material.dart';
import 'buyer_header.dart';
import 'buyer_bottom_navbar.dart';
import 'buyer_viewproduct.dart';
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

class BuyerSearchResultsPage extends StatefulWidget {
  final String userEmail;

  /// Pre-filled query — pass from the search bar if available.
  final String initialQuery;

  const BuyerSearchResultsPage({
    super.key,
    required this.userEmail,
    this.initialQuery = '',
  });

  @override
  State<BuyerSearchResultsPage> createState() => _BuyerSearchResultsPageState();
}

class _BuyerSearchResultsPageState extends State<BuyerSearchResultsPage> {
  late final TextEditingController _searchCtrl;
  final FocusNode _focusNode = FocusNode();

  bool _loading = false;
  List<Map<String, dynamic>> _results = [];
  String _lastQuery = '';

  // Filters
  String _sortBy = 'newest';
  String _category = 'all';

  static const _categories = [
    'all', 'Activewear', 'Casual', 'Suits', 'Outerwear', 'Shoes', 'Grooming',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _search(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() { _results = []; _lastQuery = ''; });
      return;
    }
    setState(() { _loading = true; _lastQuery = q; });
    try {
      var dbQuery = supabase
          .from('products')
          .select('id, name, price, image, category, seller_email, quantity, sold, rating, variations, sizes')
          .or('quantity.gt.0,sold.gt.0') // only show products with stock set
          .ilike('name', '%$q%');

      if (_category != 'all') {
        dbQuery = dbQuery.eq('category', _category);
      }

      final data = await dbQuery.order('id', ascending: false);
      var list = List<Map<String, dynamic>>.from(data as List);

      // Client-side filter: exclude flagged and inactive
      list = list.where((p) {
        if (p['is_active'] == false) return false;
        final flaggedAt = p['flagged_at'];
        if (flaggedAt != null && flaggedAt.toString().isNotEmpty) return false;
        return true;
      }).toList();

      // Client-side sort
      if (_sortBy == 'price_low')  list.sort((a, b) => ((a['price'] as num?) ?? 0).compareTo((b['price'] as num?) ?? 0));
      if (_sortBy == 'price_high') list.sort((a, b) => ((b['price'] as num?) ?? 0).compareTo((a['price'] as num?) ?? 0));
      if (_sortBy == 'rating')     list.sort((a, b) => ((b['rating'] as num?) ?? 0).compareTo((a['rating'] as num?) ?? 0));

      if (mounted) setState(() { _results = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSubmit(String value) => _search(value);

  void _onFilterChanged() => _search(_searchCtrl.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: BuyerBottomNavBar(
        userEmail: widget.userEmail,
        currentPage: BuyerPage.search,
        onSearch: () => _focusNode.requestFocus(),
      ),
      body: CustomScrollView(slivers: [
        BuyerAppBar(userEmail: widget.userEmail),
        SliverToBoxAdapter(child: _searchBar()),
        SliverToBoxAdapter(child: _filterRow()),
        if (_loading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: _gold)))
        else if (_lastQuery.isEmpty)
          SliverFillRemaining(child: _emptyPrompt())
        else if (_results.isEmpty)
          SliverFillRemaining(child: _noResults())
        else ...[
          SliverToBoxAdapter(child: _resultCount()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _productCard(_results[i]),
                childCount: _results.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _searchBar() => Container(
    color: _primary,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
    child: TextField(
      controller: _searchCtrl,
      focusNode: _focusNode,
      autofocus: widget.initialQuery.isEmpty,
      textInputAction: TextInputAction.search,
      onSubmitted: _onSubmit,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search for premium menswear...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: _gold, size: 20),
        suffixIcon: _searchCtrl.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 18),
              onPressed: () {
                _searchCtrl.clear();
                setState(() { _results = []; _lastQuery = ''; });
              })
          : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: _gold.withOpacity(0.4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: _gold, width: 2),
        ),
      ),
      onChanged: (v) => setState(() {}), // rebuild to show/hide clear button
    ),
  );

  Widget _filterRow() => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(children: [
      // Category filter
      Expanded(child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _categories.map((c) {
          final active = _category == c;
          return GestureDetector(
            onTap: () { setState(() => _category = c); _onFilterChanged(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: active ? _goldGrad : null,
                color: active ? null : _bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _gold : _border),
              ),
              child: Text(
                c == 'all' ? 'All' : c,
                style: TextStyle(
                  color: active ? _primary : _textLight,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList()),
      )),
      const SizedBox(width: 8),
      // Sort dropdown
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          icon: const Icon(Icons.sort, color: _textLight, size: 16),
          style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600),
          items: const [
            DropdownMenuItem(value: 'newest',     child: Text('Newest')),
            DropdownMenuItem(value: 'price_low',  child: Text('Price ↑')),
            DropdownMenuItem(value: 'price_high', child: Text('Price ↓')),
            DropdownMenuItem(value: 'rating',     child: Text('Top Rated')),
          ],
          onChanged: (v) { setState(() => _sortBy = v ?? 'newest'); _onFilterChanged(); },
        ),
      ),
    ]),
  );

  Widget _resultCount() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Text(
      '${_results.length} result${_results.length == 1 ? '' : 's'} for "$_lastQuery"',
      style: const TextStyle(color: _textLight, fontSize: 12, fontWeight: FontWeight.w500),
    ),
  );

  Widget _productCard(Map<String, dynamic> p) {
    final price  = (p['price'] as num?)?.toDouble() ?? 0;
    final name   = p['name'] as String? ?? '';
    final rating = (p['rating'] as num?)?.toDouble() ?? 0;
    final id     = p['id'] as int? ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => BuyerViewProductPage(userEmail: widget.userEmail, productId: id))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image placeholder
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFECEFF1), Color(0xFFE9ECEF)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, size: 40, color: Color(0xFFADB5BD))),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                style: const TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star_rounded, color: _gold, size: 12),
                const SizedBox(width: 3),
                Text(rating.toStringAsFixed(1),
                  style: const TextStyle(color: _textLight, fontSize: 10)),
              ]),
              const SizedBox(height: 4),
              Text('₱${price.toStringAsFixed(2)}',
                style: const TextStyle(color: _accent, fontWeight: FontWeight.w800, fontSize: 14)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _emptyPrompt() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.search, size: 72, color: _border),
      const SizedBox(height: 16),
      const Text('Search for products', style: TextStyle(color: _accent, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Type a product name or category above.',
        style: TextStyle(color: _textLight, fontSize: 13)),
    ]),
  );

  Widget _noResults() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.search_off_outlined, size: 72, color: _border),
      const SizedBox(height: 16),
      Text('No results for "$_lastQuery"',
        style: const TextStyle(color: _accent, fontSize: 17, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center),
      const SizedBox(height: 8),
      const Text('Try a different keyword or category.',
        style: TextStyle(color: _textLight, fontSize: 13)),
    ]),
  );
}
