// Login First Modal JavaScript Functions

// Show the login first modal
function showLoginFirstModal() {
    console.log('=== showLoginFirstModal CALLED ===');
    
    const modal = document.getElementById('loginFirstModal');
    console.log('Modal element:', modal);
    
    if (modal) {
        console.log('Modal found! Adding show class...');
        modal.classList.add('show');
        modal.setAttribute('aria-hidden', 'false');
        modal.style.display = 'flex'; // Force display
        console.log('Modal classes:', Array.from(modal.classList));
        console.log('Modal display:', modal.style.display);
        console.log('Modal should now be visible!');
    } else {
        console.error('❌ Login modal NOT FOUND!');
    }
}

// Close the login first modal
function closeLoginFirstModal() {
    const modal = document.getElementById('loginFirstModal');
    if (modal) {
        modal.classList.remove('show');
        modal.setAttribute('aria-hidden', 'true');
        modal.style.display = 'none';
    }
}

// Redirect to login page
function goToLogin() {
    window.location.href = "/login";
}

// Redirect to register page
function goToRegister() {
    window.location.href = "/register";
}

// Close modal when clicking outside
window.addEventListener('click', function(event) {
    const modal = document.getElementById('loginFirstModal');
    if (event.target === modal) {
        closeLoginFirstModal();
    }
});

// Close modal on Escape key
window.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('loginFirstModal');
        if (modal && modal.classList.contains('show')) {
            closeLoginFirstModal();
        }
    }
});

// Test function to manually trigger modal (for debugging)
window.testModal = function() {
    console.log('=== TESTING MODAL ===');
    showLoginFirstModal();
};

// Check if modal exists when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('=== Login Modal JS Loaded ===');
    const modal = document.getElementById('loginFirstModal');
    console.log('Modal element found:', modal ? 'YES' : 'NO');
    if (modal) {
        console.log('Modal initial display:', window.getComputedStyle(modal).display);
    }
});
