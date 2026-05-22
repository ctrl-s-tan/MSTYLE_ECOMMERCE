/* MStyle — Print Layout JS v6.0 — table-based, print-safe */
document.addEventListener('DOMContentLoaded', function () {
    var printData = JSON.parse(localStorage.getItem('printData') || '{}');
    if (printData && Object.keys(printData).length > 0) {
        renderPrintLayout(printData);
        setTimeout(function () { window.print(); }, 700);
    } else {
        document.getElementById('printContent').innerHTML =
            '<p style="padding:20px;text-align:center;color:#718096;font-size:8pt;font-style:italic;">No data available for printing.</p>';
    }
});

/* ── Formatters ─────────────────────────────────────────────────── */
function fmtDateTime(d) {
    return d.toLocaleDateString('en-US', { year:'numeric', month:'long', day:'numeric' }) +
           ' at ' + d.toLocaleTimeString('en-US', { hour:'2-digit', minute:'2-digit' });
}
function fmtDate(d) {
    return d.toLocaleDateString('en-US', { year:'numeric', month:'short', day:'numeric' });
}
function peso(n) {
    var v = parseFloat(n || 0);
    return '&#8369;' + v.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}
function num(n) { return parseInt(n || 0).toLocaleString(); }

/* Pills — inline so they survive print without background-graphics */
var PILL = {
    green: 'display:inline-block;padding:1px 5px;border-radius:2px;font-size:6.5pt;font-weight:700;background:#e6f4ed;color:#1a7f4b;border:1px solid #b7dfc9;',
    amber: 'display:inline-block;padding:1px 5px;border-radius:2px;font-size:6.5pt;font-weight:700;background:#fef3dc;color:#92600a;border:1px solid #f5d98a;',
    red:   'display:inline-block;padding:1px 5px;border-radius:2px;font-size:6.5pt;font-weight:700;background:#fde8e8;color:#b91c1c;border:1px solid #f5b8b8;',
    blue:  'display:inline-block;padding:1px 5px;border-radius:2px;font-size:6.5pt;font-weight:700;background:#e8effe;color:#1d4ed8;border:1px solid #b8ccf8;',
    gray:  'display:inline-block;padding:1px 5px;border-radius:2px;font-size:6.5pt;font-weight:700;background:#f1f3f5;color:#4b5563;border:1px solid #d1d5db;'
};
function pill(text, type) {
    return '<span style="' + (PILL[type] || PILL.gray) + '">' + text + '</span>';
}
function statusPill(isActive, isFlagged) {
    if (isFlagged) return pill('Flagged', 'amber');
    if (!isActive) return pill('Inactive', 'gray');
    return pill('Active', 'green');
}

/* ── Section wrapper ────────────────────────────────────────────── */
function sec(title, count, tableHtml, totHtml) {
    return '<div style="width:100%;border:1px solid #c8cdd8;border-top:2.5px solid #1a2744;margin-bottom:14px;page-break-inside:avoid;break-inside:avoid;">' +
        '<div style="font-size:8.5pt;font-weight:700;color:#1a2744;text-transform:uppercase;letter-spacing:.3px;padding:6px 10px;border-bottom:1px solid #c8cdd8;background:#f5f7fa;-webkit-print-color-adjust:exact;print-color-adjust:exact;">' +
            title + '<span style="font-size:7pt;color:#718096;font-weight:400;text-transform:none;letter-spacing:0;margin-left:6px;">(' + count + ' records)</span>' +
        '</div>' +
        tableHtml +
        totHtml +
    '</div>';
}

/* ── Table builder ──────────────────────────────────────────────── */
function thead(cols) {
    var ths = cols.map(function(c) {
        var align = c.r ? 'right' : (c.c ? 'center' : 'left');
        return '<th style="padding:5px 8px;font-size:7pt;font-weight:700;color:#1a2744;text-transform:uppercase;letter-spacing:.4px;text-align:' + align + ';border-right:1px solid #dde2ea;white-space:nowrap;background:#f5f7fa;-webkit-print-color-adjust:exact;print-color-adjust:exact;">' + c.l + '</th>';
    }).join('');
    return '<table cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;font-size:7.5pt;">' +
           '<thead><tr style="border-bottom:1.5px solid #1a2744;background:#f5f7fa;-webkit-print-color-adjust:exact;print-color-adjust:exact;">' + ths + '</tr></thead><tbody>';
}

function td(val, right, center, extra) {
    var align = right ? 'right' : (center ? 'center' : 'left');
    var s = 'padding:4px 8px;color:#1e2533;vertical-align:middle;border-right:1px solid #edf0f5;border-bottom:1px solid #edf0f5;text-align:' + align + ';font-variant-numeric:tabular-nums;' + (extra||'');
    return '<td style="' + s + '">' + val + '</td>';
}

function rowBg(i) { return i % 2 === 1 ? 'background:#fafbfd;-webkit-print-color-adjust:exact;print-color-adjust:exact;' : ''; }

/* ── Totals bar ─────────────────────────────────────────────────── */
function totBar(items) {
    var cells = items.map(function(t, i) {
        var br = i < items.length - 1 ? 'border-right:1px solid #c8cdd8;' : '';
        return '<td style="padding:6px 10px;text-align:center;vertical-align:top;' + br + '">' +
            '<div style="font-size:6.5pt;color:#718096;text-transform:uppercase;letter-spacing:.4px;margin-bottom:2px;">' + t.label + '</div>' +
            '<div style="font-size:9.5pt;font-weight:800;color:#1a2744;line-height:1;">' + t.value + '</div>' +
        '</td>';
    }).join('');
    return '<table cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;border-top:1.5px solid #1a2744;background:#f0f3f8;-webkit-print-color-adjust:exact;print-color-adjust:exact;"><tr>' + cells + '</tr></table>';
}

/* ── Main ───────────────────────────────────────────────────────── */
function renderPrintLayout(data) {
    var now = new Date();
    document.getElementById('coverDate').textContent     = fmtDateTime(now);
    document.getElementById('docFooterDate').textContent = fmtDate(now);
    if (data.reportType) document.getElementById('coverReportType').textContent = data.reportType;

    if (data.stats) {
        document.getElementById('printTotalOrders').textContent    = num(data.stats.totalOrders);
        var rev = (data.stats.totalRevenue       || '0').toString().replace(/[^0-9.]/g,'');
        var com = (data.stats.platformCommission || '0').toString().replace(/[^0-9.]/g,'');
        document.getElementById('printTotalRevenue').innerHTML      = peso(rev);
        document.getElementById('printPlatformCommission').innerHTML= peso(com);
        document.getElementById('printTotalUsers').textContent      = num(data.stats.totalUsers);
        document.getElementById('printTotalProducts').textContent   = num(data.stats.totalProducts);
    }

    var html = '';
    var s = data.sections || [];
    var has = function(k) { return s.includes(k) || s.includes('all'); };

    if (has('inventory')  && data.inventoryProducts  && data.inventoryProducts.length)  html += renderInventory(data.inventoryProducts);
    if (has('seller')     && data.sellerPerformance  && data.sellerPerformance.length)  html += renderSellers(data.sellerPerformance);
    if (has('rider')      && data.riderAnalytics     && data.riderAnalytics.length)     html += renderRiders(data.riderAnalytics);
    if (has('buyer')      && data.buyerInsights      && data.buyerInsights.length)      html += renderBuyers(data.buyerInsights);
    if (has('promo')      && data.promoCodeAnalytics && data.promoCodeAnalytics.length) html += renderPromos(data.promoCodeAnalytics);
    if (has('commission') && data.platformCommission && data.platformCommission.length) html += renderCommission(data.platformCommission);
    if (has('issues')     && data.complaintsIssues   && data.complaintsIssues.length)   html += renderIssues(data.complaintsIssues);

    if (!html) html = '<p style="padding:20px;text-align:center;color:#718096;font-size:8pt;font-style:italic;">No data available for the selected sections.</p>';
    document.getElementById('printContent').innerHTML = html;
}

/* ══════════════════════════════════════════════════════════════════
   RENDERERS
   ══════════════════════════════════════════════════════════════════ */
function renderInventory(products) {
    var cols = [{l:'No.',c:1},{l:'Product Name'},{l:'Seller'},{l:'Category'},{l:'Status'},{l:'Units Sold',r:1},{l:'Stock',r:1},{l:'Rating',r:1}];
    var rows = products.map(function(p, i) {
        var active  = p.is_active  === true || p.is_active  === 'true' || p.is_active  === 1;
        var flagged = p.is_flagged === true || p.is_flagged === 'true' || p.is_flagged === 1;
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>' + (p.product_name||'—') + '</b>') +
            td(p.seller_name||'—') +
            td(pill(p.category||'—','blue')) +
            td(statusPill(active, flagged)) +
            td(num(p.units_sold), true) +
            td(num(p.stock), true) +
            td(parseFloat(p.rating||0).toFixed(1), true) + '</tr>';
    }).join('');
    var totalSold = products.reduce(function(a,p){ return a+(parseInt(p.units_sold)||0); }, 0);
    return sec('Inventory and Products Analytics', products.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Total Products',value:products.length},{label:'Total Units Sold',value:num(totalSold)}]));
}

function renderSellers(sellers) {
    var cols = [{l:'No.',c:1},{l:'Seller / Business'},{l:'Products',r:1},{l:'Orders',r:1},{l:'Completed',r:1},{l:'Cancelled',r:1},{l:'Revenue',r:1},{l:'Flagged',r:1},{l:'Deactivated',r:1}];
    var rows = sellers.map(function(s, i) {
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>' + (s.seller_name||'—') + '</b>') +
            td(num(s.total_products), true) +
            td(num(s.total_orders), true) +
            td(num(s.completed_orders), true) +
            td(num(s.cancelled_orders), true) +
            td(peso(s.total_revenue), true) +
            td(parseInt(s.flagged_products) > 0 ? pill(s.flagged_products,'amber') : '0', true) +
            td(num(s.deactivated_products), true) + '</tr>';
    }).join('');
    var totalRev = sellers.reduce(function(a,s){ return a+(parseFloat(s.total_revenue)||0); }, 0);
    return sec('Seller Performance Reports', sellers.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Total Sellers',value:sellers.length},{label:'Total Revenue',value:peso(totalRev)}]));
}

function renderRiders(riders) {
    var cols = [{l:'No.',c:1},{l:'Rider Name'},{l:'Vehicle'},{l:'Plate'},{l:'Deliveries',r:1},{l:'Successful',r:1},{l:'Failed',r:1},{l:'Success Rate',r:1},{l:'Earnings',r:1}];
    var rows = riders.map(function(r, i) {
        var rate = r.total_deliveries > 0 ? ((r.successful_deliveries/r.total_deliveries)*100).toFixed(1) : '0.0';
        var rp   = parseFloat(rate) >= 80 ? pill(rate+'%','green') : parseFloat(rate) >= 50 ? pill(rate+'%','amber') : pill(rate+'%','red');
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>' + (r.rider_name||'—') + '</b>') +
            td(r.vehicle_type||'N/A') +
            td(r.plate_number||'N/A') +
            td(num(r.total_deliveries), true) +
            td(num(r.successful_deliveries), true) +
            td(num(r.failed_deliveries), true) +
            td(rp, true) +
            td(peso(r.total_earnings), true) + '</tr>';
    }).join('');
    var totalDel  = riders.reduce(function(a,r){ return a+(parseInt(r.total_deliveries)||0); }, 0);
    var totalEarn = riders.reduce(function(a,r){ return a+(parseFloat(r.total_earnings)||0); }, 0);
    return sec('Rider / Delivery Analytics', riders.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Total Riders',value:riders.length},{label:'Total Deliveries',value:num(totalDel)},{label:'Total Earnings',value:peso(totalEarn)}]));
}

function renderBuyers(buyers) {
    var cols = [{l:'No.',c:1},{l:'Buyer Name'},{l:'Orders',r:1},{l:'Total Spend',r:1},{l:'Avg Order Value',r:1},{l:'Last Order'},{l:'Cart',r:1},{l:'Wishlist',r:1}];
    var rows = buyers.map(function(b, i) {
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>' + (b.buyer_name||'—') + '</b>') +
            td(num(b.total_orders), true) +
            td(peso(b.total_spend), true) +
            td(peso(b.avg_order_value), true) +
            td(b.last_order_date||'N/A') +
            td(num(b.cart_items), true) +
            td(num(b.wishlist_items), true) + '</tr>';
    }).join('');
    var totalSpend = buyers.reduce(function(a,b){ return a+(parseFloat(b.total_spend)||0); }, 0);
    return sec('Buyer Activity &amp; Behavior Insights', buyers.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Total Buyers',value:buyers.length},{label:'Total Spend',value:peso(totalSpend)}]));
}

function renderPromos(promos) {
    var cols = [{l:'No.',c:1},{l:'Promo Code'},{l:'Type'},{l:'Value',r:1},{l:'Start'},{l:'End'},{l:'Uses',r:1},{l:'Discount Given',r:1},{l:'Status'}];
    var today = new Date();
    var rows = promos.map(function(p, i) {
        var start = new Date(p.start_date), end = new Date(p.end_date);
        var sp = today < start ? pill('Upcoming','blue') : today > end ? pill('Expired','gray') : pill('Active','green');
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>' + (p.promo_code||'—') + '</b>') +
            td(p.discount_type||'—') +
            td(p.discount_value||'—', true) +
            td(p.start_date||'—') +
            td(p.end_date||'—') +
            td(num(p.total_uses), true) +
            td(peso(p.total_discount_given), true) +
            td(sp) + '</tr>';
    }).join('');
    var totalUses = promos.reduce(function(a,p){ return a+(parseInt(p.total_uses)||0); }, 0);
    var totalDisc = promos.reduce(function(a,p){ return a+(parseFloat(p.total_discount_given)||0); }, 0);
    return sec('Promo Code Usage Analytics', promos.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Total Promos',value:promos.length},{label:'Total Uses',value:num(totalUses)},{label:'Discount Given',value:peso(totalDisc)}]));
}

function renderCommission(commissions) {
    var cols = [{l:'No.',c:1},{l:'Order ID'},{l:'Seller'},{l:'Rider'},{l:'Order Total',r:1},{l:'Delivery Fee',r:1},{l:'Seller Comm.',r:1},{l:'Rider Comm.',r:1},{l:'Platform Earnings',r:1},{l:'Order Date'},{l:'Completed'}];
    var rows = commissions.map(function(c, i) {
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>#' + (c.order_id||'—') + '</b>') +
            td(c.seller_email||'—') +
            td(c.rider_email||'N/A') +
            td(peso(c.order_total), true) +
            td(peso(c.delivery_fee), true) +
            td(peso(c.seller_commission), true) +
            td(peso(c.rider_commission), true) +
            td('<b>' + peso(c.total_platform_earnings) + '</b>', true) +
            td(c.order_date||'—') +
            td(c.date_completed||'N/A') + '</tr>';
    }).join('');
    var tSC = commissions.reduce(function(a,c){ return a+(parseFloat(c.seller_commission)||0); }, 0);
    var tRC = commissions.reduce(function(a,c){ return a+(parseFloat(c.rider_commission)||0); }, 0);
    var tPE = commissions.reduce(function(a,c){ return a+(parseFloat(c.total_platform_earnings)||0); }, 0);
    return sec('Platform Commission Summary', commissions.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Orders',value:commissions.length},{label:'Seller Commission',value:peso(tSC)},{label:'Rider Commission',value:peso(tRC)},{label:'Platform Earnings',value:peso(tPE)}]));
}

function renderIssues(issues) {
    var cols = [{l:'No.',c:1},{l:'Reported By'},{l:'Reported Against'},{l:'Issue Type'},{l:'Description'},{l:'Order ID',c:1},{l:'Status'},{l:'Date'}];
    var rows = issues.map(function(iss, i) {
        var desc = (iss.description||'No description').substring(0, 55) + (iss.description && iss.description.length > 55 ? '…' : '');
        var st   = (iss.status||'').toLowerCase();
        var sp   = st === 'resolved' ? pill('Resolved','green') : st === 'pending' ? pill('Pending','amber') : pill(iss.status||'—','gray');
        return '<tr style="' + rowBg(i) + '">' +
            td(i+1, false, true, 'color:#718096;font-size:7pt;font-weight:600;') +
            td('<b>' + (iss.reported_by||'—') + '</b>') +
            td(iss.reported_against||'—') +
            td(pill(iss.issue_type||'—','blue')) +
            td('<span style="font-size:7pt;color:#4a5568;">' + desc + '</span>') +
            td(iss.order_id ? '#'+iss.order_id : 'N/A', false, true) +
            td(sp) +
            td(iss.date_submitted||'—') + '</tr>';
    }).join('');
    var pending  = issues.filter(function(i){ return (i.status||'').toLowerCase()==='pending'; }).length;
    var resolved = issues.filter(function(i){ return (i.status||'').toLowerCase()==='resolved'; }).length;
    return sec('Complaints &amp; Issues Report', issues.length,
        thead(cols) + rows + '</tbody></table>',
        totBar([{label:'Total Issues',value:issues.length},{label:'Pending',value:pending},{label:'Resolved',value:resolved}]));
}
