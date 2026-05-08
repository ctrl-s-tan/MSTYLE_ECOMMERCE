import 'package:flutter/material.dart';

// ─── Image URL builder ────────────────────────────────────────────────────────
// New products: image column stores full Supabase Storage URLs
// Old products: plain filenames served by Flask
const String kFlaskBaseUrl = 'https://mstyleecommerce-production.up.railway.app';

String? buildImageUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim();
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  return '$kFlaskBaseUrl/static/images/uploads/$s';
}

List<String> parseImageUrls(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .map((e) => buildImageUrl(e)!)
      .toList();
}

// ─── Reusable product image carousel ─────────────────────────────────────────
/// Swipeable image carousel for product cards and detail pages.
///
/// Pass [height] as a fixed value (e.g. 200, 320).
/// When used inside an Expanded/flexible parent, wrap with a SizedBox first.
class ProductImageCarousel extends StatefulWidget {
  final String? imageString;
  final double height;
  final double borderRadius;
  final IconData placeholder;
  final int initialPage;

  const ProductImageCarousel({
    super.key,
    required this.imageString,
    this.height = 200,
    this.borderRadius = 18,
    this.placeholder = Icons.image_outlined,
    this.initialPage = 0,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: widget.initialPage.clamp(0, 999));
    _current = widget.initialPage;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Resolve height — never use infinity for PageView
  double get _resolvedHeight {
    final h = widget.height;
    return (h.isInfinite || h <= 0) ? 200.0 : h;
  }

  @override
  Widget build(BuildContext context) {
    final urls = parseImageUrls(widget.imageString);

    if (urls.isEmpty) return _placeholder(_resolvedHeight);

    if (urls.length == 1) {
      return SizedBox(
        height: _resolvedHeight,
        width: double.infinity,
        child: _imageWidget(urls[0], _resolvedHeight),
      );
    }

    // Multiple images → swipeable PageView with dot indicators
    return SizedBox(
      height: _resolvedHeight,
      width: double.infinity,
      child: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          itemCount: urls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => _imageWidget(urls[i], _resolvedHeight),
        ),
        // Dot indicators
        Positioned(
          bottom: 8, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(urls.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _current == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _current == i
                    ? const Color(0xFFd4af37)
                    : Colors.white.withOpacity(0.7),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 2)],
              ),
            )),
          ),
        ),
        // Left / right arrow hints (subtle)
        if (urls.length > 1) ...[
          Positioned(
            left: 6, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_current > 0) _ctrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: _current > 0
                    ? Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 18),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            right: 6, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (_current < urls.length - 1) _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: _current < urls.length - 1
                    ? Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _imageWidget(String url, double h) => ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(widget.borderRadius)),
    child: Image.network(
      url,
      height: h,
      width: double.infinity,
      fit: BoxFit.cover,
      headers: const {'Accept': 'image/*'},
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: h,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFECEFF1), Color(0xFFE9ECEF)],
              ),
            ),
            child: const Center(child: CircularProgressIndicator(
              color: Color(0xFFd4af37), strokeWidth: 2)),
          ),
        );
      },
      errorBuilder: (_, error, __) {
        debugPrint('❌ Image failed: $url — $error');
        return _placeholder(h);
      },
    ),
  );

  Widget _placeholder(double h) => Container(
    height: h,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFFECEFF1), Color(0xFFE9ECEF)],
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(widget.borderRadius)),
    ),
    child: Center(child: Icon(widget.placeholder, size: 52, color: const Color(0xFFADB5BD))),
  );
}
