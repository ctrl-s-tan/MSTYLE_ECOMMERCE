// Seller-Rider Chat Modal JavaScript

let currentRiderChatConversationId = null;
let currentRiderEmail = null;
let currentSellerEmailForRider = null;
let currentRiderName = null;
let currentRiderProfilePicture = null;
let currentSellerProfilePictureForRider = null;
let currentOrderIdForRider = null;
let currentProductNameForRider = null;
let riderMessagePollingInterval = null;

// Open Seller-Rider Chat Modal
function openSellerRiderChatModal(riderEmail, riderName, orderId, productName) {
    console.log('Opening seller-rider chat modal:', { riderEmail, riderName, orderId, productName });
    
    // Store current rider info
    currentRiderEmail = riderEmail;
    currentRiderName = riderName;
    currentOrderIdForRider = orderId;
    currentProductNameForRider = productName;
    
    // Get seller email from session (should be available in the page)
    currentSellerEmailForRider = document.body.dataset.sellerEmail || '';
    
    // Show modal
    document.getElementById('sellerRiderChatModal').style.display = 'flex';
    document.body.style.overflow = 'hidden';
    
    // Update header with rider name
    document.getElementById('chatRiderName').textContent = riderName || riderEmail;
    
    // Update header avatar with initial (will be replaced with profile picture when messages load)
    const avatarContainer = document.querySelector('.rider-avatar-chat');
    if (avatarContainer) {
        const riderInitial = riderName ? riderName.charAt(0).toUpperCase() : 'R';
        avatarContainer.innerHTML = riderInitial;
        avatarContainer.style.fontSize = '24px';
        avatarContainer.style.fontWeight = '600';
    }
    
    // Show order context if provided
    if (orderId && productName) {
        document.getElementById('riderOrderContextInfo').style.display = 'flex';
        document.getElementById('riderContextOrderId').textContent = '#' + orderId;
        document.getElementById('riderContextProductName').textContent = productName;
    } else {
        document.getElementById('riderOrderContextInfo').style.display = 'none';
    }
    
    // Load or create conversation
    loadSellerRiderConversation(riderEmail, orderId);
}

// Close Seller-Rider Chat Modal
function closeSellerRiderChatModal() {
    document.getElementById('sellerRiderChatModal').style.display = 'none';
    document.body.style.overflow = 'auto';
    
    // Clear polling interval
    if (riderMessagePollingInterval) {
        clearInterval(riderMessagePollingInterval);
        riderMessagePollingInterval = null;
    }
    
    // Reset state
    currentRiderChatConversationId = null;
    currentRiderEmail = null;
    currentSellerEmailForRider = null;
}

// Load or Create Conversation
function loadSellerRiderConversation(riderEmail, orderId) {
    console.log('Loading conversation with rider:', riderEmail);
    
    const messagesArea = document.getElementById('sellerRiderMessagesArea');
    messagesArea.innerHTML = `
        <div class="loading-messages">
            <i class="bi bi-hourglass-split"></i>
            <p>Loading conversation...</p>
        </div>
    `;
    
    // Create conversation ID (format: riderEmail_sellerEmail_orderId)
    currentRiderChatConversationId = `${riderEmail}_${currentSellerEmailForRider}_${orderId}`;
    
    console.log('Conversation ID:', currentRiderChatConversationId);
    
    // Load messages
    loadSellerRiderMessages();
    
    // Show message input
    document.getElementById('sellerRiderMessageInput').style.display = 'flex';
    
    // Start polling for new messages
    if (riderMessagePollingInterval) {
        clearInterval(riderMessagePollingInterval);
    }
    riderMessagePollingInterval = setInterval(loadSellerRiderMessages, 3000);
}

// Load Messages
function loadSellerRiderMessages() {
    if (!currentRiderEmail || !currentOrderIdForRider) {
        console.error('No rider email or order ID set');
        return;
    }
    
    console.log('🔄 Loading messages for rider:', currentRiderEmail);
    console.log('Order ID:', currentOrderIdForRider);
    
    // For sellers, we pass rider_email and order_id parameters
    let url = `/api/messages/seller-rider-conversation?rider_email=${encodeURIComponent(currentRiderEmail)}&order_id=${encodeURIComponent(currentOrderIdForRider)}`;
    
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
            
            const messagesArea = document.getElementById('sellerRiderMessagesArea');
            
            if (data.success && data.messages && data.messages.length > 0) {
                console.log('✅ Displaying', data.messages.length, 'messages');
                // Store profile pictures if available
                if (data.rider_profile_picture) {
                    currentRiderProfilePicture = data.rider_profile_picture;
                }
                if (data.seller_profile_picture) {
                    currentSellerProfilePictureForRider = data.seller_profile_picture;
                }
                
                // Update header avatar with rider profile picture
                updateRiderHeaderAvatar();
                
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
                    if (msg.sender_type === 'rider') {
                        const riderInitial = currentRiderName ? currentRiderName.charAt(0).toUpperCase() : 'R';
                        if (currentRiderProfilePicture) {
                            avatarHtml = `<img src="/static/images/uploads/${currentRiderProfilePicture}" alt="${currentRiderName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = riderInitial;
                        }
                    } else {
                        const sellerInitial = 'S';
                        if (currentSellerProfilePictureForRider) {
                            avatarHtml = `<img src="/static/images/uploads/${currentSellerProfilePictureForRider}" alt="Seller" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
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
                markSellerRiderMessagesAsRead();
                
            } else {
                // No messages yet
                messagesArea.innerHTML = `
                    <div class="chat-placeholder">
                        <i class="bi bi-chat-text"></i>
                        <h3>Start the conversation</h3>
                        <p>Send a message to the rider about the delivery</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            const messagesArea = document.getElementById('sellerRiderMessagesArea');
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
function sendSellerRiderMessage() {
    const messageText = document.getElementById('sellerRiderMessageText').value.trim();
    
    if (!messageText) {
        showToast('Please enter a message', 'warning');
        return;
    }
    
    if (!currentRiderChatConversationId || !currentRiderEmail || !currentOrderIdForRider) {
        showToast('Unable to send message. Please try again.', 'error');
        return;
    }
    
    // Disable send button
    const sendBtn = document.querySelector('#sellerRiderMessageInput .send-message-btn');
    const originalHTML = sendBtn.innerHTML;
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="bi bi-hourglass-split"></i>';
    
    // Prepare message data
    const messageData = {
        rider_email: currentRiderEmail,
        order_id: currentOrderIdForRider,
        message_text: messageText
    };
    
    console.log('📤 Sending message:', messageData);
    console.log('Current conversation ID:', currentRiderChatConversationId);
    
    fetch('/api/messages/send-seller-rider-message', {
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
            document.getElementById('sellerRiderMessageText').value = '';
            
            // Reset character count
            const charCount = document.getElementById('riderCharCount');
            if (charCount) {
                charCount.textContent = '0';
            }
            
            // Reload messages immediately with a small delay to ensure DB is updated
            setTimeout(() => {
                console.log('🔄 Reloading messages after send...');
                loadSellerRiderMessages();
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
function markSellerRiderMessagesAsRead() {
    if (!currentRiderChatConversationId) return;
    
    fetch('/api/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            conversation_id: currentRiderChatConversationId
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
function updateRiderHeaderAvatar() {
    const avatarContainer = document.querySelector('.rider-avatar-chat');
    if (!avatarContainer) return;
    
    const riderInitial = currentRiderName ? currentRiderName.charAt(0).toUpperCase() : 'R';
    
    if (currentRiderProfilePicture) {
        avatarContainer.innerHTML = `<img src="/static/images/uploads/${currentRiderProfilePicture}" alt="${currentRiderName}">`;
    } else {
        // Show initial letter instead of icon
        avatarContainer.innerHTML = riderInitial;
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
    const textarea = document.getElementById('sellerRiderMessageText');
    if (textarea) {
        // Handle Enter key
        textarea.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendSellerRiderMessage();
            }
        });
        
        // Handle character count
        textarea.addEventListener('input', function() {
            const charCount = document.getElementById('riderCharCount');
            if (charCount) {
                charCount.textContent = this.value.length;
            }
        });
    }
    
    // Close modal when clicking outside
    const modal = document.getElementById('sellerRiderChatModal');
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeSellerRiderChatModal();
            }
        });
    }
});

// Close modal with Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const modal = document.getElementById('sellerRiderChatModal');
        if (modal && modal.style.display === 'flex') {
            closeSellerRiderChatModal();
        }
    }
});
