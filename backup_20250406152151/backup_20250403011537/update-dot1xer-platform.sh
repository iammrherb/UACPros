#!/bin/bash
# update-dot1xer-platform.sh
# =======================================================================
# Platform integration script for Dot1Xer Supreme that adds:
# - Platform menu
# - AI integration
# - Portnox API integration
# - Final index.html updates
# =======================================================================

set -e

echo "=== Dot1Xer Supreme Platform Integration ==="
echo "This script will add platform menu and API integrations."
echo

# Check if previous updates were applied
if [ ! -f "js/templates/wireless/cisco/wlc_9800.js" ]; then
    echo "Error: Template update hasn't been applied. Please run update-dot1xer-templates.sh first."
    exit 1
fi

# Add AI integration
echo "Adding AI integration..."
cat > js/api/ai_integration.js << 'EOL'
/**
 * AI Integration for Dot1Xer Supreme
 * Provides AI-assisted configuration generation and troubleshooting
 */

// API configuration
const aiConfig = {
    providers: {
        openai: {
            apiUrl: "https://api.openai.com/v1/chat/completions",
            models: ["gpt-4", "gpt-3.5-turbo"],
            defaultModel: "gpt-3.5-turbo"
        },
        anthropic: {
            apiUrl: "https://api.anthropic.com/v1/messages",
            models: ["claude-3-opus-20240229", "claude-3-sonnet-20240229", "claude-3-haiku-20240307"],
            defaultModel: "claude-3-haiku-20240307"
        },
        google: {
            apiUrl: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent",
            models: ["gemini-pro"],
            defaultModel: "gemini-pro"
        }
    },
    defaultProvider: "anthropic"
};

// Store API keys securely
let apiKeys = {};

// Set API key for a provider
function setApiKey(provider, key) {
    if (aiConfig.providers[provider]) {
        apiKeys[provider] = key;
        // Store encrypted in localStorage
        try {
            const encryptedKey = btoa(key); // Simple encoding, not true encryption
            localStorage.setItem(`dot1xer_${provider}_key`, encryptedKey);
            console.log(`API key for ${provider} saved`);
            return true;
        } catch (error) {
            console.error(`Error saving API key: ${error}`);
            return false;
        }
    }
    return false;
}

// Get API key for a provider
function getApiKey(provider) {
    // Check memory first
    if (apiKeys[provider]) {
        return apiKeys[provider];
    }
    
    // Try localStorage
    try {
        const encryptedKey = localStorage.getItem(`dot1xer_${provider}_key`);
        if (encryptedKey) {
            const key = atob(encryptedKey); // Decode
            apiKeys[provider] = key;
            return key;
        }
    } catch (error) {
        console.error(`Error retrieving API key: ${error}`);
    }
    
    return null;
}

// Generate configuration using AI
async function generateConfigurationWithAI(template, variables, provider = aiConfig.defaultProvider, model = null) {
    const apiKey = getApiKey(provider);
    if (!apiKey) {
        throw new Error(`API key not set for ${provider}`);
    }
    
    if (!model) {
        model = aiConfig.providers[provider].defaultModel;
    }
    
    // Create prompt
    const prompt = `I need to configure 802.1X authentication on a network device. I have a template with the following variables:
${JSON.stringify(variables, null, 2)}

Please provide recommended values for these variables for a typical enterprise network with 802.1X authentication. 
Consider best practices for security and explain your choices for each variable.`;

    // Make API request based on provider
    switch (provider) {
        case "openai":
            return callOpenAI(prompt, model, apiKey);
        case "anthropic":
            return callAnthropic(prompt, model, apiKey);
        case "google":
            return callGoogleAI(prompt, model, apiKey);
        default:
            throw new Error(`Unknown AI provider: ${provider}`);
    }
}

// OpenAI API call
async function callOpenAI(prompt, model, apiKey) {
    const response = await fetch(aiConfig.providers.openai.apiUrl, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${apiKey}`
        },
        body: JSON.stringify({
            model: model,
            messages: [{ role: "user", content: prompt }],
            temperature: 0.2
        })
    });
    
    if (!response.ok) {
        throw new Error(`OpenAI API error: ${response.status} ${response.statusText}`);
    }
    
    const data = await response.json();
    return data.choices[0].message.content;
}

// Anthropic API call
async function callAnthropic(prompt, model, apiKey) {
    const response = await fetch(aiConfig.providers.anthropic.apiUrl, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "x-api-key": apiKey,
            "anthropic-version": "2023-06-01"
        },
        body: JSON.stringify({
            model: model,
            messages: [{ role: "user", content: prompt }],
            max_tokens: 2000,
            temperature: 0.2
        })
    });
    
    if (!response.ok) {
        throw new Error(`Anthropic API error: ${response.status} ${response.statusText}`);
    }
    
    const data = await response.json();
    return data.content[0].text;
}

// Google AI API call
async function callGoogleAI(prompt, model, apiKey) {
    const url = `${aiConfig.providers.google.apiUrl}?key=${apiKey}`;
    
    const response = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: {
                temperature: 0.2
            }
        })
    });
    
    if (!response.ok) {
        throw new Error(`Google AI API error: ${response.status} ${response.statusText}`);
    }
    
    const data = await response.json();
    return data.candidates[0].content.parts[0].text;
}

// Export functions for use in other modules
if (typeof module !== 'undefined') {
    module.exports = {
        aiConfig,
        setApiKey,
        getApiKey,
        generateConfigurationWithAI
    };
}
EOL
echo "AI integration added."
echo

# Add Portnox API integration
echo "Adding Portnox API integration..."
cat > js/api/portnox_api.js << 'EOL'
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

// Make authenticated Portnox API call
async function callPortnoxApi(endpoint, method = "GET", body = null) {
    const config = getPortnoxConfig();
    let token;
    
    if (config.useApiKey) {
        token = config.apiKey;
    } else {
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

// Apply configuration to network device
async function applyConfiguration(deviceId, config) {
    return callPortnoxApi(`network-devices/${deviceId}/config`, "POST", { config });
}

// Export functions for use in other modules
if (typeof module !== 'undefined') {
    module.exports = {
        setPortnoxConfig,
        getPortnoxConfig,
        callPortnoxApi,
        getNetworkDevices,
        getEndpoints,
        applyConfiguration
    };
}
EOL
echo "Portnox API integration added."
echo

# Add Platform Menu
echo "Adding Platform Menu..."
cat > js/platform_menu.js << 'EOL'
/**
 * Platform Menu for Dot1Xer Supreme
 * Provides a dynamic menu for selecting vendor platforms
 */

// Define platform menu structure
const platformMenu = {
    wired: {
        name: "Wired",
        description: "Wired network devices",
        platforms: {
            "cisco-ios": {
                name: "Cisco IOS/IOS-XE",
                description: "Cisco IOS and IOS-XE platforms",
                templates: ["ibns2_ios_xe", "tacacs", "radsec", "device_tracking"]
            },
            "cisco-nx": {
                name: "Cisco NX-OS",
                description: "Cisco Nexus platforms",
                templates: ["tacacs", "dot1x_nx"]
            },
            "aruba-aoscx": {
                name: "Aruba AOS-CX",
                description: "Aruba AOS-CX switches",
                templates: ["aos_cx", "tacacs_aoscx"]
            },
            "juniper-ex": {
                name: "Juniper EX",
                description: "Juniper EX Series switches",
                templates: ["juniper_ex", "juniper_tacacs"]
            },
            "fortinet-switch": {
                name: "Fortinet FortiSwitch",
                description: "Fortinet FortiSwitch platforms",
                templates: ["fortiswitch", "forti_tacacs"]
            },
            "extreme-exos": {
                name: "Extreme EXOS",
                description: "Extreme Networks EXOS",
                templates: ["extreme_exos", "extreme_tacacs"]
            }
        }
    },
    wireless: {
        name: "Wireless",
        description: "Wireless network devices",
        platforms: {
            "cisco-wlc9800": {
                name: "Cisco WLC 9800",
                description: "Cisco 9800 Series Wireless LAN Controllers",
                templates: ["wlc_9800", "ise_wireless_dot1x"]
            },
            "cisco-wlc": {
                name: "Cisco AireOS WLC",
                description: "Cisco AireOS Wireless LAN Controllers",
                templates: ["aireos_wlc", "aireos_dot1x"]
            },
            "aruba-controller": {
                name: "Aruba Controller",
                description: "Aruba Mobility Controllers",
                templates: ["aruba_wireless", "aruba_dot1x"]
            },
            "fortinet-wireless": {
                name: "Fortinet FortiWLC",
                description: "Fortinet Wireless Controllers",
                templates: ["fortinet_wireless", "fortinet_dot1x"]
            },
            "ruckus-wireless": {
                name: "Ruckus Wireless",
                description: "Ruckus Wireless Controllers",
                templates: ["ruckus_wireless", "ruckus_dot1x"]
            },
            "meraki-wireless": {
                name: "Cisco Meraki",
                description: "Cisco Meraki wireless",
                templates: ["meraki_wireless", "meraki_dot1x"]
            },
            "ubiquiti-wireless": {
                name: "Ubiquiti UniFi",
                description: "Ubiquiti UniFi controllers",
                templates: ["unifi_wireless", "unifi_dot1x"]
            }
        }
    }
};

// Initialize platform menu
function initPlatformMenu() {
    const menuContainer = document.getElementById('platform-menu');
    if (!menuContainer) return;
    
    // Clear existing menu
    menuContainer.innerHTML = '';
    
    // Create category tabs
    const tabContainer = document.createElement('div');
    tabContainer.className = 'tabs';
    
    const tabList = document.createElement('ul');
    tabList.className = 'platform-tabs';
    
    // Create tabs for each category
    Object.keys(platformMenu).forEach((category, index) => {
        const tab = document.createElement('li');
        tab.className = index === 0 ? 'active' : '';
        tab.setAttribute('data-category', category);
        tab.textContent = platformMenu[category].name;
        
        tab.addEventListener('click', function() {
            // Deactivate all tabs
            const allTabs = tabList.querySelectorAll('li');
            allTabs.forEach(t => t.className = '');
            
            // Activate this tab
            this.className = 'active';
            
            // Show corresponding content
            const allContent = menuContainer.querySelectorAll('.platform-content');
            allContent.forEach(c => c.style.display = 'none');
            
            const contentId = `platform-${category}`;
            const content = document.getElementById(contentId);
            if (content) content.style.display = 'block';
        });
        
        tabList.appendChild(tab);
    });
    
    tabContainer.appendChild(tabList);
    menuContainer.appendChild(tabContainer);
    
    // Create content sections for each category
    Object.keys(platformMenu).forEach((category) => {
        const contentContainer = document.createElement('div');
        contentContainer.className = 'platform-content';
        contentContainer.id = `platform-${category}`;
        contentContainer.style.display = category === Object.keys(platformMenu)[0] ? 'block' : 'none';
        
        // Category description
        const description = document.createElement('p');
        description.className = 'platform-description';
        description.textContent = platformMenu[category].description;
        contentContainer.appendChild(description);
        
        // Platform grid
        const platformGrid = document.createElement('div');
        platformGrid.className = 'platform-grid';
        
        // Add platform cards
        Object.keys(platformMenu[category].platforms).forEach((platform) => {
            const card = createPlatformCard(category, platform);
            platformGrid.appendChild(card);
        });
        
        contentContainer.appendChild(platformGrid);
        menuContainer.appendChild(contentContainer);
    });
}

// Create platform card
function createPlatformCard(category, platform) {
    const platformInfo = platformMenu[category].platforms[platform];
    
    const card = document.createElement('div');
    card.className = 'platform-card';
    card.setAttribute('data-platform', platform);
    
    // Card header
    const header = document.createElement('div');
    header.className = 'platform-card-header';
    
    const title = document.createElement('h3');
    title.textContent = platformInfo.name;
    header.appendChild(title);
    
    card.appendChild(header);
    
    // Card body
    const body = document.createElement('div');
    body.className = 'platform-card-body';
    
    const description = document.createElement('p');
    description.textContent = platformInfo.description;
    body.appendChild(description);
    
    const templateCount = document.createElement('p');
    templateCount.className = 'template-count';
    templateCount.textContent = `${platformInfo.templates.length} templates available`;
    body.appendChild(templateCount);
    
    card.appendChild(body);
    
    // Card footer with select button
    const footer = document.createElement('div');
    footer.className = 'platform-card-footer';
    
    const selectButton = document.createElement('button');
    selectButton.textContent = 'Select Platform';
    selectButton.addEventListener('click', function() {
        selectPlatform(category, platform);
    });
    
    footer.appendChild(selectButton);
    card.appendChild(footer);
    
    return card;
}

// Template loading/selection functions (simplified for brevity)
function selectPlatform(category, platform) {
    console.log(`Selected platform: ${category}/${platform}`);
    const platformInfo = platformMenu[category].platforms[platform];
    alert(`You selected ${platformInfo.name}. Available templates: ${platformInfo.templates.join(', ')}`);
    
    // In a real implementation, this would load templates and show them to the user
    // For this simplified version, we just show a message
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    initPlatformMenu();
});

// Export functions for use in other modules
if (typeof module !== 'undefined') {
    module.exports = {
        platformMenu,
        initPlatformMenu,
        selectPlatform
    };
}
EOL
echo "Platform Menu added."
echo

# Create final update script
echo "Creating the final update script..."
cat > update-dot1xer.sh << 'EOL'
#!/bin/bash

# Check for dependencies
for cmd in sed awk grep; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is required but not installed. Please install it and try again."
        exit 1
    fi
done

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Update index.html with necessary script and CSS references
echo "Updating index.html..."
if grep -q "</body></html>" index.html; then
    # Update just before closing tags
    sed -i.bak '/<\/body><\/html>/d' index.html
    cat >> index.html << 'EOF'
    <!-- CSS Dependencies -->
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/accordion.css">
    <link rel="stylesheet" href="css/help_tips.css">
    
    <!-- JS Dependencies -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.7.7/handlebars.min.js"></script>
    <script src="js/accordion.js"></script>
    <script src="js/platform_menu.js"></script>
    <script src="js/help/help_tips.js"></script>
    <script src="js/api/ai_integration.js"></script>
    <script src="js/api/portnox_api.js"></script>
    
    <!-- Initialize the application -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            console.log("Dot1Xer Supreme loaded successfully");
            // Initialize accordions
            if (typeof initAccordions === 'function') {
                initAccordions();
            }
            // Initialize help tips
            if (typeof initHelpTips === 'function') {
                initHelpTips();
            }
            // Initialize platform menu
            if (typeof initPlatformMenu === 'function') {
                initPlatformMenu();
            }
        });
    </script>
</body>
</html>
EOF
    echo "index.html updated successfully."
else
    echo "Error: Could not find </body></html> tags in index.html."
fi

echo "Dot1Xer Supreme has been updated successfully!"
echo "You can now use the enhanced features including:"
echo "- Comprehensive AAA configuration templates"
echo "- Multi-vendor support for both wired and wireless"
echo "- IBNS 2.0, TACACS+, RadSec, Device Tracking configuration"
echo "- Help tips and detailed documentation"
echo "- AI-assisted configuration"
echo "- Portnox API integration"
echo
echo "Reload the application in your browser to see the changes."
EOL
chmod +x update-dot1xer.sh
echo "Final update script created and made executable."
echo

echo "=== Platform Integration Complete ==="
echo "Platform menu and integrations have been added successfully."
echo "To finalize the update, run: ./update-dot1xer.sh"
echo
echo "All Dot1Xer Supreme enhancement scripts are now ready!"