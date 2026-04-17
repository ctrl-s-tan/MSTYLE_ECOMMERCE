// Rider-Buyer Chat Modal JavaScript (Rider's perspective)
console.log('🚀 Loading rider-buyer chat modal script...');

let currentBuyerChatConversationId = null;
let currentBuyerEmail = null;
let currentRiderEmailForBuyer = null;
let currentBuyerName = null;
let currentBuyerProfilePicture = null;
let currentRiderProfilePictureForBuyer = null;
let currentOrderIdForBuyer = null;
let currentProductNameForBuyer = null;
let buyerMessagePollingInterval = null;

// Open Rider-Buyer Chat Modal
function openRiderBuyerChatModal(buyerEmail, buyerName, orderId, productName) {
    console.log('🚀 Opening rider-buyer chat modal:', { buyerEmail, buyerName, orderId, productName });
    
    const modal = document.getElementById('riderBuyerChatModal');
    if (!modal) {
        console.error('❌ Modal element not found!');
        if (typeof showNotification === 'function') {
            showNotification('Chat modal not found. Please refresh the page.', 'error');
        } else {
            alert('Chat modal not found. Please refresh the page.');
        }
        return;
    }
    
    currentBuyerEmail = buyerEmail;
    currentBuyerName = buyerName;
    currentOrderIdForBuyer = orderId;
    currentProductNameForBuyer = productName;
    
    currentRiderEmailForBuyer = document.body.dataset.riderEmail || '';
    
    if (!currentRiderEmailForBuyer) {
        console.error('❌ Rider email not found in page data');
        if (typeof showNotification === 'function') {
            showNotification('Authentication error. Please refresh the page.', 'error');
        } else {
            alert('Authentication error. Please refresh the page.');
        }
        return;
    }
    
    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
    
    document.getElementById('chatBuyerName').textContent = buyerName || buyerEmail;
    
    const avatarContainer = document.querySelector('.rider-buyer-chat-modal .rider-avatar-chat');
    if (avatarContainer) {
        const buyerInitial = buyerName ? buyerName.charAt(0).toUpperCase() : 'B';
        avatarContainer.innerHTML = buyerInitial;
        avatarContainer.style.fontSize = '24px';
        avatarContainer.style.fontWeight = '600';
    }
    
    if (orderId && productName) {
        document.getElementById('buyerOrderContextInfo').style.display = 'flex';
        document.getElementById('buyerContextOrderId').textContent = '#' + orderId;
        document.getElementById('buyerContextProductName').textContent = productName;
    } else {
        document.getElementById('buyerOrderContextInfo').style.display = 'none';
    }
    
    loadRiderBuyerConversation(buyerEmail, orderId);
}

window.openRiderBuyerChatModal = openRiderBuyerChatModal;

// Close Rider-Buyer Chat Modal
function closeRiderBuyerChatModal() {
    console.log('🔒 Closing rider-buyer chat modal');
    
    const modal = document.getElementById('riderBuyerChatModal');
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }
    
    if (buyerMessagePollingInterval) {
        clearInterval(buyerMessagePollingInterval);
        buyerMessagePollingInterval = null;
    }
    
    currentBuyerChatConversationId = null;
    currentBuyerEmail = null;
    currentRiderEmailForBuyer = null;
}

window.closeRiderBuyerChatModal = closeRiderBuyerChatModal;

// Load or Create Conversation
function loadRiderBuyerConversation(buyerEmail, orderId) {
    console.log('Loading conversation with buyer:', buyerEmail);
    
    const messagesArea = document.getElementById('riderBuyerMessagesArea');
    messagesArea.innerHTML = `
        <div class="loading-messages">
            <i class="bi bi-hourglass-split"></i>
            <p>Loading conversation...</p>
        </div>
    `;
    
    currentBuyerChatConversationId = `${currentRiderEmailForBuyer}_${buyerEmail}_${orderId}`;
    
    loadRiderBuyerMessages();
    
    document.getElementById('riderBuyerMessageInput').style.display = 'flex';
    
    if (buyerMessagePollingInterval) {
        clearInterval(buyerMessagePollingInterval);
    }
    buyerMessagePollingInterval = setInterval(loadRiderBuyerMessages, 3000);
}

// Load Messages
function loadRiderBuyerMessages() {
    if (!currentBuyerEmail || !currentOrderIdForBuyer) {
        console.error('No buyer email or order ID set');
        return;
    }
    
    let url = `/api/rider/buyer-messages?order_id=${encodeURIComponent(currentOrderIdForBuyer)}`;
    
    fetch(url)
        .then(response => response.json())
        .then(data => {
            const messagesArea = document.getElementById('riderBuyerMessagesArea');
            
            if (data.success && data.messages && data.messages.length > 0) {
                if (data.buyer_profile_picture) {
                    currentBuyerProfilePicture = data.buyer_profile_picture;
                }
                if (data.rider_profile_picture) {
                    currentRiderProfilePictureForBuyer = data.rider_profile_picture;
                }
                
                updateBuyerHeaderAvatar();
                
                messagesArea.innerHTML = '';
                
                data.messages.forEach(msg => {
                    const messageItem = document.createElement('div');
                    messageItem.className = `chat-message-item ${msg.sender_email === currentRiderEmailForBuyer ? 'rider' : 'buyer'}`;
                    
                    const messageTime = new Date(msg.created_at).toLocaleString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    });
                    
                    const senderLabel = msg.sender_email === currentRiderEmailForBuyer ? 'You' : 'Buyer';
                    
                    let avatarHtml = '';
                    if (msg.sender_email === currentBuyerEmail) {
                        const buyerInitial = currentBuyerName ? currentBuyerName.charAt(0).toUpperCase() : 'B';
                        if (currentBuyerProfilePicture) {
                            avatarHtml = `<img src="/static/images/uploads/${currentBuyerProfilePicture}" alt="${currentBuyerName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = buyerInitial;
                        }
                    } else {
                        const riderInitial = 'R';
                        if (currentRiderProfilePictureForBuyer) {
                            avatarHtml = `<img src="/static/images/uploads/${currentRiderProfilePictureForBuyer}" alt="Rider" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">`;
                        } else {
                            avatarHtml = riderInitial;
                        }
                    }
                    
                    messageItem.innerHTML = `
                        <div class="message-avatar-small">${avatarHtml}</div>
                        <div class="message-content-wrapper">
                            <div class="message-bubble-chat">${escapeHtml(msg.message)}</div>
                            <span class="message-time-chat">${senderLabel} • ${messageTime}</span>
                        </div>
                    `;
                    
                    messagesArea.appendChild(messageItem);
                });
                
                messagesArea.scrollTop = messagesArea.scrollHeight;
                markRiderBuyerMessagesAsRead();
                
            } else {
                messagesArea.innerHTML = `
                    <div class="chat-placeholder">
                        <i class="bi bi-chat-text"></i>
                        <h3>Start the conversation</h3>
                        <p>Send a message to the buyer about the delivery</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            const messagesArea = document.getElementById('riderBuyerMessagesArea');
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
function sendRiderBuyerMessage() {
    const messageText = document.getElementById('riderBuyerMessageText').value.trim();
    
    if (!messageText) {
        if (typeof showNotification === 'function') {
            showNotification('Please enter a message', 'warning');
        } else {
            alert('Please enter a message');
        }
        return;
    }
    
    if (!currentBuyerChatConversationId || !currentOrderIdForBuyer) {
        if (typeof showNotification === 'function') {
            showNotification('Unable to send message. Please try again.', 'error');
        } else {
            alert('Unable to send message. Please try again.');
        }
        return;
    }
    
    const sendBtn = document.querySelector('#riderBuyerMessageInput .send-message-btn');
    const originalHTML = sendBtn.innerHTML;
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="bi bi-hourglass-split"></i>';
    
    const messageData = {
        order_id: currentOrderIdForBuyer,
        message: messageText,
        receiver_email: currentBuyerEmail
    };
    
    fetch('/api/rider/buyer-messages/send', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(messageData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            document.getElementById('riderBuyerMessageText').value = '';
            
            const charCount = document.getElementById('buyerCharCount');
            if (charCount) {
                charCount.textContent = '0';
            }
            
            setTimeout(() => {
                loadRiderBuyerMessages();
            }, 500);
            
            if (typeof showNotification === 'function') {
                showNotification('Message sent successfully', 'success');
            }
        } else {
            if (typeof showNotification === 'function') {
                showNotification(data.error || 'Failed to send message', 'error');
            } else {
                alert(data.error || 'Failed to send message');
            }
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        if (typeof showNotification === 'function') {
            showNotification('Error sending message. Please try again.', 'error');
        } else {
            alert('Error sending message. Please try again.');
        }
    })
    .finally(() => {
        sendBtn.disabled = false;
        sendBtn.innerHTML = originalHTML;
    });
}

// Mark Messages as Read
function markRiderBuyerMessagesAsRead() {
    if (!currentOrderIdForBuyer) return;
    
    fetch('/api/rider/buyer-messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            order_id: currentOrderIdForBuyer
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
function updateBuyerHeaderAvatar() {
    const avatarContainer = document.querySelector('.rider-buyer-chat-modal .rider-avatar-chat');
    if (!avatarContainer) return;
    
    const buyerInitial = currentBuyerName ? currentBuyerName.charAt(0).toUpperCase() : 'B';
    
    if (currentBuyerProfilePicture) {
        avatarContainer.innerHTML = `<img src="/static/images/uploads/${currentBuyerProfilePicture}" alt="${currentBuyerName}">`;
    } else {
        avatarContainer.innerHTML = buyerInitial;
        avatarContainer.style.fontSize = '24px';
        avatarContainer.style.fontWeight = '600';
    }
}

// Escape HTML
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Event Listeners
document.addEventListener('DOMContentLoaded', function() {
    const textarea = document.getElementById('riderBuyerMessageText');
    if (textarea) {
        textarea.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendRiderBuyerMessage();
            }
        });
        
        textarea.addEventListener('input', function() {
            const charCount = document.getElementById('buyerCharCount');
            if (charCount) {
                charCount.textContent = this.value.length;
            }
        });
    }
    
    const modal = document.getElementById('riderBuyerChatModal');
    if (modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeRiderBuyerChatModal();
            }
        });
    }
});

document.addEventListener('keydown', function(e) {
    const modal = document.getElementById('riderBuyerChatModal');
    if (modal && modal.style.display === 'flex') {
        if (e.key === 'Escape') {
            closeRiderBuyerChatModal();
        }
    }
});
