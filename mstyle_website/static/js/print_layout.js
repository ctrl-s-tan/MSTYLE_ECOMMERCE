/* MStyle — Print Layout JS v5.0 */
document.addEventListener('DOMContentLoaded', function () {
    var printData = JSON.parse(localStorage.getItem('printData') || '{}');
    if (printData && Object.keys(printData).length > 0) {
        renderPrintLayout(printData);
        setTimeout(function () { window.print(); }, 800);
    } else {
        document.getElementById('printContent').innerHTML =
            '<p style="padding:40px;text-align:center;color:#718096;font-size:9pt;">No data available for printing.</p>';
    }
});

/* ── Formatters ─────────────────────────────────────────────────── */
function fmtDateTime(d) {
    return d.toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' }) +
           ' at ' + d.toLocaleTimeString('en-US', { hour:'2-digit', minute:'2-digit' });
}
function fmtDate(d) {
    return d.toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' });
}
function peso(n) {
    var v = parseFloat(n || 0);
    return '&#8369;' + v.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}
function num(n) { return parseInt(n || 0).toLocaleString(); }

function pill(text, type) {
    var styles = {
        green: 'background:#e6f4ed;color:#1a7f4b;border:1px solid #b7dfc9;',
        amber: 'background:#fef3dc;color:#92600a;border:1px solid #f5d98a;',
        red:   'background:#fde8e8;color:#b91c1c;border:1px solid #f5b8b8;',
        blue:  'background:#e8effe;color:#1d4ed8;border:1px solid #b8ccf8;',
        gray:  'background:#f1f3f5;color:#4b5563;border:1px solid #d1d5db;'
    };
    var s = styles[type] || styles.gray;
    return '<span style="display:inline-block;padding:1px 6px;border-radius:3px;font-size:6.5pt;font-weight:700;letter-spacing:.3px;white-space:nowrap;' + s + '">' + text + '</span>';
}

function statusPill(isActive, isFlagged) {
    if (isFlagged) return pill('Flagged', 'amber');
    if (!isActive) return pill('Inactive', 'gray');
    return pill('Active', 'green');
}

/* ── Section wrapper ────────────────────────────────────────────── */
function sectionWrap(icon, title, count, tableHtml, totalsHtml) {
    return '<div style="margin-bottom:20px;border:1.5px solid #c8cdd8;border-top:3px solid #1a2744;page-break-inside:avoid;break-inside:avoid;">' +
        '<div style="display:flex;align-items:center;gap:8px;padding:8px 14px;background:#f0f3f8;border-bottom:1px solid #c8cdd8;-webkit-print-color-adjust:exact;print-color-adjust:exact;">' +
            '<span style="font-size:9pt;color:#1a2744;flex-shrink:0;">' + icon + '</span>' +
            '<span style="font-size:9pt;font-weight:700;color:#1a2744;letter-spacing:.2px;flex:1;text-transform:uppercase;">' + title + '</span>' +
            '<span style="font-size:7pt;color:#4a5568;background:#dde2ea;padding:2px 8px;border-radius:10px;font-weight:600;border:1px solid #c8cdd8;">' + count + ' records</span>' +
        '</div>' +
        tableHtml +
        totalsHtml +
    '</div>';
}

/* ── Table builder ──────────────────────────────────────────────── */
function tableHead(cols) {
    var ths = cols.map(function(c) {
        var align = c.r ? 'right' : (c.c ? 'center' : 'left');
        return '<th style="padding:7px 10px;font-size:7pt;font-weight:700;color:#1a2744;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;border-right:1px solid #dde2ea;text-align:' + align + ';background:#f7f8fa;">' + c.l + '</th>';
    }).join('');
    return '<table style="width:100%;border-collapse:collapse;font-size:7.5pt;">' +
           '<thead><tr style="border-bottom:2px solid #1a2744;background:#f7f8fa;-webkit-print-color-adjust:exact;print-color-adjust:exact;">' + ths + '</tr></thead><tbody>';
}

function tdStyle(right, center) {
    var align = right ? 'right' : (center ? 'center' : 'left');
    return 'style="padding:5px 10px;color:#1e2533;vertical-align:middle;border-right:1px solid #edf0f5;border-bottom:1px solid #edf0f5;text-align:' + align + ';font-variant-numeric:tabular-nums;"';
}

/* ── Totals bar ─────────────────────────────────────────────────── */
function totalsBar(items) {
    var cells = items.map(function(t) {
        return '<div style="flex:1;padding:8px 14px;text-align:center;border-right:1px solid #c8cdd8;">' +
            '<div style="font-size:6.5pt;color:#4a5568;text-transform:uppercase;letter-spacing:.5px;font-weight:600;margin-bottom:3px;">' + t.label + '</div>' +
            '<div style="font-size:10pt;font-weight:800;color:#1a2744;letter-spacing:-.2px;line-height:1;">' + t.value + '</div>' +
        '</div>';
    }).join('');
    return '<div style="display:flex;align-items:stretch;border-top:2px solid #1a2744;background:#f0f3f8;-webkit-print-color-adjust:exact;print-color-adjust:exact;">' + cells + '</div>';
}

/* ── Main renderer ──────────────────────────────────────────────── */
function renderPrintLayout(data) {
    var now   = new Date();
    var dtStr = fmtDateTime(now);
    var dStr  = fmtDate(now);

    document.getElementById('coverDate').textContent      = dtStr;
    document.getElementById('docFooterDate').textContent  = dStr;
    if (data.reportType) document.getElementById('coverReportType').textContent = data.reportType;

    if (data.stats) {
        document.getElementById('printTotalOrders').textContent    = num(data.stats.totalOrders);
        var rev = (data.stats.totalRevenue        || '0').toString().replace(/[^0-9.]/g,'');
        var com = (data.stats.platformCommission  || '0').toString().replace(/[^0-9.]/g,'');
        document.getElementById('printTotalRevenue').innerHTML      = peso(rev);
        document.getElementById('printPlatformCommission').innerHTML= peso(com);
        document.getElementById('printTotalUsers').textContent      = num(data.stats.totalUsers);
        document.getElementById('printTotalProducts').textContent   = num(data.stats.totalProducts);
    }

    var html = '';
    var s    = data.sections || [];
    var has  = function(k) { return s.includes(k) || s.includes('all'); };

    if (has('inventory')  && data.inventoryProducts  && data.inventoryProducts.length)  html += renderInventory(data.inventoryProducts);
    if (has('seller')     && data.sellerPerformance  && data.sellerPerformance.length)  html += renderSellers(data.sellerPerformance);
    if (has('rider')      && data.riderAnalytics     && data.riderAnalytics.length)     html += renderRiders(data.riderAnalytics);
    if (has('buyer')      && data.buyerInsights      && data.buyerInsights.length)      html += renderBuyers(data.buyerInsights);
    if (has('promo')      && data.promoCodeAnalytics && data.promoCodeAnalytics.length) html += renderPromos(data.promoCodeAnalytics);
    if (has('commission') && data.platformCommission && data.platformCommission.length) html += renderCommission(data.platformCommission);
    if (has('issues')     && data.complaintsIssues   && data.complaintsIssues.length)   html += renderIssues(data.complaintsIssues);

    if (!html) {
        html = '<p style="padding:32px;text-align:center;color:#718096;font-size:9pt;font-style:italic;">No data available for the selected sections.</p>';
    }

    document.getElementById('printContent').innerHTML = html;
}

/* ══════════════════════════════════════════════════════════════════
   SECTION RENDERERS
   ══════════════════════════════════════════════════════════════════ */
function renderInventory(products) {
    var cols = [{l:'#',c:1},{l:'Product Name'},{l:'Seller'},{l:'Category'},{l:'Status'},{l:'Units Sold',r:1},{l:'Stock',r:1},{l:'Rating',r:1}];
    var rows = products.map(function(p, i) {
        var active  = p.is_active  === true || p.is_active  === 'true' || p.is_active  === 1;
        var flagged = p.is_flagged === true || p.is_flagged === 'true' || p.is_flagged === 1;
        var bg = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">' + (p.product_name||'—') + '</strong></td>' +
            '<td ' + tdStyle() + '>' + (p.seller_name||'—') + '</td>' +
            '<td ' + tdStyle() + '>' + pill(p.category||'—','blue') + '</td>' +
            '<td ' + tdStyle() + '>' + statusPill(active, flagged) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(p.units_sold) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(p.stock) + '</td>' +
            '<td ' + tdStyle(true) + '>' + parseFloat(p.rating||0).toFixed(1) + '</td></tr>';
    }).join('');
    var totalSold = products.reduce(function(a,p){ return a+(parseInt(p.units_sold)||0); }, 0);
    return sectionWrap('&#9632;', 'Inventory &amp; Products Analytics', products.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Products',value:products.length},{label:'Total Units Sold',value:num(totalSold)}]));
}

function renderSellers(sellers) {
    var cols = [{l:'#',c:1},{l:'Seller / Business'},{l:'Products',r:1},{l:'Orders',r:1},{l:'Completed',r:1},{l:'Cancelled',r:1},{l:'Revenue',r:1},{l:'Flagged',r:1},{l:'Deactivated',r:1}];
    var rows = sellers.map(function(s, i) {
        var bg = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">' + (s.seller_name||'—') + '</strong></td>' +
            '<td ' + tdStyle(true) + '>' + num(s.total_products) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(s.total_orders) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(s.completed_orders) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(s.cancelled_orders) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(s.total_revenue) + '</td>' +
            '<td ' + tdStyle(true) + '>' + (parseInt(s.flagged_products) > 0 ? pill(s.flagged_products,'amber') : '0') + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(s.deactivated_products) + '</td></tr>';
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
        var rp   = parseFloat(rate) >= 80 ? pill(rate+'%','green') : parseFloat(rate) >= 50 ? pill(rate+'%','amber') : pill(rate+'%','red');
        var bg   = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">' + (r.rider_name||'—') + '</strong></td>' +
            '<td ' + tdStyle() + '>' + (r.vehicle_type||'N/A') + '</td>' +
            '<td ' + tdStyle() + '>' + (r.plate_number||'N/A') + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(r.total_deliveries) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(r.successful_deliveries) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(r.failed_deliveries) + '</td>' +
            '<td ' + tdStyle(true) + '>' + rp + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(r.total_earnings) + '</td></tr>';
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
        var bg = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">' + (b.buyer_name||'—') + '</strong></td>' +
            '<td ' + tdStyle(true) + '>' + num(b.total_orders) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(b.total_spend) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(b.avg_order_value) + '</td>' +
            '<td ' + tdStyle() + '>' + (b.last_order_date||'N/A') + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(b.cart_items) + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(b.wishlist_items) + '</td></tr>';
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
        var bg = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">' + (p.promo_code||'—') + '</strong></td>' +
            '<td ' + tdStyle() + '>' + (p.discount_type||'—') + '</td>' +
            '<td ' + tdStyle(true) + '>' + (p.discount_value||'—') + '</td>' +
            '<td ' + tdStyle() + '>' + (p.start_date||'—') + '</td>' +
            '<td ' + tdStyle() + '>' + (p.end_date||'—') + '</td>' +
            '<td ' + tdStyle(true) + '>' + num(p.total_uses) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(p.total_discount_given) + '</td>' +
            '<td ' + tdStyle() + '>' + sp + '</td></tr>';
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
        var bg = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">#' + (c.order_id||'—') + '</strong></td>' +
            '<td ' + tdStyle() + '>' + (c.seller_email||'—') + '</td>' +
            '<td ' + tdStyle() + '>' + (c.rider_email||'N/A') + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(c.order_total) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(c.delivery_fee) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(c.seller_commission) + '</td>' +
            '<td ' + tdStyle(true) + '>' + peso(c.rider_commission) + '</td>' +
            '<td ' + tdStyle(true) + '><strong>' + peso(c.total_platform_earnings) + '</strong></td>' +
            '<td ' + tdStyle() + '>' + (c.order_date||'—') + '</td>' +
            '<td ' + tdStyle() + '>' + (c.date_completed||'N/A') + '</td></tr>';
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
        var desc = (iss.description||'No description').substring(0, 60) + (iss.description && iss.description.length > 60 ? '…' : '');
        var st   = (iss.status||'').toLowerCase();
        var sp   = st === 'resolved' ? pill('Resolved','green') : st === 'pending' ? pill('Pending','amber') : pill(iss.status||'—','gray');
        var bg   = i % 2 === 1 ? 'background:#fafbfd;' : '';
        return '<tr style="' + bg + 'border-bottom:1px solid #edf0f5;">' +
            '<td ' + tdStyle(false,true) + '><span style="color:#718096;font-size:7pt;font-weight:600;">' + (i+1) + '</span></td>' +
            '<td ' + tdStyle() + '><strong style="color:#1a2744;">' + (iss.reported_by||'—') + '</strong></td>' +
            '<td ' + tdStyle() + '>' + (iss.reported_against||'—') + '</td>' +
            '<td ' + tdStyle() + '>' + pill(iss.issue_type||'—','blue') + '</td>' +
            '<td style="padding:5px 10px;color:#4a5568;font-size:7pt;max-width:140px;border-right:1px solid #edf0f5;border-bottom:1px solid #edf0f5;">' + desc + '</td>' +
            '<td ' + tdStyle(false,true) + '>' + (iss.order_id ? '#'+iss.order_id : 'N/A') + '</td>' +
            '<td ' + tdStyle() + '>' + sp + '</td>' +
            '<td ' + tdStyle() + '>' + (iss.date_submitted||'—') + '</td></tr>';
    }).join('');
    var pending  = issues.filter(function(i){ return (i.status||'').toLowerCase()==='pending'; }).length;
    var resolved = issues.filter(function(i){ return (i.status||'').toLowerCase()==='resolved'; }).length;
    return sectionWrap('&#9888;', 'Complaints &amp; Issues Report', issues.length,
        tableHead(cols) + rows + '</tbody></table>',
        totalsBar([{label:'Total Issues',value:issues.length},{label:'Pending',value:pending},{label:'Resolved',value:resolved}]));
}
