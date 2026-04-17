// Active Deliveries JavaScript Functions

// Filter deliveries based on status and priority
function filterDeliveries() {
    const statusFilter = document.getElementById('statusFilter').value;
    const priorityFilter = document.getElementById('priorityFilter').value;
    const deliveryCards = document.querySelectorAll('.delivery-card');
    let emptyState = document.getElementById('emptyState');
    let visibleCount = 0;

    deliveryCards.forEach(card => {
        const cardStatus = card.getAttribute('data-status');
        const cardPriority = card.getAttribute('data-priority');
        
        let showCard = true;
        
        // Filter by status
        if (statusFilter !== 'all' && cardStatus !== statusFilter) {
            showCard = false;
        }
        
        // Filter by priority
        if (priorityFilter !== 'all' && cardPriority !== priorityFilter) {
            showCard = false;
        }
        
        if (showCard) {
            card.style.display = 'block';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });

    // Create empty state if it doesn't exist
    if (!emptyState) {
        emptyState = document.createElement('div');
        emptyState.id = 'emptyState';
        emptyState.className = 'empty-state';
        emptyState.innerHTML = `
            <div class="empty-icon">
                <i class="bi bi-truck"></i>
            </div>
            <h3>No Matching Deliveries</h3>
            <p>No deliveries match your current filter criteria.</p>
            <button class="btn btn-primary" onclick="resetFilters()">
                <i class="bi bi-arrow-clockwise"></i>
                Reset Filters
            </button>
        `;
        document.querySelector('.deliveries-grid').parentElement.appendChild(emptyState);
    }

    // Show empty state if no cards are visible
    if (visibleCount === 0) {
        emptyState.style.display = 'block';
        emptyState.querySelector('h3').textContent = 'No Matching Deliveries';
        emptyState.querySelector('p').textContent = 'No deliveries match your current filter criteria.';
        // Update button to reset filters
        const emptyBtn = emptyState.querySelector('.btn');
        if (emptyBtn) {
            emptyBtn.innerHTML = '<i class="bi bi-arrow-clockwise"></i> Reset Filters';
            emptyBtn.onclick = resetFilters;
        }
    } else {
        emptyState.style.display = 'none';
    }

    console.log(`🔍 Filtered deliveries: ${visibleCount} visible`);
}

// Reset all filters
function resetFilters() {
    console.log('🔄 Resetting filters...');
    
    // Reset filter dropdowns
    document.getElementById('statusFilter').value = 'all';
    document.getElementById('priorityFilter').value = 'all';
    document.getElementById('sortBy').value = 'default';
    
    // Show all delivery cards
    const deliveryCards = document.querySelectorAll('.delivery-card');
    deliveryCards.forEach(card => {
        card.style.display = 'block';
    });
    
    // Hide empty state
    const emptyState = document.getElementById('emptyState');
    if (emptyState) {
        // Check if there are any cards at all
        if (deliveryCards.length === 0) {
            emptyState.style.display = 'block';
            emptyState.querySelector('h3').textContent = 'No Active Deliveries';
            emptyState.querySelector('p').textContent = 'You don\'t have any active deliveries at the moment.';
            // Update button to browse deliveries
            const emptyBtn = emptyState.querySelector('.btn');
            if (emptyBtn) {
                emptyBtn.innerHTML = '<i class="bi bi-list-task"></i> Browse Available Deliveries';
                emptyBtn.onclick = () => { window.location.href = '/available_deliveries'; };
            }
        } else {
            emptyState.style.display = 'none';
        }
    }
    
    console.log('✅ Filters reset successfully');
}

// Sort deliveries
function sortDeliveries() {
    const sortBy = document.getElementById('sortBy').value;
    const deliveriesGrid = document.getElementById('deliveriesGrid');
    const deliveryCards = Array.from(document.querySelectorAll('.delivery-card'));
    
    // Only sort visible cards
    const visibleCards = deliveryCards.filter(card => card.style.display !== 'none');
    
    visibleCards.sort((a, b) => {
        switch (sortBy) {
            case 'priority':
                // Sort urgent first
                const aPriority = a.getAttribute('data-priority');
                const bPriority = b.getAttribute('data-priority');
                if (aPriority === 'urgent' && bPriority !== 'urgent') return -1;
                if (bPriority === 'urgent' && aPriority !== 'urgent') return 1;
                return 0;
                
            case 'fee_high':
                // Sort by delivery fee (high to low)
                const aFee = parseFloat(a.querySelector('.fee-amount').textContent.replace('₱', '').replace('Free', '0'));
                const bFee = parseFloat(b.querySelector('.fee-amount').textContent.replace('₱', '').replace('Free', '0'));
                return bFee - aFee;
                
            case 'fee_low':
                // Sort by delivery fee (low to high)
                const aFeeLow = parseFloat(a.querySelector('.fee-amount').textContent.replace('₱', '').replace('Free', '0'));
                const bFeeLow = parseFloat(b.querySelector('.fee-amount').textContent.replace('₱', '').replace('Free', '0'));
                return aFeeLow - bFeeLow;
                
            case 'value_high':
                // Sort by order value (high to low)
                const aValue = parseFloat(a.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                const bValue = parseFloat(b.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                return bValue - aValue;
                
            case 'value_low':
                // Sort by order value (low to high)
                const aValueLow = parseFloat(a.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                const bValueLow = parseFloat(b.querySelector('.detail-item .bi-currency-dollar').parentElement.textContent.replace('₱', '').trim());
                return aValueLow - bValueLow;
                
            case 'default':
            default:
                // Keep original order (by order ID)
                const aId = parseInt(a.querySelector('h3').textContent.replace('Order #', ''));
                const bId = parseInt(b.querySelector('h3').textContent.replace('Order #', ''));
                return aId - bId;
        }
    });
    
    // Re-append sorted cards (only visible ones, hidden ones stay in place)
    visibleCards.forEach(card => {
        deliveriesGrid.appendChild(card);
    });

    console.log(`📊 Sorted deliveries by: ${sortBy}`);
}

// Start pickup for a delivery
function startPickup(orderId) {
    console.log(`🚀 Starting pickup for order: ${orderId}`);
    
    // Show confirmation dialog
    if (confirm(`Are you sure you want to start pickup for Order #${orderId}?`)) {
        // Find the card and button
        const cards = document.querySelectorAll('.delivery-card');
        let targetCard = null;
        let startBtn = null;
        
        cards.forEach(card => {
            if (card.querySelector('h3').textContent.includes(orderId)) {
                targetCard = card;
                startBtn = card.querySelector('.btn-primary');
            }
        });
        
        // Show loading state on button
        if (startBtn) {
            startBtn.disabled = true;
            startBtn.innerHTML = '<i class="bi bi-arrow-clockwise spin"></i> Starting...';
            startBtn.style.opacity = '0.7';
            startBtn.style.cursor = 'not-allowed';
        }
        
        // Disable card interactions
        if (targetCard) {
            targetCard.style.opacity = '0.6';
            targetCard.style.pointerEvents = 'none';
        }
        
        // Make API call to start pickup
        fetch('/api/start-pickup', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ orderId: orderId })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Show success modal
                showSuccessModal('pickup', orderId);
                
                // Update the card status after a short delay
                setTimeout(() => {
                    location.reload();
                }, 2000);
            } else {
                showNotification(data.message || 'Failed to start pickup', 'error');
                // Reset button and card state
                if (startBtn) {
                    startBtn.disabled = false;
                    startBtn.innerHTML = '<i class="bi bi-play-circle"></i> Start Pickup';
                    startBtn.style.opacity = '1';
                    startBtn.style.cursor = 'pointer';
                }
                if (targetCard) {
                    targetCard.style.opacity = '1';
                    targetCard.style.pointerEvents = 'auto';
                }
            }
        })
        .catch(error => {
            console.error('Error starting pickup:', error);
            showNotification('Network error. Please check your connection.', 'error');
            // Reset button and card state
            if (startBtn) {
                startBtn.disabled = false;
                startBtn.innerHTML = '<i class="bi bi-play-circle"></i> Start Pickup';
                startBtn.style.opacity = '1';
                startBtn.style.cursor = 'pointer';
            }
            if (targetCard) {
                targetCard.style.opacity = '1';
                targetCard.style.pointerEvents = 'auto';
            }
        });
    }
}

// Confirm pickup from seller
function confirmPickup(orderId) {
    console.log(`📦 Confirming pickup for order: ${orderId}`);
    
    // Show confirmation dialog
    if (confirm(`Mark Order #${orderId} as picked up from the seller?`)) {
        // Find the card and button
        const cards = document.querySelectorAll('.delivery-card');
        let targetCard = null;
        let confirmBtn = null;
        
        cards.forEach(card => {
            if (card.querySelector('h3').textContent.includes(orderId)) {
                targetCard = card;
                confirmBtn = card.querySelector('.btn-primary');
            }
        });
        
        // Show loading state on button
        if (confirmBtn) {
            confirmBtn.disabled = true;
            confirmBtn.innerHTML = '<i class="bi bi-arrow-clockwise spin"></i> Confirming...';
            confirmBtn.style.opacity = '0.7';
            confirmBtn.style.cursor = 'not-allowed';
        }
        
        // Disable card interactions
        if (targetCard) {
            targetCard.style.opacity = '0.6';
            targetCard.style.pointerEvents = 'none';
        }
        
        // Make API call to confirm pickup
        fetch('/api/confirm-pickup', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ orderId: orderId })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Show success modal
                showSuccessModal('confirm', orderId);
                
                // Refresh the page to show updated status
                setTimeout(() => {
                    location.reload();
                }, 2000);
            } else {
                showNotification(data.message || 'Failed to confirm pickup', 'error');
                // Reset button and card state
                if (confirmBtn) {
                    confirmBtn.disabled = false;
                    confirmBtn.innerHTML = '<i class="bi bi-check-circle"></i> Mark as Picked Up';
                    confirmBtn.style.opacity = '1';
                    confirmBtn.style.cursor = 'pointer';
                }
                if (targetCard) {
                    targetCard.style.opacity = '1';
                    targetCard.style.pointerEvents = 'auto';
                }
            }
        })
        .catch(error => {
            console.error('Error confirming pickup:', error);
            showNotification('Network error. Please check your connection.', 'error');
            // Reset button and card state
            if (confirmBtn) {
                confirmBtn.disabled = false;
                confirmBtn.innerHTML = '<i class="bi bi-check-circle"></i> Mark as Picked Up';
                confirmBtn.style.opacity = '1';
                confirmBtn.style.cursor = 'pointer';
            }
            if (targetCard) {
                targetCard.style.opacity = '1';
                targetCard.style.pointerEvents = 'auto';
            }
        });
    }
}

// Mark delivery as delivered
function markAsDelivered(orderId) {
    console.log(`✅ Marking delivery as completed for order: ${orderId}`);
    
    // Debug: Check what cards we have
    const cards = document.querySelectorAll('.delivery-card');
    cards.forEach(card => {
        const orderTitle = card.querySelector('h3').textContent;
        const status = card.getAttribute('data-status');
        console.log(`Card: ${orderTitle}, Status: ${status}`);
    });
    
    // Show confirmation dialog
    if (confirm(`Are you sure you want to mark Order #${orderId} as delivered?`)) {
        // Find the card and button
        const cards = document.querySelectorAll('.delivery-card');
        let targetCard = null;
        let deliverBtn = null;
        
        cards.forEach(card => {
            if (card.querySelector('h3').textContent.includes(orderId)) {
                targetCard = card;
                deliverBtn = card.querySelector('.btn-primary');
            }
        });
        
        // Show loading state on button
        if (deliverBtn) {
            deliverBtn.disabled = true;
            deliverBtn.innerHTML = '<i class="bi bi-arrow-clockwise spin"></i> Processing...';
            deliverBtn.style.opacity = '0.7';
            deliverBtn.style.cursor = 'not-allowed';
        }
        
        // Disable card interactions
        if (targetCard) {
            targetCard.style.opacity = '0.6';
            targetCard.style.pointerEvents = 'none';
        }
        
        // Make API call to mark as delivered
        fetch('/api/mark-delivered', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ orderId: orderId })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Show success modal
                showSuccessModal('delivered', orderId);
                
                // Remove the card with animation after modal
                setTimeout(() => {
                    if (targetCard) {
                        targetCard.style.animation = 'fadeOut 0.5s ease-out forwards';
                        setTimeout(() => {
                            targetCard.remove();
                            checkEmptyState();
                            updateStats();
                        }, 500);
                    }
                }, 2000);
            } else {
                showNotification(data.message || 'Failed to mark as delivered', 'error');
                // Reset button and card state
                if (deliverBtn) {
                    deliverBtn.disabled = false;
                    deliverBtn.innerHTML = '<i class="bi bi-check-circle"></i> Mark Delivered';
                    deliverBtn.style.opacity = '1';
                    deliverBtn.style.cursor = 'pointer';
                }
                if (targetCard) {
                    targetCard.style.opacity = '1';
                    targetCard.style.pointerEvents = 'auto';
                }
            }
        })
        .catch(error => {
            console.error('Error marking as delivered:', error);
            showNotification('Network error. Please check your connection.', 'error');
            // Reset button and card state
            if (deliverBtn) {
                deliverBtn.disabled = false;
                deliverBtn.innerHTML = '<i class="bi bi-check-circle"></i> Mark Delivered';
                deliverBtn.style.opacity = '1';
                deliverBtn.style.cursor = 'pointer';
            }
            if (targetCard) {
                targetCard.style.opacity = '1';
                targetCard.style.pointerEvents = 'auto';
            }
        });
    }
}

// View route for a delivery
function viewRoute(orderId) {
    console.log(`🗺️ Viewing route for order: ${orderId}`);
    
    // Find the delivery card
    const cards = document.querySelectorAll('.delivery-card');
    let deliveryData = null;
    
    cards.forEach(card => {
        if (card.querySelector('h3').textContent.includes(orderId)) {
            const pickupAddress = card.querySelector('.location-item.pickup .location-address').textContent;
            const deliveryAddress = card.querySelector('.location-item.delivery .location-address').textContent;
            const customerName = card.querySelector('.customer-name').textContent;
            const customerPhone = card.querySelector('.detail-item .bi-telephone').parentElement.textContent.trim();
            
            deliveryData = {
                orderId: orderId,
                pickupAddress: pickupAddress,
                deliveryAddress: deliveryAddress,
                customerName: customerName,
                customerPhone: customerPhone
            };
        }
    });
    
    if (!deliveryData) {
        showNotification('Could not find delivery information', 'error');
        return;
    }
    
    // Create modal with route information
    const modal = document.createElement('div');
    modal.className = 'modal-overlay';
    modal.innerHTML = `
        <div class="modal-content route-modal">
            <div class="modal-header">
                <h3><i class="bi bi-map"></i> Route Details - Order #${deliveryData.orderId}</h3>
                <button class="modal-close" onclick="this.closest('.modal-overlay').remove()">
                    <i class="bi bi-x"></i>
                </button>
            </div>
            <div class="modal-body">
                <div class="route-info">
                    <div class="route-step">
                        <div class="step-icon pickup">
                            <i class="bi bi-shop"></i>
                        </div>
                        <div class="step-details">
                            <h4>Pickup Location</h4>
                            <p>${deliveryData.pickupAddress}</p>
                            <a href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(deliveryData.pickupAddress)}" 
                               target="_blank" class="map-link">
                                <i class="bi bi-geo-alt"></i> Open in Google Maps
                            </a>
                        </div>
                    </div>
                    
                    <div class="route-arrow">
                        <i class="bi bi-arrow-down"></i>
                    </div>
                    
                    <div class="route-step">
                        <div class="step-icon delivery">
                            <i class="bi bi-house"></i>
                        </div>
                        <div class="step-details">
                            <h4>Delivery Location</h4>
                            <p>${deliveryData.deliveryAddress}</p>
                            <a href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(deliveryData.deliveryAddress)}" 
                               target="_blank" class="map-link">
                                <i class="bi bi-geo-alt"></i> Open in Google Maps
                            </a>
                        </div>
                    </div>
                    
                    <div class="route-actions">
                        <a href="https://www.google.com/maps/dir/?api=1&origin=${encodeURIComponent(deliveryData.pickupAddress)}&destination=${encodeURIComponent(deliveryData.deliveryAddress)}&travelmode=driving" 
                           target="_blank" class="btn btn-primary">
                            <i class="bi bi-navigation"></i> Get Directions
                        </a>
                    </div>
                </div>
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

// Update delivery status
function updateDeliveryStatus(card, newStatus, statusText, timeText) {
    const statusBadge = card.querySelector('.status-badge');
    const statusTime = card.querySelector('.status-time');
    
    // Update status badge
    statusBadge.className = `status-badge ${newStatus}`;
    statusBadge.innerHTML = `<i class="bi bi-truck"></i> ${statusText}`;
    
    // Update time text
    if (statusTime) {
        statusTime.textContent = timeText;
    }
    
    // Update card data attribute
    card.setAttribute('data-status', newStatus);
    
    console.log(`📝 Updated status for delivery to: ${statusText}`);
}

// Check if we should show empty state
function checkEmptyState() {
    const allCards = document.querySelectorAll('.delivery-card');
    const visibleCards = document.querySelectorAll('.delivery-card:not([style*="display: none"])');
    let emptyState = document.getElementById('emptyState');
    
    // Create empty state if it doesn't exist
    if (!emptyState) {
        emptyState = document.createElement('div');
        emptyState.id = 'emptyState';
        emptyState.className = 'empty-state';
        emptyState.innerHTML = `
            <div class="empty-icon">
                <i class="bi bi-truck"></i>
            </div>
            <h3>No Active Deliveries</h3>
            <p>You don't have any active deliveries at the moment.</p>
            <a href="/available_deliveries" class="btn btn-primary">
                <i class="bi bi-list-task"></i>
                Browse Available Deliveries
            </a>
        `;
        document.querySelector('.deliveries-grid').parentElement.appendChild(emptyState);
    }
    
    if (visibleCards.length === 0) {
        emptyState.style.display = 'block';
        
        // Check if it's because of filters or no deliveries at all
        if (allCards.length === 0) {
            emptyState.querySelector('h3').textContent = 'No Active Deliveries';
            emptyState.querySelector('p').textContent = 'You don\'t have any active deliveries at the moment.';
            const emptyBtn = emptyState.querySelector('.btn');
            if (emptyBtn) {
                emptyBtn.innerHTML = '<i class="bi bi-list-task"></i> Browse Available Deliveries';
                emptyBtn.onclick = () => { window.location.href = '/available_deliveries'; };
            }
        } else {
            emptyState.querySelector('h3').textContent = 'No Matching Deliveries';
            emptyState.querySelector('p').textContent = 'No deliveries match your current filter criteria.';
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

// Update statistics
function updateStats() {
    // This would typically fetch updated stats from the backend
    console.log('📊 Updating delivery statistics...');
    
    // Placeholder for stats update
    // You would update the header stats here
}

// Show notification
function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="bi bi-${getNotificationIcon(type)}"></i>
            <span>${message}</span>
        </div>
    `;
    
    // Add styles
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${getNotificationColor(type)};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        z-index: 1000;
        animation: slideInRight 0.3s ease-out;
    `;
    
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-out';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Get notification icon based on type
function getNotificationIcon(type) {
    switch (type) {
        case 'success': return 'check-circle';
        case 'error': return 'exclamation-triangle';
        case 'warning': return 'exclamation-circle';
        default: return 'info-circle';
    }
}

// Get notification color based on type
function getNotificationColor(type) {
    switch (type) {
        case 'success': return '#27ae60';
        case 'error': return '#e74c3c';
        case 'warning': return '#f39c12';
        default: return '#3498db';
    }
}

// Add CSS animations for notifications and modals
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    @keyframes fadeOut {
        from {
            opacity: 1;
            transform: translateY(0);
        }
        to {
            opacity: 0;
            transform: translateY(-20px);
        }
    }
    
    @keyframes spin {
        from {
            transform: rotate(0deg);
        }
        to {
            transform: rotate(360deg);
        }
    }
    
    .spin {
        animation: spin 1s linear infinite;
    }
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .route-modal {
        background: rgba(255, 255, 255, 0.98);
        border: 1px solid rgba(212, 175, 55, 0.2);
        border-radius: 20px;
        max-width: 600px;
        width: 100%;
        max-height: 90vh;
        overflow-y: auto;
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
        position: relative;
    }
    
    .route-modal::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        border-radius: 20px 20px 0 0;
    }
    
    .route-modal .modal-header {
        padding: 2rem;
        border-bottom: 1px solid rgba(212, 175, 55, 0.2);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 20px 20px 0 0;
        margin-top: 4px;
    }
    
    .route-modal .modal-header h3 {
        margin: 0;
        font-size: 1.5rem;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        background: linear-gradient(135deg, #2c3e50, #34495e);
        -webkit-background-clip: text;
        background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    
    .route-modal .modal-close {
        background: rgba(255, 255, 255, 0.9);
        border: 2px solid rgba(212, 175, 55, 0.3);
        color: #2c3e50;
        font-size: 1.5rem;
        cursor: pointer;
        padding: 0.75rem;
        border-radius: 50%;
        width: 45px;
        height: 45px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
    }
    
    .route-modal .modal-close:hover {
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        color: white;
        border-color: #d4af37;
        transform: scale(1.1);
    }
    
    .route-modal .modal-body {
        padding: 2rem;
        background: linear-gradient(135deg, #fafafa 0%, #f5f5f5 100%);
    }
    
    .route-info {
        display: flex;
        flex-direction: column;
        gap: 1.5rem;
    }
    
    .route-step {
        display: flex;
        gap: 1rem;
        padding: 1.5rem;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px;
        border: 1px solid rgba(212, 175, 55, 0.2);
        position: relative;
        transition: all 0.3s ease;
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
    }
    
    .route-step::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        border-radius: 15px 15px 0 0;
    }
    
    .route-step:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(212, 175, 55, 0.15);
        border-color: rgba(212, 175, 55, 0.4);
    }
    
    .step-icon {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        color: white;
        flex-shrink: 0;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    }
    
    .step-icon.pickup {
        background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
    }
    
    .step-icon.delivery {
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
    }
    
    .step-details {
        flex: 1;
    }
    
    .step-details h4 {
        margin: 0 0 0.5rem 0;
        color: #2c3e50;
        font-size: 1.1rem;
        font-weight: 600;
    }
    
    .step-details p {
        margin: 0 0 0.75rem 0;
        color: #555;
        line-height: 1.5;
    }
    
    .map-link {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        color: #d4af37;
        text-decoration: none;
        font-size: 0.9rem;
        font-weight: 600;
        transition: all 0.3s ease;
    }
    
    .map-link:hover {
        color: #2c3e50;
        gap: 0.75rem;
    }
    
    .route-arrow {
        text-align: center;
        color: #d4af37;
        font-size: 2rem;
        margin: -0.5rem 0;
    }
    
    .customer-contact {
        padding: 1.5rem;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 15px;
        border: 1px solid rgba(212, 175, 55, 0.2);
        position: relative;
        backdrop-filter: blur(5px);
        -webkit-backdrop-filter: blur(5px);
    }
    
    .customer-contact::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
        border-radius: 15px 15px 0 0;
    }
    
    .customer-contact h4 {
        margin: 0 0 1rem 0;
        color: #2c3e50;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-weight: 600;
    }
    
    .customer-contact p {
        margin: 0.5rem 0;
        color: #2c3e50;
    }
    
    .customer-contact p strong {
        color: #2c3e50;
        font-weight: 600;
    }
    
    .call-btn {
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.75rem 1.5rem;
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        color: white;
        text-decoration: none;
        border-radius: 25px;
        margin-top: 1rem;
        transition: all 0.3s ease;
        font-weight: 600;
        box-shadow: 0 4px 15px rgba(212, 175, 55, 0.3);
    }
    
    .call-btn:hover {
        background: linear-gradient(135deg, #f4d03f 0%, #d4af37 100%);
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(212, 175, 55, 0.4);
    }
    
    .route-actions {
        text-align: center;
        padding-top: 1rem;
        display: flex;
        gap: 1rem;
        justify-content: center;
        flex-wrap: wrap;
    }
    
    .route-actions .btn {
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
        font-size: 1rem;
    }
    
    .route-actions .btn-secondary {
        background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(212, 175, 55, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .route-actions .btn-secondary::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s;
    }
    
    .route-actions .btn-secondary:hover::before {
        left: 100%;
    }
    
    .route-actions .btn-secondary:hover {
        background: linear-gradient(135deg, #f4d03f 0%, #d4af37 100%);
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(212, 175, 55, 0.4);
    }
    
    .route-actions .btn-primary {
        background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(44, 62, 80, 0.3);
        position: relative;
        overflow: hidden;
    }
    
    .route-actions .btn-primary::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
        transition: left 0.5s;
    }
    
    .route-actions .btn-primary:hover::before {
        left: 100%;
    }
    
    .route-actions .btn-primary:hover {
        background: linear-gradient(135deg, #34495e 0%, #2c3e50 100%);
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(44, 62, 80, 0.4);
    }
`;
document.head.appendChild(style);

// Show success modal with dynamic content
function showSuccessModal(type, orderId) {
    const modal = document.getElementById('successModal');
    const title = modal.querySelector('#success-modal-title');
    const thankYouMsg = modal.querySelector('.thank-you-message');
    const orderMsg = modal.querySelector('.order-message');
    const viewBtn = modal.querySelector('.view-orders-btn');
    
    // Update modal content based on action type
    switch(type) {
        case 'pickup':
            title.textContent = 'Pickup Started Successfully!';
            thankYouMsg.textContent = "You're on your way!";
            orderMsg.textContent = 'Your pickup has been initiated. Please proceed to the seller\'s location to collect the items.';
            viewBtn.innerHTML = '<i class="fas fa-map" aria-hidden="true"></i> View Route';
            viewBtn.onclick = () => { closeSuccessModal(); viewRoute(orderId); };
            break;
        case 'confirm':
            title.textContent = 'Pickup Confirmed Successfully!';
            thankYouMsg.textContent = 'Items Collected!';
            orderMsg.textContent = 'You have successfully picked up the items from the seller. Now proceed to deliver them to the customer.';
            viewBtn.innerHTML = '<i class="fas fa-map" aria-hidden="true"></i> View Delivery Route';
            viewBtn.onclick = () => { closeSuccessModal(); viewRoute(orderId); };
            break;
        case 'delivered':
            title.textContent = 'Delivery Completed Successfully!';
            thankYouMsg.textContent = 'Great Job!';
            orderMsg.textContent = 'You have successfully completed this delivery. The customer has received their order. Keep up the excellent work!';
            viewBtn.innerHTML = '<i class="fas fa-history" aria-hidden="true"></i> View Delivery History';
            viewBtn.onclick = () => { window.location.href = '/delivery_history'; };
            break;
    }
    
    if (modal) {
        modal.classList.add('show');
        modal.setAttribute('aria-hidden', 'false');
    }
}

// Close success modal
function closeSuccessModal() {
    const modal = document.getElementById('successModal');
    if (modal) {
        modal.classList.remove('show');
        modal.setAttribute('aria-hidden', 'true');
    }
}

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚚 Active Deliveries page loaded');
    
    // Verify functions are available
    console.log('✅ contactSeller function available:', typeof contactSeller === 'function');
    console.log('✅ contactBuyer function available:', typeof contactBuyer === 'function');
    
    // Add data-order-id attributes to cards for easier identification
    const deliveryCards = document.querySelectorAll('.delivery-card');
    deliveryCards.forEach((card) => {
        const orderTitle = card.querySelector('h3').textContent;
        const orderId = orderTitle.replace('Order #', '');
        card.setAttribute('data-order-id', orderId);
    });
    
    // Check initial empty state
    checkEmptyState();
});

// Real-time updates (placeholder for WebSocket or polling)
function startRealTimeUpdates() {
    console.log('🔄 Starting real-time updates...');
    
    // This would typically connect to a WebSocket or start polling
    // setInterval(() => {
    //     fetchActiveDeliveries();
    // }, 30000); // Update every 30 seconds
}

// Fetch active deliveries from backend (placeholder)
function fetchActiveDeliveries() {
    console.log('📡 Fetching active deliveries...');
    
    // This would make an API call to get updated delivery data
    // fetch('/api/rider/active-deliveries')
    //     .then(response => response.json())
    //     .then(data => {
    //         updateDeliveriesDisplay(data);
    //     });
}

// Contact seller function
function contactSeller(orderId) {
    console.log(`💬 Opening chat with seller for order: ${orderId}`);
    
    // Close the route modal first
    const routeModal = document.querySelector('.modal-overlay');
    if (routeModal) {
        routeModal.remove();
    }
    
    // Show loading notification
    showNotification('Loading chat...', 'info');
    
    // Fetch order details to get seller information
    fetch(`/api/order-details/${orderId}`)
        .then(response => {
            console.log('📡 API Response status:', response.status);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('📦 Order details response:', data);
            if (data.success && data.order) {
                const sellerEmail = data.order.seller.email;
                const sellerName = data.order.seller.name || 'Seller';
                const productName = data.order.product_name || 'Order Items';
                
                console.log('📧 Seller info:', { sellerEmail, sellerName, orderId, productName });
                
                // Check if the function exists
                console.log('🔍 Checking for openRiderSellerChatModal function...');
                console.log('Script loaded flag:', window.riderSellerChatLoaded);
                console.log('Function type:', typeof openRiderSellerChatModal);
                console.log('Window function type:', typeof window.openRiderSellerChatModal);
                
                if (typeof openRiderSellerChatModal === 'function') {
                    console.log('✅ Opening chat modal...');
                    openRiderSellerChatModal(sellerEmail, sellerName, orderId, productName);
                } else if (typeof window.openRiderSellerChatModal === 'function') {
                    console.log('✅ Opening chat modal via window object...');
                    window.openRiderSellerChatModal(sellerEmail, sellerName, orderId, productName);
                } else {
                    console.error('❌ openRiderSellerChatModal function not found');
                    console.log('Available window functions:', Object.getOwnPropertyNames(window).filter(name => name.toLowerCase().includes('chat')));
                    console.log('Available global functions:', Object.getOwnPropertyNames(window).filter(name => name.toLowerCase().includes('modal')));
                    
                    // Try to manually load the function after a delay
                    setTimeout(() => {
                        if (typeof window.openRiderSellerChatModal === 'function') {
                            console.log('🔄 Function became available after delay, trying again...');
                            window.openRiderSellerChatModal(sellerEmail, sellerName, orderId, productName);
                        } else {
                            console.error('❌ Function still not available after delay');
                            
                            // Try the test function as a last resort
                            if (typeof window.testChatModal === 'function') {
                                console.log('🧪 Using test modal function');
                                window.testChatModal();
                                showNotification('Chat opened in test mode. Some features may not work.', 'warning');
                            } else {
                                showNotification('Chat feature is not available. Please refresh the page and try again.', 'error');
                            }
                        }
                    }, 500);
                }
            } else {
                console.error('❌ Failed to load seller info:', data.message || 'No order data');
                showNotification(data.message || 'Unable to load seller information', 'error');
            }
        })
        .catch(error => {
            console.error('❌ Error fetching order details:', error);
            showNotification('Error loading chat. Please try again.', 'error');
        });
}

// Contact buyer function
function contactBuyer(orderId) {
    console.log(`💬 Opening chat with buyer for order: ${orderId}`);
    
    // Close the route modal first
    const routeModal = document.querySelector('.modal-overlay');
    if (routeModal) {
        routeModal.remove();
    }
    
    // Show loading notification
    showNotification('Loading chat...', 'info');
    
    // Fetch order details to get buyer information
    fetch(`/api/order-details/${orderId}`)
        .then(response => {
            console.log('📡 API Response status:', response.status);
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('📦 Order details response:', data);
            if (data.success && data.order) {
                const buyerEmail = data.order.buyer.email;
                const buyerName = data.order.buyer.name || 'Buyer';
                const productName = data.order.product_name || 'Order Items';
                
                console.log('📧 Buyer info:', { buyerEmail, buyerName, orderId, productName });
                
                // Check if the function exists
                console.log('🔍 Checking for openRiderBuyerChatModal function...');
                console.log('Function type:', typeof openRiderBuyerChatModal);
                console.log('Window function type:', typeof window.openRiderBuyerChatModal);
                
                if (typeof openRiderBuyerChatModal === 'function') {
                    console.log('✅ Opening chat modal...');
                    openRiderBuyerChatModal(buyerEmail, buyerName, orderId, productName);
                } else if (typeof window.openRiderBuyerChatModal === 'function') {
                    console.log('✅ Opening chat modal via window object...');
                    window.openRiderBuyerChatModal(buyerEmail, buyerName, orderId, productName);
                } else {
                    console.error('❌ openRiderBuyerChatModal function not found');
                    
                    // Try to manually load the function after a delay
                    setTimeout(() => {
                        if (typeof window.openRiderBuyerChatModal === 'function') {
                            console.log('🔄 Function became available after delay, trying again...');
                            window.openRiderBuyerChatModal(buyerEmail, buyerName, orderId, productName);
                        } else {
                            console.error('❌ Function still not available after delay');
                            showNotification('Chat feature is not available. Please refresh the page and try again.', 'error');
                        }
                    }, 500);
                }
            } else {
                console.error('❌ Failed to load buyer info:', data.message || 'No order data');
                showNotification(data.message || 'Unable to load buyer information', 'error');
            }
        })
        .catch(error => {
            console.error('❌ Error fetching order details:', error);
            showNotification('Error loading chat. Please try again.', 'error');
        });
}
