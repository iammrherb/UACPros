/**
 * Dot1Xer Supreme - Templates Module
 * Version: 2.0.0
 */
function loadTemplate(vendorId, platform, container, callback) {
    let templatePath = platform === 'wired' ? `js/templates/${vendorId}/config_form.html` : `js/templates/wireless/${vendorId}/config_form.html`;
    fetch(templatePath)
        .then(response => response.ok ? response.text() : Promise.reject())
        .then(html => {
            container.innerHTML = html;
            initTemplateElements(vendorId, platform);
            if (typeof callback === 'function') callback();
        })
        .catch(() => loadGenericTemplate(vendorId, platform, container, callback));
}

function loadGenericTemplate(vendorId, platform, container, callback) {
    const vendor = (platform === 'wired' ? vendorData.wired : vendorData.wireless).find(v => v.id === vendorId);
    if (!vendor) {
        container.innerHTML = `<div class="alert alert-danger">Vendor information not found for ${vendorId}.</div>`;
        return;
    }
    container.innerHTML = platform === 'wired' ? generateGenericWiredTemplate(vendor) : generateGenericWirelessTemplate(vendor);
    initTemplateElements(vendorId, platform);
    if (typeof callback === 'function') callback();
}

function generateGenericWiredTemplate(vendor) {
    return `
        <div class="vendor-form-header">
            <h3>${vendor.name} Configuration</h3>
            <img src="assets/logos/${vendor.logo}" alt="${vendor.name}" class="vendor-logo">
        </div>
        <form id="vendor-config-form">
            <div class="form-group">
                <label for="auth_method">Authentication Method</label>
                <select class="form-control" id="auth_method" name="auth_method" required>
                    <option value="dot1x">802.1X</option>
                    <option value="dot1x_mab" selected>802.1X with MAB Fallback</option>
                    <option value="mab">MAC Authentication Bypass (MAB) Only</option>
                </select>
                <span class="form-hint">Select the authentication method</span>
            </div>
            <div class="form-group">
                <label for="primary_radius">Primary RADIUS Server</label>
                <input type="text" class="form-control" id="primary_radius" name="primary_radius" required>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-primary" id="generate-config-btn">Generate Configuration</button>
                <button type="button" class="btn btn-light" id="reset-form-btn">Reset</button>
            </div>
        </form>
    `;
}

function generateGenericWirelessTemplate(vendor) {
    return `
        <div class="vendor-form-header">
            <h3>${vendor.name} Configuration</h3>
            <img src="assets/logos/${vendor.logo}" alt="${vendor.name}" class="vendor-logo">
        </div>
        <form id="vendor-config-form">
            <div class="form-group">
                <label for="ssid_name">SSID Name</label>
                <input type="text" class="form-control" id="ssid_name" name="ssid_name" required>
            </div>
            <div class="form-group">
                <label for="auth_method">Authentication Method</label>
                <select class="form-control" id="auth_method" name="auth_method" required>
                    <option value="wpa2-enterprise" selected>WPA2-Enterprise (802.1X)</option>
                    <option value="wpa3-enterprise">WPA3-Enterprise</option>
                    <option value="wpa2-psk">WPA2-Personal</option>
                </select>
            </div>
            <div class="form-actions">
                <button type="button" class="btn btn-primary" id="generate-config-btn">Generate Configuration</button>
                <button type="button" class="btn btn-light" id="reset-form-btn">Reset</button>
            </div>
        </form>
    `;
}

function initTemplateElements(vendorId, platform) {
    // Placeholder for template-specific initialization
}
