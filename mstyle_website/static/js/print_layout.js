/* MStyle — Print Layout JS v3.0 */
document.addEventListener('DOMContentLoaded', function () {
    var printData = JSON.parse(localStorage.getItem('printData') || '{}');
    if (printData && Object.keys(printData).length > 0) {
        renderPrintLayout(printData);
        setTimeout(function () { window.print(); }, 600);
    } else {
        document.getElementById('printContent').innerHTML =
            '<p style="padding:32px;text-align:center;color:#78909c;font-size:9pt;">No data available for printing.</p>';
    }
});

function fmtDateTime(d) {
    return d.toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric', hour:'2-digit', minute:'2-digit' });
}
function fmtDate(d) {
    return d.toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' });
}
function peso(n) {
    var v = parseFloat(n || 0);
    return '&#8369;' + v.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}
function num(n) { return parseInt(n || 0).toLocaleString(); }
function pill(text, type) { return '<span class="pill pill-' + type + '">' + text + '</span>'; }
function statusPill(isActive, isFlagged) {
    if (isFlagged) return pill('Flagged', 'amber');
    if (!isActive) return pill('Inactive', 'gray');
    return pill('Active', 'green');
}

function sectionWrap(icon, title, count, tableHtml, totalsHtml) {
    return '<div class="data-section">' +
        '<div class="data-section-header">' +
            '<span class="data-section-icon">' + icon + '</span>' +
            '<span class="data-section-title">' + title + '</span>' +
            '<span class="data-section-count">' + count + ' records</span>' +
        '</div>' +
        tableHtml + totalsHtml +
    '</div>';
}

function tableHead(cols) {
    return '<table class="report-table"><thead><tr>' +
        cols.map(function(c) {
            return '<th' + (c.r ? ' class="num-col"' : c.c ? ' class="center-col"' : '') + '>' + c.l + '</th>';
        }).join('') +
        '</tr></thead><tbody>';
}

function totalsBar(items) {
    return '<div class="table-totals">' +
        items.map(function(t) {
            return '<div class="totals-item"><div class="totals-label">' + t.label +
                '</div><div class="totals-value">' + t.value + '</div></div>';
        }).join('') +
    '</div>';
}

/* ── Main ─────────────────────────────────────────────────────────────── */
function renderPrintLayout(data) {
    var now = new Date();
    var dtStr = fmtDateTime(now);
    var dStr  = fmtDate(now);

    document.getElementById('coverDate').textContent = dtStr;
    document.getElementById('docFooterDate').textContent = dStr;
    if (data.reportType) document.getElementById('coverReportType').textContent = data.reportType;

    if (data.stats) {
        document.getElementById('printTotalOrders').textContent = num(data.stats.totalOrders);
        var rev = data.stats.totalRevenue ? data.stats.totalRevenue.toString().replace(/[^0-9.]/g,'') : '0';
        var com = data.stats.platformCommission ? data.stats.platformCommission.toString().replace(/[^0-9.]/g,'') : '0';
        document.getElementById('printTotalRevenue').innerHTML       = peso(rev);
        document.getElementById('printPlatformCommission').innerHTML = peso(com);
        document.getElementById('printTotalUsers').textContent    = num(data.stats.totalUsers);
        document.getElementById('printTotalProducts').textContent = num(data.stats.totalProducts);
    }

    var html = '';
    var s = data.sections || [];
    var has = function(k) { return s.includes(k) || s.includes('all'); };

    if (has('inventory')  && data.inventoryProducts   && data.inventoryProducts.length)   html += renderInventory(data.inventoryProducts);
    if (has('seller')     && data.sellerPerformance   && data.sellerPerformance.length)   html += renderSellers(data.sellerPerformance);
    if (has('rider')      && data.riderAnalytics      && data.riderAnalytics.length)      html += renderRiders(data.riderAnalytics);
    if (has('buyer')      && data.buyerInsights       && data.buyerInsights.length)       html += renderBuyers(data.buyerInsights);
    if (has('promo')      && data.promoCodeAnalytics  && data.promoCodeAnalytics.length)  html += renderPromos(data.promoCodeAnalytics);
    if (has('commission') && data.platformCommission  && data.platformCommission.length)  html += renderCommission(data.platformCommission);
    if (has('issues')     && data.complaintsIssues    && data.complaintsIssues.length)    html += renderIssues(data.complaintsIssues);

    document.getElementById('printContent').innerHTML = html;
}

/* ── Section renderers ────────────────────────────────────────────────── */
function renderInventory(products) {
    var cols = [{l:'#',c:1},{l:'Product Name'},{l:'Seller'},{l:'Category'},{l:'Status'},{l:'Units Sold',r:1},{l:'Stock',r:1},{l:'Rating',r:1}];
    var rows = products.map(function(p, i) {
        var active  = p.is_active  === true || p.is_active  === 'true' || p.is_active  === 1;
        var flagged = p.is_flagged === true || p.is_flagged === 'true' || p.is_flagged === 1;
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>' + (p.product_name||'—') + '</strong></td>' +
            '<td>' + (p.seller_name||'—') + '</td>' +
            '<td>' + pill(p.category||'—','blue') + '</td>' +
            '<td>' + statusPill(active, flagged) + '</td>' +
            '<td class="num-col">' + num(p.units_sold) + '</td>' +
            '<td class="num-col">' + num(p.stock) + '</td>' +
            '<td class="num-col">' + parseFloat(p.rating||0).toFixed(1) + '</td></tr>';
    }).join('');
    var totalSold = products.reduce(function(a,p){ return a+(parseInt(p.units_sold)||0); }, 0);
    return sectionWrap('&#9632;', 'Inventory &amp; Products Analytics', products.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Products',value:products.length},{label:'Total Units Sold',value:num(totalSold)}]));
}

function renderSellers(sellers) {
    var cols = [{l:'#',c:1},{l:'Seller / Business'},{l:'Products',r:1},{l:'Orders',r:1},{l:'Completed',r:1},{l:'Cancelled',r:1},{l:'Revenue',r:1},{l:'Flagged',r:1},{l:'Deactivated',r:1}];
    var rows = sellers.map(function(s, i) {
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>' + (s.seller_name||'—') + '</strong></td>' +
            '<td class="num-col">' + num(s.total_products) + '</td>' +
            '<td class="num-col">' + num(s.total_orders) + '</td>' +
            '<td class="num-col">' + num(s.completed_orders) + '</td>' +
            '<td class="num-col">' + num(s.cancelled_orders) + '</td>' +
            '<td class="num-col">' + peso(s.total_revenue) + '</td>' +
            '<td class="num-col">' + (s.flagged_products > 0 ? pill(s.flagged_products,'amber') : '0') + '</td>' +
            '<td class="num-col">' + num(s.deactivated_products) + '</td></tr>';
    }).join('');
    var totalRev = sellers.reduce(function(a,s){ return a+(parseFloat(s.total_revenue)||0); }, 0);
    return sectionWrap('&#9650;', 'Seller Performance Report', sellers.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Sellers',value:sellers.length},{label:'Total Revenue',value:peso(totalRev)}]));
}

function renderRiders(riders) {
    var cols = [{l:'#',c:1},{l:'Rider Name'},{l:'Vehicle'},{l:'Plate'},{l:'Deliveries',r:1},{l:'Successful',r:1},{l:'Failed',r:1},{l:'Success Rate',r:1},{l:'Earnings',r:1}];
    var rows = riders.map(function(r, i) {
        var rate = r.total_deliveries > 0 ? ((r.successful_deliveries/r.total_deliveries)*100).toFixed(1) : '0.0';
        var rp = parseFloat(rate) >= 80 ? pill(rate+'%','green') : parseFloat(rate) >= 50 ? pill(rate+'%','amber') : pill(rate+'%','red');
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>' + (r.rider_name||'—') + '</strong></td>' +
            '<td>' + (r.vehicle_type||'N/A') + '</td>' +
            '<td>' + (r.plate_number||'N/A') + '</td>' +
            '<td class="num-col">' + num(r.total_deliveries) + '</td>' +
            '<td class="num-col">' + num(r.successful_deliveries) + '</td>' +
            '<td class="num-col">' + num(r.failed_deliveries) + '</td>' +
            '<td class="num-col">' + rp + '</td>' +
            '<td class="num-col">' + peso(r.total_earnings) + '</td></tr>';
    }).join('');
    var totalDel  = riders.reduce(function(a,r){ return a+(parseInt(r.total_deliveries)||0); }, 0);
    var totalEarn = riders.reduce(function(a,r){ return a+(parseFloat(r.total_earnings)||0); }, 0);
    return sectionWrap('&#9654;', 'Rider / Delivery Analytics', riders.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Riders',value:riders.length},{label:'Total Deliveries',value:num(totalDel)},{label:'Total Earnings',value:peso(totalEarn)}]));
}

function renderBuyers(buyers) {
    var cols = [{l:'#',c:1},{l:'Buyer Name'},{l:'Orders',r:1},{l:'Total Spend',r:1},{l:'Avg Order Value',r:1},{l:'Last Order'},{l:'Cart',r:1},{l:'Wishlist',r:1}];
    var rows = buyers.map(function(b, i) {
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>' + (b.buyer_name||'—') + '</strong></td>' +
            '<td class="num-col">' + num(b.total_orders) + '</td>' +
            '<td class="num-col">' + peso(b.total_spend) + '</td>' +
            '<td class="num-col">' + peso(b.avg_order_value) + '</td>' +
            '<td>' + (b.last_order_date||'N/A') + '</td>' +
            '<td class="num-col">' + num(b.cart_items) + '</td>' +
            '<td class="num-col">' + num(b.wishlist_items) + '</td></tr>';
    }).join('');
    var totalSpend = buyers.reduce(function(a,b){ return a+(parseFloat(b.total_spend)||0); }, 0);
    return sectionWrap('&#9679;', 'Buyer Activity &amp; Behavior Insights', buyers.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Buyers',value:buyers.length},{label:'Total Spend',value:peso(totalSpend)}]));
}

function renderPromos(promos) {
    var cols = [{l:'#',c:1},{l:'Promo Code'},{l:'Type'},{l:'Value',r:1},{l:'Start'},{l:'End'},{l:'Uses',r:1},{l:'Discount Given',r:1},{l:'Status'}];
    var today = new Date();
    var rows = promos.map(function(p, i) {
        var start = new Date(p.start_date), end = new Date(p.end_date);
        var sp = today < start ? pill('Upcoming','blue') : today > end ? pill('Expired','gray') : pill('Active','green');
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>' + (p.promo_code||'—') + '</strong></td>' +
            '<td>' + (p.discount_type||'—') + '</td>' +
            '<td class="num-col">' + (p.discount_value||'—') + '</td>' +
            '<td>' + (p.start_date||'—') + '</td>' +
            '<td>' + (p.end_date||'—') + '</td>' +
            '<td class="num-col">' + num(p.total_uses) + '</td>' +
            '<td class="num-col">' + peso(p.total_discount_given) + '</td>' +
            '<td>' + sp + '</td></tr>';
    }).join('');
    var totalUses = promos.reduce(function(a,p){ return a+(parseInt(p.total_uses)||0); }, 0);
    var totalDisc = promos.reduce(function(a,p){ return a+(parseFloat(p.total_discount_given)||0); }, 0);
    return sectionWrap('&#9670;', 'Promo Code Usage Analytics', promos.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Promos',value:promos.length},{label:'Total Uses',value:num(totalUses)},{label:'Discount Given',value:peso(totalDisc)}]));
}

function renderCommission(commissions) {
    var cols = [{l:'#',c:1},{l:'Order ID'},{l:'Seller'},{l:'Rider'},{l:'Order Total',r:1},{l:'Delivery Fee',r:1},{l:'Seller Comm.',r:1},{l:'Rider Comm.',r:1},{l:'Platform Earnings',r:1},{l:'Order Date'},{l:'Completed'}];
    var rows = commissions.map(function(c, i) {
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>#' + (c.order_id||'—') + '</strong></td>' +
            '<td>' + (c.seller_email||'—') + '</td>' +
            '<td>' + (c.rider_email||'N/A') + '</td>' +
            '<td class="num-col">' + peso(c.order_total) + '</td>' +
            '<td class="num-col">' + peso(c.delivery_fee) + '</td>' +
            '<td class="num-col">' + peso(c.seller_commission) + '</td>' +
            '<td class="num-col">' + peso(c.rider_commission) + '</td>' +
            '<td class="num-col"><strong>' + peso(c.total_platform_earnings) + '</strong></td>' +
            '<td>' + (c.order_date||'—') + '</td>' +
            '<td>' + (c.date_completed||'N/A') + '</td></tr>';
    }).join('');
    var tSC = commissions.reduce(function(a,c){ return a+(parseFloat(c.seller_commission)||0); }, 0);
    var tRC = commissions.reduce(function(a,c){ return a+(parseFloat(c.rider_commission)||0); }, 0);
    var tPE = commissions.reduce(function(a,c){ return a+(parseFloat(c.total_platform_earnings)||0); }, 0);
    return sectionWrap('&#9632;', 'Platform Commission Summary', commissions.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Orders',value:commissions.length},{label:'Seller Commission',value:peso(tSC)},{label:'Rider Commission',value:peso(tRC)},{label:'Platform Earnings',value:peso(tPE)}]));
}

function renderIssues(issues) {
    var cols = [{l:'#',c:1},{l:'Reported By'},{l:'Reported Against'},{l:'Issue Type'},{l:'Description'},{l:'Order ID',c:1},{l:'Status'},{l:'Date'}];
    var rows = issues.map(function(iss, i) {
        var desc = (iss.description||'No description').substring(0, 65) + (iss.description && iss.description.length > 65 ? '…' : '');
        var st = (iss.status||'').toLowerCase();
        var sp = st === 'resolved' ? pill('Resolved','green') : st === 'pending' ? pill('Pending','amber') : pill(iss.status||'—','gray');
        return '<tr><td class="row-num center-col">' + (i+1) + '</td>' +
            '<td><strong>' + (iss.reported_by||'—') + '</strong></td>' +
            '<td>' + (iss.reported_against||'—') + '</td>' +
            '<td>' + pill(iss.issue_type||'—','blue') + '</td>' +
            '<td style="max-width:160px;font-size:7pt;">' + desc + '</td>' +
            '<td class="center-col">' + (iss.order_id ? '#'+iss.order_id : 'N/A') + '</td>' +
            '<td>' + sp + '</td>' +
            '<td>' + (iss.date_submitted||'—') + '</td></tr>';
    }).join('');
    var pending  = issues.filter(function(i){ return (i.status||'').toLowerCase()==='pending'; }).length;
    var resolved = issues.filter(function(i){ return (i.status||'').toLowerCase()==='resolved'; }).length;
    return sectionWrap('&#9888;', 'Complaints &amp; Issues Report', issues.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Issues',value:issues.length},{label:'Pending',value:pending},{label:'Resolved',value:resolved}]));
}
