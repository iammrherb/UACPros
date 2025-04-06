function createApiConfigUI() {
    const container = document.getElementById('api-config-container');
    if (!container) return;
    
    container.innerHTML = `
        <div class="api-settings">
            <h2>API Configuration</h2>
            <div class="form-group">
                <label for="openai-key">OpenAI API Key</label>
                <input type="password" id="openai-key">
                <button onclick="window.setApiKey('openai', document.getElementById('openai-key').value)">Save</button>
            </div>
            <div class="form-group">
                <label for="portnox-url">Portnox API URL</label>
                <input type="text" id="portnox-url">
                <label for="portnox-key">Portnox API Key</label>
                <input type="password" id="portnox-key">
                <button onclick="window.setPortnoxConfig({apiUrl: document.getElementById('portnox-url').value, apiKey: document.getElementById('portnox-key').value})">Save</button>
            </div>
        </div>
    `;
}

document.addEventListener('DOMContentLoaded', createApiConfigUI);
