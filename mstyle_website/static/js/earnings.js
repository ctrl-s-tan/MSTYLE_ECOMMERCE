// Earnings JavaScript Functions

// Update earnings data based on time range
function updateEarningsData() {
    const timeRange = document.getElementById('timeRange').value;
    const customDateRange = document.getElementById('customDateRange');
    
    if (timeRange === 'custom') {
        customDateRange.style.display = 'block';
        return;
    } else {
        customDateRange.style.display = 'none';
    }
    
    // Reload page with time range filter
    window.location.href = `${window.location.pathname}?time_range=${timeRange}`;
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
    
    // Reload page with custom date range
    window.location.href = `${window.location.pathname}?start_date=${startDateInput.value}&end_date=${endDateInput.value}`;
}

// Filter by status
function filterByStatus() {
    applyAllFilters();
}

// Filter by date range
function filterByDate() {
    const dateRange = document.getElementById('dateRange').value;
    const customDateRange = document.getElementById('customDateRange');
    
    if (dateRange === 'custom') {
        customDateRange.style.display = 'block';
    } else {
        customDateRange.style.display = 'none';
        applyAllFilters();
    }
}

// Search earnings
function searchEarnings() {
    applyAllFilters();
}

// Reset all filters
function resetFilters() {
    document.getElementById('dateRange').value = 'month';
    document.getElementById('statusFilter').value = 'all';
    document.getElementById('searchInput').value = '';
    document.getElementById('customDateRange').style.display = 'none';
    applyAllFilters();
}

// Apply all filters together
function applyAllFilters() {
    const statusFilter = document.getElementById('statusFilter').value;
    const dateRange = document.getElementById('dateRange').value;
    const searchQuery = document.getElementById('searchInput').value.toLowerCase();
    const tableRows = document.querySelectorAll('.table tbody tr');
    let visibleCount = 0;
    
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    tableRows.forEach(row => {
        if (row.querySelector('td[colspan]')) {
            return;
        }
        
        let showRow = true;
        
        // Status filter
        const statusBadge = row.querySelector('.status-badge');
        if (statusBadge && statusFilter !== 'all') {
            const rowStatus = statusBadge.textContent.trim().toLowerCase();
            if (rowStatus !== statusFilter) {
                showRow = false;
            }
        }
        
        // Date filter
        if (showRow && dateRange !== 'all' && dateRange !== 'custom') {
            const dateCell = row.cells[1].textContent.trim();
            const rowDate = new Date(dateCell);
            
            if (!isNaN(rowDate.getTime())) {
                rowDate.setHours(0, 0, 0, 0);
                
                switch(dateRange) {
                    case 'today':
                        if (rowDate.getTime() !== today.getTime()) {
                            showRow = false;
                        }
                        break;
                    case 'week':
                        const weekAgo = new Date(today);
                        weekAgo.setDate(weekAgo.getDate() - 7);
                        if (rowDate < weekAgo) {
                            showRow = false;
                        }
                        break;
                    case 'month':
                        const monthAgo = new Date(today);
                        monthAgo.setMonth(monthAgo.getMonth() - 1);
                        if (rowDate < monthAgo) {
                            showRow = false;
                        }
                        break;
                    case 'last_month':
                        const lastMonthStart = new Date(today.getFullYear(), today.getMonth() - 1, 1);
                        const lastMonthEnd = new Date(today.getFullYear(), today.getMonth(), 0);
                        if (rowDate < lastMonthStart || rowDate > lastMonthEnd) {
                            showRow = false;
                        }
                        break;
                }
            }
        }
        
        // Search filter
        if (showRow && searchQuery) {
            const orderId = row.cells[0].textContent.toLowerCase();
            const buyerName = row.cells[2].textContent.toLowerCase();
            const sellerName = row.cells[3].textContent.toLowerCase();
            
            if (!orderId.includes(searchQuery) && 
                !buyerName.includes(searchQuery) && 
                !sellerName.includes(searchQuery)) {
                showRow = false;
            }
        }
        
        if (showRow) {
            row.style.display = '';
            visibleCount++;
        } else {
            row.style.display = 'none';
        }
    });
    
    checkEmptyState(visibleCount);
}

// Check if we should show empty state
function checkEmptyState(visibleCount) {
    const tbody = document.querySelector('.table tbody');
    let existingEmptyRow = tbody.querySelector('.filter-empty-row');
    
    if (visibleCount === 0 && !existingEmptyRow) {
        const emptyRow = document.createElement('tr');
        emptyRow.className = 'filter-empty-row';
        emptyRow.innerHTML = `
            <td colspan="9" class="filter-empty-state">
                <div class="empty-state-content">
                    <i class="bi bi-currency-dollar"></i>
                    <h5>No Matching Earnings</h5>
                    <p>No earnings match your current filter criteria.</p>
                </div>
            </td>
        `;
        tbody.appendChild(emptyRow);
    } else if (visibleCount > 0 && existingEmptyRow) {
        existingEmptyRow.remove();
    }
}

// Export earnings report
function exportEarnings() {
    console.log('📄 Exporting earnings report...');
    
    // Get visible table rows
    const visibleRows = Array.from(document.querySelectorAll('.table tbody tr'))
        .filter(row => row.style.display !== 'none' && !row.querySelector('td[colspan]'));
    
    if (visibleRows.length === 0) {
        alert('No earnings data to export');
        return;
    }
    
    // Create CSV data with updated headers including Platform Commission
    let csvContent = "Order ID,Delivery Date,Buyer Name,Seller Name,Status,Delivery Fee,Platform Commission (5%),COD Collected,Net Earnings\n";
    
    visibleRows.forEach(row => {
        const cells = row.querySelectorAll('td');
        const rowData = [];
        
        cells.forEach((cell, index) => {
            let text = cell.textContent.trim();
            
            // Clean up status badge text (remove icon)
            if (index === 4) { // Status column
                const statusBadge = cell.querySelector('.status-badge');
                if (statusBadge) {
                    text = statusBadge.textContent.trim().replace(/\s+/g, ' ');
                }
            }
            
            // For delivery date column (index 1), ensure it's treated as text
            if (index === 1) {
                // Add a tab character to force Excel to treat it as text
                text = '\t' + text;
            }
            
            // Remove extra whitespace and newlines
            text = text.replace(/\s+/g, ' ');
            // Escape quotes
            text = text.replace(/"/g, '""');
            rowData.push(`"${text}"`);
        });
        
        csvContent += rowData.join(',') + '\n';
    });
    
    // Download CSV
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    const today = new Date().toISOString().split('T')[0];
    
    link.setAttribute('href', url);
    link.setAttribute('download', `earnings_report_${today}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    console.log(`✅ Exported ${visibleRows.length} earnings records to CSV`);
    showNotification(`Exported ${visibleRows.length} earnings records successfully!`, 'success');
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="bi bi-${getNotificationIcon(type)}"></i>
            <span>${message}</span>
        </div>
    `;
    
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
        max-width: 400px;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.3s ease-out';
        setTimeout(() => {
            if (document.body.contains(notification)) {
                document.body.removeChild(notification);
            }
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

// Add CSS animations for notifications
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
    
    .notification-content {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
`;
document.head.appendChild(style);

// Initialize page
document.addEventListener('DOMContentLoaded', function() {
    console.log('💰 Earnings page loaded');
    
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
});
