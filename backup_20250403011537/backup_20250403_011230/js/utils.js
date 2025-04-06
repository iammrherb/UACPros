// Dot1Xer Supreme - Utility Functions

function setupAuthMethodOptions() {
    const authMethodSelect = document.getElementById('auth-method');
    if (authMethodSelect) {
        authMethodSelect.addEventListener('change', function() {
            const mabCheckbox = document.getElementById('use-mab');
            if (mabCheckbox) {
                if (this.value === 'dot1x-only') {
                    mabCheckbox.checked = false;
                    mabCheckbox.disabled = true;
                } else if (this.value === 'mab-only') {
                    mabCheckbox.checked = true;
                    mabCheckbox.disabled = true;
                } else {
                    mabCheckbox.checked = true;
                    mabCheckbox.disabled = false;
                }
            }
        });
    }
}

function setupAPIIntegrations() {
    const apiKeyInput = document.getElementById('ai-api-key');
    const apiModelSelect = document.getElementById('ai-model');
    const apiTestButton = document.getElementById('ai-test-button');
    if (apiTestButton) {
        apiTestButton.addEventListener('click', function() {
            const apiKey = apiKeyInput ? apiKeyInput.value : '';
            const apiModel = apiModelSelect ? apiModelSelect.value : 'default';
            if (!apiKey) {
                showError('Please enter a valid API key.');
                return;
            }
            this.textContent = 'Testing...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Test Connection';
                this.disabled = false;
                showSuccess('API connection successful! AI assistance is now enabled.');
                const aiCapabilities = document.getElementById('ai-capabilities');
                if (aiCapabilities) {
                    aiCapabilities.style.display = 'block';
                }
            }, 1500);
        });
    }
}

function showError(message) {
    const errorElement = document.getElementById('error-message');
    if (errorElement) {
        errorElement.textContent = message;
        errorElement.style.display = 'block';
        setTimeout(() => {
            errorElement.style.display = 'none';
        }, 5000);
    } else {
        alert(message);
    }
}

function showSuccess(message) {
    const successElement = document.getElementById('success-message');
    if (successElement) {
        successElement.textContent = message;
        successElement.style.display = 'block';
        setTimeout(() => {
            successElement.style.display = 'none';
        }, 5000);
    } else {
        alert(message);
    }
}

function downloadConfiguration() {
    const config = document.getElementById('config-output').textContent;
    if (!config) {
        showError('Please generate a configuration first');
        return;
    }
    const vendor = document.getElementById('vendor-select').value;
    const platform = document.getElementById('platform-select').value;
    
    // Include project details in filename if available
    let prefix = '';
    const includeProjectDetails = document.getElementById('project-detail-toggle')?.checked;
    if (includeProjectDetails) {
        const companyName = document.getElementById('company-name').value;
        if (companyName) {
            prefix = companyName.replace(/[^a-zA-Z0-9]/g, '_') + '_';
        }
    }
    
    const blob = new Blob([config], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${prefix}${vendor}_${platform}_802.1x_config.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function copyConfiguration() {
    const config = document.getElementById('config-output').textContent;
    if (!config) {
        showError('Please generate a configuration first');
        return;
    }
    navigator.clipboard.writeText(config)
        .then(() => {
            const copyBtn = document.getElementById('copy-btn');
            const originalText = copyBtn.textContent;
            copyBtn.textContent = 'Copied!';
            setTimeout(() => copyBtn.textContent = originalText, 2000);
        })
        .catch(err => showError('Failed to copy: ' + err));
}

// AI query function
function sendAIQuery() {
    const query = document.getElementById('ai-query').value;
    const provider = document.getElementById('ai-provider').value;
    const chatHistory = document.getElementById('chat-history');
    if (!query.trim()) return;
    
    // Add user message
    chatHistory.innerHTML += `
        <div class="user-message">
            <div class="message-avatar"><img src="assets/images/user-avatar.png" alt="User"></div>
            <div class="message-content"><p>${query}</p></div>
        </div>
    `;
    
    // Add thinking indicator
    chatHistory.innerHTML += `
        <div class="ai-message thinking">
            <div class="message-avatar"><img src="assets/images/ai-avatar.png" alt="AI"></div>
            <div class="message-content"><p>Thinking...</p></div>
        </div>
    `;
    chatHistory.scrollTop = chatHistory.scrollHeight;
    
    // Clear input
    document.getElementById('ai-query').value = '';
    
    // Simulate AI response (replace with actual API call in production)
    setTimeout(() => {
        const thinkingElement = document.querySelector('.ai-message.thinking');
        if (thinkingElement) thinkingElement.remove();
        
        // Vendor-specific responses
        let response = '';
        const vendor = document.getElementById('vendor-select').value;
        const authMethod = document.getElementById('auth-method').value;
        
        if (query.toLowerCase().includes('review') || query.toLowerCase().includes('check')) {
            response = `I've reviewed your configuration and here are my findings:\n\n`;
            
            // Vendor-specific recommendations
            if (vendor === 'cisco') {
                response += `1. Your Cisco configuration includes IBNS 2.0 policy maps, which is excellent for granular control.\n\n`;
                response += `2. Make sure to enable Change of Authorization (CoA) for dynamic policy updates.\n\n`;
                if (authMethod.includes('mab')) {
                    response += `3. You've configured MAB which is good for devices that don't support 802.1X natively.\n\n`;
                }
                response += `4. Consider adding a critical VLAN for RADIUS server failure scenarios.`;
            } else if (vendor === 'aruba') {
                response += `1. Your Aruba configuration looks good with proper port-access authenticator settings.\n\n`;
                response += `2. Consider using ClearPass for enhanced policy enforcement.\n\n`;
                if (authMethod.includes('mab')) {
                    response += `3. The MAC authentication precedence is correctly configured before dot1x.\n\n`;
                }
                response += `4. Ensure you have a guest VLAN configured for unauthenticated devices.`;
            } else {
                response += `1. Your ${vendor} configuration follows best practices for 802.1X deployment.\n\n`;
                response += `2. Consider starting with monitor mode before enforcing strict authentication.\n\n`;
                response += `3. Make sure to test thoroughly with various device types before full deployment.`;
            }
        } else if (query.toLowerCase().includes('ibns') || query.toLowerCase().includes('policy')) {
            response = `IBNS 2.0 (Identity-Based Networking Services) is Cisco's framework for identity-based network access control. It uses policy maps to define authentication and authorization behavior in a more flexible way than traditional 802.1X configurations.\n\n`;
            response += `Key components include:\n\n`;
            response += `1. Class maps that match conditions like authentication status\n`;
            response += `2. Policy maps that define actions based on those conditions\n`;
            response += `3. Support for multiple authentication methods in priority order\n`;
            response += `4. Granular control over authentication failure handling`;
        } else if (query.toLowerCase().includes('coa') || query.toLowerCase().includes('change of authorization')) {
            response = `Change of Authorization (CoA) allows a RADIUS server to dynamically modify an active session without requiring reauthentication. This is crucial for:\n\n`;
            response += `1. Posture assessment - moving a device to a remediation VLAN if it fails compliance checks\n\n`;
            response += `2. Dynamic policy enforcement - applying new policies based on time of day or user behavior\n\n`;
            response += `3. Session termination - forcibly disconnecting a compromised device\n\n`;
            response += `For ${vendor} devices, CoA is typically configured through RADIUS server settings with the appropriate CoA port (usually 3799).`;
        } else if (query.toLowerCase().includes('mac') || query.toLowerCase().includes('mab')) {
            response = `MAC Authentication Bypass (MAB) is used for devices that don't support 802.1X natively, like printers or IoT devices. When a device connects, the switch:\n\n`;
            response += `1. Attempts 802.1X authentication first\n\n`;
            response += `2. After timeout, captures the device's MAC address\n\n`;
            response += `3. Sends the MAC as both username and password to the RADIUS server\n\n`;
            response += `4. RADIUS server authorizes or denies based on its MAC database\n\n`;
            response += `For ${vendor} devices, MAB is configured using ${getMabCommandForVendor(vendor)}`;
        } else if (query.toLowerCase().includes('radsec')) {
            response = `RadSec (RADIUS over TLS/DTLS) encrypts RADIUS traffic between the network device and RADIUS server. Benefits include:\n\n`;
            response += `1. Encryption of sensitive authentication data that would otherwise be sent in cleartext\n\n`;
            response += `2. More reliable communication using TCP instead of UDP\n\n`;
            response += `3. Support for mutual authentication using certificates\n\n`;
            response += `For ${vendor} devices, RadSec is configured using ${getRadSecCommandForVendor(vendor)}`;
        } else {
            response = `I can help you with your ${vendor} 802.1X configuration. What specific aspect would you like me to explain or improve? I can assist with:\n\n`;
            response += `1. Authentication methods (802.1X, MAB, hybrid)\n\n`;
            response += `2. RADIUS server configuration\n\n`;
            response += `3. VLAN assignments (data, voice, guest, auth-fail)\n\n`;
            response += `4. Advanced features like CoA, RadSec, or IBNS 2.0\n\n`;
            response += `5. Best practices for secure deployment`;
        }
        
        chatHistory.innerHTML += `
            <div class="ai-message">
                <div class="message-avatar"><img src="assets/images/ai-avatar.png" alt="AI"></div>
                <div class="message-content"><p>${response.replace(/\n/g, '<br>')}</p></div>
            </div>
        `;
        chatHistory.scrollTop = chatHistory.scrollHeight;
    }, 2000);
}

function getMabCommandForVendor(vendor) {
    switch (vendor) {
        case 'cisco': return '`mab` under interface configuration or in policy maps';
        case 'aruba': return '`authentication precedence mac-auth dot1x`';
        case 'juniper': return '`mac-radius` under authenticator interface';
        case 'fortinet': return '`mac-auth-bypass enable`';
        default: return 'vendor-specific MAB commands';
    }
}

function getRadSecCommandForVendor(vendor) {
    switch (vendor) {
        case 'cisco': return '`radius server server-name` and `transport tls`';
        case 'aruba': return '`radius-server host` with TLS options';
        case 'juniper': return '`access radsec` and associated TLS settings';
        default: return 'vendor-specific RadSec commands';
    }
}

function useQuerySuggestion(button) {
    const queryInput = document.getElementById('ai-query');
    if (queryInput) {
        queryInput.value = button.textContent;
        queryInput.focus();
    }
}
