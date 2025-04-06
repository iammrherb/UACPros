/**
 * AI Integration for Dot1Xer Supreme
 * Provides AI-assisted configuration generation and troubleshooting
 */

// API configuration
const aiConfig = {
    providers: {
        openai: {
            name: "OpenAI",
            apiUrl: "https://api.openai.com/v1/chat/completions",
            models: ["gpt-4", "gpt-3.5-turbo"],
            defaultModel: "gpt-3.5-turbo"
        },
        anthropic: {
            name: "Anthropic",
            apiUrl: "https://api.anthropic.com/v1/messages",
            models: ["claude-3-opus-20240229", "claude-3-sonnet-20240229", "claude-3-haiku-20240307"],
            defaultModel: "claude-3-haiku-20240307"
        },
        google: {
            name: "Google AI",
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
            
            // Trigger an event to notify listeners that an API key has been updated
            const event = new CustomEvent('apiKeyUpdated', { 
                detail: { provider, configured: true } 
            });
            document.dispatchEvent(event);
            
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

// Check if API key is set for a provider
function hasApiKey(provider) {
    return getApiKey(provider) !== null;
}

// Clear API key for a provider
function clearApiKey(provider) {
    if (aiConfig.providers[provider]) {
        apiKeys[provider] = null;
        localStorage.removeItem(`dot1xer_${provider}_key`);
        console.log(`API key for ${provider} cleared`);
        
        // Trigger an event to notify listeners that an API key has been updated
        const event = new CustomEvent('apiKeyUpdated', { 
            detail: { provider, configured: false } 
        });
        document.dispatchEvent(event);
        
        return true;
    }
    return false;
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
    const prompt = `I need to configure 802.1X authentication on a network device using a template. Please review my template variables and provide recommended values with explanations for each.

Template: ${template.name}
Description: ${template.description}

Here are the current variable settings:
${JSON.stringify(variables, null, 2)}

For each variable, please:
1. Confirm if the value is appropriate or suggest a better value
2. Explain why your recommendation is secure and follows best practices
3. Highlight any potential security risks with the current configuration

Please focus on security best practices for enterprise networks. Format your response as a list of recommendations.`;

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
        const error = await response.json().catch(() => ({}));
        throw new Error(`OpenAI API error: ${response.status} ${response.statusText} - ${error.error?.message || 'Unknown error'}`);
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
        const error = await response.json().catch(() => ({}));
        throw new Error(`Anthropic API error: ${response.status} ${response.statusText} - ${error.error?.message || 'Unknown error'}`);
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
        const error = await response.json().catch(() => ({}));
        throw new Error(`Google AI API error: ${response.status} ${response.statusText} - ${error.error?.message || 'Unknown error'}`);
    }
    
    const data = await response.json();
    return data.candidates[0].content.parts[0].text;
}

// Get AI-assisted troubleshooting help
async function getTroubleshootingHelp(problem, device, provider = aiConfig.defaultProvider) {
    const apiKey = getApiKey(provider);
    if (!apiKey) {
        throw new Error(`API key not set for ${provider}`);
    }
    
    const model = aiConfig.providers[provider].defaultModel;
    
    // Create prompt
    const prompt = `I'm having an issue with 802.1X authentication on a ${device} device. Here's the problem:
${problem}

Please provide troubleshooting steps, potential causes, and solutions to resolve this issue. Include specific commands to run for diagnostics if applicable.`;

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

// Get security review of configuration
async function getSecurityReview(config, deviceType, provider = aiConfig.defaultProvider) {
    const apiKey = getApiKey(provider);
    if (!apiKey) {
        throw new Error(`API key not set for ${provider}`);
    }
    
    const model = aiConfig.providers[provider].defaultModel;
    
    // Create prompt
    const prompt = `Please review this ${deviceType} configuration for security best practices and potential issues:

\`\`\`
${config}
\`\`\`

Please provide:
1. Security assessment - rate the overall security level (Low/Medium/High)
2. Potential vulnerabilities or misconfigurations
3. Recommended improvements
4. Best practices that are already implemented correctly

Focus on authentication, authorization, and accounting aspects.`;

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

// Initialize API key status
function initApiKeyStatus() {
    // Check status for each provider
    for (const provider in aiConfig.providers) {
        const hasKey = hasApiKey(provider);
        console.log(`API key for ${provider}: ${hasKey ? 'Configured' : 'Not configured'}`);
        
        // Trigger event with status
        const event = new CustomEvent('apiKeyUpdated', { 
            detail: { provider, configured: hasKey } 
        });
        document.dispatchEvent(event);
    }
}

// Initialize when module is loaded
if (typeof document !== 'undefined') {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initApiKeyStatus);
    } else {
        initApiKeyStatus();
    }
}

// Export functions for use in other modules
window.aiConfig = aiConfig;
window.setApiKey = setApiKey;
window.getApiKey = getApiKey;
window.hasApiKey = hasApiKey;
window.clearApiKey = clearApiKey;
window.generateConfigurationWithAI = generateConfigurationWithAI;
window.getTroubleshootingHelp = getTroubleshootingHelp;
window.getSecurityReview = getSecurityReview;

if (typeof module !== 'undefined') {
    module.exports = {
        aiConfig,
        setApiKey,
        getApiKey,
        hasApiKey,
        clearApiKey,
        generateConfigurationWithAI,
        getTroubleshootingHelp,
        getSecurityReview
    };
}
