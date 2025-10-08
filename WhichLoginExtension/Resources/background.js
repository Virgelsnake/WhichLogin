// background.js - Background service worker for WhichLogin extension

// Listen for messages from content scripts
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log('Background received message:', message);
    
    if (message.type === 'getPreference') {
        handleGetPreference(message.site).then(sendResponse);
        return true; // Keep channel open for async response
    }
    
    if (message.type === 'recordLogin') {
        handleRecordLogin(message.site, message.method).then(sendResponse);
        return true;
    }
    
    if (message.type === 'getSettings') {
        handleGetSettings().then(sendResponse);
        return true;
    }
    
    return false;
});

// Handle navigation to OAuth providers
browser.webNavigation.onBeforeNavigate.addListener((details) => {
    if (details.frameId !== 0) return; // Only main frame
    
    const url = details.url;
    const provider = detectOAuthProvider(url);
    
    if (provider) {
        // Store the provider for when we return
        browser.storage.local.set({
            pendingOAuth: {
                provider: provider,
                tabId: details.tabId,
                timestamp: Date.now()
            }
        });
    }
});

// Detect OAuth provider from URL
function detectOAuthProvider(url) {
    const patterns = {
        apple: /appleid\.apple\.com\/auth/,
        google: /accounts\.google\.com\/o\/oauth2/,
        microsoft: /login\.microsoftonline\.com/,
        github: /github\.com\/login\/oauth/,
        facebook: /facebook\.com.*oauth/,
        linkedin: /linkedin\.com\/oauth/
    };
    
    for (const [provider, pattern] of Object.entries(patterns)) {
        if (pattern.test(url)) {
            return provider;
        }
    }
    
    return null;
}

// Communicate with native app
async function handleGetPreference(site) {
    try {
        const response = await browser.runtime.sendNativeMessage('application.id', {
            name: 'getPreference',
            site: site
        });
        return response;
    } catch (error) {
        console.error('Error getting preference:', error);
        return { found: false };
    }
}

async function handleRecordLogin(site, method) {
    try {
        const response = await browser.runtime.sendNativeMessage('application.id', {
            name: 'recordLogin',
            site: site,
            method: method
        });
        return response;
    } catch (error) {
        console.error('Error recording login:', error);
        return { success: false };
    }
}

async function handleGetSettings() {
    try {
        const response = await browser.runtime.sendNativeMessage('application.id', {
            name: 'getSettings'
        });
        return response;
    } catch (error) {
        console.error('Error getting settings:', error);
        return {
            showHint: true,
            hintPosition: 'bottom_right',
            hintTimeoutMs: 6000
        };
    }
}

console.log('WhichLogin background script loaded');
