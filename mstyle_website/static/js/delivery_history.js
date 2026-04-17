// Delivery History JavaScript Functions

// Filter by date range
function filterByDate() {
    const dateRange = document.getElementById('dateRange').value;
    const customDateRange = document.getElementById('customDateRange');
    
    if (dateRange === 'custom') {
        customDateRange.style.display = 'block';
        return;
    } else {
        customDateRange.style.display = 'none';
    }
    
    const deliveryCards = document.querySelectorAll('.delivery-card');
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    let visibleCount = 0;
    
    deliveryCards.forEach(card => {
        const cardDateStr = card.getAttribute('data-date');
        if (!cardDateStr) {
            card.style.display = 'none';
            return;
        }
        
        const cardDate = new Date(cardDateStr);
        cardDate.setHours(0, 0, 0, 0);
        
        let showCard = false;
        
        switch(dateRange) {
            case 'all':
                showCard = true;
                break;
            case 'today':
                showCard = cardDate.getTime() === today.getTime();
                break;
            case 'week':
                const weekAgo = new Date(today);
                weekAgo.setDate(today.getDate() - 7);
                showCard = cardDate >= weekAgo && cardDate <= today;
                break;
            case 'month':
                const monthAgo = new Date(today);
                monthAgo.setMonth(today.getMonth() - 1);
                showCard = cardDate >= monthAgo && cardDate <= today;
                break;
            case 'last_month':
                const lastMonthStart = new Date(today.getFullYear(), today.getMonth() - 1, 1);
                const lastMonthEnd = new Date(today.getFullYear(), today.getMonth(), 0);
                showCard = cardDate >= lastMonthStart && cardDate <= lastMonthEnd;
                break;
        }
        
        if (showCard) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    checkEmptyState(visibleCount);
    console.log(`📅 Filtered by date: ${dateRange}, ${visibleCount} deliveries visible`);
}

// Apply custom date range
function applyCustomDateRange() {
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');
    
    if (!startDateInput.value || !endDateInput.value) {
        alert('Please select both start and end dates');
        return;
    }
    
    const startDate = new Date(startDateInput.value);
    const endDate = new Date(endDateInput.value);
    
    if (startDate > endDate) {
        alert('Start date cannot be after end date');
        return;
    }
    
    const deliveryCards = document.querySelectorAll('.delivery-card');
    let visibleCount = 0;
    
    deliveryCards.forEach(card => {
        const cardDateStr = card.getAttribute('data-date');
        if (!cardDateStr) {
            card.style.display = 'none';
            return;
        }
        
        const cardDate = new Date(cardDateStr);
        
        if (cardDate >= startDate && cardDate <= endDate) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    checkEmptyState(visibleCount);
    console.log(`📅 Applied custom date range: ${visibleCount} deliveries visible`);
}

// Filter by status
function filterDeliveries() {
    const statusFilter = document.getElementById('statusFilter').value;
    const deliveryCards = document.querySelectorAll('.delivery-card');
    let visibleCount = 0;
    
    deliveryCards.forEach(card => {
        const cardStatus = card.getAttribute('data-status');
        
        if (statusFilter === 'all' || cardStatus === statusFilter) {
            // Only show if not already hidden by date filter
            if (card.style.display !== 'none' || statusFilter !== 'all') {
                card.style.display = 'block';
                visibleCount++;
            }
        } else {
            card.style.display = 'none';
        }
    });
    
    checkEmptyState(visibleCount);
    console.log(`🔍 Filtered by status: ${statusFilter}, ${visibleCount} deliveries visible`);
}

// Sort deliveries
function sortDeliveries() {
    const sortBy = document.getElementById('sortBy').value;
    const deliveriesList = document.getElementById('deliveriesList');
    const deliveryCards = Array.from(document.querySelectorAll('.delivery-card'));
    
    deliveryCards.sort((a, b) => {
        switch(sortBy) {
            case 'date_desc':
                return new Date(b.getAttribute('data-date')) - new Date(a.getAttribute('data-date'));
            case 'date_asc':
                return new Date(a.getAttribute('data-date')) - new Date(b.getAttribute('data-date'));
            case 'earnings_desc':
                return parseFloat(b.getAttribute('data-earnings')) - parseFloat(a.getAttribute('data-earnings'));
            case 'earnings_asc':
                return parseFloat(a.getAttribute('data-earnings')) - parseFloat(b.getAttribute('data-earnings'));
            default:
                return 0;
        }
    });
    
    // Re-append sorted cards
    deliveryCards.forEach(card => {
        deliveriesList.appendChild(card);
    });
    
    console.log(`🔄 Sorted deliveries by: ${sortBy}`);
}

// Reset all filters
function resetFilters() {
    document.getElementById('dateRange').value = 'month';
    document.getElementById('statusFilter').value = 'all';
    document.getElementById('sortBy').value = 'date_desc';
    document.getElementById('customDateRange').style.display = 'none';
    
    const deliveryCards = document.querySelectorAll('.delivery-card');
    deliveryCards.forEach(card => {
        card.style.display = 'block';
    });
    
    sortDeliveries();
    checkEmptyState(deliveryCards.length);
    
    console.log('🔄 Filters reset');
}

// Check if we should show empty state
function checkEmptyState(visibleCount) {
    const emptyState = document.getElementById('emptyState');
    const deliveryCards = document.querySelectorAll('.delivery-card');
    
    if (visibleCount === 0 && deliveryCards.length > 0) {
        // Show filtered empty state
        if (!emptyState) {
            const newEmptyState = document.createElement('div');
            newEmptyState.id = 'emptyState';
            newEmptyState.className = 'empty-state';
            newEmptyState.innerHTML = `
                <div class="empty-icon">
                    <i class="bi bi-search"></i>
                </div>
                <h3>No Matching Deliveries</h3>
                <p>No deliveries match your current filter criteria.</p>
                <button class="btn btn-primary" onclick="resetFilters()">
                    <i class="bi bi-arrow-clockwise"></i>
                    Reset Filters
                </button>
            `;
            document.getElementById('deliveriesList').appendChild(newEmptyState);
        } else {
            emptyState.style.display = 'block';
        }
    } else if (emptyState && visibleCount > 0) {
        emptyState.style.display = 'none';
    }
}

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    console.log('📦 Delivery History page loaded');
    
    // Set default dates for custom range
    const today = new Date();
    const endDateInput = document.getElementById('endDate');
    const startDateInput = document.getElementById('startDate');
    
    if (endDateInput) {
        endDateInput.value = today.toISOString().split('T')[0];
    }
    
    if (startDateInput) {
        const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        startDateInput.value = firstDayOfMonth.toISOString().split('T')[0];
    }
    
    // Apply default filter (This Month)
    filterByDate();
});
