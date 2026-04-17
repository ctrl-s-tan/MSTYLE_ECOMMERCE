// Hero image carousel functionality
// Powers the right-side background image slides in the hero sections

(function() {
  document.addEventListener('DOMContentLoaded', function() {
    const hero = document.querySelector('.suits-hero, .casual-hero, .outerwear-hero, .activewear-hero, .shoes-hero, .grooming-hero');
    if (!hero) return;

    const slides = hero.querySelectorAll('.hero-image-slide');
    const indicators = hero.querySelectorAll('.carousel-indicators .indicator');
    let currentIndex = 0;
    const total = slides.length;

    function render() {
      slides.forEach(s => s.classList.remove('active'));
      indicators.forEach(i => i.classList.remove('active'));
      if (slides[currentIndex]) slides[currentIndex].classList.add('active');
      if (indicators[currentIndex]) indicators[currentIndex].classList.add('active');
    }

    function show(n) {
      if (total === 0) return;
      if (n >= total) currentIndex = 0;
      else if (n < 0) currentIndex = total - 1;
      else currentIndex = n;
      render();
    }

    // Expose for inline indicator clicks in suits.html
    window.currentImageSlide = function(n) {
      show(n - 1);
    };

    // Auto-rotate every 4s
    if (total > 1) {
      setInterval(function() {
        show(currentIndex + 1);
      }, 4000);
    }

    // Initial render in case markup default isn't first
    render();
  });
})();
