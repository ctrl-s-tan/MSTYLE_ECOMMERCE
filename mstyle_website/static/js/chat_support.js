// Chat Support State
let currentChatTopic = '';
let chatMessages = [];

// Chat Support functionality
function toggleChatSupport() {
    const chatBtn = document.getElementById('chatSupportBtn');
    const chatModal = document.getElementById('chatSupportModal');

    if (chatModal.style.display === 'none' || chatModal.style.display === '') {
        chatModal.style.display = 'block';
        chatBtn.style.transform = 'scale(0.9)';
        setTimeout(() => {
            chatModal.classList.add('show');
        }, 10);
    } else {
        chatModal.classList.remove('show');
        chatBtn.style.transform = 'scale(1)';
        setTimeout(() => {
            chatModal.style.display = 'none';
            // Reset to options view when closing
            showChatOptions();
        }, 300);
    }
}

// Start chat with selected topic
function startChat(topic) {
    currentChatTopic = topic;
    
    // Hide welcome and options
    document.getElementById('chatWelcome').style.display = 'none';
    document.getElementById('chatOptions').style.display = 'none';
    document.getElementById('availabilityInfo').style.display = 'none';
    
    // Show chat interface
    document.getElementById('chatMessagesContainer').style.display = 'block';
    document.getElementById('chatInputContainer').style.display = 'flex';
    document.getElementById('backToOptions').style.display = 'flex';
    
    // Update header
    document.getElementById('chatHeaderTitle').textContent = topic;
    
    // Clear previous messages
    chatMessages = [];
    document.getElementById('chatMessages').innerHTML = '';
    
    // Add contextual welcome message based on topic
    let welcomeMessage = '';
    switch(topic) {
        case 'Order Inquiry':
            welcomeMessage = 'Hello! I can help you with:\n\n• Order tracking\n• Order status\n• Order cancellation\n• Order history\n\nWhat would you like to know about your order?';
            break;
        case 'Product Information':
            welcomeMessage = 'Hello! I can help you with:\n\n• Product details\n• Size guides\n• Product availability\n• Quality information\n\nWhat product information do you need?';
            break;
        case 'Shipping & Delivery':
            welcomeMessage = 'Hello! I can help you with:\n\n• Shipping rates\n• Delivery time\n• Tracking shipments\n• Delivery issues\n\nWhat shipping question can I answer?';
            break;
        case 'Returns & Refunds':
            welcomeMessage = 'Hello! I can help you with:\n\n• Return policy\n• Refund process\n• Exchange items\n• Return status\n\nHow can I assist with returns or refunds?';
            break;
        default:
            welcomeMessage = `Hello! How can I help you with ${topic.toLowerCase()}? Feel free to ask me anything! 😊`;
    }
    
    addAdminMessage(welcomeMessage);
}

// Show chat options (back button)
function showChatOptions() {
    // Show welcome and options
    document.getElementById('chatWelcome').style.display = 'block';
    document.getElementById('chatOptions').style.display = 'flex';
    document.getElementById('availabilityInfo').style.display = 'flex';
    
    // Hide chat interface
    document.getElementById('chatMessagesContainer').style.display = 'none';
    document.getElementById('chatInputContainer').style.display = 'none';
    document.getElementById('backToOptions').style.display = 'none';
    
    // Reset header
    document.getElementById('chatHeaderTitle').textContent = 'Chat Support';
    
    currentChatTopic = '';
}

// Add user message
function addUserMessage(message) {
    const timestamp = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    const messageObj = {
        type: 'user',
        message: message,
        time: timestamp
    };
    chatMessages.push(messageObj);
    renderMessage(messageObj);
}

// Add admin message
function addAdminMessage(message) {
    const timestamp = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' });
    const messageObj = {
        type: 'admin',
        message: message,
        time: timestamp
    };
    chatMessages.push(messageObj);
    renderMessage(messageObj);
}

// Render message in chat
function renderMessage(messageObj) {
    const chatMessagesDiv = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `chat-message ${messageObj.type}`;
    
    const avatar = messageObj.type === 'user' ? 'U' : '🤖';
    
    // Format message with line breaks
    const formattedMessage = messageObj.message.replace(/\n/g, '<br>');
    
    messageDiv.innerHTML = `
        <div class="message-avatar">${avatar}</div>
        <div class="message-content">
            <div class="message-bubble">${formattedMessage}</div>
            <div class="message-time">${messageObj.time}</div>
        </div>
    `;
    
    chatMessagesDiv.appendChild(messageDiv);
    
    // Scroll to bottom smoothly
    const container = document.getElementById('chatMessagesContainer');
    setTimeout(() => {
        container.scrollTop = container.scrollHeight;
    }, 100);
}

// Show typing indicator
function showTypingIndicator() {
    const chatMessagesDiv = document.getElementById('chatMessages');
    const typingDiv = document.createElement('div');
    typingDiv.className = 'typing-indicator';
    typingDiv.id = 'typingIndicator';
    
    typingDiv.innerHTML = `
        <div class="message-avatar">A</div>
        <div class="message-content">
            <div class="message-bubble">
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
            </div>
        </div>
    `;
    
    chatMessagesDiv.appendChild(typingDiv);
    
    // Scroll to bottom
    const container = document.getElementById('chatMessagesContainer');
    container.scrollTop = container.scrollHeight;
}

// Remove typing indicator
function removeTypingIndicator() {
    const typingIndicator = document.getElementById('typingIndicator');
    if (typingIndicator) {
        typingIndicator.remove();
    }
}

// Send message
function sendMessage() {
    const input = document.getElementById('chatMessageInput');
    const message = input.value.trim();
    
    if (message === '') return;
    
    // Add user message
    addUserMessage(message);
    
    // Clear input
    input.value = '';
    
    // Show typing indicator
    showTypingIndicator();
    
    // Simulate admin response (replace with actual backend call)
    setTimeout(() => {
        removeTypingIndicator();
        
        // Auto-response based on keywords (replace with actual backend)
        let response = getAutoResponse(message);
        addAdminMessage(response);
    }, 1500);
}

// Enhanced AI Chatbot Response System
function getAutoResponse(message) {
    const lowerMessage = message.toLowerCase();
    
    // Greeting responses
    if (lowerMessage.match(/^(hi|hello|hey|good morning|good afternoon|good evening|kumusta)/)) {
        return 'Hello! Welcome to MStyle. How can I assist you today? 😊';
    }
    
    // Thank you responses
    if (lowerMessage.match(/(thank you|thanks|salamat)/)) {
        return 'You\'re welcome! Is there anything else I can help you with?';
    }
    
    // Order tracking and status
    if (lowerMessage.match(/(track|where|status|nasaan|saan na).*order/i) || 
        lowerMessage.match(/order.*(track|status|where|nasaan)/i)) {
        return 'To track your order:\n\n1. Go to your Orders page\n2. Click on the order you want to track\n3. You\'ll see the current status and estimated delivery date\n\nIf you need help with a specific order, please provide your order number (e.g., ORD-12345).';
    }
    
    // Order cancellation
    if (lowerMessage.match(/(cancel|stop).*order/i) || lowerMessage.match(/order.*(cancel|stop)/i)) {
        return 'To cancel an order:\n\n• Orders can be cancelled within 24 hours of placement\n• Go to Orders → Select order → Click "Cancel Order"\n• Refunds will be processed within 5-7 business days\n\nNote: Orders already shipped cannot be cancelled. You may return them instead.';
    }
    
    // Shipping and delivery
    if (lowerMessage.match(/(shipping|delivery|deliver|ship|magkano.*shipping|shipping.*fee)/i)) {
        return 'Shipping Information:\n\n📦 Free Shipping: Orders over ₱1,000\n💰 Standard Shipping: ₱50-150 (based on location)\n⏱️ Delivery Time: 3-5 business days (Metro Manila)\n🌏 Provincial: 5-7 business days\n\nWe deliver nationwide! Shipping fee is calculated at checkout based on your location.';
    }
    
    // Returns and refunds
    if (lowerMessage.match(/(return|refund|exchange|palit|ibalik|money back)/i)) {
        return 'Returns & Refunds Policy:\n\n✅ 30-day return period\n✅ Items must be unused with original tags\n✅ Free return shipping for defective items\n\nHow to return:\n1. Go to Orders → Select item → Request Return\n2. Choose reason and upload photos\n3. Wait for approval (1-2 days)\n4. Ship item back or schedule pickup\n5. Refund processed within 7-10 days after receiving item\n\nExchanges are also available for size/color changes!';
    }
    
    // Payment methods
    if (lowerMessage.match(/(payment|pay|bayad|how to pay|payment method|gcash|credit card|debit|cod|cash on delivery)/i)) {
        return 'Payment Methods:\n\n💳 Credit/Debit Cards (Visa, Mastercard)\n📱 GCash\n🏦 Online Banking\n💵 Cash on Delivery (COD) - Available in select areas\n\nAll payments are secure and encrypted. You can choose your preferred payment method at checkout.';
    }
    
    // Product availability and stock
    if (lowerMessage.match(/(available|stock|out of stock|meron ba|available ba|may stock)/i)) {
        return 'To check product availability:\n\n• Visit the product page\n• Available items show "Add to Cart" button\n• Out of stock items are clearly marked\n• You can add items to your Wishlist to get notified when back in stock\n\nIf a specific size/color is unavailable, try checking similar products or contact the seller directly.';
    }
    
    // Sizing and measurements
    if (lowerMessage.match(/(size|sizing|fit|measurement|sukat|laki|small|medium|large|xl)/i)) {
        return 'Size Guide:\n\n📏 Each product has a detailed size chart\n📐 Click "Size Guide" on the product page\n👕 Measurements include chest, waist, length, etc.\n\nTips:\n• Check the size chart before ordering\n• Read customer reviews for fit feedback\n• Contact seller for specific measurements\n• Free exchanges available for wrong sizes\n\nNeed help choosing a size? Tell me your measurements!';
    }
    
    // Product quality and authenticity
    if (lowerMessage.match(/(quality|authentic|original|legit|totoo ba|authentic ba|original ba)/i)) {
        return 'Quality Assurance:\n\n✅ All sellers are verified\n✅ Products undergo quality checks\n✅ 100% authentic guarantee\n✅ Customer reviews and ratings available\n\nWe ensure:\n• High-quality materials\n• Accurate product descriptions\n• Authentic branded items\n• Buyer protection policy\n\nIf you receive a defective or fake item, we offer full refund + return shipping!';
    }
    
    // Account and registration
    if (lowerMessage.match(/(account|register|sign up|login|password|forgot password|create account)/i)) {
        return 'Account Help:\n\n🔐 Create Account: Click "Register" → Fill in details → Verify email\n🔑 Login Issues: Use "Forgot Password" to reset\n📧 Email Verification: Check spam folder if not received\n👤 Update Profile: Go to Profile → Edit Information\n\nBenefits of having an account:\n• Track orders easily\n• Save addresses\n• Wishlist items\n• Exclusive deals and promotions';
    }
    
    // Promotions and discounts
    if (lowerMessage.match(/(promo|discount|sale|voucher|coupon|code|may sale|may discount)/i)) {
        return 'Current Promotions:\n\n🎉 Check our homepage for featured deals\n🏷️ Look for products with discount badges\n💝 First-time buyer discount available\n📧 Subscribe to newsletter for exclusive codes\n\nHow to use promo codes:\n1. Add items to cart\n2. Go to checkout\n3. Enter code in "Promo Code" field\n4. Click "Apply"\n\nPromo codes cannot be combined with other offers.';
    }
    
    // Seller information
    if (lowerMessage.match(/(seller|shop|store|contact seller|message seller)/i)) {
        return 'Seller Information:\n\n🏪 View seller profile on product page\n⭐ Check seller ratings and reviews\n💬 Contact seller directly through product page\n📦 Each seller has their own shipping policies\n\nTo become a seller:\n• Click "Become a Seller" on homepage\n• Complete registration\n• Wait for approval (1-3 days)\n• Start listing products!';
    }
    
    // Product categories
    if (lowerMessage.match(/(category|categories|what do you sell|ano meron|products)/i)) {
        return 'Our Product Categories:\n\n👔 Suits & Blazers - Executive & formal wear\n👕 Casual Wear - Everyday comfort\n🧥 Outerwear - Jackets & coats\n🏃 Activewear - Fitness & sports\n👞 Shoes & Accessories - Premium footwear\n💈 Grooming Products - Complete care\n\nAll products are premium quality menswear designed for the modern gentleman!';
    }
    
    // Wishlist
    if (lowerMessage.match(/(wishlist|favorite|save|bookmark)/i)) {
        return 'Wishlist Feature:\n\n❤️ Click the heart icon on any product\n📋 View all saved items in "Wishlist"\n🔔 Get notified when items go on sale\n🔔 Alerts when out-of-stock items are available\n\nYou must be logged in to use the Wishlist feature.';
    }
    
    // Cart issues
    if (lowerMessage.match(/(cart|add to cart|checkout|hindi ma-add|cant add)/i)) {
        return 'Cart & Checkout Help:\n\n🛒 Click "Add to Cart" on product page\n🎨 Select color and size before adding\n📝 Review items in cart before checkout\n✏️ Update quantities or remove items anytime\n\nCheckout process:\n1. Review cart items\n2. Enter shipping address\n3. Choose payment method\n4. Confirm order\n\nIf you can\'t add items, the product may be out of stock or you need to select size/color first.';
    }
    
    // Delivery issues
    if (lowerMessage.match(/(late|delayed|not received|hindi dumating|tagal|matagal)/i)) {
        return 'Delivery Issues:\n\n⏰ Standard delivery: 3-5 business days\n📍 Track your order for real-time updates\n\nIf your order is delayed:\n1. Check tracking status\n2. Contact the courier (tracking number provided)\n3. Contact seller through order page\n4. File a report if not received after expected date\n\nWe\'ll help resolve any delivery issues. Your satisfaction is our priority!';
    }
    
    // Contact and support
    if (lowerMessage.match(/(contact|support|help|customer service|email|phone|number)/i)) {
        return 'Contact Us:\n\n📧 Email: support@mstyle.com\n📞 Phone: (02) 1234-5678\n💬 Live Chat: Available Mon-Sat, 9AM-6PM\n📍 Office: Manila, Philippines\n\nResponse time:\n• Chat: Immediate\n• Email: Within 24 hours\n• Phone: Business hours only\n\nWe\'re here to help! 😊';
    }
    
    // Business hours
    if (lowerMessage.match(/(hours|open|close|available|schedule|operating hours)/i)) {
        return 'Business Hours:\n\n🕐 Monday - Saturday: 9:00 AM - 6:00 PM\n🕐 Sunday: Closed\n\n💬 Live Chat Support: Mon-Sat, 9AM-6PM\n📧 Email Support: 24/7 (response within 24 hours)\n📦 Order Processing: Mon-Sat\n\nOrders placed on Sunday will be processed on Monday.';
    }
    
    // Complaints or problems
    if (lowerMessage.match(/(problem|issue|complaint|wrong|defective|damaged|sira|mali)/i)) {
        return 'We\'re sorry to hear that! 😔\n\nTo resolve your issue:\n\n1. Go to your Orders page\n2. Select the problematic order\n3. Click "Report Issue"\n4. Upload photos and describe the problem\n5. Our team will respond within 24 hours\n\nFor urgent issues:\n• Contact us directly: support@mstyle.com\n• Call: (02) 1234-5678\n\nWe\'ll make it right! Your satisfaction is guaranteed.';
    }
    
    // Price inquiries
    if (lowerMessage.match(/(price|cost|magkano|how much|presyo)/i)) {
        return 'Pricing Information:\n\n💰 Prices are displayed on each product page\n🏷️ Look for items with discount badges for sales\n💳 All prices are in Philippine Peso (₱)\n📦 Shipping fee calculated at checkout\n\nPrice includes:\n• Product cost\n• Taxes (if applicable)\n\nShipping fee is separate and based on your location.';
    }
    
    // Default response with helpful suggestions
    return 'I\'m here to help! I can assist you with:\n\n📦 Order tracking and status\n🚚 Shipping and delivery info\n↩️ Returns and refunds\n💳 Payment methods\n📏 Size guides\n🏷️ Promotions and discounts\n👔 Product information\n\nPlease tell me what you need help with, and I\'ll provide detailed information!';
}

// Handle Enter key press
document.addEventListener('DOMContentLoaded', function() {
    const chatInput = document.getElementById('chatMessageInput');
    if (chatInput) {
        chatInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });
    }
});

// Close chat modal when clicking outside
document.addEventListener('click', function (e) {
    const chatModal = document.getElementById('chatSupportModal');
    const chatBtn = document.getElementById('chatSupportBtn');

    if (chatModal && chatBtn &&
        chatModal.style.display === 'block' &&
        !chatModal.contains(e.target) &&
        !chatBtn.contains(e.target)) {
        toggleChatSupport();
    }
});


