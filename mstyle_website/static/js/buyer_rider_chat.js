// Buyer-Rider Chat Functionality - Matching Buyer-Seller Chat Style

let currentOrderId = null;
let currentRiderId = null;
let chatRefreshInterval = null;
let currentRiderName = null;
let currentRiderProfilePic = null;
let isLoadingMessages = false;

// Open rider chat modal
function openRiderChat(orderId, riderId) {
    console.log('=== openRiderChat called ===');
    console.log('Order ID:', orderId);
    console.log('Rider ID:', riderId);
    
    if (!riderId || riderId === 'None' || riderId === '') {
        console.error('No rider ID provided');
        alert('No rider has been assigned to this order yet.');
        return;
    }
    
    currentOrderId = orderId;
    currentRiderId = riderId;
    
    // Check if modal exists
    const modal = document.getElementById('buyerRiderChatModal');
    if (!modal) {
        console.error('Modal element not found!');
        alert('Chat modal not found. Please refresh the page.');
        return;
    }
    
    console.log('Modal found:', modal);
    
    // Set hidden form fields
    const orderIdInput = document.getElementById('riderOrderId');
    const riderIdInput = document.getElementById('riderIdInput');
    
    if (orderIdInput) orderIdInput.value = orderId;
    if (riderIdInput) riderIdInput.value = riderId;
    
    // Show modal
    console.log('Showing modal...');
    modal.style.display = 'flex';
    setTimeout(() => {
        modal.classList.add('show');
        console.log('Modal should be visible now');
    }, 10);
    
    // Load chat messages
    loadRiderChatMessages(orderId, riderId);
    
    // Start auto-refresh
    startChatRefresh();
    
    // Focus on input
    setTimeout(() => {
        const messageInput = document.getElementById('riderMessageInput');
        if (messageInput) {
            messageInput.focus();
        }
    }, 300);
}

// Make function globally accessible
window.openRiderChat = openRiderChat;

// Close rider chat modal
function closeRiderChat() {
    console.log('Closing rider chat modal');
    const modal = document.getElementById('buyerRiderChatModal');
    if (!modal) {
        console.error('Modal not found when trying to close');
        return;
    }
    
    modal.classList.remove('show');
    
    setTimeout(() => {
        modal.style.display = 'none';
        
        // Clear chat
        const messagesContainer = document.getElementById('riderChatMessages');
        const messageInput = document.getElementById('riderMessageInput');
        
        if (messagesContainer) messagesContainer.innerHTML = '';
        if (messageInput) messageInput.value = '';
        
        // Stop auto-refresh
        stopChatRefresh();
        
        currentOrderId = null;
        currentRiderId = null;
        currentRiderName = null;
        currentRiderProfilePic = null;
    }, 300);
}

// Make function globally accessible
window.closeRiderChat = closeRiderChat;

// Load chat messages
function loadRiderChatMessages(orderId, riderId) {
    // Prevent multiple simultaneous loads
    if (isLoadingMessages) {
        console.log('Already loading messages, skipping...');
        return;
    }
    
    isLoadingMessages = true;
    console.log('Loading messages for order:', orderId, 'rider:', riderId);
    
    const messagesContainer = document.getElementById('riderChatMessages');
    
    // Only show loading state if container is empty
    if (!messagesContainer.children.length || messagesContainer.querySelector('.no-messages')) {
        messagesContainer.innerHTML = `
            <div class="chat-loading">
                <i class="bi bi-hourglass-split"></i>
                <p>Loading messages...</p>
            </div>
        `;
    }
    
    // Fetch messages from API
    fetch(`/api/buyer/rider-messages?order_id=${orderId}&rider_id=${riderId}`)
        .then(response => response.json())
        .then(data => {
            console.log('=== Messages API Response ===');
            console.log('Full data:', data);
            console.log('Rider name:', data.rider_name);
            console.log('Rider profile picture:', data.rider_profile_picture);
            console.log('Messages count:', data.messages ? data.messages.length : 0);
            
            if (data.success) {
                // Update rider info in header
                updateRiderHeader(data.rider_name, data.rider_profile_picture);
                
                if (data.messages && data.messages.length > 0) {
                    displayRiderMessages(data.messages, data.rider_profile_picture);
                } else {
                    // No messages yet
                    messagesContainer.innerHTML = `
                        <div class="no-messages">
                            <i class="bi bi-chat-dots"></i>
                            <p>No messages yet. Start a conversation with your rider!</p>
                        </div>
                    `;
                }
            } else {
                messagesContainer.innerHTML = `
                    <div class="no-messages">
                        <i class="bi bi-exclamation-triangle"></i>
                        <p>Error loading messages. Please try again.</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            messagesContainer.innerHTML = `
                <div class="no-messages">
                    <i class="bi bi-exclamation-triangle"></i>
                    <p>Error loading messages. Please try again.</p>
                </div>
            `;
        })
        .finally(() => {
            isLoadingMessages = false;
        });
}

// Update rider header with name and profile picture
function updateRiderHeader(riderName, riderProfilePic) {
    currentRiderName = riderName;
    currentRiderProfilePic = riderProfilePic;
    
    console.log('Updating rider header:', { riderName, riderProfilePic });
    
    // Update rider name
    const nameElement = document.getElementById('chatRiderName');
    if (nameElement) {
        nameElement.textContent = riderName || 'Rider';
    }
    
    // Update profile picture
    const profilePicImg = document.getElementById('chatRiderProfilePic');
    const avatarIcon = document.getElementById('chatRiderAvatarIcon');
    
    console.log('Profile pic element:', profilePicImg);
    console.log('Avatar icon element:', avatarIcon);
    
    if (riderProfilePic && riderProfilePic !== 'None' && riderProfilePic !== '' && riderProfilePic !== null) {
        // Show profile picture
        console.log('Showing profile picture:', riderProfilePic);
        if (profilePicImg) {
            profilePicImg.src = `/static/images/uploads/${riderProfilePic}`;
            profilePicImg.style.display = 'block';
            profilePicImg.onerror = function() {
                console.error('Failed to load profile picture, showing icon instead');
                this.style.display = 'none';
                if (avatarIcon) {
                    avatarIcon.style.display = 'flex';
                }
            };
        }
        if (avatarIcon) {
            avatarIcon.style.display = 'none';
        }
    } else {
        // Show icon
        console.log('Showing icon (no profile picture)');
        if (profilePicImg) {
            profilePicImg.style.display = 'none';
        }
        if (avatarIcon) {
            avatarIcon.style.display = 'flex';
        }
    }
}

// Display messages in chat
function displayRiderMessages(messages, riderProfilePic) {
    const messagesContainer = document.getElementById('riderChatMessages');
    const buyerEmail = document.body.getAttribute('data-buyer-email') || '';
    
    // Clear container
    messagesContainer.innerHTML = `
        <div class="chat-date-divider">
            <span>Today</span>
        </div>
    `;
    
    // Add messages
    messages.forEach(message => {
        const isSent = message.sender_email === buyerEmail;
        const messageEl = createMessageElement(message, isSent, riderProfilePic);
        messagesContainer.appendChild(messageEl);
    });
    
    // Scroll to bottom
    scrollToBottom();
}

// Create message element
function createMessageElement(message, isSent, riderProfilePic) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `rider-chat-message-item ${isSent ? 'buyer' : 'rider'}`;
    
    const time = formatMessageTime(message.created_at);
    
    // Create avatar HTML for rider messages (left side)
    let avatarHTML = '';
    if (!isSent) {
        // Rider message - show avatar on left
        if (riderProfilePic && riderProfilePic !== 'None' && riderProfilePic !== '' && riderProfilePic !== null) {
            avatarHTML = `
                <div class="rider-message-avatar-small">
                    <img src="/static/images/uploads/${riderProfilePic}" alt="Rider" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                    <div class="avatar-icon" style="display: none;">
                        <i class="bi bi-bicycle"></i>
                    </div>
                </div>
            `;
        } else {
            avatarHTML = `
                <div class="rider-message-avatar-small">
                    <div class="avatar-icon">
                        <i class="bi bi-bicycle"></i>
                    </div>
                </div>
            `;
        }
    }
    
    messageDiv.innerHTML = `
        ${avatarHTML}
        <div class="rider-message-content-wrapper">
            <div class="rider-message-bubble-chat">
                ${escapeHtml(message.message)}
            </div>
            <div class="rider-message-time-chat">${time}</div>
        </div>
    `;
    
    return messageDiv;
}

// Send message to rider
function sendRiderMessage(event) {
    event.preventDefault();
    console.log('Sending rider message...');
    
    const form = event.target;
    const messageInput = document.getElementById('riderMessageInput');
    const message = messageInput.value.trim();
    
    if (!message) {
        console.log('Empty message, not sending');
        return;
    }
    
    const submitBtn = form.querySelector('.send-rider-message-btn');
    if (submitBtn) submitBtn.disabled = true;
    
    // Prepare form data
    const formData = new FormData(form);
    
    // Convert FormData to JSON
    const messageData = {
        order_id: parseInt(formData.get('order_id')),
        message: formData.get('message')
    };
    
    console.log('Sending to API:', messageData);
    
    // Send message via API
    fetch('/api/buyer/send-rider-message', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(messageData)
    })
    .then(response => response.json())
    .then(data => {
        console.log('Message sent response:', data);
        
        if (data.success) {
            // Clear input
            messageInput.value = '';
            messageInput.style.height = 'auto';
            
            // Update char count
            const charCountSpan = document.getElementById('charCount');
            if (charCountSpan) charCountSpan.textContent = '0';
            
            // Reload messages
            loadRiderChatMessages(currentOrderId, currentRiderId);
        } else {
            alert('Failed to send message: ' + (data.error || 'Unknown error'));
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        alert('Error sending message. Please try again.');
    })
    .finally(() => {
        if (submitBtn) submitBtn.disabled = false;
        messageInput.focus();
    });
}

// Make function globally accessible
window.sendRiderMessage = sendRiderMessage;

// Auto-refresh chat messages
function startChatRefresh() {
    // Stop any existing interval first
    stopChatRefresh();
    
    // Refresh every 10 seconds (reduced from 5 to prevent loading loop)
    chatRefreshInterval = setInterval(() => {
        if (currentOrderId && currentRiderId && !isLoadingMessages) {
            loadRiderChatMessages(currentOrderId, currentRiderId);
        }
    }, 10000);
}

function stopChatRefresh() {
    if (chatRefreshInterval) {
        clearInterval(chatRefreshInterval);
        chatRefreshInterval = null;
    }
}

// Helper functions
function scrollToBottom() {
    const messagesContainer = document.getElementById('riderChatMessages');
    if (messagesContainer) {
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
}

function formatMessageTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diffInMinutes = Math.floor((now - date) / (1000 * 60));
    
    if (diffInMinutes < 1) return 'Just now';
    if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
    if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)}h ago`;
    
    // Format as time if today
    const hours = date.getHours();
    const minutes = date.getMinutes();
    const ampm = hours >= 12 ? 'PM' : 'AM';
    const displayHours = hours % 12 || 12;
    const displayMinutes = minutes < 10 ? '0' + minutes : minutes;
    
    return `${displayHours}:${displayMinutes} ${ampm}`;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Auto-resize textarea and handle events
document.addEventListener('DOMContentLoaded', function() {
    const textarea = document.getElementById('riderMessageInput');
    const charCountSpan = document.getElementById('charCount');
    
    if (textarea) {
        // Auto-resize
        textarea.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 100) + 'px';
            
            // Update character count
            if (charCountSpan) {
                charCountSpan.textContent = this.value.length;
            }
        });
        
        // Handle Enter key (send message)
        textarea.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                const form = document.getElementById('riderChatForm');
                if (form) {
                    form.dispatchEvent(new Event('submit'));
                }
            }
        });
    }
    
    // Close modal when clicking outside
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('buyerRiderChatModal');
        if (event.target === modal) {
            closeRiderChat();
        }
    });
    
    // Close modal with Escape key
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            const modal = document.getElementById('buyerRiderChatModal');
            if (modal && modal.classList.contains('show')) {
                closeRiderChat();
            }
        }
    });
});
