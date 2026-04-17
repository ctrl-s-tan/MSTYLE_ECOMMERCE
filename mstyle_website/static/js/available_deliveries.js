// Available Deliveries JavaScript

document.addEventListener('DOMContentLoaded', function() {
    initializeFilters();
    initializeDeliveryCards();
});

function initializeFilters() {
    const sortSelect = document.getElementById('sortBy');
    const prioritySelect = document.getElementById('filterPriority');
    const feeSelect = document.getElementById('filterFee');

    if (sortSelect) {
        sortSelect.addEventListener('change', applyFilters);
    }
    if (prioritySelect) {
        prioritySelect.addEventListener('change', applyFilters);
    }
    if (feeSelect) {
        feeSelect.addEventListener('change', applyFilters);
    }
}

function initializeDeliveryCards() {
    const cards = document.querySelectorAll('.delivery-card');
    cards.forEach((card, index) => {
        // Add staggered animation
        card.style.animationDelay = `${index * 0.1}s`;
        card.classList.add('fade-in-card');
    });
}

function filterDeliveries() {
    applyFilters();
}

function sortDeliveries() {
    applyFilters();
}

function applyFilters() {
    const sortBy = document.getElementById('sortBy').value;
    const priorityFilter = document.getElementById('filterPriority').value;
    const feeFilter = document.getElementById('filterFee').value;
    
    const cards = Array.from(document.querySelectorAll('.delivery-card'));
    const grid = document.querySelector('.deliveries-grid');
    
    // Filter cards
    let visibleCount = 0;
    cards.forEach(card => {
        const fee = parseFloat(card.dataset.fee);
        const priority = card.dataset.priority;
        const feeAmount = card.querySelector('.fee-amount').textContent.trim();
        const isFree = feeAmount.toLowerCase() === 'free';
        
        let showCard = true;
        
        // Priority filter
        if (priorityFilter !== 'all' && priority !== priorityFilter) {
            showCard = false;
        }
        
        // Fee filter
        if (feeFilter === 'free' && !isFree) {
            showCard = false;
        } else if (feeFilter === 'paid' && isFree) {
            showCard = false;
        }
        
        if (showCard) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });
    
    // Get only visible cards for sorting
    const visibleCards = cards.filter(card => card.style.display !== 'none');
    
    // Sort visible cards
    visibleCards.sort((a, b) => {
        switch (sortBy) {
            case 'distance':
                return parseFloat(a.dataset.distance) - parseFloat(b.dataset.distance);
            case 'fee_high':
                return parseFloat(b.dataset.fee) - parseFloat(a.dataset.fee);
            case 'fee_low':
                return parseFloat(a.dataset.fee) - parseFloat(b.dataset.fee);
            case 'priority':
                const priorityOrder = { 'urgent': 0, 'normal': 1 };
                return priorityOrder[a.dataset.priority] - priorityOrder[b.dataset.priority];
            case 'value_high':
                const aValue = parseFloat(a.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                const bValue = parseFloat(b.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                return bValue - aValue;
            case 'value_low':
                const aValueLow = parseFloat(a.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                const bValueLow = parseFloat(b.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                return aValueLow - bValueLow;
            case 'newest':
            default:
                return 0; // Keep original order for newest
        }
    });
    
    // Re-append sorted visible cards
    visibleCards.forEach((card, index) => {
        card.style.animationDelay = `${index * 0.05}s`;
        grid.appendChild(card);
    });
    
    // Check empty state
    checkEmptyState(visibleCount, cards.length);
}

function checkEmptyState(visibleCount, totalCount) {
    let emptyState = document.getElementById('emptyState');
    
    // Create empty state if it doesn't exist
    if (!emptyState) {
        emptyState = document.createElement('div');
        emptyState.id = 'emptyState';
        emptyState.className = 'empty-state';
        emptyState.style.gridColumn = '1 / -1';
        emptyState.innerHTML = `
            <div class="empty-icon">
                <i class="bi bi-inbox"></i>
            </div>
            <h3>No Available Deliveries</h3>
            <p>There are currently no delivery orders available in your area. Check back later!</p>
            <button class="btn btn-primary" onclick="refreshDeliveries()">
                <i class="bi bi-arrow-clockwise"></i>
                Refresh
            </button>
        `;
        document.querySelector('.deliveries-grid').appendChild(emptyState);
    }
    
    if (visibleCount === 0) {
        emptyState.style.display = 'block';
        
        // Check if it's because of filters or no deliveries at all
        if (totalCount === 0) {
            emptyState.querySelector('h3').textContent = 'No Available Deliveries';
            emptyState.querySelector('p').textContent = 'There are currently no delivery orders available in your area. Check back later!';
            const emptyBtn = emptyState.querySelector('.btn');
            if (emptyBtn) {
                emptyBtn.innerHTML = '<i class="bi bi-arrow-clockwise"></i> Refresh';
                emptyBtn.onclick = refreshDeliveries;
            }
        } else {
            emptyState.querySelector('h3').textContent = 'No Matching Deliveries';
            emptyState.querySelector('p').textContent = 'No deliveries match your current filter criteria. Try adjusting your filters.';
            const emptyBtn = emptyState.querySelector('.btn');
            if (emptyBtn) {
                emptyBtn.innerHTML = '<i class="bi bi-arrow-clockwise"></i> Reset Filters';
                emptyBtn.onclick = resetFilters;
            }
        }
    } else {
        emptyState.style.display = 'none';
    }
}

function resetFilters() {
    console.log('🔄 Resetting filters...');
    
    // Reset filter dropdowns
    document.getElementById('sortBy').value = 'newest';
    document.getElementById('filterPriority').value = 'all';
    document.getElementById('filterFee').value = 'all';
    
    // Show all delivery cards
    const deliveryCards = document.querySelectorAll('.delivery-card');
    deliveryCards.forEach(card => {
        card.style.display = 'block';
    });
    
    // Re-apply filters to restore original order
    applyFilters();
    
    console.log('✅ Filters reset successfully');
}



function viewOrderDetails(orderId) {
    // Show loading state
    const loadingModal = createLoadingModal();
    document.body.appendChild(loadingModal);
    
    // Fetch order details from API
    fetch(`/api/order-details/${orderId}`)
        .then(response => response.json())
        .then(data => {
            loadingModal.remove();
            
            if (data.success) {
                showOrderDetailsModal(data.order);
            } else {
                showErrorMessage(data.message || 'Failed to load order details');
            }
        })
        .catch(error => {
            loadingModal.remove();
            console.error('Error fetching order details:', error);
            showErrorMessage('Network error. Please check your connection.');
        });
}

function createLoadingModal() {
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
        <div class="modal-content loading-modal">
            <div class="loading-spinner">
                <i class="bi bi-arrow-clockwise spin"></i>
            </div>
            <p>Loading order details...</p>
        </div>
    `;
    
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
    `;
    
    return modal;
}

function showOrderDetailsModal(order) {
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
        <div class="modal-content order-details-modal">
            <div class="modal-header">
                <h3>Order Details #${order.id}</h3>
                <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">
                    <i class="bi bi-x"></i>
                </button>
            </div>
            <div class="modal-body">
                <div class="order-info-grid">
                    <div class="info-section">
                        <h4><i class="bi bi-bag"></i> Product Information</h4>
                        <p><strong>Product:</strong> ${order.product_name}</p>
                        <p><strong>Quantity:</strong> ${order.quantity}</p>
                        ${order.variations ? `<p><strong>Color:</strong> ${order.variations}</p>` : ''}
                        ${order.size ? `<p><strong>Size:</strong> ${order.size}</p>` : ''}
                        <p><strong>Product Price:</strong> ₱${order.total_price.toFixed(2)}</p>
                        <p><strong>Shipping Fee:</strong> ${order.has_free_shipping ? 'Free' : '₱' + order.shipping_fee.toFixed(2)}</p>
                        <p><strong>Total Value:</strong> ₱${(order.total_price + order.shipping_fee).toFixed(2)}</p>
                        <p><strong>Payment:</strong> ${order.payment_method}</p>
                    </div>
                    
                    <div class="info-section">
                        <h4><i class="bi bi-person"></i> Customer Information</h4>
                        <p><strong>Name:</strong> ${order.customer.name}</p>
                        <p><strong>Email:</strong> ${order.customer.email}</p>
                        ${order.customer.phone ? `<p><strong>Phone:</strong> ${order.customer.phone}</p>` : ''}
                        <p><strong>Delivery Address:</strong> ${order.customer.address || 'Not provided'}</p>
                    </div>
                    
                    <div class="info-section">
                        <h4><i class="bi bi-shop"></i> Pickup Information</h4>
                        <p><strong>Seller:</strong> ${order.seller.name}</p>
                        <p><strong>Email:</strong> ${order.seller.email}</p>
                        ${order.seller.phone ? `<p><strong>Phone:</strong> ${order.seller.phone}</p>` : ''}
                        <p><strong>Pickup Address:</strong> ${order.seller.address || 'Contact seller for address'}</p>
                    </div>
                    
                    <div class="info-section">
                        <h4><i class="bi bi-clock"></i> Order Status</h4>
                        <p><strong>Status:</strong> <span class="status-badge ${order.status.toLowerCase()}">${order.status}</span></p>
                        <p><strong>Order Date:</strong> ${new Date(order.order_date).toLocaleString()}</p>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" onclick="this.closest('.modal-overlay').remove()">
                    Close
                </button>
                <button class="btn btn-primary" onclick="acceptDelivery(${order.id}); this.closest('.modal-overlay').remove();">
                    <i class="bi bi-check-circle"></i>
                    Accept Delivery
                </button>
            </div>
        </div>
    `;
    
    // Add modal styles
    modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
        padding: 20px;
    `;
    
    document.body.appendChild(modal);
    
    // Close modal when clicking outside
    modal.addEventListener('click', function(e) {
        if (e.target === modal) {
            modal.remove();
        }
    });
}

function acceptDelivery(orderId) {
    // Show confirmation dialog
    const confirmed = confirm(`Accept delivery for Order #${orderId}?\n\nBy accepting, you commit to picking up and delivering this order.`);
    
    if (confirmed) {
        // Find the button that was clicked
        const card = document.querySelector(`[data-order-id="${orderId}"]`);
        const acceptBtn = card ? card.querySelector('.btn-primary') : null;
        
        // Show loading state on button
        if (acceptBtn) {
            acceptBtn.disabled = true;
            acceptBtn.innerHTML = '<i class="bi bi-arrow-clockwise spin"></i> Processing...';
            acceptBtn.style.opacity = '0.7';
            acceptBtn.style.cursor = 'not-allowed';
        }
        
        // Disable card interactions
        if (card) {
            card.style.opacity = '0.6';
            card.style.pointerEvents = 'none';
        }
        
        // Make API call to accept the delivery
        fetch('/api/accept-delivery', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ orderId: orderId })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Show success modal
                showSuccessModal();
                
                // Remove the card from available deliveries after a short delay
                setTimeout(() => {
                    if (card) {
                        card.remove();
                    }
                }, 500);
            } else {
                showErrorMessage(data.message || 'Failed to accept delivery. Please try again.');
                // Reset button and card state
                if (acceptBtn) {
                    acceptBtn.disabled = false;
                    acceptBtn.innerHTML = '<i class="bi bi-check-circle"></i> Accept Delivery';
                    acceptBtn.style.opacity = '1';
                    acceptBtn.style.cursor = 'pointer';
                }
                if (card) {
                    card.style.opacity = '1';
                    card.style.pointerEvents = 'auto';
                }
            }
        })
        .catch(error => {
            console.error('Error accepting delivery:', error);
            showErrorMessage('Network error. Please check your connection.');
            // Reset button and card state
            if (acceptBtn) {
                acceptBtn.disabled = false;
                acceptBtn.innerHTML = '<i class="bi bi-check-circle"></i> Accept Delivery';
                acceptBtn.style.opacity = '1';
                acceptBtn.style.cursor = 'pointer';
            }
            if (card) {
                card.style.opacity = '1';
                card.style.pointerEvents = 'auto';
            }
        });
    }
}

function showSuccessModal() {
    const modal = document.getElementById('successModal');
    if (modal) {
        modal.classList.add('show');
        modal.setAttribute('aria-hidden', 'false');
    }
}

function closeSuccessModal() {
    const modal = document.getElementById('successModal');
    if (modal) {
        modal.classList.remove('show');
        modal.setAttribute('aria-hidden', 'true');
    }
}

function goToActiveDeliveries() {
    window.location.href = '/active_deliveries';
}

function refreshDeliveries() {
    // Show loading state
    const refreshBtn = event.target;
    const originalText = refreshBtn.innerHTML;
    refreshBtn.innerHTML = '<i class="bi bi-arrow-clockwise spin"></i> Refreshing...';
    refreshBtn.disabled = true;
    
    // Simulate refresh
    setTimeout(() => {
        location.reload();
    }, 1500);
}

function showSuccessMessage(message) {
    const notification = createNotification(message, 'success');
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 5000);
}

function showErrorMessage(message) {
    const notification = createNotification(message, 'error');
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 5000);
}

function createNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="bi bi-${type === 'success' ? 'check-circle' : 'exclamation-triangle'}"></i>
            <span>${message}</span>
        </div>
        <button class="notification-close" onclick="this.parentElement.remove()">
            <i class="bi bi-x"></i>
        </button>
    `;
    
    // Add notification styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#d4edda' : '#f8d7da'};
        color: ${type === 'success' ? '#155724' : '#721c24'};
        padding: 1rem 1.5rem;
        border-radius: 10px;
        border: 1px solid ${type === 'success' ? '#c3e6cb' : '#f5c6cb'};
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        z-index: 1000;
        display: flex;
        align-items: center;
        gap: 1rem;
        max-width: 400px;
        animation: slideIn 0.3s ease-out;
    `;
    
    return notification;
}

// Add CSS for animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
    }
    
    .spin {
        animation: spin 1s linear infinite;
    }
    
    .fade-in-card {
        animation: fadeInCard 0.5s ease-out forwards;
        opacity: 0;
        transform: translateY(20px);
    }
    
    @keyframes fadeInCard {
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        flex: 1;
    }
    
    .notification-close {
        background: none;
        border: none;
        cursor: pointer;
        padding: 0.25rem;
        border-radius: 4px;
        opacity: 0.7;
        transition: opacity 0.2s;
    }
    
    .notification-close:hover {
        opacity: 1;
    }
    
    .modal-content {
        background: rgba(255, 255, 255, 0.98);
        border: 1px solid rgba(212, 175, 55, 0.2);
        border-radius: 20px;
        max-width: 900px;
        width: 100%;
        max-height: 90vh;
        overflow-y: auto;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        position: relative;
    }
    
    .modal-content::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        border-radius: 20px 20px 0 0;
    }
    
    .loading-modal {
        max-width: 350px;
        padding: 2.5rem;
        text-align: center;
    }
    
    .loading-spinner {
        font-size: 2.5rem;
        margin-bottom: 1.5rem;
        color: #d4af37;
        animation: spin 1s linear infinite;
    }
    
    .loading-modal p {
        color: #2c3e50;
        font-weight: 500;
        font-size: 1.1rem;
    }
    
    .order-details-modal {
        max-width: 950px;
    }
    
    .modal-header {
        padding: 2rem;
        border-bottom: 1px solid rgba(212, 175, 55, 0.2);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 20px 20px 0 0;
        margin-top: 4px;
    }
    
    .modal-header h3 {
        margin: 0;
        color: #2c3e50;
        font-size: 1.5rem;
        font-weight: 600;
        background: linear-gradient(135deg, #2c3e50, #34495e);
        -webkit-background-clip: text;
        background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    
    .modal-close {
        background: rgba(255, 255, 255, 0.9);
        border: 2px solid rgba(212, 175, 55, 0.3);
        font-size: 1.5rem;
        cursor: pointer;
        padding: 0.75rem;
        border-radius: 50%;
        transition: all 0.3s ease;
        color: #2c3e50;
        width: 45px;
        height: 45px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .modal-close:hover {
        background: #d4af37;
        color: white;
        border-color: #d4af37;
        transform: scale(1.1);
    }
    
    .modal-body {
        padding: 2rem;
        background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%);
    }
    
    .order-info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
        gap: 1.5rem;
    }
    
    .info-section {
        background: rgba(255, 255, 255, 0.95);
        padding: 1.5rem;
        border-radius: 15px;
        border: 1px solid rgba(212, 175, 55, 0.2);
        position: relative;
        transition: all 0.3s ease;
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
    }
    
    .info-section::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        border-radius: 15px 15px 0 0;
    }
    
    .info-section:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(212, 175, 55, 0.15);
        border-color: rgba(212, 175, 55, 0.4);
    }
    
    .info-section h4 {
        margin: 0 0 1.25rem 0;
        color: #2c3e50;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        font-size: 1.1rem;
        font-weight: 600;
    }
    
    .info-section h4 i {
        color: #d4af37;
        font-size: 1.2rem;
        width: 20px;
        text-align: center;
    }
    
    .info-section p {
        margin: 0.75rem 0;
        line-height: 1.6;
        color: #2c3e50;
    }
    
    .info-section p strong {
        color: #2c3e50;
        font-weight: 600;
    }
    
    .status-badge {
        padding: 0.5rem 1rem;
        border-radius: 25px;
        font-size: 0.85rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        border: 2px solid transparent;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .status-badge.pending {
        background: linear-gradient(135deg, #fff3cd 0%, #fef7d9 100%);
        color: #856404;
        border-color: #f39c12;
    }
    
    .status-badge.shipped {
        background: linear-gradient(135deg, #cce5ff 0%, #b3d9ff 100%);
        color: #0056b3;
        border-color: #3498db;
    }
    
    .status-badge.out-for-delivery {
        background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
        color: #155724;
        border-color: #27ae60;
    }
    
    .modal-footer {
        padding: 2rem;
        border-top: 1px solid rgba(212, 175, 55, 0.2);
        display: flex;
        justify-content: flex-end;
        gap: 1rem;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 0 0 20px 20px;
    }
    
    .btn {
        padding: 1rem 2rem;
        border: none;
        border-radius: 25px;
        cursor: pointer;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 0.75rem;
        transition: all 0.3s ease;
        text-decoration: none;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        position: relative;
        overflow: hidden;
    }
    
    .btn::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s;
    }
    
    .btn:hover::before {
        left: 100%;
    }
    
    .btn-primary {
        background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(44, 62, 80, 0.3);
    }
    
    .btn-primary:hover {
        background: linear-gradient(135deg, #34495e 0%, #2c3e50 100%);
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(44, 62, 80, 0.4);
    }
    
    .btn-secondary {
        background: rgba(255, 255, 255, 0.9);
        color: #2c3e50;
        border: 2px solid rgba(212, 175, 55, 0.3);
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    }
    
    .btn-secondary:hover {
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        border-color: #d4af37;
        color: white;
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(212, 175, 55, 0.3);
    }
`;
document.head.appendChild(style);