// Filter Section JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize product cards with data attributes
    initializeProductCards();
    
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
    const productCards = document.querySelectorAll('.product-card');
    console.log('=== FILTER INITIALIZATION TEST ===');
    console.log('Total product cards found:', productCards.length);
    
    // Detailed logging for each product
    const categories = new Set();
    const testData = [];
    
    productCards.forEach((card, index) => {
        const productData = {
            index: index + 1,
            category: card.dataset.category || 'MISSING',
            price: card.dataset.price || 'MISSING',
            name: card.dataset.name || 'MISSING',
            id: card.dataset.id || 'MISSING'
        };
        
        testData.push(productData);
        
        if (card.dataset.category) {
            categories.add(card.dataset.category);
        }
        
        // Log first 5 products in detail
        if (index < 5) {
            console.log(`Product ${index + 1}:`, productData);
        }
    });
    
    console.log('\n=== SUMMARY ===');
    console.log('Available categories (should be UPPERCASE):', Array.from(categories).join(', '));
    console.log('Total unique categories:', categories.size);
    console.log('Expected categories: SUITS, BLAZERS');
    
    // Count products per category
    const categoryCounts = {};
    testData.forEach(product => {
        const cat = product.category;
        categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
    });
    console.log('Products per category:', categoryCounts);
    
    // Check for missing data
    const missingCategory = testData.filter(p => p.category === 'MISSING').length;
    const missingPrice = testData.filter(p => p.price === 'MISSING').length;
    const missingName = testData.filter(p => p.name === 'MISSING').length;
    const missingId = testData.filter(p => p.id === 'MISSING').length;
    
    if (missingCategory > 0 || missingPrice > 0 || missingName > 0 || missingId > 0) {
        console.warn('⚠️ MISSING DATA DETECTED:');
        if (missingCategory > 0) console.warn(`  - ${missingCategory} products missing category`);
        if (missingPrice > 0) console.warn(`  - ${missingPrice} products missing price`);
        if (missingName > 0) console.warn(`  - ${missingName} products missing name`);
        if (missingId > 0) console.warn(`  - ${missingId} products missing id`);
    } else {
        console.log('✅ All products have complete data attributes');
    }
    
    console.log('=== END TEST ===\n');
    
    // Store test data globally for manual inspection
    window.filterTestData = testData;
    console.log('💡 TIP: Type "window.filterTestData" in console to see all product data');
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
    console.log('=== APPLYING FILTER ===');
    console.log('Filter Type:', filterType);
    console.log('Filter Value:', value);
    
    // Get all product cards
    const productCards = document.querySelectorAll('.product-card');
    let visibleCount = 0;
    
    // Get current filters
    const currentFilters = getCurrentFilters();
    currentFilters[filterType] = value;
    
    console.log('Current filters:', currentFilters);
    console.log('Total product cards:', productCards.length);
    
    // Apply filters to products
    productCards.forEach((card, index) => {
        let shouldShow = true;
        
        // Category filter
        if (currentFilters.category && currentFilters.category !== 'all') {
            const productCategory = card.dataset.category;
            const filterCategory = currentFilters.category;
            const matches = productCategory === filterCategory;
            
            if (index < 3) { // Log first 3 products for debugging
                console.log(`Product ${index + 1}:`, {
                    category: productCategory,
                    filterValue: filterCategory,
                    matches: matches
                });
            }
            
            if (!matches) {
                shouldShow = false;
            }
        }
        
        // Sort filter (handled separately)
        if (filterType === 'sort') {
            // Sorting will be handled after filtering
        }
        
        // Show/hide card
        if (shouldShow) {
            card.style.display = '';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    console.log('Visible products after filter:', visibleCount);
    console.log('=== FILTER COMPLETE ===');
    
    // Apply sorting if needed
    if (currentFilters.sort) {
        sortProducts(currentFilters.sort);
    }
    
    // Update results count
    updateResultsCount(visibleCount);
    
    // Update active filters display
    updateActiveFilters(currentFilters);
    
    // Show/hide empty state
    showEmptyState(visibleCount === 0);
}

function sortProducts(sortType) {
    const productGrid = document.querySelector('.product-grid');
    if (!productGrid) return;
    
    const productCards = Array.from(productGrid.querySelectorAll('.product-card'));
    const visibleCards = productCards.filter(card => card.style.display !== 'none');
    
    visibleCards.sort((a, b) => {
        switch(sortType) {
            case 'price-low':
                return parseFloat(a.dataset.price || 0) - parseFloat(b.dataset.price || 0);
            case 'price-high':
                return parseFloat(b.dataset.price || 0) - parseFloat(a.dataset.price || 0);
            case 'name-az':
                return (a.dataset.name || '').localeCompare(b.dataset.name || '');
            case 'name-za':
                return (b.dataset.name || '').localeCompare(a.dataset.name || '');
            case 'newest':
                return parseFloat(b.dataset.id || 0) - parseFloat(a.dataset.id || 0);
            default:
                return 0;
        }
    });
    
    // Reorder cards in DOM
    visibleCards.forEach(card => {
        productGrid.appendChild(card);
    });
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
            const btnText = filterBtn.querySelector('.btn-text');
            if (btnText) {
                btnText.textContent = defaultItem.textContent.trim();
            }
        }
    });
    
    // Show all products
    document.querySelectorAll('.product-card').forEach(card => {
        card.style.display = '';
    });
    
    // Update results count
    const totalProducts = document.querySelectorAll('.product-card').length;
    updateResultsCount(totalProducts);
    
    // Clear active filters display
    updateActiveFilters({});
    
    // Hide empty state
    showEmptyState(false);
}

function showEmptyState(show) {
    const productGrid = document.querySelector('.product-grid');
    if (!productGrid) return;
    
    // Remove existing empty state if any
    const existingEmptyState = productGrid.querySelector('.filter-empty-state');
    if (existingEmptyState) {
        existingEmptyState.remove();
    }
    
    if (show) {
        // Create and show empty state
        const emptyState = document.createElement('div');
        emptyState.className = 'filter-empty-state';
        emptyState.innerHTML = `
            <div class="empty-state-icon">
                <i class="fas fa-search"></i>
            </div>
            <h3>No Products Found</h3>
            <p>We couldn't find any products matching your filters.</p>
            <button class="btn-clear-filters" onclick="clearAllFilters()">
                <i class="fas fa-redo"></i> Clear All Filters
            </button>
        `;
        productGrid.appendChild(emptyState);
    }
}
