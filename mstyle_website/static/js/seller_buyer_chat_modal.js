// Seller-Buyer Chat Modal JavaScript

let currentChatConversationId = null;
let currentBuyerEmail = null;
let currentSellerEmail = null;
let currentBuyerName = null;
let currentBuyerProfilePicture = null;
let currentSellerProfilePicture = null;
let currentProductId = null;
let currentProductName = null;
let messagePollingInterval = null;

// Open Seller-Buyer Chat Modal
function openSellerBuyerChatModal(buyerEmail, buyerName, orderId, productName, productId) {
    console.log('Opening seller-buyer chat modal:', { buyerEmail, buyerName, orderId, productName, productId });
    
    // Store current buyer info
    currentBuyerEmail = buyerEmail;
    currentBuyerName = buyerName;
    currentProductId = productId;
    currentProductName = productName;
    
    // Get seller email from session (should be available in the page)
    currentSellerEmail = document.body.dataset.sellerEmail || '';
    
    // Show modal
    document.getElementById('sellerBuyerChatModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
    
    // Update header with buyer name
    document.getElementById('chatBuyerName').textContent = buyerName || buyerEmail;
    
    // Update header avatar with initial (will be replaced with profile picture when messages load)
    const avatarContainer = document.querySelector('.buyer-avatar-chat');
    if (avatarContainer) {
        const buyerInitial = buyerName ? buyerName.charAt(0).toUpperCase() : 'B';
        avatarContainer.innerHTML = buyerInitial;
        avatarContainer.style.fontSize = '24px';
        avatarContainer.style.fontWeight = '600';
    }
    
    // Show order context if provided
    if (orderId && productName) {
        document.getElementById('orderContextInfo').style.display = 'flex';
        document.getElementById('contextOrderId').textContent = '#' + orderId;
        document.getElementById('contextProductName').textContent = productName;
    } else {
        document.getElementById('orderContextInfo').style.display = 'none';
    }
    
    // Load or create conversation
    loadSellerBuyerConversation(buyerEmail, productName);
}

// Close Seller-Buyer Chat Modal
function closeSellerBuyerChatModal() {
    document.getElementById('sellerBuyerChatModal').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    // Clear polling interval
    if (messagePollingInterval) {
        clearInterval(messagePollingInterval);
        messagePollingInterval = null;
    }
    
    // Reset state
    currentChatConversationId = null;
    currentBuyerEmail = null;
    currentSellerEmail = null;
}

// Load or Create Conversation
function loadSellerBuyerConversation(buyerEmail, productName) {
    console.log('Loading conversation with buyer:', buyerEmail);
    
    const messagesArea = document.getElementById('sellerBuyerMessagesArea');
    messagesArea.innerHTML = `
        <div class="loading-messages">
            <i class="bi bi-hourglass-split"></i>
            <p>Loading conversation...</p>
        </div>
    `;
    
    // Create conversation ID (format: buyerEmail_sellerEmail_general)
    // This matches the format used by the API
    currentChatConversationId = `${buyerEmail}_${currentSellerEmail}_general`;
    
    console.log('Conversation ID:', currentChatConversationId);
    
    // Load messages
    loadSellerBuyerMessages();
    
    // Show message input
    document.getElementById('sellerBuyerMessageInput').style.display = 'flex';
    
    // Start polling for new messages
    if (messagePollingInterval) {
        clearInterval(messagePollingInterval);
    }
    messagePollingInterval = setInterval(loadSellerBuyerMessages, 3000);
}

// Load Messages
function loadSellerBuyerMessages() {
    if (!currentBuyerEmail) {
        console.error('No buyer email set');
        return;
    }
    
    console.log('🔄 Loading messages for buyer:', currentBuyerEmail);
    console.log('Product ID:', currentProductId);
    
    // For sellers, we pass buyer_email and product_id parameters
    let url = `/api/messages/conversation?buyer_email=${encodeURIComponent(currentBuyerEmail)}`;
    if (currentProductId) {
        url += `&product_id=${encodeURIComponent(currentProductId)}`;
    }
    
    console.log('Fetching from URL:', url);
    
    fetch(url)
        .then(response => {
            console.log('📡 Response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('📨 Messages API response:', data);
            console.log('Success:', data.success);
            console.log('Messages count:', data.messages ? data.messages.length : 0);
            console.log('Conversation ID from API:', data.conversation_id);
            
            const messagesArea = document.getElementById('sellerBuyerMessagesArea');
            
            if (data.success && data.messages && data.messages.length > 0) {
                console.log('✅ Displaying', data.messages.length, 'messages');
                // Store profile pictures if available
                if (data.buyer_profile_picture) {
                    currentBuyerProfilePicture = data.buyer_profile_picture;
                }
                if (data.seller_profile_picture) {
                    currentSellerProfilePicture = data.seller_profile_picture;
                }
                
                // Update header avatar with buyer profile picture
                updateHeaderAvatar();
                
                // Display messages
                messagesArea.innerHTML = '';
                
                data.messages.forEach(msg => {
                    const messageItem = document.createElement('div');
                    messageItem.className = `chat-message-item ${msg.sender_type}`;
                    
                    const messageTime = new Date(msg.created_at).toLocaleString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    });
                    
                    // Create avatar HTML
                    let avatarHtml = '';
                    if (msg.sender_type === 'buyer') {
                        const buyerInitial = currentBuyerName ? currentBuyerName.charAt(0).toUpperCase() : 'B';
                        if (currentBuyerProfilePicture) {
                            avatarHtml = `<img src="/static/images/uploads/${currentBuyerProfilePicture}" alt="${currentBuyerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = buyerInitial;
                        }
                    } else {
                        const sellerInitial = 'S';
                        if (currentSellerProfilePicture) {
                            avatarHtml = `<img src="/static/images/uploads/${currentSellerProfilePicture}" alt="Seller" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = sellerInitial;
                        }
                    }
                    
                    messageItem.innerHTML = `
                        <div class="message-avatar-small">${avatarHtml}</div>
                        <div class="message-content-wrapper">
                            <div class="message-bubble-chat">${escapeHtml(msg.message_text)}</div>
                            <span class="message-time-chat">${messageTime}</span>
                        </div>
                    `;
                    
                    messagesArea.appendChild(messageItem);
                });
                
                // Scroll to bottom
                messagesArea.scrollTop = messagesArea.scrollHeight;
                
                // Mark messages as read
                markSellerBuyerMessagesAsRead();
                
            } else {
                // No messages yet
                messagesArea.innerHTML = `
                    <div class="chat-placeholder">
                        <i class="bi bi-chat-text"></i>
                        <h3>Start the conversation</h3>
                        <p>Send a message to the buyer about their order</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            const messagesArea = document.getElementById('sellerBuyerMessagesArea');
            messagesArea.innerHTML = `
                <div class="chat-placeholder">
                    <i class="bi bi-exclamation-triangle"></i>
                    <h3>Error loading messages</h3>
                    <p>Please try again later</p>
                </div>
            `;
        });
}

// Send Message
function sendSellerBuyerMessage() {
    const messageText = document.getElementById('sellerBuyerMessageText').value.trim();
    
    if (!messageText) {
        showToast('Please enter a message', 'warning');
        return;
    }
    
    if (!currentChatConversationId || !currentBuyerEmail) {
        showToast('Unable to send message. Please try again.', 'error');
        return;
    }
    
    // Disable send button
    const sendBtn = document.querySelector('.send-message-btn');
    const originalHTML = sendBtn.innerHTML;
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="bi bi-hourglass-split"></i><span>Sending...</span>';
    
    // Prepare message data
    const messageData = {
        buyer_email: currentBuyerEmail,
        message_text: messageText,
        product_id: currentProductId // Use the product_id from the order
    };
    
    console.log('📤 Sending message:', messageData);
    console.log('Current conversation ID:', currentChatConversationId);
    
    fetch('/api/messages/send-seller-reply', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(messageData)
    })
    .then(response => {
        console.log('📡 Send response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📨 Send response data:', data);
        
        if (data.success) {
            console.log('✅ Message sent successfully, reloading messages...');
            
            // Clear input
            document.getElementById('sellerBuyerMessageText').value = '';
            
            // Reset character count
            const charCount = document.getElementById('sellerCharCount');
            if (charCount) {
                charCount.textContent = '0';
            }
            
            // Reload messages immediately with a small delay to ensure DB is updated
            setTimeout(() => {
                console.log('🔄 Reloading messages after send...');
                loadSellerBuyerMessages();
            }, 500);
            
            showToast('Message sent successfully', 'success');
        } else {
            console.error('❌ Failed to send message:', data.error);
            showToast(data.error || 'Failed to send message', 'error');
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        showToast('Error sending message. Please try again.', 'error');
    })
    .finally(() => {
        // Re-enable send button
        sendBtn.disabled = false;
        sendBtn.innerHTML = originalHTML;
    });
}

// Mark Messages as Read
function markSellerBuyerMessagesAsRead() {
    if (!currentChatConversationId) return;
    
    fetch('/api/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            conversation_id: currentChatConversationId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            console.log('Messages marked as read');
        }
    })
    .catch(error => {
        console.error('Error marking messages as read:', error);
    });
}

// Update Header Avatar
function updateHeaderAvatar() {
    const avatarContainer = document.querySelector('.buyer-avatar-chat');
    if (!avatarContainer) return;
    
    const buyerInitial = currentBuyerName ? currentBuyerName.charAt(0).toUpperCase() : 'B';
    
    if (currentBuyerProfilePicture) {
        avatarContainer.innerHTML = `<img src="/static/images/uploads/${currentBuyerProfilePicture}" alt="${currentBuyerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
    } else {
        // Show initial letter instead of icon
        avatarContainer.innerHTML = buyerInitial;
        avatarContainer.style.fontSize = '24px';
        avatarContainer.style.fontWeight = '600';
    }
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Handle Enter key in textarea and character count
document.addEventListener('DOMContentLoaded', function() {
    const textarea = document.getElementById('sellerBuyerMessageText');
    if (textarea) {
        // Handle Enter key
        textarea.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendSellerBuyerMessage();
            }
        });
        
        // Handle character count
        textarea.addEventListener('input', function() {
            const charCount = document.getElementById('sellerCharCount');
            if (charCount) {
                charCount.textContent = this.value.length;
            }
        });
    }
    
    // Close modal when clicking outside
    const modal = document.getElementById('sellerBuyerChatModal');
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeSellerBuyerChatModal();
            }
        });
    }
    
    // Get seller email from session and store in body dataset
    // This should be set by the backend template
    const sellerEmailMeta = document.querySelector('meta[name="seller-email"]');
    if (sellerEmailMeta) {
        document.body.dataset.sellerEmail = sellerEmailMeta.content;
    }
});

// Close modal with Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const modal = document.getElementById('sellerBuyerChatModal');
        if (modal && modal.style.display === 'flex') {
            closeSellerBuyerChatModal();
        }
    }
});
