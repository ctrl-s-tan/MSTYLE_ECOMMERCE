// Filter Section JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize product cards with data attributes
    initializeProductCards();
    
    // Update initial results count
    const initialCount = document.querySelectorAll('.pc-card').length;
    updateResultsCount(initialCount);
    
    // Get all filter buttons and dropdowns
    const filterBtns = document.querySelectorAll('.filter-btn');
    const dropdownMenus = document.querySelectorAll('.dropdown-menu');
    
    // Toggle dropdown on button click
    filterBtns.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            const dropdown = this.nextElementSibling;
            const isActive = dropdown.classList.contains('show');
            
            // Close all dropdowns
            closeAllDropdowns();
            
            // Toggle current dropdown
            if (!isActive) {
                dropdown.classList.add('show');
                this.classList.add('active');
            }
        });
    });
    
    // Handle dropdown item clicks
    const dropdownItems = document.querySelectorAll('.dropdown-item');
    dropdownItems.forEach(item => {
        item.addEventListener('click', function(e) {
            e.stopPropagation();
            const dropdown = this.closest('.dropdown-menu');
            const filterBtn = dropdown.previousElementSibling;
            const filterType = dropdown.dataset.filter;
            
            // Update active state
            dropdown.querySelectorAll('.dropdown-item').forEach(i => i.classList.remove('active'));
            this.classList.add('active');
            
            // Update button text
            const btnText = filterBtn.querySelector('.btn-text');
            if (btnText) {
                btnText.textContent = this.textContent.trim();
            }
            
            // Apply filter
            applyFilter(filterType, this.dataset.value);
            
            // Close dropdown
            closeAllDropdowns();
        });
    });
    
    // Close dropdowns when clicking outside
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.filter-dropdown')) {
            closeAllDropdowns();
        }
    });
    
    // Clear all filters
    const clearAllBtn = document.querySelector('.clear-all-btn');
    if (clearAllBtn) {
        clearAllBtn.addEventListener('click', function() {
            clearAllFilters();
        });
    }
    
    // Remove individual filter tag
    document.addEventListener('click', function(e) {
        if (e.target.closest('.filter-tag i')) {
            const tag = e.target.closest('.filter-tag');
            const filterType = tag.dataset.filter;
            removeFilter(filterType);
        }
    });
});

function initializeProductCards() {
    const productCards = document.querySelectorAll('.pc-card');
    console.log('Filter init: found', productCards.length, 'product cards');
}

function closeAllDropdowns() {
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('show');
    });
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
}

function applyFilter(filterType, value) {
    const productCards = document.querySelectorAll('.pc-card');
    let visibleCount = 0;

    const currentFilters = getCurrentFilters();
    currentFilters[filterType] = value;

    productCards.forEach(card => {
        let shouldShow = true;

        // Category filter
        if (currentFilters.category && currentFilters.category !== 'all') {
            const productCategory = (card.dataset.category || '').toUpperCase();
            const filterCategory  = currentFilters.category.toUpperCase();
            if (productCategory !== filterCategory) shouldShow = false;
        }

        card.style.display = shouldShow ? '' : 'none';
        if (shouldShow) visibleCount++;
    });

    // Apply sorting
    if (currentFilters.sort && currentFilters.sort !== 'default') {
        sortProducts(currentFilters.sort);
    }

    updateResultsCount(visibleCount);
    updateActiveFilters(currentFilters);
    showEmptyState(visibleCount === 0);
}

function sortProducts(sortType) {
    const productGrid = document.querySelector('.product-grid');
    if (!productGrid) return;

    const cards = Array.from(productGrid.querySelectorAll('.pc-card'))
        .filter(c => c.style.display !== 'none');

    cards.sort((a, b) => {
        switch (sortType) {
            case 'price-low':  return parseFloat(a.dataset.price || 0) - parseFloat(b.dataset.price || 0);
            case 'price-high': return parseFloat(b.dataset.price || 0) - parseFloat(a.dataset.price || 0);
            case 'name-az':    return (a.dataset.name || '').localeCompare(b.dataset.name || '');
            case 'name-za':    return (b.dataset.name || '').localeCompare(a.dataset.name || '');
            case 'newest':     return parseFloat(b.dataset.id || 0) - parseFloat(a.dataset.id || 0);
            default:           return 0;
        }
    });

    cards.forEach(card => productGrid.appendChild(card));
}

function getCurrentFilters() {
    const filters = {};
    
    // Get category filter
    const categoryActive = document.querySelector('[data-filter="category"] .dropdown-item.active');
    if (categoryActive) {
        filters.category = categoryActive.dataset.value;
    }
    
    // Get sort filter
    const sortActive = document.querySelector('[data-filter="sort"] .dropdown-item.active');
    if (sortActive) {
        filters.sort = sortActive.dataset.value;
    }
    
    return filters;
}

function updateResultsCount(count) {
    const resultsCount = document.querySelector('.results-count strong');
    if (resultsCount) {
        resultsCount.textContent = count;
    }
}

function updateActiveFilters(filters) {
    const activeFiltersContainer = document.querySelector('.active-filters');
    if (!activeFiltersContainer) return;
    
    // Clear existing tags (except clear all button)
    const existingTags = activeFiltersContainer.querySelectorAll('.filter-tag');
    existingTags.forEach(tag => tag.remove());
    
    // Add filter tags
    Object.entries(filters).forEach(([type, value]) => {
        if (value && value !== 'all' && value !== 'default') {
            const tag = document.createElement('span');
            tag.className = 'filter-tag';
            tag.dataset.filter = type;
            
            let displayText = value;
            if (type === 'category') {
                displayText = value.charAt(0).toUpperCase() + value.slice(1);
            } else if (type === 'sort') {
                const sortItem = document.querySelector(`[data-filter="sort"] [data-value="${value}"]`);
                displayText = sortItem ? sortItem.textContent.trim() : value;
            }
            
            tag.innerHTML = `${displayText} <i class="fas fa-times"></i>`;
            activeFiltersContainer.insertBefore(tag, activeFiltersContainer.querySelector('.clear-all-btn'));
        }
    });
    
    // Show/hide clear all button
    const clearAllBtn = activeFiltersContainer.querySelector('.clear-all-btn');
    const hasTags = activeFiltersContainer.querySelectorAll('.filter-tag').length > 0;
    if (clearAllBtn) {
        clearAllBtn.style.display = hasTags ? 'inline-block' : 'none';
    }
}

function removeFilter(filterType) {
    // Reset the filter dropdown
    const dropdown = document.querySelector(`[data-filter="${filterType}"]`);
    if (dropdown) {
        const items = dropdown.querySelectorAll('.dropdown-item');
        items.forEach(item => item.classList.remove('active'));
        
        // Set to default/all
        const defaultItem = dropdown.querySelector('[data-value="all"], [data-value="default"]');
        if (defaultItem) {
            defaultItem.classList.add('active');
            const filterBtn = dropdown.previousElementSibling;
            const btnText = filterBtn.querySelector('.btn-text');
            if (btnText) {
                btnText.textContent = defaultItem.textContent.trim();
            }
        }
    }
    
    // Reapply filters
    const currentFilters = getCurrentFilters();
    applyFilter(filterType, currentFilters[filterType] || 'all');
}

function clearAllFilters() {
    // Reset all dropdowns
    document.querySelectorAll('.dropdown-menu').forEach(dropdown => {
        const items = dropdown.querySelectorAll('.dropdown-item');
        items.forEach(item => item.classList.remove('active'));

        const defaultItem = dropdown.querySelector('[data-value="all"], [data-value="default"]');
        if (defaultItem) {
            defaultItem.classList.add('active');
            const filterBtn = dropdown.previousElementSibling;
            const btnText = filterBtn && filterBtn.querySelector('.btn-text');
            if (btnText) btnText.textContent = defaultItem.textContent.trim();
        }
    });

    // Show all products
    document.querySelectorAll('.pc-card').forEach(card => {
        card.style.display = '';
    });

    const totalProducts = document.querySelectorAll('.pc-card').length;
    updateResultsCount(totalProducts);
    updateActiveFilters({});
    showEmptyState(false);
}

function showEmptyState(show) {
    const productGrid = document.querySelector('.product-grid');
    if (!productGrid) return;

    const existing = productGrid.querySelector('.filter-empty-state');
    if (existing) existing.remove();

    if (show) {
        const emptyState = document.createElement('div');
        emptyState.className = 'filter-empty-state';
        emptyState.style.cssText = 'grid-column:1/-1;text-align:center;padding:3rem 1rem;color:#6c757d;';
        emptyState.innerHTML = `
            <i class="fas fa-search" style="font-size:3rem;color:#dee2e6;display:block;margin-bottom:1rem;"></i>
            <h3 style="color:#2c3e50;margin-bottom:.5rem;">No Products Found</h3>
            <p>No products match your current filters.</p>
            <button onclick="clearAllFilters()" style="margin-top:1rem;padding:.6rem 1.4rem;background:linear-gradient(135deg,#1a1a1a,#2c3e50);color:#fff;border:none;border-radius:8px;cursor:pointer;font-weight:600;">
                <i class="fas fa-redo"></i> Clear Filters
            </button>`;
        productGrid.appendChild(emptyState);
    }
}
