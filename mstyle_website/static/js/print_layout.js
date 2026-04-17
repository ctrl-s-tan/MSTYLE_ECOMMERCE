// Print Layout JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Get data from localStorage (passed from main page)
    const printData = JSON.parse(localStorage.getItem('printData') || '{}');
    
    if (printData && Object.keys(printData).length > 0) {
        renderPrintLayout(printData);
        
        // Auto-print after rendering
        setTimeout(() => {
            window.print();
        }, 500);
    } else {
        document.getElementById('printContent').innerHTML = '<div class="no-data">No data available for printing</div>';
    }
});

function renderPrintLayout(data) {
    // Set date and report type
    const today = new Date();
    document.getElementById('printDate').textContent = today.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
    
    document.getElementById('reportType').textContent = data.reportType || 'Complete Analytics Report';
    
    // Set summary stats
    if (data.stats) {
        document.getElementById('printTotalOrders').textContent = data.stats.totalOrders || '0';
        document.getElementById('printPlatformCommission').textContent = data.stats.platformCommission || '₱0.00';
        document.getElementById('printTotalRevenue').textContent = data.stats.totalRevenue || '₱0.00';
        document.getElementById('printTotalUsers').textContent = data.stats.totalUsers || '0';
        document.getElementById('printTotalProducts').textContent = data.stats.totalProducts || '0';
    }
    
    // Render sections
    const contentDiv = document.getElementById('printContent');
    let html = '';
    
    // Inventory Products
    if (data.sections.includes('inventory') && data.inventoryProducts && data.inventoryProducts.length > 0) {
        html += renderInventorySection(data.inventoryProducts);
    }
    
    // Seller Performance
    if (data.sections.includes('seller') && data.sellerPerformance && data.sellerPerformance.length > 0) {
        html += renderSellerSection(data.sellerPerformance);
    }
    
    // Rider Analytics
    if (data.sections.includes('rider') && data.riderAnalytics && data.riderAnalytics.length > 0) {
        html += renderRiderSection(data.riderAnalytics);
    }
    
    // Buyer Insights
    if (data.sections.includes('buyer') && data.buyerInsights && data.buyerInsights.length > 0) {
        html += renderBuyerSection(data.buyerInsights);
    }
    
    // Promo Code Analytics
    if (data.sections.includes('promo') && data.promoCodeAnalytics && data.promoCodeAnalytics.length > 0) {
        html += renderPromoSection(data.promoCodeAnalytics);
    }
    
    // Platform Commission
    if (data.sections.includes('commission') && data.platformCommission && data.platformCommission.length > 0) {
        html += renderCommissionSection(data.platformCommission);
    }
    
    // Complaints & Issues
    if (data.sections.includes('issues') && data.complaintsIssues && data.complaintsIssues.length > 0) {
        html += renderIssuesSection(data.complaintsIssues);
    }
    
    contentDiv.innerHTML = html;
}

function renderInventorySection(products) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-boxes"></i> Inventory and Products Analytics</h2>';
    html += '<table><thead><tr>';
    html += '<th>No.</th><th>Product Name</th><th>Seller</th><th>Category</th><th>Status</th><th>Units Sold</th><th>Stock</th><th>Rating</th>';
    html += '</tr></thead><tbody>';
    
    products.forEach((product, index) => {
        const isActive = product.is_active === true || product.is_active === 'true' || product.is_active === 1;
        const isFlagged = product.is_flagged === true || product.is_flagged === 'true' || product.is_flagged === 1;
        let status = isFlagged ? '<span class="status-flagged">Flagged</span>' : 
                     !isActive ? '<span class="status-inactive">Inactive</span>' : 
                     '<span class="status-active">Active</span>';
        
        html += `<tr>
            <td>${index + 1}</td>
            <td>${product.product_name}</td>
            <td>${product.seller_name}</td>
            <td>${product.category}</td>
            <td>${status}</td>
            <td>${product.units_sold || 0}</td>
            <td>${product.stock || 0}</td>
            <td>${product.rating || 0}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const totalSold = products.reduce((sum, p) => sum + (p.units_sold || 0), 0);
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Products:</span><span>${products.length}</span></div>`;
    html += `<div class="total-row grand-total"><span>Total Units Sold:</span><span>${totalSold}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}

function renderSellerSection(sellers) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-store"></i> Seller Performance Reports</h2>';
    html += '<table><thead><tr>';
    html += '<th>No.</th><th>Seller Name</th><th>Products</th><th>Orders</th><th>Completed</th><th>Cancelled</th><th>Revenue</th><th>Flagged</th><th>Deactivated</th>';
    html += '</tr></thead><tbody>';
    
    sellers.forEach((seller, index) => {
        html += `<tr>
            <td>${index + 1}</td>
            <td>${seller.seller_name}</td>
            <td>${seller.total_products || 0}</td>
            <td>${seller.total_orders || 0}</td>
            <td>${seller.completed_orders || 0}</td>
            <td>${seller.cancelled_orders || 0}</td>
            <td>₱${(seller.total_revenue || 0).toFixed(2)}</td>
            <td>${seller.flagged_products || 0}</td>
            <td>${seller.deactivated_products || 0}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const totalRevenue = sellers.reduce((sum, s) => sum + (s.total_revenue || 0), 0);
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Sellers:</span><span>${sellers.length}</span></div>`;
    html += `<div class="total-row grand-total"><span>Total Revenue:</span><span>₱${totalRevenue.toFixed(2)}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}

function renderRiderSection(riders) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-motorcycle"></i> Rider/Delivery Analytics</h2>';
    html += '<table><thead><tr>';
    html += '<th>No.</th><th>Rider Name</th><th>Vehicle</th><th>Plate</th><th>Deliveries</th><th>Successful</th><th>Failed</th><th>Success Rate</th><th>Earnings</th>';
    html += '</tr></thead><tbody>';
    
    riders.forEach((rider, index) => {
        const successRate = rider.total_deliveries > 0 
            ? ((rider.successful_deliveries / rider.total_deliveries) * 100).toFixed(1) 
            : 0;
        
        html += `<tr>
            <td>${index + 1}</td>
            <td>${rider.rider_name}</td>
            <td>${rider.vehicle_type || 'N/A'}</td>
            <td>${rider.plate_number || 'N/A'}</td>
            <td>${rider.total_deliveries || 0}</td>
            <td>${rider.successful_deliveries || 0}</td>
            <td>${rider.failed_deliveries || 0}</td>
            <td>${successRate}%</td>
            <td>₱${(rider.total_earnings || 0).toFixed(2)}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const totalDeliveries = riders.reduce((sum, r) => sum + (r.total_deliveries || 0), 0);
    const totalEarnings = riders.reduce((sum, r) => sum + (r.total_earnings || 0), 0);
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Riders:</span><span>${riders.length}</span></div>`;
    html += `<div class="total-row"><span>Total Deliveries:</span><span>${totalDeliveries}</span></div>`;
    html += `<div class="total-row grand-total"><span>Total Earnings:</span><span>₱${totalEarnings.toFixed(2)}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}

function renderBuyerSection(buyers) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-user-chart"></i> Buyer Activity & Behavior Insights</h2>';
    html += '<table><thead><tr>';
    html += '<th>No.</th><th>Buyer Name</th><th>Orders</th><th>Total Spend</th><th>Avg Order Value</th><th>Last Order</th><th>Cart Items</th><th>Wishlist</th>';
    html += '</tr></thead><tbody>';
    
    buyers.forEach((buyer, index) => {
        html += `<tr>
            <td>${index + 1}</td>
            <td>${buyer.buyer_name}</td>
            <td>${buyer.total_orders || 0}</td>
            <td>₱${(buyer.total_spend || 0).toFixed(2)}</td>
            <td>₱${(buyer.avg_order_value || 0).toFixed(2)}</td>
            <td>${buyer.last_order_date || 'N/A'}</td>
            <td>${buyer.cart_items || 0}</td>
            <td>${buyer.wishlist_items || 0}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const totalSpend = buyers.reduce((sum, b) => sum + (b.total_spend || 0), 0);
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Buyers:</span><span>${buyers.length}</span></div>`;
    html += `<div class="total-row grand-total"><span>Total Spend:</span><span>₱${totalSpend.toFixed(2)}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}

function renderPromoSection(promos) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-tags"></i> Promo Code Usage Analytics</h2>';
    html += '<table><thead><tr>';
    html += '<th>No.</th><th>Promo Code</th><th>Type</th><th>Value</th><th>Start Date</th><th>End Date</th><th>Uses</th><th>Discount Given</th><th>Status</th>';
    html += '</tr></thead><tbody>';
    
    promos.forEach((promo, index) => {
        const today = new Date();
        const startDate = new Date(promo.start_date);
        const endDate = new Date(promo.end_date);
        let status = today < startDate ? '<span class="badge-secondary">Upcoming</span>' :
                     today > endDate ? '<span class="badge-danger">Expired</span>' :
                     '<span class="badge-success">Active</span>';
        
        html += `<tr>
            <td>${index + 1}</td>
            <td>${promo.promo_code}</td>
            <td>${promo.discount_type}</td>
            <td>${promo.discount_value}</td>
            <td>${promo.start_date}</td>
            <td>${promo.end_date}</td>
            <td>${promo.total_uses || 0}</td>
            <td>₱${(promo.total_discount_given || 0).toFixed(2)}</td>
            <td>${status}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const totalUses = promos.reduce((sum, p) => sum + (p.total_uses || 0), 0);
    const totalDiscount = promos.reduce((sum, p) => sum + (p.total_discount_given || 0), 0);
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Promo Codes:</span><span>${promos.length}</span></div>`;
    html += `<div class="total-row"><span>Total Uses:</span><span>${totalUses}</span></div>`;
    html += `<div class="total-row grand-total"><span>Total Discount Given:</span><span>₱${totalDiscount.toFixed(2)}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}

function renderCommissionSection(commissions) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-coins"></i> Platform Commission Summary Report</h2>';
    html += '<table class="compact-table"><thead><tr>';
    html += '<th>No.</th><th>Order ID</th><th>Seller</th><th>Rider</th><th>Order Total</th><th>Delivery Fee</th><th>Seller Comm.</th><th>Rider Comm.</th><th>Platform Earnings</th><th>Order Date</th><th>Completed</th>';
    html += '</tr></thead><tbody>';
    
    commissions.forEach((commission, index) => {
        html += `<tr>
            <td>${index + 1}</td>
            <td>#${commission.order_id}</td>
            <td>${commission.seller_email}</td>
            <td>${commission.rider_email || 'N/A'}</td>
            <td>₱${(commission.order_total || 0).toFixed(2)}</td>
            <td>₱${(commission.delivery_fee || 0).toFixed(2)}</td>
            <td>₱${(commission.seller_commission || 0).toFixed(2)}</td>
            <td>₱${(commission.rider_commission || 0).toFixed(2)}</td>
            <td>₱${(commission.total_platform_earnings || 0).toFixed(2)}</td>
            <td>${commission.order_date}</td>
            <td>${commission.date_completed || 'N/A'}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const totalSellerComm = commissions.reduce((sum, c) => sum + (c.seller_commission || 0), 0);
    const totalRiderComm = commissions.reduce((sum, c) => sum + (c.rider_commission || 0), 0);
    const totalEarnings = commissions.reduce((sum, c) => sum + (c.total_platform_earnings || 0), 0);
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Orders:</span><span>${commissions.length}</span></div>`;
    html += `<div class="total-row"><span>Total Seller Commission:</span><span>₱${totalSellerComm.toFixed(2)}</span></div>`;
    html += `<div class="total-row"><span>Total Rider Commission:</span><span>₱${totalRiderComm.toFixed(2)}</span></div>`;
    html += `<div class="total-row grand-total"><span>Total Platform Earnings:</span><span>₱${totalEarnings.toFixed(2)}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}

function renderIssuesSection(issues) {
    let html = '<div class="section">';
    html += '<h2 class="section-title"><i class="fas fa-exclamation-triangle"></i> Complaints & Issues Report</h2>';
    html += '<table><thead><tr>';
    html += '<th>No.</th><th>Reported By</th><th>Reported Against</th><th>Issue Type</th><th>Description</th><th>Order ID</th><th>Status</th><th>Date</th>';
    html += '</tr></thead><tbody>';
    
    issues.forEach((issue, index) => {
        const description = (issue.description || 'No description').substring(0, 80) + '...';
        let statusBadge = '';
        switch(issue.status.toLowerCase()) {
            case 'pending': statusBadge = '<span class="status-pending">Pending</span>'; break;
            case 'resolved': statusBadge = '<span class="status-resolved">Resolved</span>'; break;
            default: statusBadge = issue.status;
        }
        
        html += `<tr>
            <td>${index + 1}</td>
            <td>${issue.reported_by}</td>
            <td>${issue.reported_against}</td>
            <td>${issue.issue_type}</td>
            <td>${description}</td>
            <td>${issue.order_id ? '#' + issue.order_id : 'N/A'}</td>
            <td>${statusBadge}</td>
            <td>${issue.date_submitted}</td>
        </tr>`;
    });
    
    html += '</tbody></table>';
    
    // Totals
    const pendingCount = issues.filter(i => i.status.toLowerCase() === 'pending').length;
    const resolvedCount = issues.filter(i => i.status.toLowerCase() === 'resolved').length;
    html += '<div class="totals-section">';
    html += `<div class="total-row"><span>Total Issues:</span><span>${issues.length}</span></div>`;
    html += `<div class="total-row"><span>Pending Issues:</span><span>${pendingCount}</span></div>`;
    html += `<div class="total-row grand-total"><span>Resolved Issues:</span><span>${resolvedCount}</span></div>`;
    html += '</div>';
    
    html += '</div>';
    return html;
}
