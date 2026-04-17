// scripts.js
function confirmLogout() {
    if (confirm("Are you sure you want to logout?")) {
        // Clear any cached data
        if (window.sessionStorage) {
            sessionStorage.clear();
        }
        if (window.localStorage) {
            // Only clear app-specific data, not all localStorage
            const keysToRemove = [];
            for (let i = 0; i < localStorage.length; i++) {
                const key = localStorage.key(i);
                if (key && (key.startsWith('cart_') || key.startsWith('user_') || key.startsWith('session_'))) {
                    keysToRemove.push(key);
                }
            }
            keysToRemove.forEach(key => localStorage.removeItem(key));
        }
        
        // Redirect to logout route which will clear session and redirect to home
        window.location.href = "/logout";
    }
}

// Force page reload when navigating back after logout
window.addEventListener('pageshow', function(event) {
    // Check if page was loaded from cache (back/forward navigation)
    if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
        // Force reload to get fresh content
        window.location.reload();
    }
});

// Prevent caching on page unload
window.addEventListener('beforeunload', function() {
    // This helps ensure the page isn't cached
    document.body.style.display = 'none';
});