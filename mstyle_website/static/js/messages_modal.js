// Messages Modal JavaScript Functionality
let currentModalConversationId = null;
let currentModalConversation = null; // Store the full conversation object
let userType = null; // 'buyer' or 'seller'

// Detect user type based on which API endpoint works
function detectUserType() {
    // Check if we're on a rider page
    if (window.location.pathname.includes('rider') || window.location.pathname.includes('deliveries') || window.location.pathname.includes('earnings')) {
        return 'rider';
    }
    // Check if we're on a seller page or buyer page
    if (window.location.pathname.includes('seller') || window.location.pathname.includes('products') || window.location.pathname.includes('orders_list')) {
        return 'seller';
    }
    return 'buyer';
}

function openMessagesModal(event, conversationOrId = null) {
    if (event) event.preventDefault();
    
    document.getElementById('messagesModal').style.display = 'flex';
    
    // Close dropdowns
    const messagesDropdown = document.getElementById('messagesDropdown');
    if (messagesDropdown) {
        messagesDropdown.classList.remove('active');
    }
    
    // Detect user type
    userType = detectUserType();
    console.log('🔍 Detected user type:', userType);
    
    // Handle conversation parameter - can be conversation object or conversation ID
    let conversationId = null;
    let conversationObj = null;
    
    if (conversationOrId) {
        if (typeof conversationOrId === 'object') {
            conversationObj = conversationOrId;
            conversationId = conversationOrId.conversation_id;
            console.log('📦 Received conversation object:', conversationObj);
        } else {
            conversationId = conversationOrId;
            console.log('🔑 Received conversation ID:', conversationId);
        }
    }
    
    // Load conversations
    loadAllConversations(conversationId);
    
    // If conversation object was passed, open it after a delay
    if (conversationObj) {
        setTimeout(() => {
            // Find the conversation item in the list and click it
            const convItem = document.querySelector(`[data-conversation-id="${conversationId}"]`);
            if (convItem) {
                console.log('✅ Found conversation item, clicking it');
                convItem.click();
            } else {
                console.log('⚠️ Conversation item not found, loading directly');
                loadModalConversation(conversationObj);
            }
        }, 500);
    }
}

function closeMessagesModal() {
    document.getElementById('messagesModal').style.display = 'none';
    currentModalConversationId = null;
}

function loadAllConversations(selectConversationId = null) {
    console.log('📋 Loading all conversations for:', userType);
    
    // Use appropriate API endpoint based on user type
    let apiEndpoint;
    if (userType === 'seller') {
        apiEndpoint = '/api/seller/messages';
    } else if (userType === 'rider') {
        apiEndpoint = '/api/rider/messages';
    } else {
        apiEndpoint = '/api/buyer/messages';
    }
    
    fetch(apiEndpoint)
        .then(response => {
            console.log('Response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('API Response:', data);
            const conversationsList = document.getElementById('conversationsListModal');
            
            if (data.success && data.conversations && data.conversations.length > 0) {
                console.log(`Found ${data.conversations.length} conversations`);
                console.log('📋 All conversations:', JSON.stringify(data.conversations, null, 2));
                conversationsList.innerHTML = '';
                
                data.conversations.forEach((conv, index) => {
                    console.log(`📋 Conversation ${index + 1}:`, conv);
                    console.log(`📋 Type: ${conv.conversation_type}, Has rider_email: ${!!conv.rider_email}, Has order_id: ${!!conv.order_id}`);
                    const item = document.createElement('div');
                    item.className = `conversation-item-modal ${conv.unread_count > 0 ? 'unread' : ''}`;
                    item.setAttribute('data-conversation-id', conv.conversation_id);
                    
                    // Add click handler with proper event
                    item.addEventListener('click', function() {
                        loadModalConversation(conv, this);
                    });
                    
                    const formattedTime = formatTimeHelper(conv.last_message_at);
                    
                    // Determine other party info based on user type and conversation type
                    let otherPartyName, otherPartyPicture, otherPartyIcon, conversationTypeLabel;
                    if (userType === 'seller') {
                        // Seller can have conversations with both buyers and riders
                        if (conv.conversation_type === 'rider') {
                            otherPartyName = conv.rider_name || 'Rider';
                            otherPartyPicture = conv.rider_profile_picture;
                            otherPartyIcon = 'bi-truck';
                            conversationTypeLabel = '<small style="color: #999;">(Rider)</small>';
                        } else {
                            otherPartyName = conv.buyer_name || 'Buyer';
                            otherPartyPicture = conv.buyer_profile_picture;
                            otherPartyIcon = 'bi-person-circle';
                            conversationTypeLabel = '<small style="color: #999;">(Buyer)</small>';
                        }
                    } else if (userType === 'rider') {
                        // Rider can have conversations with both buyers and sellers
                        if (conv.conversation_type === 'seller') {
                            otherPartyName = conv.contact_name || conv.seller_name || 'Seller';
                            otherPartyPicture = conv.contact_profile_picture || conv.seller_profile_picture;
                            otherPartyIcon = 'bi-shop';
                            conversationTypeLabel = '<small style="color: #999;">(Seller)</small>';
                            // Map contact_email to seller_email for later use
                            conv.seller_email = conv.contact_email;
                        } else {
                            otherPartyName = conv.contact_name || conv.buyer_name || 'Buyer';
                            otherPartyPicture = conv.contact_profile_picture || conv.buyer_profile_picture;
                            otherPartyIcon = 'bi-person-circle';
                            conversationTypeLabel = '<small style="color: #999;">(Buyer)</small>';
                            // Map contact_email to buyer_email for later use
                            conv.buyer_email = conv.contact_email;
                        }
                    } else {
                        // Buyer - check if it's a rider or seller conversation
                        if (conv.conversation_type === 'rider' || conv.rider_name) {
                            otherPartyName = conv.rider_name || 'Rider';
                            otherPartyPicture = conv.rider_profile_picture;
                            otherPartyIcon = 'bi-truck';
                            conversationTypeLabel = '<small style="color: #999;">(Rider)</small>';
                        } else {
                            otherPartyName = conv.seller_name || 'Seller';
                            otherPartyPicture = conv.seller_profile_picture;
                            otherPartyIcon = 'bi-shop';
                            conversationTypeLabel = '<small style="color: #999;">(Seller)</small>';
                        }
                    }
                    const otherPartyInitial = otherPartyName.charAt(0).toUpperCase();
                    
                    item.innerHTML = `
                        <div class="message-avatar">
                            ${otherPartyPicture 
                                ? `<img src="/static/uploads/${otherPartyPicture}" alt="${otherPartyName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">` 
                                : `<i class="${otherPartyIcon}" style="font-size: 24px;"></i>`
                            }
                        </div>
                        <div class="message-content">
                            <div class="message-header">
                                <span class="buyer-name">${otherPartyName} ${conversationTypeLabel}</span>
                                <span class="message-time">${formattedTime}</span>
                            </div>
                            <div class="product-context">${
                                userType === 'rider' ? (conv.order_id ? `Order #${conv.order_id}` : 'Delivery') :
                                userType === 'seller' && conv.conversation_type === 'rider' ? (conv.order_id ? `Order #${conv.order_id}` : 'Delivery') :
                                userType === 'seller' && conv.order_id ? `Order #${conv.order_id}` :
                                userType === 'buyer' && conv.order_id ? `Order #${conv.order_id}` :
                                (conv.product_name || 'General Inquiry')
                            }</div>
                            <div class="message-preview">${conv.last_message || 'No messages yet'}</div>
                        </div>
                        ${conv.unread_count > 0 ? `<div class="unread-badge">${conv.unread_count}</div>` : ''}
                    `;
                    
                    conversationsList.appendChild(item);
                    
                    // Auto-select conversation if specified
                    if (selectConversationId && conv.conversation_id === selectConversationId) {
                        setTimeout(() => item.click(), 100);
                    }
                });
            } else {
                console.log('No conversations found or API error');
                if (!data.success) {
                    console.error('API Error:', data.error);
                }
                conversationsList.innerHTML = `
                    <div class="no-messages">
                        <i class="bi bi-chat-slash"></i>
                        <p>No conversations yet</p>
                        ${!data.success ? `<p style="color: red; font-size: 12px;">${data.error}</p>` : ''}
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('Error loading conversations:', error);
            const conversationsList = document.getElementById('conversationsListModal');
            conversationsList.innerHTML = `
                <div class="no-messages">
                    <i class="bi bi-exclamation-triangle"></i>
                    <p>Error loading conversations</p>
                    <p style="color: red; font-size: 12px;">${error.message}</p>
                </div>
            `;
        });
}

// Helper function for formatting time
function formatTimeHelper(timestamp) {
    // Use user's local timezone from their device
    const date = new Date(timestamp);
    const now = new Date();
    const diffInMinutes = Math.floor((now - date) / (1000 * 60));

    if (diffInMinutes < 1) return 'Just now';
    if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
    if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)}h ago`;
    return `${Math.floor(diffInMinutes / 1440)}d ago`;
}

function loadModalConversation(conversation, clickedElement) {
    console.log('📖 ========== LOADING CONVERSATION ==========');
    console.log('📖 Conversation:', JSON.stringify(conversation, null, 2));
    console.log('📖 Conversation type:', conversation.conversation_type);
    console.log('📖 Has rider_email:', !!conversation.rider_email);
    console.log('📖 Has order_id:', !!conversation.order_id);
    console.log('📖 Has buyer_email:', !!conversation.buyer_email);
    console.log('📖 ===========================================');
    
    currentModalConversationId = conversation.conversation_id;
    currentModalConversation = conversation; // Store the full conversation object
    
    // Update active state
    document.querySelectorAll('.conversation-item-modal').forEach(item => {
        item.classList.remove('active');
    });
    
    if (clickedElement) {
        clickedElement.classList.add('active');
        
        // Remove unread badge and styling immediately for better UX
        clickedElement.classList.remove('unread');
        const unreadBadge = clickedElement.querySelector('.unread-badge');
        if (unreadBadge) {
            unreadBadge.remove();
        }
    }
    
    // Mark messages as read
    if (conversation.unread_count > 0) {
        console.log('🔔 Unread count:', conversation.unread_count, 'User type:', userType);
        console.log('📦 Conversation type:', conversation.conversation_type);
        console.log('📦 Order ID:', conversation.order_id);
        
        if (userType === 'seller') {
            // Check if it's a seller-rider or seller-buyer conversation
            if (conversation.conversation_type === 'rider') {
                console.log('✅ Detected seller-rider conversation, marking as read...');
                markSellerRiderConversationAsRead(conversation.order_id);
            } else {
                console.log('✅ Detected seller-buyer conversation, marking as read...');
                // For order-based conversations, use conversation_id
                if (conversation.conversation_id) {
                    markConversationAsReadByConversationId(conversation.conversation_id);
                } else {
                    markConversationAsRead(conversation.buyer_email, conversation.product_id);
                }
            }
        } else if (userType === 'rider') {
            markRiderConversationAsRead(conversation.order_id);
        } else {
            // Buyer - check if it's a rider or seller conversation
            if (conversation.conversation_type === 'rider') {
                markBuyerRiderConversationAsRead(conversation.order_id);
            } else {
                // For order-based conversations, use conversation_id
                if (conversation.conversation_id) {
                    markConversationAsReadByConversationId(conversation.conversation_id);
                } else {
                    markConversationAsRead(conversation.seller_email, conversation.product_id);
                }
            }
        }
    } else {
        console.log('ℹ️ No unread messages, skipping mark-as-read');
    }
    
    // Show loading state
    const chatArea = document.getElementById('chatAreaModal');
    chatArea.innerHTML = `
        <div class="chat-placeholder-modal">
            <i class="bi bi-hourglass-split" style="animation: spin 2s linear infinite;"></i>
            <h3>Loading conversation...</h3>
        </div>
    `;
    
    // Load messages - use appropriate parameter based on user type and conversation type
    let fetchUrl;
    if (userType === 'seller') {
        // Seller can have conversations with both buyers and riders
        if (conversation.conversation_type === 'rider') {
            console.log('🔍 Fetching seller-rider messages for order:', conversation.order_id);
            console.log('🔍 Conversation data:', conversation);
            
            const riderEmail = conversation.rider_email;
            const orderId = conversation.order_id;
            
            if (!riderEmail || !orderId) {
                console.error('❌ Missing required data for seller-rider conversation:', {
                    riderEmail,
                    orderId,
                    conversation
                });
                chatArea.innerHTML = `
                    <div class="chat-placeholder-modal">
                        <i class="bi bi-exclamation-triangle" style="color: #dc3545;"></i>
                        <h3>Error loading conversation</h3>
                        <p style="color: #dc3545;">Missing rider or order information. Please try again.</p>
                    </div>
                `;
                return;
            }
            
            fetchUrl = `/api/messages/seller-rider-conversation?order_id=${orderId}&rider_email=${encodeURIComponent(riderEmail)}`;
            console.log('🔍 Fetch URL:', fetchUrl);
        } else {
            // Seller-Buyer conversation (including order-based conversations)
            console.log('🔍 Fetching messages for buyer:', conversation.buyer_email);
            console.log('🔍 Conversation ID:', conversation.conversation_id);
            console.log('🔍 Order ID:', conversation.order_id);
            
            if (!conversation.buyer_email) {
                console.error('❌ Missing buyer_email for seller-buyer conversation');
                chatArea.innerHTML = `
                    <div class="chat-placeholder-modal">
                        <i class="bi bi-exclamation-triangle" style="color: #dc3545;"></i>
                        <h3>Error loading conversation</h3>
                        <p style="color: #dc3545;">Missing buyer information. Please try again.</p>
                    </div>
                `;
                return;
            }
            
            // Use conversation_id if available (for order-based conversations)
            if (conversation.conversation_id) {
                fetchUrl = `/api/messages/conversation?conversation_id=${encodeURIComponent(conversation.conversation_id)}`;
            } else {
                fetchUrl = `/api/messages/conversation?buyer_email=${encodeURIComponent(conversation.buyer_email)}&product_id=${conversation.product_id || ''}`;
            }
        }
    } else if (userType === 'rider') {
        // Rider can have conversations with both buyers and sellers
        if (conversation.conversation_type === 'seller') {
            console.log('🔍 Fetching rider-seller messages for order:', conversation.order_id);
            const sellerEmail = conversation.contact_email || conversation.seller_email;
            if (!sellerEmail) {
                console.error('❌ Missing seller_email for seller-rider conversation');
            }
            fetchUrl = `/api/messages/rider-seller-conversation?order_id=${conversation.order_id}&seller_email=${encodeURIComponent(sellerEmail)}`;
        } else {
            console.log('🔍 Fetching rider-buyer messages for order:', conversation.order_id);
            fetchUrl = `/api/rider/conversation-messages?order_id=${conversation.order_id}`;
        }
    } else {
        // Buyer - check if it's a rider or seller conversation
        if (conversation.conversation_type === 'rider') {
            console.log('🔍 Fetching buyer-rider messages for order:', conversation.order_id);
            fetchUrl = `/api/buyer/rider-messages?order_id=${conversation.order_id}`;
        } else {
            // Buyer-Seller conversation (including order-based conversations)
            console.log('🔍 Fetching messages for seller:', conversation.seller_email);
            console.log('🔍 Conversation ID:', conversation.conversation_id);
            console.log('🔍 Order ID:', conversation.order_id);
            
            // Use conversation_id if available (for order-based conversations)
            if (conversation.conversation_id) {
                fetchUrl = `/api/messages/conversation?conversation_id=${encodeURIComponent(conversation.conversation_id)}`;
            } else {
                fetchUrl = `/api/messages/conversation?seller_email=${encodeURIComponent(conversation.seller_email)}&product_id=${conversation.product_id || ''}`;
            }
        }
    }
    
    fetch(fetchUrl)
        .then(response => {
            console.log('📡 Response status:', response.status);
            return response.json();
        })
        .then(data => {
            console.log('📋 Messages data:', data);
            if (data.success) {
                // Merge API response data with conversation
                if (userType === 'seller') {
                    // Seller viewing conversation - could be with buyer or rider
                    if (conversation.conversation_type === 'rider') {
                        // Seller-Rider conversation - merge all available data
                        if (data.rider_name) conversation.rider_name = data.rider_name;
                        if (data.rider_email) conversation.rider_email = data.rider_email;
                        if (data.rider_profile_picture) conversation.rider_profile_picture = data.rider_profile_picture;
                        if (data.seller_name) conversation.seller_name = data.seller_name;
                        if (data.seller_email) conversation.seller_email = data.seller_email;
                        if (data.seller_profile_picture) conversation.seller_profile_picture = data.seller_profile_picture;
                        
                        // Also ensure order_id is set
                        if (!conversation.order_id && data.order_id) {
                            conversation.order_id = data.order_id;
                        }
                        
                        console.log('✅ Merged seller-rider conversation data:', conversation);
                        console.log('✅ Rider email:', conversation.rider_email);
                        console.log('✅ Order ID:', conversation.order_id);
                    }
                } else if (userType === 'rider') {
                    // Rider viewing conversation - could be with buyer or seller
                    if (conversation.conversation_type === 'seller' && data.seller_name) {
                        // Rider-Seller conversation
                        conversation.seller_name = data.seller_name;
                        conversation.seller_email = data.seller_email;
                        conversation.seller_profile_picture = data.seller_profile_picture;
                        conversation.rider_name = data.rider_name;
                        conversation.rider_email = data.rider_email;
                        conversation.rider_profile_picture = data.rider_profile_picture;
                        console.log('✅ Merged rider-seller conversation data:', conversation);
                    } else if (data.buyer_name) {
                        // Rider-Buyer conversation
                        conversation.buyer_name = data.buyer_name;
                        conversation.buyer_email = data.buyer_email;
                        conversation.buyer_profile_picture = data.buyer_profile_picture;
                        conversation.rider_name = data.rider_name;
                        conversation.rider_email = data.rider_email;
                        conversation.rider_profile_picture = data.rider_profile_picture;
                        console.log('✅ Merged rider-buyer conversation data:', conversation);
                    }
                } else if (conversation.conversation_type === 'rider' && data.rider_name) {
                    // Buyer viewing rider conversation
                    conversation.rider_name = data.rider_name;
                    conversation.rider_email = data.rider_email;
                    conversation.rider_profile_picture = data.rider_profile_picture;
                    conversation.buyer_name = data.buyer_name;
                    conversation.buyer_email = data.buyer_email;
                    conversation.buyer_profile_picture = data.buyer_profile_picture;
                    console.log('✅ Merged buyer-rider conversation data:', conversation);
                } else if (data.buyer_email && data.rider_email) {
                    // Fallback: merge all data if both emails are present
                    conversation.rider_name = data.rider_name;
                    conversation.rider_email = data.rider_email;
                    conversation.rider_profile_picture = data.rider_profile_picture;
                    conversation.buyer_name = data.buyer_name;
                    conversation.buyer_email = data.buyer_email;
                    conversation.buyer_profile_picture = data.buyer_profile_picture;
                    console.log('✅ Merged conversation data (fallback):', conversation);
                }
                displayModalMessages(data.messages, conversation);
            } else {
                console.error('❌ Failed to load messages:', data.error);
                chatArea.innerHTML = `
                    <div class="chat-placeholder-modal">
                        <i class="bi bi-exclamation-triangle" style="color: #dc3545;"></i>
                        <h3>Error loading messages</h3>
                        <p style="color: #dc3545;">${data.error}</p>
                    </div>
                `;
            }
        })
        .catch(error => {
            console.error('❌ Error loading conversation:', error);
            chatArea.innerHTML = `
                <div class="chat-placeholder-modal">
                    <i class="bi bi-exclamation-triangle" style="color: #dc3545;"></i>
                    <h3>Error loading conversation</h3>
                    <p style="color: #dc3545;">${error.message}</p>
                </div>
            `;
        });
}

function markConversationAsRead(otherPartyEmail, productId) {
    console.log('📝 Marking conversation as read for:', otherPartyEmail);
    console.log('User type:', userType);
    
    const requestBody = userType === 'seller' 
        ? { buyer_email: otherPartyEmail, product_id: productId || null }
        : { seller_email: otherPartyEmail, product_id: productId || null };
    
    console.log('📤 Sending mark-read request:', requestBody);
    
    fetch('/api/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
    })
    .then(response => {
        console.log('📡 Mark-read response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📋 Mark-read response:', data);
        if (data.success) {
            console.log(`✅ Marked ${data.affected_rows} messages as read`);
            
            // Update message badge in header
            updateMessageBadge();
        } else {
            console.error('❌ Failed to mark conversation as read:', data.error);
        }
    })
    .catch(error => {
        console.error('❌ Error marking conversation as read:', error);
    });
}

function markConversationAsReadByConversationId(conversationId) {
    console.log('📝 Marking conversation as read by conversation_id:', conversationId);
    
    fetch('/api/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ conversation_id: conversationId })
    })
    .then(response => {
        console.log('📡 Mark-read response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📋 Mark-read response:', data);
        if (data.success) {
            console.log(`✅ Marked ${data.affected_rows} messages as read`);
            
            // Update message badge in header
            updateMessageBadge();
        } else {
            console.error('❌ Failed to mark conversation as read:', data.error);
        }
    })
    .catch(error => {
        console.error('❌ Error marking conversation as read:', error);
    });
}

function markSellerRiderConversationAsRead(orderId) {
    console.log('📝 Marking seller-rider conversation as read for order:', orderId);
    
    fetch('/api/seller/rider-messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ order_id: orderId })
    })
    .then(response => {
        console.log('📡 Mark-read response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📋 Mark-read response:', data);
        if (data.success) {
            console.log(`✅ Marked seller-rider messages as read`);
            
            // Update message badge in header if function exists
            if (typeof updateMessageBadge === 'function') {
                updateMessageBadge();
            }
        } else {
            console.error('❌ Failed to mark seller-rider conversation as read:', data.error);
        }
    })
    .catch(error => {
        console.error('❌ Error marking seller-rider conversation as read:', error);
    });
}

function markRiderConversationAsRead(orderId) {
    console.log('📝 Marking rider conversation as read for order:', orderId);
    
    fetch('/api/rider/messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ order_id: orderId })
    })
    .then(response => {
        console.log('📡 Mark-read response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📋 Mark-read response:', data);
        if (data.success) {
            console.log(`✅ Marked rider messages as read`);
            
            // Update message badge in header
            updateMessageBadge();
        } else {
            console.error('❌ Failed to mark rider conversation as read:', data.error);
        }
    })
    .catch(error => {
        console.error('❌ Error marking rider conversation as read:', error);
    });
}

function markBuyerRiderConversationAsRead(orderId) {
    console.log('📝 Marking buyer-rider conversation as read for order:', orderId);
    
    // For now, buyer-rider messages don't have a mark-read endpoint
    // This can be implemented later if needed
    console.log('ℹ️ Buyer-rider mark-read not yet implemented');
}

function markBuyerRiderConversationAsRead(orderId) {
    console.log('📝 Marking buyer-rider conversation as read for order:', orderId);
    
    fetch('/api/buyer/rider-messages/mark-read', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ order_id: orderId })
    })
    .then(response => {
        console.log('📡 Mark-read response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📋 Mark-read response:', data);
        if (data.success) {
            console.log(`✅ Marked buyer-rider messages as read`);
            
            // Update message badge in header
            updateMessageBadge();
        } else {
            console.error('❌ Failed to mark buyer-rider conversation as read:', data.error);
        }
    })
    .catch(error => {
        console.error('❌ Error marking buyer-rider conversation as read:', error);
    });
}

function updateMessageBadge() {
    // Update the message badge count in the header
    let apiEndpoint;
    if (userType === 'seller') {
        apiEndpoint = '/api/seller/messages';
    } else if (userType === 'rider') {
        apiEndpoint = '/api/rider/messages';
    } else {
        apiEndpoint = '/api/buyer/messages';
    }
    
    fetch(apiEndpoint)
        .then(response => response.json())
        .then(data => {
            if (data.success && data.conversations) {
                const unreadCount = data.conversations.reduce((sum, conv) => sum + (conv.unread_count || 0), 0);
                const messageBadge = document.getElementById('messageBadge');
                if (messageBadge) {
                    messageBadge.textContent = unreadCount;
                    messageBadge.style.display = unreadCount > 0 ? 'block' : 'none';
                }
            }
        })
        .catch(error => {
            console.error('Error updating message badge:', error);
        });
}

function displayModalMessages(messages, conversation) {
    console.log('💬 ========== DISPLAYING MESSAGES ==========');
    console.log('💬 Messages count:', messages.length);
    console.log('💬 User type:', userType);
    console.log('💬 Conversation object:', JSON.stringify(conversation, null, 2));
    console.log('💬 Conversation type:', conversation.conversation_type);
    console.log('💬 Has rider_name:', !!conversation.rider_name);
    console.log('💬 Has seller_name:', !!conversation.seller_name);
    console.log('💬 Has order_id:', !!conversation.order_id);
    console.log('💬 Buyer email:', conversation.buyer_email);
    console.log('💬 Rider email:', conversation.rider_email);
    console.log('💬 Seller email:', conversation.seller_email);
    console.log('🖼️ Buyer profile picture:', conversation.buyer_profile_picture);
    console.log('🖼️ Seller profile picture:', conversation.seller_profile_picture);
    console.log('🖼️ Rider profile picture:', conversation.rider_profile_picture);
    console.log('💬 Sample message:', messages[0]);
    console.log('💬 ==========================================');
    
    const chatArea = document.getElementById('chatAreaModal');
    
    // Get first letters for avatars
    const buyerInitial = (conversation.buyer_name || 'Buyer').charAt(0).toUpperCase();
    const sellerInitial = (conversation.seller_name || 'Seller').charAt(0).toUpperCase();
    const riderInitial = (conversation.rider_name || 'Rider').charAt(0).toUpperCase();
    
    // Get profile pictures
    const buyerProfilePic = conversation.buyer_profile_picture;
    const sellerProfilePic = conversation.seller_profile_picture;
    const riderProfilePic = conversation.rider_profile_picture;
    
    // Get emails for identification with safety checks
    let buyerEmail = conversation.buyer_email || null;
    let riderEmail = conversation.rider_email || null;
    let sellerEmail = conversation.seller_email || null;
    
    console.log('📧 Initial emails - Buyer:', buyerEmail, 'Rider:', riderEmail, 'Seller:', sellerEmail);
    console.log('👤 User type:', userType);
    console.log('📦 Conversation:', conversation);
    
    // CRITICAL FIX: Extract rider email from messages if missing
    if (!riderEmail && userType === 'rider' && messages.length > 0) {
        console.log('⚠️ Rider email missing in rider view, extracting from messages...');
        
        // Get all unique sender emails
        const senderEmails = [...new Set(messages.map(m => m.sender_email))];
        console.log('📧 All sender emails:', senderEmails);
        
        // If we have buyer email, rider is the other one
        if (buyerEmail && senderEmails.length === 2) {
            riderEmail = senderEmails.find(email => email !== buyerEmail);
            conversation.rider_email = riderEmail;
            console.log('✅ Extracted rider_email (not buyer):', riderEmail);
        } else if (senderEmails.length === 2) {
            // If we have 2 senders and one is seller, the other must be rider
            if (sellerEmail) {
                riderEmail = senderEmails.find(email => email !== sellerEmail);
                conversation.rider_email = riderEmail;
                console.log('✅ Extracted rider_email (not seller):', riderEmail);
            } else {
                // Assume the first sender is the rider
                riderEmail = senderEmails[0];
                conversation.rider_email = riderEmail;
                console.log('✅ Using first sender as rider_email:', riderEmail);
            }
        } else if (senderEmails.length > 0) {
            // Assume the first sender is the rider (since rider usually initiates)
            riderEmail = senderEmails[0];
            conversation.rider_email = riderEmail;
            console.log('✅ Using first sender as rider_email:', riderEmail);
        }
    }
    
    // CRITICAL FIX: If buyer_email is missing and we're in buyer view, 
    // the buyer_email should be the current session user's email
    if (!buyerEmail && userType === 'buyer' && messages.length > 0) {
        console.log('⚠️ Buyer email missing, attempting to extract from messages...');
        
        // For buyer-rider conversations, we need to identify which email is the buyer's
        // The buyer is the one who is NOT the rider
        if (riderEmail) {
            // Find a message where sender is not the rider
            const buyerMessage = messages.find(m => m.sender_email !== riderEmail);
            if (buyerMessage) {
                buyerEmail = buyerMessage.sender_email;
                conversation.buyer_email = buyerEmail;
                console.log('✅ Extracted buyer_email from messages (not rider):', buyerEmail);
            }
        } else {
            // If we don't have rider email, try to find the most common sender
            // (assuming buyer sends more messages or is the first sender)
            const firstMessage = messages[0];
            if (firstMessage) {
                buyerEmail = firstMessage.sender_email;
                conversation.buyer_email = buyerEmail;
                console.log('✅ Using first message sender as buyer_email:', buyerEmail);
            }
        }
        
        if (!buyerEmail) {
            console.error('❌ Could not extract buyer_email from messages');
        }
    }
    
    // CRITICAL FIX: If buyer_email is missing and we're in rider view,
    // extract it from messages (buyer is the one who is NOT the rider)
    if (!buyerEmail && userType === 'rider' && messages.length > 0 && riderEmail) {
        console.log('⚠️ Buyer email missing in rider view, attempting to extract from messages...');
        
        // Find a message where sender is not the rider
        const buyerMessage = messages.find(m => m.sender_email !== riderEmail);
        if (buyerMessage) {
            buyerEmail = buyerMessage.sender_email;
            conversation.buyer_email = buyerEmail;
            console.log('✅ Extracted buyer_email from messages (not rider):', buyerEmail);
        } else {
            console.error('❌ Could not extract buyer_email - all messages are from rider');
        }
    }
    
    console.log('📧 Email data:', { 
        buyer: buyerEmail, 
        rider: riderEmail, 
        seller: sellerEmail,
        userType: userType,
        conversationHasBuyerEmail: !!conversation.buyer_email,
        conversationHasRiderEmail: !!conversation.rider_email
    });
    
    // Validate that we have the necessary email for identification
    if (userType === 'rider' && !buyerEmail) {
        console.error('❌ Missing buyer_email for rider conversation - messages may not align correctly');
    }
    if (userType === 'buyer' && conversation.rider_name && !buyerEmail) {
        console.error('❌ Missing buyer_email for buyer-rider conversation - messages may not align correctly');
    }
    if (userType === 'buyer' && conversation.rider_name && !riderEmail) {
        console.warn('⚠️ Missing rider_email for buyer-rider conversation');
    }
    
    // Determine who we're chatting with based on user type
    let otherPartyName, otherPartyPicture, otherPartyIcon;
    if (userType === 'seller') {
        // Seller can chat with both buyers and riders
        if (conversation.conversation_type === 'rider') {
            otherPartyName = conversation.rider_name || 'Rider';
            otherPartyPicture = riderProfilePic;
            otherPartyIcon = 'bi-truck';
        } else {
            otherPartyName = conversation.buyer_name || 'Buyer';
            otherPartyPicture = buyerProfilePic;
            otherPartyIcon = 'bi-person-circle';
        }
    } else if (userType === 'rider') {
        // Rider can chat with both buyers and sellers
        if (conversation.conversation_type === 'seller') {
            otherPartyName = conversation.seller_name || 'Seller';
            otherPartyPicture = sellerProfilePic;
            otherPartyIcon = 'bi-shop';
        } else {
            otherPartyName = conversation.buyer_name || 'Buyer';
            otherPartyPicture = buyerProfilePic;
            otherPartyIcon = 'bi-person-circle';
        }
    } else if (userType === 'buyer') {
        // Check if it's a rider or seller conversation
        // ONLY check conversation_type, not order_id (order_id can exist in buyer-seller conversations)
        if (conversation.conversation_type === 'rider') {
            otherPartyName = conversation.rider_name || 'Rider';
            otherPartyPicture = riderProfilePic;
            otherPartyIcon = 'bi-truck';
        } else {
            otherPartyName = conversation.seller_name || 'Seller';
            otherPartyPicture = sellerProfilePic;
            otherPartyIcon = 'bi-shop';
        }
    } else {
        otherPartyName = conversation.seller_name || 'Seller';
        otherPartyPicture = sellerProfilePic;
        otherPartyIcon = 'bi-shop';
    }
    
    chatArea.innerHTML = `
        <div class="chat-header-modal">
            <div class="message-avatar">
                ${otherPartyPicture 
                    ? `<img src="/static/uploads/${otherPartyPicture}" alt="${otherPartyName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">` 
                    : `<i class="${otherPartyIcon}"></i>`
                }
            </div>
            <div>
                <div class="buyer-name" style="font-weight: 600; font-size: 16px;">${otherPartyName}</div>
                <div class="product-context" style="font-size: 13px; color: #666;">${
                    userType === 'rider' ? (conversation.order_id ? `Order #${conversation.order_id}` : 'Delivery') :
                    userType === 'seller' && conversation.conversation_type === 'rider' ? (conversation.order_id ? `Order #${conversation.order_id}` : 'Delivery') :
                    userType === 'seller' && conversation.order_id ? `Order #${conversation.order_id}` :
                    userType === 'buyer' && conversation.order_id ? `Order #${conversation.order_id}` :
                    (conversation.product_name || 'General Inquiry')
                }</div>
            </div>
        </div>
        <div class="chat-messages-modal" id="chatMessagesModal">
            ${messages.length > 0 ? messages.map((msg, index) => {
                console.log(`📨 ========== MESSAGE ${index + 1} ==========`);
                console.log(`📨 Message data:`, msg);
                console.log(`👤 USER TYPE: ${userType}`);
                console.log(`📧 Available emails - Buyer: ${buyerEmail}, Rider: ${riderEmail}, Seller: ${sellerEmail}`);
                console.log(`📦 Conversation type: ${conversation.conversation_type}`);
                
                let isBuyer, initial, profilePic, isCurrentUser, messageClass, senderName;
                
                if (userType === 'rider') {
                    // For rider messages, check if it's a seller-rider or buyer-rider conversation
                    if (conversation.conversation_type === 'seller') {
                        // Seller-Rider conversation
                        let isSeller;
                        if (!sellerEmail || !msg.sender_email) {
                            console.warn('⚠️ Missing email data:', { sellerEmail, senderEmail: msg.sender_email });
                            isSeller = false;
                        } else {
                            isSeller = msg.sender_email === sellerEmail;
                        }
                        
                        initial = isSeller ? sellerInitial : riderInitial;
                        profilePic = isSeller ? sellerProfilePic : riderProfilePic;
                        senderName = isSeller ? (conversation.seller_name || 'Seller') : (conversation.rider_name || 'Rider');
                        // Rider is current user: Rider messages on RIGHT, Seller messages on LEFT
                        let isRider = !isSeller;
                        isCurrentUser = isRider;
                        messageClass = isRider ? 'seller' : 'buyer'; // 'seller' = right (rider), 'buyer' = left (seller)
                        
                        console.log(`  📧 Sender: ${msg.sender_email}, Seller: ${sellerEmail}, Is Seller: ${isSeller}, Is Rider: ${isRider}, messageClass: ${messageClass}`);
                    } else {
                        // Buyer-Rider conversation
                        console.log(`  🚚 RIDER-BUYER conversation - analyzing message ${index + 1}`);
                        console.log(`  📧 Sender: ${msg.sender_email}`);
                        console.log(`  📧 Rider: ${riderEmail}`);
                        console.log(`  📧 Buyer: ${buyerEmail}`);
                        
                        // Determine if message is from buyer or rider
                        let isRider = false;
                        let isBuyer = false;
                        
                        // Method 1: Compare with rider email (most reliable)
                        if (riderEmail && msg.sender_email) {
                            isRider = (msg.sender_email.toLowerCase().trim() === riderEmail.toLowerCase().trim());
                            isBuyer = !isRider;
                            console.log(`  ✅ Method 1 (Rider email): isRider=${isRider}, isBuyer=${isBuyer}`);
                        }
                        // Method 2: Compare with buyer email
                        else if (buyerEmail && msg.sender_email) {
                            isBuyer = (msg.sender_email.toLowerCase().trim() === buyerEmail.toLowerCase().trim());
                            isRider = !isBuyer;
                            console.log(`  ⚠️ Method 2 (Buyer email): isBuyer=${isBuyer}, isRider=${isRider}`);
                        }
                        // Method 3: Analyze all senders
                        else {
                            const allSenders = messages.map(m => m.sender_email).filter(Boolean);
                            const uniqueSenders = [...new Set(allSenders)];
                            console.warn('⚠️ Method 3 (Analyze senders):', uniqueSenders);
                            
                            if (uniqueSenders.length === 2) {
                                // Assume first unique sender is rider
                                const assumedRiderEmail = uniqueSenders[0];
                                isRider = (msg.sender_email === assumedRiderEmail);
                                isBuyer = !isRider;
                                console.log(`  🔍 Assumed rider: ${assumedRiderEmail}, isRider=${isRider}`);
                            } else {
                                // Default: assume message is from buyer
                                isBuyer = true;
                                isRider = false;
                                console.warn(`  ❌ Cannot determine, defaulting to buyer`);
                            }
                        }
                        
                        initial = isBuyer ? buyerInitial : riderInitial;
                        profilePic = isBuyer ? buyerProfilePic : riderProfilePic;
                        senderName = isBuyer ? (conversation.buyer_name || 'Buyer') : (conversation.rider_name || 'Rider');
                        
                        // CRITICAL: Rider is current user
                        // Rider's own messages should be on RIGHT (class 'seller')
                        // Buyer's messages should be on LEFT (class 'buyer')
                        isCurrentUser = isRider;
                        messageClass = isRider ? 'seller' : 'buyer';
                        
                        console.log(`  📍 FINAL RESULT:`);
                        console.log(`     - isBuyer: ${isBuyer}`);
                        console.log(`     - isRider: ${isRider}`);
                        console.log(`     - isCurrentUser: ${isCurrentUser}`);
                        console.log(`     - messageClass: ${messageClass} (seller=RIGHT/rider, buyer=LEFT/buyer)`);
                    }
                } else if (userType === 'buyer') {
                    // For buyer messages in buyer-seller or buyer-rider context
                    // CHECK RIDER CONVERSATION FIRST (before seller) - ONLY by conversation_type
                    if (conversation.conversation_type === 'rider') {
                        // Buyer-Rider conversation
                        console.log(`  🚚 BUYER-RIDER conversation detected`);
                        
                        // Determine if message is from buyer by comparing emails
                        if (buyerEmail && msg.sender_email) {
                            // Primary method: compare sender email with buyer email
                            isBuyer = msg.sender_email === buyerEmail;
                            console.log(`  ✅ Email match: sender=${msg.sender_email}, buyer=${buyerEmail}, isBuyer=${isBuyer}`);
                        } else if (riderEmail && msg.sender_email) {
                            // Fallback: if sender is NOT rider, then it's buyer
                            isBuyer = msg.sender_email !== riderEmail;
                            console.log(`  ⚠️ Rider exclusion: sender=${msg.sender_email}, rider=${riderEmail}, isBuyer=${isBuyer}`);
                        } else {
                            // Last resort: assume it's from buyer
                            isBuyer = true;
                            console.warn(`  ❌ Fallback: assuming buyer, sender=${msg.sender_email}`);
                        }
                        
                        initial = isBuyer ? buyerInitial : riderInitial;
                        profilePic = isBuyer ? buyerProfilePic : riderProfilePic;
                        senderName = isBuyer ? (conversation.buyer_name || 'You') : (conversation.rider_name || 'Rider');
                        
                        // CRITICAL: Buyer is current user
                        // Buyer messages should be on RIGHT (class 'seller')
                        // Rider messages should be on LEFT (class 'buyer')
                        isCurrentUser = isBuyer;
                        messageClass = isCurrentUser ? 'seller' : 'buyer';
                        
                        console.log(`  📍 FINAL: isBuyer=${isBuyer}, isCurrentUser=${isCurrentUser}, messageClass=${messageClass} (seller=right, buyer=left)`);
                    } else if (conversation.seller_name || conversation.seller_email) {
                        // Buyer-Seller conversation
                        console.log(`  🏪 BUYER-SELLER conversation detected`);
                        isBuyer = msg.sender_type === 'buyer';
                        initial = isBuyer ? buyerInitial : sellerInitial;
                        profilePic = isBuyer ? buyerProfilePic : sellerProfilePic;
                        senderName = isBuyer ? conversation.buyer_name : conversation.seller_name;
                        isCurrentUser = isBuyer;
                        messageClass = isCurrentUser ? 'seller' : 'buyer';
                        
                        console.log(`  📍 FINAL: isBuyer=${isBuyer}, isCurrentUser=${isCurrentUser}, messageClass=${messageClass}`);
                    }
                } else {
                    // For seller messages
                    // Check if it's a seller-rider conversation (ONLY check conversation_type, not order_id)
                    if (conversation.conversation_type === 'rider') {
                        // Seller-Rider conversation
                        console.log(`  🚚 SELLER-RIDER conversation detected`);
                        const isRider = msg.sender_type === 'rider';
                        initial = isRider ? riderInitial : sellerInitial;
                        profilePic = isRider ? riderProfilePic : sellerProfilePic;
                        senderName = isRider ? (conversation.rider_name || 'Rider') : (conversation.seller_name || 'Seller');
                        // Seller is current user: Seller messages on RIGHT, Rider messages on LEFT
                        isCurrentUser = !isRider; // Seller is current user (messages NOT from rider are from seller)
                        messageClass = isCurrentUser ? 'seller' : 'buyer'; // 'seller' = right (seller), 'buyer' = left (rider)
                        
                        console.log(`  📧 Sender type: ${msg.sender_type}, Is Rider: ${isRider}, Is Current User (Seller): ${isCurrentUser}, Class: ${messageClass}`);
                    } else {
                        // Seller-Buyer conversation (including order-based conversations)
                        console.log(`  🏪 SELLER-BUYER conversation detected`);
                        isBuyer = msg.sender_type === 'buyer';
                        initial = isBuyer ? buyerInitial : sellerInitial;
                        profilePic = isBuyer ? buyerProfilePic : sellerProfilePic;
                        senderName = isBuyer ? (conversation.buyer_name || 'Buyer') : (conversation.seller_name || 'Seller');
                        // Seller is current user: Seller messages on RIGHT, Buyer messages on LEFT
                        isCurrentUser = !isBuyer; // Seller is current user (messages NOT from buyer are from seller)
                        messageClass = isCurrentUser ? 'seller' : 'buyer'; // 'seller' = right (seller), 'buyer' = left (buyer)
                        
                        console.log(`  📧 Sender type: ${msg.sender_type}, Is Buyer: ${isBuyer}, Is Current User (Seller): ${isCurrentUser}, Class: ${messageClass}`);
                    }
                }
                
                const messageText = msg.message_text || msg.message || '';
                const messageTime = msg.created_at || msg.timestamp;
                
                return `
                    <div class="chat-message-item ${messageClass}">
                        <div class="message-avatar-small">
                            ${profilePic 
                                ? `<img src="/static/uploads/${profilePic}" alt="${senderName}" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">` 
                                : initial
                            }
                        </div>
                        <div class="message-content-wrapper">
                            <div class="message-bubble-chat">${escapeHtml(messageText)}</div>
                            <div class="message-time-chat">${formatMessageTime(messageTime)}</div>
                        </div>
                    </div>
                `;
            }).join('') : '<div class="no-messages" style="padding: 40px; text-align: center; color: #999;"><i class="bi bi-chat-slash" style="font-size: 48px; display: block; margin-bottom: 10px;"></i><p>No messages yet</p></div>'}
        </div>
        <div class="chat-footer-modal">
            <div class="chat-input-wrapper">
                <textarea id="modalMessageInput" placeholder="Type your message..." rows="1" maxlength="1000"></textarea>
                <button class="send-message-btn" onclick="sendModalReply()">
                    <i class="bi bi-send"></i>
                </button>
            </div>
        </div>
    `;
    
    // Scroll to bottom
    setTimeout(() => {
        const messagesArea = document.getElementById('chatMessagesModal');
        if (messagesArea) {
            messagesArea.scrollTop = messagesArea.scrollHeight;
            console.log('✅ Scrolled to bottom');
        }
    }, 100);
    
    // Auto-resize textarea
    const textarea = document.getElementById('modalMessageInput');
    if (textarea) {
        textarea.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 100) + 'px';
        });
        
        // Send on Enter
        textarea.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendModalReply();
            }
        });
        
        console.log('✅ Chat interface ready');
    }
}

function sendModalReply() {
    const input = document.getElementById('modalMessageInput');
    const message = input.value.trim();
    
    if (!message || !currentModalConversationId || !currentModalConversation) {
        console.log('❌ Cannot send: message, conversation ID, or conversation object missing');
        console.log('❌ Debug info:', {
            hasMessage: !!message,
            hasConversationId: !!currentModalConversationId,
            hasConversation: !!currentModalConversation
        });
        return;
    }
    
    console.log('📤 ========== SENDING MESSAGE ==========');
    console.log('📤 User type:', userType);
    console.log('📤 Conversation ID:', currentModalConversationId);
    console.log('📤 Conversation object:', JSON.stringify(currentModalConversation, null, 2));
    console.log('📤 Message:', message);
    console.log('📤 =====================================');
    
    // Use appropriate API endpoint based on user type and conversation type
    let apiEndpoint, requestBody;
    
    if (userType === 'seller') {
        // Seller can send messages to both buyers and riders
        if (currentModalConversation.conversation_type === 'rider') {
            // Seller sending message to rider
            console.log('📤 Seller sending to rider');
            console.log('📤 Current conversation data:', currentModalConversation);
            
            // Try multiple sources for rider email
            let riderEmail = currentModalConversation.rider_email || 
                            currentModalConversation.contact_email ||
                            currentModalConversation.email;
            
            // Try multiple sources for order ID
            let orderId = currentModalConversation.order_id || 
                         currentModalConversation.id;
            
            // If still missing, try to extract from conversation ID
            if (!orderId && currentModalConversationId) {
                const idParts = currentModalConversationId.split('_');
                if (idParts.length >= 3) {
                    orderId = idParts[idParts.length - 1]; // Last part should be order ID
                }
            }
            
            // If still missing rider email, try to extract from conversation ID
            if (!riderEmail && currentModalConversationId) {
                const idParts = currentModalConversationId.split('_');
                if (idParts.length >= 2) {
                    // For seller-rider conversations, rider email might be first or second part
                    riderEmail = idParts[0].includes('@') ? idParts[0] : idParts[1];
                }
            }
            
            console.log('📤 Extracted data:', { 
                riderEmail, 
                orderId, 
                conversationId: currentModalConversationId,
                conversationType: currentModalConversation.conversation_type
            });
            
            if (!riderEmail || !orderId) {
                console.error('❌ ========== MISSING DATA ERROR ==========');
                console.error('❌ Missing rider_email or order_id after extraction');
                console.error('❌ Rider email:', riderEmail);
                console.error('❌ Order ID:', orderId);
                console.error('❌ Conversation data:', JSON.stringify(currentModalConversation, null, 2));
                console.error('❌ Conversation ID:', currentModalConversationId);
                console.error('❌ Available keys in conversation:', Object.keys(currentModalConversation));
                console.error('❌ =========================================');
                alert('Error: Missing rider or order information. Please try again.\n\nPlease check the browser console for details.');
                return;
            }
            
            console.log('✅ Data validation passed:', { riderEmail, orderId });
            
            apiEndpoint = '/api/messages/send-seller-rider-message';
            requestBody = {
                order_id: parseInt(orderId),
                rider_email: riderEmail,
                message_text: message
            };
        } else {
            // Seller sending message to buyer
            console.log('📤 Seller sending to buyer');
            const buyerEmail = currentModalConversation.buyer_email;
            const productId = currentModalConversation.product_id;
            const orderId = currentModalConversation.order_id;
            
            if (!buyerEmail) {
                console.error('❌ Missing buyer_email');
                alert('Error: Missing buyer information. Please try again.');
                return;
            }
            
            apiEndpoint = '/api/messages/send-seller-reply';
            requestBody = {
                buyer_email: buyerEmail,
                message_text: message,
                product_id: productId,
                conversation_id: currentModalConversationId,
                order_id: orderId
            };
        }
    } else if (userType === 'rider') {
        // For rider, check if it's a seller-rider or buyer-rider conversation
        if (currentModalConversation.conversation_type === 'seller') {
            // Rider sending message to seller
            console.log('📤 Rider sending to seller');
            const sellerEmail = currentModalConversation.contact_email || currentModalConversation.seller_email;
            const orderId = currentModalConversation.order_id;
            
            if (!sellerEmail || !orderId) {
                console.error('❌ Missing seller_email or order_id:', { sellerEmail, orderId });
                alert('Error: Missing seller or order information. Please try again.');
                return;
            }
            
            apiEndpoint = '/api/messages/send-rider-seller-message';
            requestBody = {
                order_id: parseInt(orderId),
                seller_email: sellerEmail,
                message_text: message
            };
        } else {
            // Rider sending message to buyer
            console.log('📤 Rider sending to buyer');
            const orderId = currentModalConversation.order_id;
            
            if (!orderId) {
                console.error('❌ Missing order_id');
                alert('Error: Missing order information. Please try again.');
                return;
            }
            
            apiEndpoint = '/api/rider/send-message';
            requestBody = {
                order_id: parseInt(orderId),
                message: message
            };
        }
    } else if (userType === 'buyer') {
        // Buyer can send messages to both sellers and riders
        if (currentModalConversation.conversation_type === 'rider' || currentModalConversation.order_id) {
            // Buyer sending message to rider
            console.log('📤 Buyer sending to rider');
            const orderId = currentModalConversation.order_id;
            
            if (!orderId) {
                console.error('❌ Missing order_id');
                alert('Error: Missing order information. Please try again.');
                return;
            }
            
            apiEndpoint = '/api/buyer/send-rider-message';
            requestBody = {
                order_id: parseInt(orderId),
                message: message
            };
        } else {
            // Buyer sending message to seller
            console.log('📤 Buyer sending to seller');
            const sellerEmail = currentModalConversation.seller_email;
            const productId = currentModalConversation.product_id;
            
            if (!sellerEmail) {
                console.error('❌ Missing seller_email');
                alert('Error: Missing seller information. Please try again.');
                return;
            }
            
            apiEndpoint = '/api/messages/send';
            requestBody = {
                seller_email: sellerEmail,
                message_text: message,
                product_id: productId
            };
        }
    } else {
        console.error('❌ Unknown user type:', userType);
        alert('Error: Unable to determine user type. Please refresh the page.');
        return;
    }
    
    console.log('📤 API Endpoint:', apiEndpoint);
    console.log('📤 Request Body:', requestBody);
    
    fetch(apiEndpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody)
    })
    .then(response => {
        console.log('📡 Response status:', response.status);
        return response.json();
    })
    .then(data => {
        console.log('📋 Response data:', data);
        if (data.success) {
            console.log('✅ Message sent successfully');
            input.value = '';
            input.style.height = 'auto';
            
            // Store current conversation ID before reloading
            const currentConvId = currentModalConversationId;
            
            // Refresh conversations list and maintain selection
            loadAllConversations(currentConvId);
            
            // Also reload the current conversation to show the new message
            setTimeout(() => {
                if (currentModalConversation) {
                    console.log('🔄 Reloading current conversation to show new message');
                    loadModalConversation(currentModalConversation);
                }
            }, 500);
        } else {
            console.error('❌ Failed to send message:', data.error);
            alert('Failed to send message: ' + (data.error || 'Unknown error'));
        }
    })
    .catch(error => {
        console.error('❌ Error sending message:', error);
        alert('Failed to send message. Please try again.');
    });
}

function formatMessageTime(timestamp) {
    // Use user's local timezone from their device
    const date = new Date(timestamp);
    const now = new Date();
    
    // Check if message is from today
    const isToday = date.toDateString() === now.toDateString();
    
    // Check if message is from yesterday
    const yesterday = new Date(now);
    yesterday.setDate(yesterday.getDate() - 1);
    const isYesterday = date.toDateString() === yesterday.toDateString();
    
    // Format time using user's local timezone
    const timeStr = date.toLocaleTimeString('en-US', { 
        hour: '2-digit', 
        minute: '2-digit',
        hour12: true
    });
    
    if (isToday) {
        return timeStr; // Just show time for today's messages
    } else if (isYesterday) {
        return `Yesterday ${timeStr}`;
    } else {
        // Show date and time for older messages
        const dateStr = date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric',
            year: date.getFullYear() !== now.getFullYear() ? 'numeric' : undefined
        });
        return `${dateStr} ${timeStr}`;
    }
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Close modal when clicking outside
document.addEventListener('click', function(e) {
    const modal = document.getElementById('messagesModal');
    if (e.target === modal) {
        closeMessagesModal();
    }
});

// Close modal on Escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const modal = document.getElementById('messagesModal');
        if (modal && modal.style.display === 'flex') {
            closeMessagesModal();
        }
    }
});

// Update openSellerChat to use modal
function openSellerChat(conversation) {
    openMessagesModal();
    setTimeout(() => {
        loadModalConversation(conversation);
    }, 300);
}

// Global function for opening rider chat
function openRiderChatModal(conversation) {
    console.log('🚚 Opening rider chat modal:', conversation);
    openMessagesModal(null, conversation);
}

// Global function for opening buyer chat
function openBuyerChatModal(conversation) {
    console.log('🛍️ Opening buyer chat modal:', conversation);
    openMessagesModal(null, conversation);
}
