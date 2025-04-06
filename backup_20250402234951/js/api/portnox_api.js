/**
 * Portnox API Integration for Dot1Xer Supreme
 * Allows integration with Portnox NAC solutions
 */

// Portnox API configuration
const portnoxConfig = {
    apiUrl: "",
    apiKey: "",
    username: "",
    password: "",
    useApiKey: true // If false, use username/password authentication
};

// Set Portnox API configuration
function setPortnoxConfig(config) {
    Object.assign(portnoxConfig, config);
    
    // Store in localStorage
    try {
        const encryptedConfig = btoa(JSON.stringify({
            apiUrl: config.apiUrl,
            username: config.username,
            useApiKey: config.useApiKey
        }));
        localStorage.setItem("dot1xer_portnox_config", encryptedConfig);
        
        // Store credentials separately (more secure)
        if (config.apiKey) {
            localStorage.setItem("dot1xer_portnox_key", btoa(config.apiKey));
        }
        if (config.password) {
            localStorage.setItem("dot1xer_portnox_pwd", btoa(config.password));
        }
        
        console.log("Portnox configuration saved");
        
        // Trigger an event to notify listeners that Portnox config has been updated
        const event = new CustomEvent('portnoxConfigUpdated', { 
            detail: { configured: isPortnoxConfigured() } 
        });
        document.dispatchEvent(event);
        
        return true;
    } catch (error) {
        console.error(`Error saving Portnox configuration: ${error}`);
        return false;
    }
}

// Get Portnox API configuration
function getPortnoxConfig() {
    // Check memory first
    if (portnoxConfig.apiUrl) {
        return portnoxConfig;
    }
    
    // Try localStorage
    try {
        const encryptedConfig = localStorage.getItem("dot1xer_portnox_config");
        const encryptedKey = localStorage.getItem("dot1xer_portnox_key");
        const encryptedPwd = localStorage.getItem("dot1xer_portnox_pwd");
        
        if (encryptedConfig) {
            const config = JSON.parse(atob(encryptedConfig));
            Object.assign(portnoxConfig, config);
            
            if (encryptedKey) {
                portnoxConfig.apiKey = atob(encryptedKey);
            }
            if (encryptedPwd) {
                portnoxConfig.password = atob(encryptedPwd);
            }
            
            return portnoxConfig;
        }
    } catch (error) {
        console.error(`Error retrieving Portnox configuration: ${error}`);
    }
    
    return portnoxConfig;
}

// Check if Portnox API is configured
function isPortnoxConfigured() {
    const config = getPortnoxConfig();
    return config.apiUrl && ((config.useApiKey && config.apiKey) || (!config.useApiKey && config.username && config.password));
}

// Clear Portnox configuration
function clearPortnoxConfig() {
    portnoxConfig.apiUrl = "";
    portnoxConfig.apiKey = "";
    portnoxConfig.username = "";
    portnoxConfig.password = "";
    portnoxConfig.useApiKey = true;
    
    localStorage.removeItem("dot1xer_portnox_config");
    localStorage.removeItem("dot1xer_portnox_key");
    localStorage.removeItem("dot1xer_portnox_pwd");
    
    console.log("Portnox configuration cleared");
    
    // Trigger an event to notify listeners that Portnox config has been updated
    const event = new CustomEvent('portnoxConfigUpdated', { 
        detail: { configured: false } 
    });
    document.dispatchEvent(event);
    
    return true;
}

// Make authenticated Portnox API call
async function callPortnoxApi(endpoint, method = "GET", body = null) {
    const config = getPortnoxConfig();
    let token;
    
    if (!config.apiUrl) {
        throw new Error("Portnox API URL not configured");
    }
    
    if (config.useApiKey) {
        if (!config.apiKey) {
            throw new Error("Portnox API key not configured");
        }
        token = config.apiKey;
    } else {
        if (!config.username || !config.password) {
            throw new Error("Portnox credentials not configured");
        }
        
        // Get authentication token
        const authResponse = await fetch(`${config.apiUrl}/api/auth/token`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                username: config.username,
                password: config.password
            })
        });
        
        if (!authResponse.ok) {
            throw new Error(`Portnox authentication error: ${authResponse.status} ${authResponse.statusText}`);
        }
        
        const authData = await authResponse.json();
        token = authData.token;
    }
    
    // Make API call
    const url = `${config.apiUrl}/api/${endpoint}`;
    const headers = { "Content-Type": "application/json" };
    
    if (config.useApiKey) {
        headers["X-API-Key"] = token;
    } else {
        headers["Authorization"] = `Bearer ${token}`;
    }
    
    const options = { method, headers };
    if (body && (method === "POST" || method === "PUT" || method === "PATCH")) {
        options.body = JSON.stringify(body);
    }
    
    const response = await fetch(url, options);
    if (!response.ok) {
        throw new Error(`Portnox API error: ${response.status} ${response.statusText}`);
    }
    
    return await response.json();
}

// Get network devices from Portnox
async function getNetworkDevices() {
    return callPortnoxApi("network-devices");
}

// Get endpoints from Portnox
async function getEndpoints() {
    return callPortnoxApi("endpoints");
}

// Get access policies from Portnox
async function getAccessPolicies() {
    return callPortnoxApi("access-policies");
}

// Apply configuration to network device
async function applyConfiguration(deviceId, config) {
    return callPortnoxApi(`network-devices/${deviceId}/config`, "POST", { config });
}

// Test Portnox connection
async function testPortnoxConnection() {
    try {
        // Try a simple API call to verify connection
        await callPortnoxApi("status");
        return { success: true, message: "Connection successful" };
    } catch (error) {
        return { success: false, message: `Connection failed: ${error.message}` };
    }
}

// Initialize Portnox config status
function initPortnoxStatus() {
    const configured = isPortnoxConfigured();
    console.log(`Portnox API: ${configured ? 'Configured' : 'Not configured'}`);
    
    // Trigger event with status
    const event = new CustomEvent('portnoxConfigUpdated', { 
        detail: { configured } 
    });
    document.dispatchEvent(event);
}

// Initialize when module is loaded
if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPortnoxStatus);
    } else {
        initPortnoxStatus();
    }
}

// Export functions for use in other modules
window.portnoxConfig = portnoxConfig;
window.setPortnoxConfig = setPortnoxConfig;
window.getPortnoxConfig = getPortnoxConfig;
window.isPortnoxConfigured = isPortnoxConfigured;
window.clearPortnoxConfig = clearPortnoxConfig;
window.getNetworkDevices = getNetworkDevices;
window.getEndpoints = getEndpoints;
window.getAccessPolicies = getAccessPolicies;
window.applyConfiguration = applyConfiguration;
window.testPortnoxConnection = testPortnoxConnection;

if (typeof module !== 'undefined') {
    module.exports = {
        portnoxConfig,
        setPortnoxConfig,
        getPortnoxConfig,
        isPortnoxConfigured,
        clearPortnoxConfig,
        callPortnoxApi,
        getNetworkDevices,
        getEndpoints,
        getAccessPolicies,
        applyConfiguration,
        testPortnoxConnection
    };
}
