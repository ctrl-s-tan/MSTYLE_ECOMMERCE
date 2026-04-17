// Buyer-Seller Chat for Orders - JavaScript
let currentSellerOrderId = null;
let currentSellerEmailOrder = null;
let sellerOrderChatInterval = null;
let lastSellerOrderMessageId = 0;

// Open seller chat modal for a specific order
function openSellerChatOrder(orderId, sellerEmail) {
    console.log('📞 Opening seller chat for order:', orderId, 'Seller:', sellerEmail);
    
    currentSellerOrderId = orderId;
    currentSellerEmailOrder = sellerEmail;
    lastSellerOrderMessageId = 0;
    
    const modal = document.getElementById('buyerSellerChatOrderModal');
    const messagesArea = document.getElementById('sellerMessagesAreaOrder');
    const orderIdContext = document.getElementById('orderIdContextSeller');
    const sellerName = document.getElementById('sellerNameOrder');
    
    // Set order ID in context
    orderIdContext.textContent = '#' + orderId;
    
    // Fetch seller name
    fetchSellerNameOrder(sellerEmail);
    
    // Clear messages area
    messagesArea.innerHTML = `
        <div class="chat-loading" id="sellerChatLoadingOrder">
            <i class="bi bi-hourglass-split"></i>
            <p>Loading messages...</p>
        </div>
    `;
    
    // Show modal
    modal.style.display = 'flex';
    setTimeout(() => {
        modal.classList.add('show');
    }, 10);
    
    // Load messages (but don't create conversation if no messages exist)
    loadSellerOrderMessages();
    
    // Start polling for new messages only after first message is sent
    // Don't start polling immediately to avoid creating empty conversations
    if (sellerOrderChatInterval) {
        clearInterval(sellerOrderChatInterval);
        sellerOrderChatInterval = null;
    }
    
    // Focus on input
    setTimeout(() => {
        document.getElementById('sellerMessageInputOrder').focus();
    }, 300);
}

// Close seller chat modal
function closeSellerChatOrder() {
    const modal = document.getElementById('buyerSellerChatOrderModal');
    modal.classList.remove('show');
    
    setTimeout(() => {
        modal.style.display = 'none';
        currentSellerOrderId = null;
        currentSellerEmailOrder = null;
        lastSellerOrderMessageId = 0;
        
        // Clear polling interval
        if (sellerOrderChatInterval) {
            clearInterval(sellerOrderChatInterval);
            sellerOrderChatInterval = null;
        }
        
        // Reset input
        document.getElementById('sellerMessageInputOrder').value = '';
        updateSellerOrderCharCount();
    }, 300);
}

// Fetch seller name and profile picture
function fetchSellerNameOrder(sellerEmail) {
    fetch(`/get_seller_info?email=${encodeURIComponent(sellerEmail)}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Set seller name
                document.getElementById('sellerNameOrder').textContent = data.name || 'Seller';
                
                // Set profile picture
                const profilePicImg = document.getElementById('sellerProfilePicOrder');
                const avatarIcon = document.getElementById('sellerAvatarIconOrder');
                
                if (data.profile_picture) {
                    profilePicImg.src = '/static/uploads/' + data.profile_picture;
                    profilePicImg.style.display = 'block';
                    avatarIcon.style.display = 'none';
                    
                    // Handle image load error
                    profilePicImg.onerror = function() {
                        this.style.display = 'none';
                        avatarIcon.style.display = 'flex';
                        // Update icon to show first letter of name
                        if (data.name) {
                            avatarIcon.innerHTML = '<span style="font-size: 24px; font-weight: 600;">' + data.name[0].toUpperCase() + '</span>';
                        }
                    };
                } else {
                    // No profile picture, show initial
                    profilePicImg.style.display = 'none';
                    avatarIcon.style.display = 'flex';
                    if (data.name) {
                        avatarIcon.innerHTML = '<span style="font-size: 24px; font-weight: 600;">' + data.name[0].toUpperCase() + '</span>';
                    }
                }
            }
        })
        .catch(error => {
            console.error('Error fetching seller info:', error);
        });
}

// Load messages from server
function loadSellerOrderMessages() {
    if (!currentSellerOrderId || !currentSellerEmailOrder) return;
    
    const buyerEmail = document.body.getAttribute('data-buyer-email');
    
    fetch(`/get_buyer_seller_messages_order?order_id=${currentSellerOrderId}&seller_email=${encodeURIComponent(currentSellerEmailOrder)}&buyer_email=${encodeURIComponent(buyerEmail)}`)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displaySellerOrderMessages(data.messages);
            } else {
                console.error('Failed to load messages:', data.error);
                showSellerOrderEmptyState();
            }
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            showSellerOrderEmptyState();
        });
}

// Display messages in chat
function displaySellerOrderMessages(messages) {
    const messagesArea = document.getElementById('sellerMessagesAreaOrder');
    const loadingEl = document.getElementById('sellerChatLoadingOrder');
    const emptyEl = document.getElementById('sellerChatEmptyOrder');
    
    // Hide loading and empty states
    if (loadingEl) loadingEl.style.display = 'none';
    if (emptyEl) emptyEl.style.display = 'none';
    
    if (!messages || messages.length === 0) {
        showSellerOrderEmptyState();
        return;
    }
    
    const buyerEmail = document.body.getAttribute('data-buyer-email');
    let messagesHTML = '';
    let lastDate = '';
    
    messages.forEach((msg, index) => {
        // Add date divider if date changes
        const msgDate = new Date(msg.created_at).toLocaleDateString();
        if (msgDate !== lastDate) {
            messagesHTML += `
                <div class="chat-date-divider">
                    <span>${formatDateDivider(msg.created_at)}</span>
                </div>
            `;
            lastDate = msgDate;
        }
        
        const isBuyer = msg.sender_email === buyerEmail;
        const messageClass = isBuyer ? 'buyer' : 'rider';
        const time = formatMessageTime(msg.created_at);
        
        messagesHTML += `
            <div class="rider-chat-message-item ${messageClass}">
                <div class="rider-message-avatar-small">
                    <div class="avatar-icon">
                        <i class="bi ${isBuyer ? 'bi-person-fill' : 'bi-shop'}"></i>
                    </div>
                </div>
                <div class="rider-message-content-wrapper">
                    <div class="rider-message-bubble-chat">${escapeHtml(msg.message_text)}</div>
                    <div class="rider-message-time-chat">${time}</div>
                </div>
            </div>
        `;
        
        // Track last message ID
        if (msg.id > lastSellerOrderMessageId) {
            lastSellerOrderMessageId = msg.id;
        }
    });
    
    // Only update if content changed
    const currentHTML = messagesArea.innerHTML;
    if (!currentHTML.includes(messagesHTML)) {
        messagesArea.innerHTML = messagesHTML;
        scrollToBottomSellerOrder();
    }
}

// Show empty state
function showSellerOrderEmptyState() {
    const messagesArea = document.getElementById('sellerMessagesAreaOrder');
    const loadingEl = document.getElementById('sellerChatLoadingOrder');
    
    if (loadingEl) loadingEl.style.display = 'none';
    
    messagesArea.innerHTML = `
        <div class="rider-chat-empty-state">
            <i class="bi bi-chat-dots"></i>
            <h4>Start a conversation</h4>
            <p>Send a message to the seller about your order</p>
        </div>
    `;
}

// Send message to seller
function sendSellerMessageOrder() {
    const messageInput = document.getElementById('sellerMessageInputOrder');
    const sendBtn = document.getElementById('sendSellerBtnOrder');
    const messageText = messageInput.value.trim();
    
    if (!messageText || !currentSellerOrderId || !currentSellerEmailOrder) {
        return;
    }
    
    // Disable input and button
    messageInput.disabled = true;
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="bi bi-hourglass-split" style="animation: spin 1s linear infinite;"></i>';
    
    const buyerEmail = document.body.getAttribute('data-buyer-email');
    
    // Send message to server
    fetch('/send_buyer_seller_message_order', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            order_id: currentSellerOrderId,
            seller_email: currentSellerEmailOrder,
            buyer_email: buyerEmail,
            message: messageText
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Clear input
            messageInput.value = '';
            updateSellerOrderCharCount();
            
            // Reload messages
            loadSellerOrderMessages();
            
            // Start polling for new messages after first message is sent
            if (!sellerOrderChatInterval) {
                sellerOrderChatInterval = setInterval(loadSellerOrderMessages, 3000);
            }
        } else {
            console.error('Failed to send message:', data.error);
            alert('Failed to send message. Please try again.');
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        alert('Failed to send message. Please try again.');
    })
    .finally(() => {
        // Re-enable input and button
        messageInput.disabled = false;
        sendBtn.disabled = false;
        sendBtn.innerHTML = '<i class="bi bi-send-fill"></i>';
        messageInput.focus();
    });
}

// Handle Enter key press
function handleSellerOrderKeyPress(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        sendSellerMessageOrder();
    }
}

// Auto-resize textarea
function autoResizeSellerOrderTextarea(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = Math.min(textarea.scrollHeight, 100) + 'px';
}

// Update character count
function updateSellerOrderCharCount() {
    const input = document.getElementById('sellerMessageInputOrder');
    const counter = document.getElementById('sellerCharCountOrder');
    const length = input.value.length;
    counter.textContent = `${length}/1000`;
    
    if (length > 900) {
        counter.style.color = '#dc3545';
    } else if (length > 800) {
        counter.style.color = '#ffc107';
    } else {
        counter.style.color = '#999';
    }
}

// Scroll to bottom of messages
function scrollToBottomSellerOrder() {
    const messagesArea = document.getElementById('sellerMessagesAreaOrder');
    messagesArea.scrollTop = messagesArea.scrollHeight;
}

// Format message time
function formatMessageTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h ago`;
    
    return date.toLocaleTimeString('en-US', { 
        hour: 'numeric', 
        minute: '2-digit',
        hour12: true 
    });
}

// Format date divider
function formatDateDivider(timestamp) {
    const date = new Date(timestamp);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    if (date.toDateString() === today.toDateString()) {
        return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
        return 'Yesterday';
    } else {
        return date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric',
            year: date.getFullYear() !== today.getFullYear() ? 'numeric' : undefined
        });
    }
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Close modal when clicking outside
window.addEventListener('click', function(event) {
    const modal = document.getElementById('buyerSellerChatOrderModal');
    if (event.target === modal) {
        closeSellerChatOrder();
    }
});

// Close modal with Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('buyerSellerChatOrderModal');
        if (modal && modal.classList.contains('show')) {
            closeSellerChatOrder();
        }
    }
});

// Clean up on page unload
window.addEventListener('beforeunload', function() {
    if (sellerOrderChatInterval) {
        clearInterval(sellerOrderChatInterval);
    }
});
