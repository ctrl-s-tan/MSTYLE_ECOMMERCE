// Rider-Seller Chat Modal JavaScript (Rider's perspective)
console.log('🚀 Loading rider-seller chat modal script...');

// Immediate test to ensure script is executing
(function() {
    console.log('📝 Rider-seller chat script executing immediately');
    window.riderSellerChatLoaded = true;
})();

let currentSellerChatConversationId = null;
let currentSellerEmail = null;
let currentRiderEmailForSeller = null;
let currentSellerName = null;
let currentSellerProfilePicture = null;
let currentRiderProfilePictureForSeller = null;
let currentOrderIdForSeller = null;
let currentProductNameForSeller = null;
let sellerMessagePollingInterval = null;

// Open Rider-Seller Chat Modal (called from rider's side)
function openRiderSellerChatModal(sellerEmail, sellerName, orderId, productName) {
    console.log('🚀 Opening rider-seller chat modal:', { sellerEmail, sellerName, orderId, productName });
    
    // Check if modal element exists
    const modal = document.getElementById('riderSellerChatModal');
    if (!modal) {
        console.error('❌ Modal element not found!');
        if (typeof showNotification === 'function') {
            showNotification('Chat modal not found. Please refresh the page.', 'error');
        } else {
            alert('Chat modal not found. Please refresh the page.');
        }
        return;
    }
    
    // Store current seller info
    currentSellerEmail = sellerEmail;
    currentSellerName = sellerName;
    currentOrderIdForSeller = orderId;
    currentProductNameForSeller = productName;
    
    // Get rider email from session (should be available in the page)
    currentRiderEmailForSeller = document.body.dataset.riderEmail || '';
    
    console.log('🔑 Rider email:', currentRiderEmailForSeller);
    
    if (!currentRiderEmailForSeller) {
        console.error('❌ Rider email not found in page data');
        if (typeof showNotification === 'function') {
            showNotification('Authentication error. Please refresh the page.', 'error');
        } else {
            alert('Authentication error. Please refresh the page.');
        }
        return;
    }
    
    // Show modal
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    console.log('✅ Modal opened successfully');
    
    // Update header with seller name
    document.getElementById('chatSellerName').textContent = sellerName || sellerEmail;
    
    // Update header avatar with initial (will be replaced with profile picture when messages load)
    const avatarContainer = document.querySelector('.rider-avatar-chat');
    if (avatarContainer) {
        const sellerInitial = sellerName ? sellerName.charAt(0).toUpperCase() : 'S';
        avatarContainer.innerHTML = sellerInitial;
        avatarContainer.style.fontSize = '24px';
        avatarContainer.style.fontWeight = '600';
    }
    
    // Show order context if provided
    if (orderId && productName) {
        document.getElementById('sellerOrderContextInfo').style.display = 'flex';
        document.getElementById('sellerContextOrderId').textContent = '#' + orderId;
        document.getElementById('sellerContextProductName').textContent = productName;
    } else {
        document.getElementById('sellerOrderContextInfo').style.display = 'none';
    }
    
    // Load or create conversation
    loadRiderSellerConversation(sellerEmail, orderId);
}

// Make the function globally available
window.openRiderSellerChatModal = openRiderSellerChatModal;

// Create a simple fallback function for testing
window.testChatModal = function() {
    console.log('🧪 Test function called');
    const testModal = document.getElementById('riderSellerChatModal');
    if (testModal) {
        testModal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        console.log('✅ Test modal opened');
    } else {
        console.error('❌ Modal not found in test');
    }
};

// Ensure function is available when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('🔧 Rider-Seller Chat Modal script loaded');
    console.log('✅ openRiderSellerChatModal function available:', typeof window.openRiderSellerChatModal === 'function');
    
    // Test the modal element exists
    const domModal = document.getElementById('riderSellerChatModal');
    console.log('🔍 Modal element found:', !!domModal);
    
    // Test rider email is available
    const riderEmail = document.body.dataset.riderEmail;
    console.log('🔑 Rider email available:', !!riderEmail, riderEmail);
    
    // Force register the function if it's not available
    if (typeof window.openRiderSellerChatModal !== 'function') {
        console.log('🔧 Force registering openRiderSellerChatModal function');
        window.openRiderSellerChatModal = openRiderSellerChatModal;
    }
});

// Close Rider-Seller Chat Modal
function closeRiderSellerChatModal() {
    console.log('🔒 Closing rider-seller chat modal');
    
    const closeModal = document.getElementById('riderSellerChatModal');
    if (closeModal) {
        closeModal.style.display = 'none';
        document.body.style.overflow = 'auto';
        console.log('✅ Modal closed successfully');
    } else {
        console.error('❌ Modal element not found when trying to close');
    }
    
    // Clear polling interval
    if (sellerMessagePollingInterval) {
        clearInterval(sellerMessagePollingInterval);
        sellerMessagePollingInterval = null;
        console.log('🔄 Polling interval cleared');
    }
    
    // Reset state
    currentSellerChatConversationId = null;
    currentSellerEmail = null;
    currentRiderEmailForSeller = null;
    console.log('🧹 Chat state reset');
}

// Make the function globally available
window.closeRiderSellerChatModal = closeRiderSellerChatModal;

// Load or Create Conversation
function loadRiderSellerConversation(sellerEmail, orderId) {
    console.log('Loading conversation with seller:', sellerEmail);
    
    const messagesArea = document.getElementById('riderSellerMessagesArea');
    messagesArea.innerHTML = `
        <div class="loading-messages">
            <i class="bi bi-hourglass-split"></i>
            <p>Loading conversation...</p>
        </div>
    `;
    
    // Create conversation ID (format: riderEmail_sellerEmail_orderId)
    // Note: Keep the same format as seller side for consistency
    currentSellerChatConversationId = `${currentRiderEmailForSeller}_${sellerEmail}_${orderId}`;
    
    console.log('Conversation ID:', currentSellerChatConversationId);
    
    // Load messages
    loadRiderSellerMessages();
    
    // Show message input
    document.getElementById('riderSellerMessageInput').style.display = 'flex';
    
    // Start polling for new messages
    if (sellerMessagePollingInterval) {
        clearInterval(sellerMessagePollingInterval);
    }
    sellerMessagePollingInterval = setInterval(loadRiderSellerMessages, 3000);
}

// Load Messages (from rider's perspective)
function loadRiderSellerMessages() {
    if (!currentSellerEmail || !currentOrderIdForSeller) {
        console.error('No seller email or order ID set');
        return;
    }
    
    console.log('🔄 Loading messages with seller:', currentSellerEmail);
    console.log('Order ID:', currentOrderIdForSeller);
    
    // For riders, we pass seller_email and order_id parameters
    let url = `/api/messages/rider-seller-conversation?seller_email=${encodeURIComponent(currentSellerEmail)}&order_id=${encodeURIComponent(currentOrderIdForSeller)}`;
    
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
            
            const messagesArea = document.getElementById('riderSellerMessagesArea');
            
            if (data.success && data.messages && data.messages.length > 0) {
                console.log('✅ Displaying', data.messages.length, 'messages');
                // Store profile pictures if available
                if (data.seller_profile_picture) {
                    currentSellerProfilePicture = data.seller_profile_picture;
                }
                if (data.rider_profile_picture) {
                    currentRiderProfilePictureForSeller = data.rider_profile_picture;
                }
                
                // Update header avatar with seller profile picture
                updateSellerHeaderAvatar();
                
                // Display messages
                messagesArea.innerHTML = '';
                
                data.messages.forEach(msg => {
                    console.log('📨 Message:', msg.message_text, 'Sender type:', msg.sender_type);
                    
                    const messageItem = document.createElement('div');
                    messageItem.className = `chat-message-item ${msg.sender_type}`;
                    
                    // Format message time with proper date handling
                    const messageDate = new Date(msg.created_at);
                    const now = new Date();
                    
                    // Check if message is from today
                    const isToday = messageDate.toDateString() === now.toDateString();
                    
                    // Check if message is from yesterday
                    const yesterday = new Date(now);
                    yesterday.setDate(yesterday.getDate() - 1);
                    const isYesterday = messageDate.toDateString() === yesterday.toDateString();
                    
                    // Format time
                    const timeStr = messageDate.toLocaleTimeString('en-US', { 
                        hour: '2-digit', 
                        minute: '2-digit',
                        hour12: true
                    });
                    
                    let messageTime;
                    if (isToday) {
                        messageTime = timeStr; // Just show time for today's messages
                    } else if (isYesterday) {
                        messageTime = `Yesterday ${timeStr}`;
                    } else {
                        // Show date and time for older messages
                        const dateStr = messageDate.toLocaleDateString('en-US', { 
                            month: 'short', 
                            day: 'numeric',
                            year: messageDate.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
                        });
                        messageTime = `${dateStr} ${timeStr}`;
                    }
                    
                    // Determine sender label
                    const senderLabel = msg.sender_type === 'seller' ? 'Seller' : 'You';
                    
                    // Create avatar HTML
                    let avatarHtml = '';
                    if (msg.sender_type === 'seller') {
                        const sellerInitial = currentSellerName ? currentSellerName.charAt(0).toUpperCase() : 'S';
                        if (currentSellerProfilePicture) {
                            avatarHtml = `<img src="/static/images/uploads/${currentSellerProfilePicture}" alt="${currentSellerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = sellerInitial;
                        }
                    } else {
                        const riderInitial = 'R';
                        if (currentRiderProfilePictureForSeller) {
                            avatarHtml = `<img src="/static/images/uploads/${currentRiderProfilePictureForSeller}" alt="Rider" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = riderInitial;
                        }
                    }
                    
                    messageItem.innerHTML = `
                        <div class="message-avatar-small">${avatarHtml}</div>
                        <div class="message-content-wrapper">
                            <div class="message-bubble-chat">${escapeHtml(msg.message_text)}</div>
                            <span class="message-time-chat">${senderLabel} • ${messageTime}</span>
                        </div>
                    `;
                    
                    messagesArea.appendChild(messageItem);
                });
                
                // Scroll to bottom
                messagesArea.scrollTop = messagesArea.scrollHeight;
                
                // Mark messages as read
                markRiderSellerMessagesAsRead();
                
            } else {
                // No messages yet
                messagesArea.innerHTML = `
                    <div class="chat-placeholder">
                        <i class="bi bi-chat-text"></i>
                        <h3>Start the conversation</h3>
                        <p>Send a message to the seller about the delivery</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            const messagesArea = document.getElementById('riderSellerMessagesArea');
            messagesArea.innerHTML = `
                <div class="chat-placeholder">
                    <i class="bi bi-exclamation-triangle"></i>
                    <h3>Error loading messages</h3>
                    <p>Please try again later</p>
                </div>
            `;
        });
}

// Send Message (from rider's perspective)
function sendRiderSellerMessage() {
    const messageText = document.getElementById('riderSellerMessageText').value.trim();
    
    console.log('📤 Attempting to send message:', messageText);
    
    if (!messageText) {
        if (typeof showNotification === 'function') {
            showNotification('Please enter a message', 'warning');
        } else {
            alert('Please enter a message');
        }
        return;
    }
    
    if (!currentSellerChatConversationId || !currentSellerEmail || !currentOrderIdForSeller) {
        console.error('❌ Missing conversation data:', {
            conversationId: currentSellerChatConversationId,
            sellerEmail: currentSellerEmail,
            orderId: currentOrderIdForSeller
        });
        if (typeof showNotification === 'function') {
            showNotification('Unable to send message. Please try again.', 'error');
        } else {
            alert('Unable to send message. Please try again.');
        }
        return;
    }
    
    // Disable send button
    const sendBtn = document.querySelector('#riderSellerMessageInput .send-message-btn');
    const originalHTML = sendBtn.innerHTML;
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="bi bi-hourglass-split"></i>';
    
    // Prepare message data
    const messageData = {
        seller_email: currentSellerEmail,
        order_id: currentOrderIdForSeller,
        message_text: messageText
    };
    
    console.log('📤 Sending message:', messageData);
    console.log('Current conversation ID:', currentSellerChatConversationId);
    
    fetch('/api/messages/send-rider-seller-message', {
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
            document.getElementById('riderSellerMessageText').value = '';
            
            // Reset character count
            const charCount = document.getElementById('sellerCharCount');
            if (charCount) {
                charCount.textContent = '0';
            }
            
            // Reload messages immediately with a small delay to ensure DB is updated
            setTimeout(() => {
                console.log('🔄 Reloading messages after send...');
                loadRiderSellerMessages();
            }, 500);
            
            showNotification('Message sent successfully', 'success');
        } else {
            console.error('❌ Failed to send message:', data.error);
            showNotification(data.error || 'Failed to send message', 'error');
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        showNotification('Error sending message. Please try again.', 'error');
    })
    .finally(() => {
        // Re-enable send button
        sendBtn.disabled = false;
        sendBtn.innerHTML = originalHTML;
    });
}

// Mark Messages as Read
function markRiderSellerMessagesAsRead() {
    if (!currentSellerChatConversationId) return;
    
    fetch('/api/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            conversation_id: currentSellerChatConversationId
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

// Update Header Avatar with Seller's picture
function updateSellerHeaderAvatar() {
    const avatarContainer = document.querySelector('.rider-avatar-chat');
    if (!avatarContainer) return;
    
    const sellerInitial = currentSellerName ? currentSellerName.charAt(0).toUpperCase() : 'S';
    
    if (currentSellerProfilePicture) {
        avatarContainer.innerHTML = `<img src="/static/images/uploads/${currentSellerProfilePicture}" alt="${currentSellerName}">`;
    } else {
        // Show initial letter instead of icon
        avatarContainer.innerHTML = sellerInitial;
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
    const textarea = document.getElementById('riderSellerMessageText');
    if (textarea) {
        // Handle Enter key
        textarea.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendRiderSellerMessage();
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
    const clickModal = document.getElementById('riderSellerChatModal');
    if (clickModal) {
        clickModal.addEventListener('click', function(e) {
            if (e.target === clickModal) {
                console.log('🖱️ Modal background clicked - closing modal');
                closeRiderSellerChatModal();
            }
        });
        
        // Also add double-click as backup
        clickModal.addEventListener('dblclick', function(e) {
            if (e.target === clickModal) {
                console.log('🖱️ Modal background double-clicked - closing modal');
                closeRiderSellerChatModal();
            }
        });
    }
});

// Close modal with Escape key and other shortcuts
document.addEventListener('keydown', function(e) {
    const keyModal = document.getElementById('riderSellerChatModal');
    if (keyModal && keyModal.style.display === 'flex') {
        // Close with Escape key
        if (e.key === 'Escape') {
            console.log('⌨️ Escape key pressed - closing modal');
            closeRiderSellerChatModal();
        }
        // Close with Ctrl+W or Cmd+W (but prevent default browser behavior)
        else if ((e.ctrlKey || e.metaKey) && e.key === 'w') {
            e.preventDefault();
            console.log('⌨️ Ctrl/Cmd+W pressed - closing modal');
            closeRiderSellerChatModal();
        }
    }
});
