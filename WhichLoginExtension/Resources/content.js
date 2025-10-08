// content.js - Content script for WhichLogin extension

(function() {
    'use strict';
    
    console.log('WhichLogin content script loaded');
    
    // Provider detection patterns
    const providerPatterns = [
        { key: 'apple', regex: /apple/i, hosts: ['appleid.apple.com'] },
        { key: 'google', regex: /google/i, hosts: ['accounts.google.com'] },
        { key: 'microsoft', regex: /(microsoft|azure|outlook)/i, hosts: ['login.microsoftonline.com'] },
        { key: 'github', regex: /github/i, hosts: ['github.com'] },
        { key: 'facebook', regex: /facebook/i, hosts: ['facebook.com'] },
        { key: 'linkedin', regex: /linkedin/i, hosts: ['linkedin.com'] }
    ];
    
    // Detect if this is a login page
    function isLoginPage() {
        // Check for password fields
        const hasPasswordField = document.querySelector('input[type="password"]') !== null;
        
        // Check for login-related text
        const bodyText = document.body.innerText.toLowerCase();
        const hasLoginText = /sign\s*in|log\s*in|login|sign\s*up|register/.test(bodyText);
        
        // Check for OAuth buttons
        const hasOAuthButtons = detectProviderButtons().length > 0;
        
        return hasPasswordField || (hasLoginText && hasOAuthButtons);
    }
    
    // Detect provider buttons on the page
    function detectProviderButtons() {
        const buttons = [];
        const elements = document.querySelectorAll('button, a, [role="button"]');
        
        elements.forEach(el => {
            const text = (el.textContent || '') + ' ' + 
                        (el.getAttribute('aria-label') || '') + ' ' + 
                        (el.getAttribute('title') || '') + ' ' +
                        (el.className || '');
            
            for (const pattern of providerPatterns) {
                if (pattern.regex.test(text)) {
                    buttons.push({
                        element: el,
                        provider: pattern.key
                    });
                    break;
                }
            }
        });
        
        return buttons;
    }
    
    // Attach click listeners to provider buttons
    function attachProviderListeners() {
        const buttons = detectProviderButtons();
        
        buttons.forEach(({ element, provider }) => {
            element.addEventListener('click', () => {
                console.log('Provider button clicked:', provider);
                recordLogin(provider);
            }, { once: true });
        });
        
        // Also detect email/password submission
        const forms = document.querySelectorAll('form');
        forms.forEach(form => {
            const hasPassword = form.querySelector('input[type="password"]');
            if (hasPassword) {
                form.addEventListener('submit', () => {
                    console.log('Password form submitted');
                    recordLogin('email_password');
                }, { once: true });
            }
        });
    }
    
    // Record login method
    function recordLogin(method) {
        const site = window.location.hostname;
        
        browser.runtime.sendMessage({
            type: 'recordLogin',
            site: site,
            method: method
        }).then(response => {
            console.log('Login recorded:', response);
        }).catch(error => {
            console.error('Error recording login:', error);
        });
    }
    
    // Show hint for returning users
    async function showHint() {
        const site = window.location.hostname;
        
        try {
            // Get preference
            const preference = await browser.runtime.sendMessage({
                type: 'getPreference',
                site: site
            });
            
            if (!preference.found || preference.ignored) {
                return;
            }
            
            // Get settings
            const settings = await browser.runtime.sendMessage({
                type: 'getSettings'
            });
            
            if (!settings.showHint) {
                return;
            }
            
            // Create and show hint
            createHintElement(preference.method, settings);
            
        } catch (error) {
            console.error('Error showing hint:', error);
        }
    }
    
    // Create hint element
    function createHintElement(method, settings) {
        // Check if hint already exists
        if (document.getElementById('whichlogin-hint')) {
            return;
        }
        
        const methodNames = {
            apple: 'Apple',
            google: 'Google',
            microsoft: 'Microsoft',
            github: 'GitHub',
            facebook: 'Facebook',
            linkedin: 'LinkedIn',
            email_password: 'Email/Password',
            magic_link: 'Magic Link',
            sms_otp: 'SMS/OTP',
            other: 'Other'
        };
        
        const hint = document.createElement('div');
        hint.id = 'whichlogin-hint';
        hint.setAttribute('role', 'status');
        hint.setAttribute('aria-live', 'polite');
        
        // Position based on settings
        const positions = {
            bottom_right: { bottom: '12px', right: '12px' },
            bottom_left: { bottom: '12px', left: '12px' },
            top_right: { top: '12px', right: '12px' },
            top_left: { top: '12px', left: '12px' }
        };
        
        const position = positions[settings.hintPosition] || positions.bottom_right;
        
        // Styles
        Object.assign(hint.style, {
            position: 'fixed',
            ...position,
            zIndex: '999999',
            backgroundColor: 'rgba(0, 0, 0, 0.9)',
            color: 'white',
            padding: '12px 16px',
            borderRadius: '8px',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.3)',
            fontSize: '14px',
            fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            maxWidth: '300px',
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            animation: 'whichlogin-slide-in 0.3s ease-out'
        });
        
        hint.innerHTML = `
            <span>You last signed in here with <strong>${methodNames[method] || method}</strong></span>
            <button id="whichlogin-dismiss" style="
                background: transparent;
                border: none;
                color: white;
                cursor: pointer;
                padding: 4px;
                font-size: 16px;
                line-height: 1;
            " aria-label="Dismiss">×</button>
        `;
        
        // Add animation keyframes
        if (!document.getElementById('whichlogin-styles')) {
            const style = document.createElement('style');
            style.id = 'whichlogin-styles';
            style.textContent = `
                @keyframes whichlogin-slide-in {
                    from {
                        opacity: 0;
                        transform: translateY(10px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }
            `;
            document.head.appendChild(style);
        }
        
        document.body.appendChild(hint);
        
        // Dismiss button
        const dismissBtn = hint.querySelector('#whichlogin-dismiss');
        dismissBtn.addEventListener('click', () => {
            hint.remove();
        });
        
        // Auto-dismiss after timeout
        setTimeout(() => {
            if (hint.parentNode) {
                hint.style.transition = 'opacity 0.3s ease-out';
                hint.style.opacity = '0';
                setTimeout(() => hint.remove(), 300);
            }
        }, settings.hintTimeoutMs || 6000);
        
        // Dismiss on Escape key
        const escapeHandler = (e) => {
            if (e.key === 'Escape' && hint.parentNode) {
                hint.remove();
                document.removeEventListener('keydown', escapeHandler);
            }
        };
        document.addEventListener('keydown', escapeHandler);
    }
    
    // Initialize
    function init() {
        if (!isLoginPage()) {
            console.log('Not a login page, skipping');
            return;
        }
        
        console.log('Login page detected');
        
        // Attach listeners
        attachProviderListeners();
        
        // Show hint if returning user
        showHint();
    }
    
    // Run on DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    
})();
