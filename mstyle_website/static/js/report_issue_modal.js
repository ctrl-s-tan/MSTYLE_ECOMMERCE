// Report Issue Modal Functions

// Store current order details for the report
let currentReportOrderDetails = null;

// Open Report Issue Modal
function openReportIssueModal() {
    const order = currentOrderDetails;

    if (!order || !order.orderId) {
        showToast('Unable to open report form. Order information not available.', 'error');
        return;
    }

    // Store order details for the report
    currentReportOrderDetails = order;

    // Set order ID and reporter info
    document.getElementById('report-order-id').value = order.orderId;
    
    // Store buyer, seller, and rider emails for later use
    document.getElementById('buyer-email-hidden').value = order.customerEmail || '';
    document.getElementById('seller-email-hidden').value = order.sellerEmail || '';
    document.getElementById('rider-email-hidden').value = order.riderEmail || '';

    // Update order context display
    document.getElementById('contextReportOrderId').textContent = order.orderId;
    document.getElementById('contextReportProductName').textContent = order.productName || 'N/A';

    // Get order status (handle both 'status' and 'orderStatus' property names)
    const orderStatus = order.orderStatus || order.status || '';
    
    console.log('Order Status:', orderStatus);
    console.log('Rider Email:', order.riderEmail);
    console.log('Rider Name:', order.riderName);
    console.log('Full Order Object:', order);
    
    // Check if rider is assigned (has email and is in a status where rider is involved)
    const riderStatuses = ['For Pickup', 'Heading to Seller', 'Shipped', 'Delivered', 'Completed'];
    const hasRider = order.riderEmail && order.riderEmail.trim() !== '' && order.riderEmail !== 'null';
    const isRiderInvolved = riderStatuses.includes(orderStatus);
    
    console.log('Has Rider:', hasRider);
    console.log('Is Rider Involved (status check):', isRiderInvolved);

    // Determine reporter role FIRST before updating any options
    const reporterRoleInput = document.getElementById('report-reporter-role');
    const reporterRole = reporterRoleInput ? reporterRoleInput.value : 'seller';
    
    console.log('Reporter Role:', reporterRole);
    
    // Update issue types based on reporter role
    updateIssueTypesForRole(reporterRole);
    
    // Update report against options based on reporter role (this will show/hide options appropriately)
    updateReportAgainstOptions(reporterRole, hasRider, order);
    
    // NOW update rider option text and enabled state (but visibility is already set by updateReportAgainstOptions)
    const riderOption = document.getElementById('rider-option');
    if (riderOption && reporterRole !== 'rider') {
        // Only update rider option if reporter is NOT a rider (since it's hidden for riders)
        if (hasRider && isRiderInvolved) {
            riderOption.disabled = false;
            riderOption.textContent = order.riderName ? `Rider (${order.riderName})` : 'Rider';
            console.log('✓ Rider option ENABLED - Rider:', order.riderName || 'Unknown');
        } else {
            riderOption.disabled = true;
            riderOption.textContent = 'Rider (Not assigned yet)';
            console.log('✗ Rider option DISABLED - No rider assigned');
        }
    }

    // Reset form
    document.getElementById('reportIssueForm').reset();
    
    // Re-set all the important hidden fields after reset
    document.getElementById('report-order-id').value = order.orderId;
    document.getElementById('buyer-email-hidden').value = order.customerEmail || '';
    document.getElementById('seller-email-hidden').value = order.sellerEmail || '';
    document.getElementById('rider-email-hidden').value = order.riderEmail || '';
    document.getElementById('issueCharCount').textContent = '0';
    
    console.log('After reset - Hidden fields set to:');
    console.log('- buyer-email-hidden:', document.getElementById('buyer-email-hidden').value);
    console.log('- seller-email-hidden:', document.getElementById('seller-email-hidden').value);
    console.log('- rider-email-hidden:', document.getElementById('rider-email-hidden').value);

    // Show modal
    const modal = document.getElementById('reportIssueModal');
    modal.style.display = 'flex';
    setTimeout(() => modal.classList.add('show'), 10);
}

// Update issue types based on reporter role
function updateIssueTypesForRole(role) {
    const issueTypeSelect = document.getElementById('issue-type');
    
    // Clear existing options
    issueTypeSelect.innerHTML = '<option value="">Select issue type</option>';
    
    let issueTypes = [];
    
    if (role === 'seller') {
        issueTypes = [
            { value: 'payment_issue', label: 'Payment Issue' },
            { value: 'delivery_delay', label: 'Delivery Delay' },
            { value: 'wrong_address', label: 'Wrong/Incomplete Address' },
            { value: 'customer_unreachable', label: 'Customer Unreachable' },
            { value: 'rider_issue', label: 'Rider Issue' },
            { value: 'damaged_product', label: 'Damaged Product (Before Pickup)' },
            { value: 'order_cancellation', label: 'Order Cancellation Request' },
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'fraudulent_order', label: 'Suspected Fraudulent Order' },
            { value: 'other', label: 'Other' }
        ];
    } else if (role === 'rider') {
        issueTypes = [
            { value: 'pickup_issue', label: 'Pickup Issue' },
            { value: 'address_issue', label: 'Address Issue' },
            { value: 'customer_unavailable', label: 'Customer Unavailable' },
            { value: 'seller_unavailable', label: 'Seller Unavailable' },
            { value: 'product_issue', label: 'Product Issue' },
            { value: 'wrong_address', label: 'Wrong/Incomplete Address' },
            { value: 'access_issue', label: 'Access/Security Issue' },
            { value: 'payment_issue', label: 'Payment Issue' },
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'other', label: 'Other' }
        ];
    } else if (role === 'buyer') {
        issueTypes = [
            { value: 'damaged_product', label: 'Damaged Product' },
            { value: 'wrong_item', label: 'Wrong Item Received' },
            { value: 'missing_parts', label: 'Missing Parts/Accessories' },
            { value: 'quality_issue', label: 'Quality Issue' },
            { value: 'size_issue', label: 'Size/Fit Issue' },
            { value: 'delivery_issue', label: 'Delivery Issue' },
            { value: 'seller_unresponsive', label: 'Seller Unresponsive' },
            { value: 'rider_issue', label: 'Rider Issue' },
            { value: 'late_delivery', label: 'Late Delivery' },
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'other', label: 'Other' }
        ];
    }
    
    // Add options to select
    issueTypes.forEach(type => {
        const option = document.createElement('option');
        option.value = type.value;
        option.textContent = type.label;
        issueTypeSelect.appendChild(option);
    });
}

// Update report against options based on reporter role
function updateReportAgainstOptions(role, hasRider, order) {
    const reportAgainstSelect = document.getElementById('report-against');
    const buyerOption = document.getElementById('buyer-option');
    const sellerOption = document.getElementById('seller-option');
    const riderOption = document.getElementById('rider-option');
    const platformOption = document.getElementById('platform-option');
    const otherOption = document.getElementById('other-option');
    
    console.log('=== Updating report against options ===');
    console.log('Reporter Role:', role);
    console.log('Has Rider:', hasRider);
    console.log('Buyer Option found:', !!buyerOption);
    console.log('Seller Option found:', !!sellerOption);
    console.log('Rider Option found:', !!riderOption);
    console.log('Platform Option found:', !!platformOption);
    console.log('Other Option found:', !!otherOption);
    
    // Reset all options to visible first
    if (buyerOption) buyerOption.style.display = 'block';
    if (sellerOption) sellerOption.style.display = 'block';
    if (riderOption) riderOption.style.display = 'block';
    if (platformOption) platformOption.style.display = 'block';
    if (otherOption) otherOption.style.display = 'block';
    
    // Show/hide options based on role
    if (role === 'seller') {
        // Seller can report: Buyer, Rider, Platform, Other (NOT Seller)
        if (sellerOption) {
            sellerOption.style.display = 'none';
            sellerOption.disabled = true;
            console.log('✗ Seller option HIDDEN (seller cannot report seller)');
        }
        console.log('✓ Seller mode: Buyer, Rider, Platform, Other visible');
    } else if (role === 'rider') {
        // Rider can report: Buyer, Seller, Platform, Other (NOT Rider)
        if (riderOption) {
            riderOption.style.display = 'none';
            riderOption.disabled = true;
            riderOption.selected = false;
            console.log('✗ Rider option HIDDEN (rider cannot report rider)');
        }
        console.log('✓ Rider mode: Buyer, Seller, Platform, Other visible');
    } else if (role === 'buyer') {
        // Buyer can report: Seller, Rider, Platform, Other (NOT Buyer)
        if (buyerOption) {
            buyerOption.style.display = 'none';
            buyerOption.disabled = true;
            console.log('✗ Buyer option HIDDEN (buyer cannot report buyer)');
        }
        console.log('✓ Buyer mode: Seller, Rider, Platform, Other visible');
    }
    
    console.log('=== Report against options updated ===');
}

// Close Report Issue Modal
function closeReportIssueModal() {
    const modal = document.getElementById('reportIssueModal');
    modal.classList.remove('show');
    setTimeout(() => {
        modal.style.display = 'none';
        document.getElementById('reportIssueForm').reset();
        currentReportOrderDetails = null;
    }, 300);
}

// Update Report Against Email and Issue Types
function updateReportAgainstEmail() {
    const reportAgainst = document.getElementById('report-against').value;
    const reportAgainstEmailInput = document.getElementById('report-against-email');
    const buyerEmail = document.getElementById('buyer-email-hidden').value;
    const sellerEmail = document.getElementById('seller-email-hidden').value;
    const riderEmail = document.getElementById('rider-email-hidden').value;
    const riderOption = document.getElementById('rider-option');

    console.log('=== updateReportAgainstEmail called ===');
    console.log('Report Against Selected:', reportAgainst);
    console.log('Buyer Email (from hidden):', buyerEmail);
    console.log('Seller Email (from hidden):', sellerEmail);
    console.log('Rider Email (from hidden):', riderEmail);
    console.log('Current reported_against_email value:', reportAgainstEmailInput.value);

    // Set the appropriate email based on selection
    if (reportAgainst === 'buyer') {
        reportAgainstEmailInput.value = buyerEmail;
        console.log('✓ Set reported_against_email to BUYER:', buyerEmail);
    } else if (reportAgainst === 'seller') {
        reportAgainstEmailInput.value = sellerEmail;
        console.log('✓ Set reported_against_email to SELLER:', sellerEmail);
    } else if (reportAgainst === 'rider') {
        // Check if rider option is disabled
        if (riderOption && riderOption.disabled) {
            alert('No rider assigned to this order yet.');
            document.getElementById('report-against').value = '';
            reportAgainstEmailInput.value = '';
            console.log('✗ Rider not available - cleared selection');
            return;
        } else {
            reportAgainstEmailInput.value = riderEmail;
            console.log('✓ Set reported_against_email to RIDER:', riderEmail);
        }
    } else if (reportAgainst === 'platform') {
        reportAgainstEmailInput.value = '';
        console.log('✓ Cleared email (PLATFORM selected - no email needed)');
    } else if (reportAgainst === 'other') {
        reportAgainstEmailInput.value = '';
        console.log('✓ Cleared email (OTHER selected - no email needed)');
    } else {
        reportAgainstEmailInput.value = '';
        console.log('✓ Cleared email (no selection)');
    }
    
    console.log('Final reported_against_email value:', reportAgainstEmailInput.value);
    console.log('=== updateReportAgainstEmail completed ===');
    
    // Update issue types based on who is being reported
    updateIssueTypesBasedOnReportedParty(reportAgainst);
}

// Update issue types based on who is being reported against
function updateIssueTypesBasedOnReportedParty(reportedAgainst) {
    const issueTypeSelect = document.getElementById('issue-type');
    
    // Clear existing options
    issueTypeSelect.innerHTML = '<option value="">Select issue type</option>';
    
    let issueTypes = [];
    
    if (reportedAgainst === 'buyer') {
        // Issues when reporting a buyer
        issueTypes = [
            { value: 'payment_issue', label: 'Payment Issue' },
            { value: 'wrong_address', label: 'Wrong/Incomplete Address' },
            { value: 'customer_unreachable', label: 'Customer Unreachable' },
            { value: 'customer_unavailable', label: 'Customer Unavailable' },
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'fraudulent_order', label: 'Suspected Fraudulent Order' },
            { value: 'order_cancellation', label: 'Order Cancellation Request' },
            { value: 'rude_behavior', label: 'Rude/Inappropriate Behavior' },
            { value: 'other', label: 'Other' }
        ];
    } else if (reportedAgainst === 'seller') {
        // Issues when reporting a seller
        issueTypes = [
            { value: 'damaged_product', label: 'Damaged Product' },
            { value: 'wrong_item', label: 'Wrong Item' },
            { value: 'missing_parts', label: 'Missing Parts' },
            { value: 'quality_issue', label: 'Quality Issue' },
            { value: 'seller_unresponsive', label: 'Seller Unresponsive' },
            { value: 'seller_unavailable', label: 'Seller Unavailable' },
            { value: 'pickup_issue', label: 'Pickup Issue' },
            { value: 'product_issue', label: 'Product Issue' },
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'late_preparation', label: 'Late Order Preparation' },
            { value: 'other', label: 'Other' }
        ];
    } else if (reportedAgainst === 'rider') {
        // Issues when reporting a rider
        issueTypes = [
            { value: 'delivery_delay', label: 'Delivery Delay' },
            { value: 'rider_issue', label: 'Rider Issue' },
            { value: 'late_delivery', label: 'Late Delivery' },
            { value: 'damaged_product', label: 'Damaged Product (During Delivery)' },
            { value: 'rider_unresponsive', label: 'Rider Unresponsive' },
            { value: 'wrong_delivery', label: 'Wrong Delivery Location' },
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'rude_behavior', label: 'Rude/Inappropriate Behavior' },
            { value: 'other', label: 'Other' }
        ];
    } else if (reportedAgainst === 'platform') {
        // Issues when reporting the platform
        issueTypes = [
            { value: 'technical_issue', label: 'Technical Issue' },
            { value: 'payment_issue', label: 'Payment Issue' },
            { value: 'app_bug', label: 'App/Website Bug' },
            { value: 'feature_request', label: 'Feature Request' },
            { value: 'account_issue', label: 'Account Issue' },
            { value: 'notification_issue', label: 'Notification Issue' },
            { value: 'other', label: 'Other' }
        ];
    } else {
        // Default/Other - general issues
        issueTypes = [
            { value: 'communication_issue', label: 'Communication Issue' },
            { value: 'delivery_issue', label: 'Delivery Issue' },
            { value: 'payment_issue', label: 'Payment Issue' },
            { value: 'quality_issue', label: 'Quality Issue' },
            { value: 'other', label: 'Other' }
        ];
    }
    
    // Add options to select
    issueTypes.forEach(type => {
        const option = document.createElement('option');
        option.value = type.value;
        option.textContent = type.label;
        issueTypeSelect.appendChild(option);
    });
    
    console.log('Updated issue types for:', reportedAgainst, '- Total options:', issueTypes.length);
}

// Submit Report Issue
function submitReportIssue(event) {
    event.preventDefault();

    const form = event.target;
    const submitBtn = form.querySelector('.btn-submit-report');
    const formData = new FormData(form);

    // Disable submit button and show loading state
    submitBtn.disabled = true;
    const originalBtnContent = submitBtn.innerHTML;
    submitBtn.innerHTML = '<i class="bi bi-hourglass-split" style="animation: spin 1s linear infinite;"></i><span>Submitting...</span>';

    // Convert FormData to JSON
    const data = {};
    formData.forEach((value, key) => {
        data[key] = value;
    });

    console.log('=== SUBMITTING REPORT ===');
    console.log('Form data collected:', data);
    console.log('reported_against_email value:', data.reported_against_email);
    console.log('reported_against_role value:', data.reported_against_role);
    console.log('reporter_role value:', data.reporter_role);
    console.log('reporter_email value:', data.reporter_email);
    
    // Double-check the hidden field value
    const reportAgainstEmailField = document.getElementById('report-against-email');
    console.log('Hidden field #report-against-email value:', reportAgainstEmailField ? reportAgainstEmailField.value : 'FIELD NOT FOUND');
    console.log('=== END SUBMIT DATA ===');

    fetch('/submit_order_issue', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(result => {
        console.log('Report submission result:', result);
        
        if (result.success) {
            // Close the report modal
            closeReportIssueModal();
            
            // Show success modal
            showReportSuccessModal(result.message || 'Issue report submitted successfully. Admin will review your report.');
            
            // Reset button state
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalBtnContent;
        } else {
            // Show error message
            alert('Error: ' + (result.message || 'Failed to submit report. Please try again.'));
            
            // Reset button state
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalBtnContent;
        }
    })
    .catch(error => {
        console.error('Error submitting report:', error);
        alert('An error occurred while submitting the report. Please try again.');
        
        // Reset button state
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalBtnContent;
    });
}

// Show Report Success Modal
function showReportSuccessModal(message) {
    // Check if success modal exists (for pages that have it)
    let successModal = document.getElementById('reportSuccessModal');
    
    if (!successModal) {
        // Create a simple success modal if it doesn't exist
        successModal = document.createElement('div');
        successModal.id = 'reportSuccessModal';
        successModal.className = 'success-modal';
        successModal.innerHTML = `
            <div class="success-modal-content">
                <div class="success-icon" style="background: linear-gradient(135deg, #e74c3c, #c0392b);">
                    <i class="bi bi-check success-checkmark"></i>
                </div>
                <h2 style="color: #e74c3c;">Issue Reported!</h2>
                <p class="thank-you-message">We've received your report</p>
                <p class="order-message" id="reportSuccessMessage"></p>
                <div class="success-modal-buttons">
                    <button type="button" class="continue-shopping-btn" onclick="closeReportSuccessModal()">
                        <i class="bi bi-check"></i> Continue
                    </button>
                </div>
            </div>
        `;
        document.body.appendChild(successModal);
    }
    
    // Set the message
    const messageEl = document.getElementById('reportSuccessMessage');
    if (messageEl) {
        messageEl.textContent = message;
    }
    
    // Show the modal
    successModal.style.display = 'flex';
    setTimeout(() => {
        successModal.classList.add('show');
    }, 10);
    
    // Auto-close after 5 seconds
    setTimeout(() => {
        closeReportSuccessModal();
    }, 5000);
}

// Close Report Success Modal
function closeReportSuccessModal() {
    const modal = document.getElementById('reportSuccessModal');
    if (modal) {
        modal.classList.remove('show');
        setTimeout(() => {
            modal.style.display = 'none';
            // Reload the page to show updated data
            location.reload();
        }, 300);
    }
}

// Add CSS for spin animation if not already present
if (!document.getElementById('report-modal-animations')) {
    const style = document.createElement('style');
    style.id = 'report-modal-animations';
    style.textContent = `
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    `;
    document.head.appendChild(style);
}

// Character counter for issue description
document.addEventListener('DOMContentLoaded', function() {
    const issueDescription = document.getElementById('issue-description');
    const charCount = document.getElementById('issueCharCount');

    if (issueDescription && charCount) {
        issueDescription.addEventListener('input', function() {
            const length = this.value.length;
            charCount.textContent = length;
            
            // Change color when approaching limit
            if (length > 900) {
                charCount.style.color = '#e74c3c';
            } else if (length > 800) {
                charCount.style.color = '#f39c12';
            } else {
                charCount.style.color = '#999';
            }
        });
    }
});

// Close modal when clicking outside
window.addEventListener('click', function(event) {
    const modal = document.getElementById('reportIssueModal');
    if (event.target === modal) {
        closeReportIssueModal();
    }
});

// Close modal with Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('reportIssueModal');
        if (modal && modal.style.display === 'flex') {
            closeReportIssueModal();
        }
    }
});
