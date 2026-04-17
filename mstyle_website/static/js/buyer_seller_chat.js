// Buyer-Seller Chat JavaScript
let currentConversationId = null;
let currentSellerEmail = null;
let currentProductId = null;
let messagePollingInterval = null;
let currentSellerName = null;
let currentBuyerName = null;
let currentSellerProfilePicture = null;
let currentBuyerProfilePicture = null;

// Decode HTML entities
function decodeHtmlEntities(text) {
    const textarea = document.createElement('textarea');
    textarea.innerHTML = text;
    return textarea.value;
}

// Open chat with seller
function openBuyerSellerChat(sellerEmail, sellerName, productId = null, productName = null, productImage = null) {
    currentSellerEmail = sellerEmail;
    currentProductId = productId;
    currentSellerName = decodeHtmlEntities(sellerName || 'Seller');

    // Update seller info in header
    document.getElementById('chatSellerName').textContent = currentSellerName;
    
    // Update seller avatar - will be updated with profile picture when conversation loads
    const sellerAvatar = document.getElementById('chatSellerAvatar');
    const sellerInitial = currentSellerName.charAt(0).toUpperCase();
    sellerAvatar.innerHTML = sellerInitial;
    sellerAvatar.style.fontSize = '20px';
    sellerAvatar.style.fontWeight = '600';

    // Show/hide product context
    const productContext = document.getElementById('chatProductContext');
    if (productId && productName) {
        productContext.style.display = 'flex';
        document.getElementById('chatProductName').textContent = decodeHtmlEntities(productName);
        if (productImage) {
            document.getElementById('chatProductImage').src = productImage;
        }
    } else {
        productContext.style.display = 'none';
    }

    // Show modal
    document.getElementById('buyerSellerChatModal').style.display = 'flex';

    // Load conversation
    loadConversation(sellerEmail, productId);

    // Start polling for new messages
    startMessagePolling();
}

// Close chat modal
function closeBuyerSellerChat() {
    document.getElementById('buyerSellerChatModal').style.display = 'none';
    currentConversationId = null;
    currentSellerEmail = null;
    currentProductId = null;

    // Stop polling
    stopMessagePolling();
}

// Load conversation messages
function loadConversation(sellerEmail, productId = null) {
    const url = `/api/messages/conversation?seller_email=${encodeURIComponent(sellerEmail)}${productId ? `&product_id=${productId}` : ''}`;

    fetch(url)
        .then(response => response.json())
        .then(data => {
            console.log('📡 API Response:', data);
            if (data.success) {
                currentConversationId = data.conversation_id;
                
                // Store buyer and seller names and profile pictures if available
                if (data.buyer_name) {
                    currentBuyerName = decodeHtmlEntities(data.buyer_name);
                }
                if (data.seller_name) {
                    currentSellerName = decodeHtmlEntities(data.seller_name);
                    // Update the header with the correct seller name
                    document.getElementById('chatSellerName').textContent = currentSellerName;
                }
                if (data.buyer_profile_picture) {
                    currentBuyerProfilePicture = data.buyer_profile_picture;
                    console.log('✅ Buyer profile picture loaded:', currentBuyerProfilePicture);
                } else {
                    console.warn('❌ No buyer profile picture in API response!');
                    console.log('Full API data:', JSON.stringify(data, null, 2));
                }
                if (data.seller_profile_picture) {
                    currentSellerProfilePicture = data.seller_profile_picture;
                    console.log('✅ Seller profile picture loaded:', currentSellerProfilePicture);
                } else {
                    console.warn('❌ No seller profile picture in API response!');
                }
                
                // Update seller avatar in header with profile picture if available
                updateSellerAvatar();
                
                renderMessages(data.messages);
            } else {
                console.error('Failed to load conversation:', data.error);
                showEmptyState();
            }
        })
        .catch(error => {
            console.error('Error loading conversation:', error);
            showEmptyState();
        });
}

// Update seller avatar in header
function updateSellerAvatar() {
    const sellerAvatar = document.getElementById('chatSellerAvatar');
    const sellerInitial = currentSellerName ? currentSellerName.charAt(0).toUpperCase() : 'S';
    
    if (currentSellerProfilePicture) {
        sellerAvatar.innerHTML = `<img src="/static/uploads/${currentSellerProfilePicture}" alt="${currentSellerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
    } else {
        sellerAvatar.innerHTML = sellerInitial;
        sellerAvatar.style.fontSize = '20px';
        sellerAvatar.style.fontWeight = '600';
    }
}

// Render messages in chat
function renderMessages(messages) {
    const messagesArea = document.getElementById('buyerSellerMessages');

    if (!messages || messages.length === 0) {
        showEmptyState();
        return;
    }

    messagesArea.innerHTML = '';

    messages.forEach(message => {
        const messageDiv = document.createElement('div');
        // For buyer-seller chat, buyer messages go right (seller class), seller messages go left (buyer class)
        const messageClass = message.sender_type === 'buyer' ? 'seller' : 'buyer';
        messageDiv.className = `chat-message-item ${messageClass}`;

        // Get avatar based on sender type
        let avatarHtml;
        if (message.sender_type === 'buyer') {
            const buyerInitial = currentBuyerName ? currentBuyerName.charAt(0).toUpperCase() : 'B';
            console.log('👤 Buyer message - Name:', currentBuyerName, 'Picture:', currentBuyerProfilePicture);
            if (currentBuyerProfilePicture) {
                avatarHtml = `<img src="/static/uploads/${currentBuyerProfilePicture}" alt="${currentBuyerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
            } else {
                console.warn('⚠️ No buyer profile picture, using initial:', buyerInitial);
                avatarHtml = buyerInitial;
            }
        } else {
            const sellerInitial = currentSellerName ? currentSellerName.charAt(0).toUpperCase() : 'S';
            console.log('🏪 Seller message - Name:', currentSellerName, 'Picture:', currentSellerProfilePicture);
            if (currentSellerProfilePicture) {
                avatarHtml = `<img src="/static/uploads/${currentSellerProfilePicture}" alt="${currentSellerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
            } else {
                console.warn('⚠️ No seller profile picture, using initial:', sellerInitial);
                avatarHtml = sellerInitial;
            }
        }
        
        const time = formatMessageTime(message.created_at);

        messageDiv.innerHTML = `
            <div class="message-avatar-small">${avatarHtml}</div>
            <div class="message-content-wrapper">
                <div class="message-bubble-chat">${escapeHtml(message.message_text)}</div>
                <div class="message-time-chat">${time}</div>
                ${message.sender_type === 'buyer' ? `
                    <div class="message-status">
                        ${message.is_read ? '<i class="fas fa-check-double"></i> Read' : '<i class="fas fa-check"></i> Sent'}
                    </div>
                ` : ''}
            </div>
        `;

        messagesArea.appendChild(messageDiv);
    });

    // Scroll to bottom
    scrollToBottom();

    // Mark messages as read
    markMessagesAsRead();
}

// Show empty state
function showEmptyState() {
    const messagesArea = document.getElementById('buyerSellerMessages');
    messagesArea.innerHTML = `
        <div class="chat-empty-state">
            <i class="fas fa-comments"></i>
            <h4>Start a Conversation</h4>
            <p>Send a message to the seller to get started!</p>
        </div>
    `;
}

// Send message
function sendBuyerSellerMessage() {
    const input = document.getElementById('buyerSellerMessageInput');
    const message = input.value.trim();

    if (message === '') return;

    // Disable send button
    const sendBtn = document.querySelector('.send-message-btn');
    sendBtn.disabled = true;

    // Prepare data
    const data = {
        seller_email: currentSellerEmail,
        message_text: message,
        product_id: currentProductId
    };

    // Send message
    fetch('/api/messages/send', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Clear input
                input.value = '';
                updateCharCount();

                // Reload messages
                loadConversation(currentSellerEmail, currentProductId);
            } else {
                alert(data.error || 'Failed to send message');
            }
        })
        .catch(error => {
            console.error('Error sending message:', error);
            alert('Failed to send message. Please try again.');
        })
        .finally(() => {
            sendBtn.disabled = false;
        });
}

// Mark messages as read
function markMessagesAsRead() {
    if (!currentConversationId) {
        console.warn('⚠️ No conversation ID, cannot mark as read');
        return;
    }

    console.log('📝 Marking messages as read for conversation:', currentConversationId);

    fetch('/api/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            conversation_id: currentConversationId
        })
    })
        .then(response => {
            console.log('📡 Mark-read response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('📋 Mark-read response:', data);
            if (data.success) {
                console.log(`✅ Marked ${data.affected_rows} messages as read`);
            } else {
                console.error('❌ Failed to mark messages as read:', data.error);
            }
        })
        .catch(error => {
            console.error('❌ Error marking messages as read:', error);
        });
}

// Start polling for new messages
function startMessagePolling() {
    // Poll every 3 seconds
    messagePollingInterval = setInterval(() => {
        if (currentSellerEmail) {
            loadConversation(currentSellerEmail, currentProductId);
        }
    }, 3000);
}

// Stop polling
function stopMessagePolling() {
    if (messagePollingInterval) {
        clearInterval(messagePollingInterval);
        messagePollingInterval = null;
    }
}

// Scroll to bottom of messages
function scrollToBottom() {
    const messagesArea = document.getElementById('buyerSellerMessages');
    setTimeout(() => {
        messagesArea.scrollTop = messagesArea.scrollHeight;
    }, 100);
}

// Format message time
function formatMessageTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;

    // Less than 1 minute
    if (diff < 60000) {
        return 'Just now';
    }

    // Less than 1 hour
    if (diff < 3600000) {
        const minutes = Math.floor(diff / 60000);
        return `${minutes} min${minutes > 1 ? 's' : ''} ago`;
    }

    // Less than 24 hours
    if (diff < 86400000) {
        const hours = Math.floor(diff / 3600000);
        return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    }

    // Same year
    if (date.getFullYear() === now.getFullYear()) {
        return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
    }

    // Different year
    return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Update character count
function updateCharCount() {
    const input = document.getElementById('buyerSellerMessageInput');
    const charCount = document.getElementById('charCount');
    if (input && charCount) {
        charCount.textContent = input.value.length;
    }
}

// Event listeners
document.addEventListener('DOMContentLoaded', function () {
    // Character count
    const messageInput = document.getElementById('buyerSellerMessageInput');
    if (messageInput) {
        messageInput.addEventListener('input', updateCharCount);

        // Auto-resize textarea
        messageInput.addEventListener('input', function () {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 100) + 'px';
        });

        // Send on Enter (Shift+Enter for new line)
        messageInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendBuyerSellerMessage();
            }
        });
    }

    // Close modal when clicking outside
    const modal = document.getElementById('buyerSellerChatModal');
    if (modal) {
        modal.addEventListener('click', function (e) {
            if (e.target === modal) {
                closeBuyerSellerChat();
            }
        });
    }
});

// Clean up on page unload
window.addEventListener('beforeunload', function () {
    stopMessagePolling();
});
