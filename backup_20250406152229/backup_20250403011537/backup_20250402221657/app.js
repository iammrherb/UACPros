// Dot1Xer Supreme - Combined JavaScript Application

// Load core modules
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all components
    initAccordions();
    initTabs();
    initVendorOptions();
    initNetworkScopingOptions();
    setupAuthMethodOptions();
    setupAPIIntegrations();
    setupPortnoxIntegration();
    initProjectDetails();
    initMultiVendorSelection();

    // Show the first tab by default
    const firstTabBtn = document.querySelector('.tab-btn');
    if (firstTabBtn) {
        firstTabBtn.click();
    }

    // Show the first discovery tab by default
    const firstDiscoveryTab = document.querySelector('.discovery-tab');
    if (firstDiscoveryTab) {
        firstDiscoveryTab.click();
    }

    // Show the first reference tab by default
    const firstRefTab = document.querySelector('.ref-tab');
    if (firstRefTab) {
        firstRefTab.click();
    }

    // Show the first server tab by default
    const firstServerTab = document.querySelector('.tab-control-btn');
    if (firstServerTab) {
        firstServerTab.click();
    }

    // Show the first Portnox tab by default
    const firstPortnoxTab = document.querySelector('.portnox-nav-tab');
    if (firstPortnoxTab) {
        firstPortnoxTab.click();
    }
});

// Including all modules
// Dot1Xer Supreme - Core Functionality

// Current step in the configurator
let currentStep = 1;

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all accordions
    initAccordions();
    
    // Initialize all tabs
    initTabs();
    
    // Initialize vendor selection and platform options
    initVendorOptions();
    
    // Initialize network scoping options
    initNetworkScopingOptions();
    
    // Setup authentication method options
    setupAuthMethodOptions();
    
    // Setup API integrations for AI assistance
    setupAPIIntegrations();
    
    // Setup Portnox Cloud integration
    setupPortnoxIntegration();
    
    // Initialize project details
    initProjectDetails();
    
    // Initialize multi-vendor configuration
    initMultiVendorConfig();
    
    // Show the first tab by default
    const firstTabBtn = document.querySelector('.tab-btn');
    if (firstTabBtn) {
        firstTabBtn.click();
    }
    
    // Show the first discovery tab by default
    const firstDiscoveryTab = document.querySelector('.discovery-tab');
    if (firstDiscoveryTab) {
        firstDiscoveryTab.click();
    }
    
    // Show the first reference tab by default
    const firstRefTab = document.querySelector('.ref-tab');
    if (firstRefTab) {
        firstRefTab.click();
    }
    
    // Show the first server tab by default
    const firstServerTab = document.querySelector('.tab-control-btn');
    if (firstServerTab) {
        firstServerTab.click();
    }
    
    // Show the first Portnox tab by default
    const firstPortnoxTab = document.querySelector('.portnox-nav-tab');
    if (firstPortnoxTab) {
        firstPortnoxTab.click();
    }
});

// Initialize accordion functionality
function initAccordions() {
    const accordionHeaders = document.querySelectorAll('.accordion-header');
    accordionHeaders.forEach(header => {
        header.addEventListener('click', function() {
            const content = this.nextElementSibling;
            const icon = this.querySelector('.accordion-icon');
            const isActive = content.classList.contains('active');
            
            // Toggle the active class and visibility
            if (isActive) {
                content.classList.remove('active');
                content.style.display = 'none';
                this.classList.remove('active');
                if (icon) icon.textContent = '+';
            } else {
                content.classList.add('active');
                content.style.display = 'block';
                this.classList.add('active');
                if (icon) icon.textContent = '-';
            }
        });
    });
}

// Initialize project details section
function initProjectDetails() {
    const projectDetailToggle = document.getElementById('project-detail-toggle');
    if (projectDetailToggle) {
        projectDetailToggle.addEventListener('change', function() {
            const projectDetailsSection = document.getElementById('project-details-section');
            if (projectDetailsSection) {
                projectDetailsSection.style.display = this.checked ? 'block' : 'none';
            }
        });
    }
}

// Initialize multi-vendor configuration
function initMultiVendorConfig() {
    const multiVendorToggle = document.getElementById('multi-vendor-toggle');
    if (multiVendorToggle) {
        multiVendorToggle.addEventListener('change', function() {
            const multiVendorSection = document.getElementById('multi-vendor-section');
            if (multiVendorSection) {
                multiVendorSection.style.display = this.checked ? 'block' : 'none';
            }
        });
    }
    
    // Add vendor to multi-vendor list
    const addVendorBtn = document.getElementById('add-vendor-button');
    if (addVendorBtn) {
        addVendorBtn.addEventListener('click', function() {
            const vendor = document.getElementById('vendor-select').value;
            const platform = document.getElementById('platform-select').value;
            
            if (vendor && platform) {
                addVendorToList(vendor, platform);
            }
        });
    }
}

// Add vendor to multi-vendor list
function addVendorToList(vendor, platform) {
    const vendorList = document.getElementById('vendor-list');
    if (!vendorList) return;
    
    // Check if vendor+platform combination already exists
    const existingItems = vendorList.querySelectorAll('li');
    for (let i = 0; i < existingItems.length; i++) {
        if (existingItems[i].dataset.vendor === vendor && existingItems[i].dataset.platform === platform) {
            showError('This vendor and platform combination is already in the list.');
            return;
        }
    }
    
    const listItem = document.createElement('li');
    listItem.className = 'vendor-list-item';
    listItem.dataset.vendor = vendor;
    listItem.dataset.platform = platform;
    
    let vendorDisplay = vendor.charAt(0).toUpperCase() + vendor.slice(1);
    let platformDisplay = platform.charAt(0).toUpperCase() + platform.slice(1);
    
    listItem.innerHTML = `
        <span>${vendorDisplay} - ${platformDisplay}</span>
        <button type="button" class="remove-vendor-btn" onclick="removeVendorFromList(this)">✕</button>
    `;
    
    vendorList.appendChild(listItem);
}

// Remove vendor from multi-vendor list
function removeVendorFromList(button) {
    const listItem = button.parentElement;
    listItem.remove();
}

// Function to navigate to specific configurator step
function goToStep(step) {
    document.querySelectorAll('.step-content').forEach(content => {
        content.style.display = 'none';
    });
    document.querySelectorAll('.step').forEach(stepEl => {
        stepEl.classList.remove('active');
    });
    const stepContent = document.getElementById(`step-${step}`);
    if (stepContent) {
        stepContent.style.display = 'block';
    }
    const stepIndicator = document.querySelector(`.step[data-step="${step}"]`);
    if (stepIndicator) {
        stepIndicator.classList.add('active');
    }
    currentStep = step;
}

// Add RADIUS server
function addRadiusServer() {
    const container = document.getElementById('radius-servers');
    if (!container) return;
    
    const existingServers = container.querySelectorAll('.radius-server-entry');
    const index = existingServers.length + 1;
    
    const newServer = document.createElement('div');
    newServer.className = 'radius-server-entry';
    newServer.dataset.index = index;
    
    newServer.innerHTML = `
        <h5>RADIUS Server ${index} <button type="button" class="remove-server-btn" onclick="removeRadiusServer(this)">✕</button></h5>
        <div class="row">
            <div class="col">
                <label for="radius-ip-${index}">Server IP:</label>
                <input type="text" id="radius-ip-${index}" placeholder="e.g., 10.1.1.100">
            </div>
            <div class="col">
                <label for="radius-key-${index}">Shared Secret:</label>
                <input type="password" id="radius-key-${index}" placeholder="Shared secret">
            </div>
        </div>
        <div class="row">
            <div class="col">
                <label for="radius-auth-port-${index}">Authentication Port:</label>
                <input type="number" id="radius-auth-port-${index}" value="1812">
            </div>
            <div class="col">
                <label for="radius-acct-port-${index}">Accounting Port:</label>
                <input type="number" id="radius-acct-port-${index}" value="1813">
            </div>
            <div class="col">
                <label for="radius-coa-port-${index}">CoA Port:</label>
                <input type="number" id="radius-coa-port-${index}" value="3799">
            </div>
        </div>
        <div class="checkbox-group">
            <label>
                <input type="checkbox" id="radius-enable-coa-${index}" checked> 
                Enable Change of Authorization (CoA)
            </label>
        </div>
    `;
    
    container.appendChild(newServer);
}

// Remove RADIUS server
function removeRadiusServer(button) {
    const serverEntry = button.closest('.radius-server-entry');
    if (serverEntry && serverEntry.dataset.index !== '1') {
        serverEntry.remove();
        
        // Reindex remaining servers
        const container = document.getElementById('radius-servers');
        const serverEntries = container.querySelectorAll('.radius-server-entry');
        serverEntries.forEach((entry, index) => {
            const newIndex = index + 1;
            entry.dataset.index = newIndex;
            entry.querySelector('h5').innerHTML = `RADIUS Server ${newIndex} ${newIndex > 1 ? '<button type="button" class="remove-server-btn" onclick="removeRadiusServer(this)">✕</button>' : ''}`;
            
            const inputs = entry.querySelectorAll('input, select');
            inputs.forEach(input => {
                const oldId = input.id;
                const baseName = oldId.substring(0, oldId.lastIndexOf('-') + 1);
                input.id = baseName + newIndex;
                
                const label = entry.querySelector(`label[for="${oldId}"]`);
                if (label) {
                    label.setAttribute('for', baseName + newIndex);
                }
            });
        });
    } else if (serverEntry && serverEntry.dataset.index === '1') {
        showError('Cannot remove the primary RADIUS server.');
    }
}

// Add RadSec server
function addRadSecServer() {
    const container = document.getElementById('radsec-servers');
    if (!container) return;
    
    const existingServers = container.querySelectorAll('.radsec-server-entry');
    const index = existingServers.length + 1;
    
    const newServer = document.createElement('div');
    newServer.className = 'radsec-server-entry';
    newServer.dataset.index = index;
    
    newServer.innerHTML = `
        <h5>RadSec Server ${index} <button type="button" class="remove-server-btn" onclick="removeRadSecServer(this)">✕</button></h5>
        <div class="row">
            <div class="col">
                <label for="radsec-ip-${index}">Server IP:</label>
                <input type="text" id="radsec-ip-${index}" placeholder="e.g., 10.1.1.104">
            </div>
            <div class="col">
                <label for="radsec-key-${index}">Shared Secret:</label>
                <input type="password" id="radsec-key-${index}" placeholder="Shared secret">
            </div>
        </div>
        <div class="row">
            <div class="col">
                <label for="radsec-port-${index}">TLS Port:</label>
                <input type="number" id="radsec-port-${index}" value="2083">
            </div>
            <div class="col">
                <label for="radsec-protocol-${index}">Protocol:</label>
                <select id="radsec-protocol-${index}">
                    <option value="tls" selected>TLS</option>
                    <option value="dtls">DTLS</option>
                </select>
            </div>
        </div>
        <div class="checkbox-group">
            <label>
                <input type="checkbox" id="radsec-validate-server-${index}" checked> 
                Validate Server Certificate
            </label>
        </div>
    `;
    
    container.appendChild(newServer);
}

// Remove RadSec server
function removeRadSecServer(button) {
    const serverEntry = button.closest('.radsec-server-entry');
    if (serverEntry && serverEntry.dataset.index !== '1') {
        serverEntry.remove();
        
        // Reindex remaining servers
        const container = document.getElementById('radsec-servers');
        const serverEntries = container.querySelectorAll('.radsec-server-entry');
        serverEntries.forEach((entry, index) => {
            const newIndex = index + 1;
            entry.dataset.index = newIndex;
            entry.querySelector('h5').innerHTML = `RadSec Server ${newIndex} ${newIndex > 1 ? '<button type="button" class="remove-server-btn" onclick="removeRadSecServer(this)">✕</button>' : ''}`;
            
            const inputs = entry.querySelectorAll('input, select');
            inputs.forEach(input => {
                const oldId = input.id;
                const baseName = oldId.substring(0, oldId.lastIndexOf('-') + 1);
                input.id = baseName + newIndex;
                
                const label = entry.querySelector(`label[for="${oldId}"]`);
                if (label) {
                    label.setAttribute('for', baseName + newIndex);
                }
            });
        });
    } else if (serverEntry && serverEntry.dataset.index === '1') {
        showError('Cannot remove the primary RadSec server.');
    }
}

// Generate configuration for a single vendor
function generateSingleVendorConfig() {
    const vendor = document.getElementById('vendor-select').value;
    const platform = document.getElementById('platform-select').value;
    
    if (!vendor || !platform) {
        showError('Please select a vendor and platform.');
        return '';
    }
    
    return generateVendorConfig(vendor, platform);
}

// Generate configuration for multiple vendors
function generateMultiVendorConfig() {
    const vendorList = document.getElementById('vendor-list');
    if (!vendorList || vendorList.children.length === 0) {
        showError('No vendors selected for multi-vendor configuration.');
        return '';
    }
    
    let configs = '';
    const vendors = vendorList.querySelectorAll('.vendor-list-item');
    
    vendors.forEach(vendor => {
        const vendorName = vendor.dataset.vendor;
        const platform = vendor.dataset.platform;
        
        configs += `\n\n# ======= Configuration for ${vendorName.toUpperCase()} ${platform.toUpperCase()} =======\n\n`;
        configs += generateVendorConfig(vendorName, platform);
    });
    
    return configs;
}

// Generate configuration for a specific vendor
function generateVendorConfig(vendor, platform) {
    // Common configuration data
    const authMethod = document.getElementById('auth-method').value;
    const authMode = document.querySelector('input[name="auth_mode"]:checked').value;
    const hostMode = document.getElementById('host-mode').value;
    const dataVlan = document.getElementById('data-vlan').value;
    const voiceVlan = document.getElementById('voice-vlan').value || '';
    const guestVlan = document.getElementById('guest-vlan').value || '';
    const criticalVlan = document.getElementById('critical-vlan').value || '';
    const authFailVlan = document.getElementById('auth-fail-vlan').value || '';
    
    // Get all RADIUS servers
    const radiusServers = [];
    const radiusServerElements = document.querySelectorAll('.radius-server-entry');
    radiusServerElements.forEach(server => {
        const index = server.dataset.index;
        const ip = document.getElementById(`radius-ip-${index}`).value;
        const key = document.getElementById(`radius-key-${index}`).value;
        const authPort = document.getElementById(`radius-auth-port-${index}`).value;
        const acctPort = document.getElementById(`radius-acct-port-${index}`).value;
        const coaPort = document.getElementById(`radius-coa-port-${index}`).value;
        const enableCoA = document.getElementById(`radius-enable-coa-${index}`).checked;
        
        if (ip && key) {
            radiusServers.push({
                ip: ip,
                key: key,
                authPort: authPort,
                acctPort: acctPort,
                coaPort: coaPort,
                enableCoA: enableCoA
            });
        }
    });
    
    // Get RadSec servers
    const radsecServers = [];
    const radsecServerElements = document.querySelectorAll('.radsec-server-entry');
    radsecServerElements.forEach(server => {
        const index = server.dataset.index;
        const ip = document.getElementById(`radsec-ip-${index}`).value;
        const key = document.getElementById(`radsec-key-${index}`).value;
        const port = document.getElementById(`radsec-port-${index}`).value;
        const protocol = document.getElementById(`radsec-protocol-${index}`).value;
        const validateServer = document.getElementById(`radsec-validate-server-${index}`).checked;
        
        if (ip && key) {
            radsecServers.push({
                ip: ip,
                key: key,
                port: port,
                protocol: protocol,
                validateServer: validateServer
            });
        }
    });
    
    // Advanced options
    const useMAB = document.getElementById('use-mab').checked;
    const useCoA = document.getElementById('use-coa').checked;
    const useLocal = document.getElementById('use-local').checked;
    const reAuthPeriod = document.getElementById('reauth-period').value;
    const serverTimeout = document.getElementById('timeout-period').value;
    const txPeriod = document.getElementById('tx-period').value;
    const quietPeriod = document.getElementById('quiet-period').value;
    
    // Generate config based on vendor
    let config = '';
    
    // Add project details if enabled
    const includeProjectDetails = document.getElementById('project-detail-toggle')?.checked;
    if (includeProjectDetails) {
        const companyName = document.getElementById('company-name').value;
        const sfdcOpportunity = document.getElementById('sfdc-opportunity').value;
        const seEmail = document.getElementById('se-email').value;
        const customerEmail = document.getElementById('customer-email').value;
        
        config += `# Project Details\n`;
        config += `# Company Name: ${companyName || 'N/A'}\n`;
        config += `# SFDC Opportunity: ${sfdcOpportunity || 'N/A'}\n`;
        config += `# SE Email: ${seEmail || 'N/A'}\n`;
        config += `# Customer Email: ${customerEmail || 'N/A'}\n`;
        config += `# Date Generated: ${new Date().toLocaleString()}\n\n`;
    }
    
    // Start vendor-specific configuration
    config += `! 802.1X Configuration for ${vendor.toUpperCase()} ${platform.toUpperCase()}\n`;
    config += `! Generated by Dot1Xer Supreme (https://github.com/username/dot1xer-supreme)\n`;
    config += `! Authentication: ${authMethod}, Mode: ${authMode}, Host Mode: ${hostMode}\n\n`;
    
    // Cisco IOS-XE config
    if (vendor === 'cisco' && platform === 'ios-xe') {
        config += generateCiscoIOSXEConfig(authMethod, authMode, hostMode, dataVlan, voiceVlan, guestVlan, criticalVlan, 
                                          authFailVlan, radiusServers, radsecServers, useMAB, useCoA, useLocal, 
                                          reAuthPeriod, serverTimeout, txPeriod, quietPeriod);
    } 
    // Cisco NX-OS config
    else if (vendor === 'cisco' && platform === 'nx-os') {
        config += generateCiscoNXOSConfig(authMethod, authMode, hostMode, dataVlan, voiceVlan, guestVlan, criticalVlan, 
                                         authFailVlan, radiusServers, radsecServers, useMAB, useCoA, useLocal, 
                                         reAuthPeriod, serverTimeout, txPeriod, quietPeriod);
    }
    // Aruba AOS-CX config
    else if (vendor === 'aruba' && platform === 'aos-cx') {
        config += generateArubaAOSCXConfig(authMethod, authMode, hostMode, dataVlan, voiceVlan, guestVlan, criticalVlan, 
                                          authFailVlan, radiusServers, radsecServers, useMAB, useCoA, useLocal, 
                                          reAuthPeriod, serverTimeout, txPeriod, quietPeriod);
    }
    // Add more vendor configs here...
    else {
        // Default generic config for other vendors
        config += `! Configuration for ${vendor} ${platform}\n`;
        config += `! This is a placeholder. Please refer to vendor-specific templates.\n`;
        
        // Basic RADIUS configuration
        config += `\n! RADIUS Server Configuration\n`;
        radiusServers.forEach((server, index) => {
            config += `radius-server host ${server.ip} auth-port ${server.authPort} acct-port ${server.acctPort} key ${server.key}\n`;
            if (server.enableCoA) {
                config += `radius-server host ${server.ip} coa-port ${server.coaPort}\n`;
            }
        });
        
        // Basic VLAN configuration
        config += `\n! VLAN Configuration\n`;
        config += `vlan ${dataVlan}\n`;
        if (voiceVlan) config += `vlan ${voiceVlan}\n`;
        if (guestVlan) config += `vlan ${guestVlan}\n`;
        if (criticalVlan) config += `vlan ${criticalVlan}\n`;
        if (authFailVlan) config += `vlan ${authFailVlan}\n`;
        
        // Basic interface configuration
        config += `\n! Interface Configuration\n`;
        config += `interface GigabitEthernet1/0/1\n`;
        config += ` switchport access vlan ${dataVlan}\n`;
        config += ` authentication port-control ${authMode === 'closed' ? 'auto' : 'auto open'}\n`;
        if (useMAB) config += ` mab\n`;
        if (guestVlan) config += ` authentication event fail action authorize vlan ${guestVlan}\n`;
    }
    
    return config;
}

// Generate configuration for Cisco IOS-XE
function generateCiscoIOSXEConfig(authMethod, authMode, hostMode, dataVlan, voiceVlan, guestVlan, criticalVlan, 
                                 authFailVlan, radiusServers, radsecServers, useMAB, useCoA, useLocal, 
                                 reAuthPeriod, serverTimeout, txPeriod, quietPeriod) {
    let config = '';
    
    // Global AAA config
    config += `! Global AAA Configuration\n`;
    config += `aaa new-model\n`;
    
    // RADIUS server config
    config += `\n! RADIUS Server Configuration\n`;
    radiusServers.forEach((server, index) => {
        config += `radius server RADIUS-SRV-${index + 1}\n`;
        config += ` address ipv4 ${server.ip} auth-port ${server.authPort} acct-port ${server.acctPort}\n`;
        config += ` key ${server.key}\n`;
    });
    
    // RADIUS server group
    config += `\n! RADIUS Server Group\n`;
    config += `aaa group server radius RADIUS-SERVERS\n`;
    radiusServers.forEach((server, index) => {
        config += ` server name RADIUS-SRV-${index + 1}\n`;
    });
    
    // RadSec configuration if available
    if (radsecServers.length > 0) {
        config += `\n! RadSec Configuration\n`;
        radsecServers.forEach((server, index) => {
            config += `radius server RADSEC-SRV-${index + 1}\n`;
            config += ` address ipv4 ${server.ip} auth-port ${server.port} acct-port ${server.port}\n`;
            config += ` key ${server.key}\n`;
            config += ` transport ${server.protocol}\n`;
            if (server.validateServer) {
                config += ` server-identity check\n`;
            }
        });
        
        // Add RadSec servers to group
        config += `\n! Add RadSec to Server Group\n`;
        radsecServers.forEach((server, index) => {
            config += `aaa group server radius RADIUS-SERVERS\n`;
            config += ` server name RADSEC-SRV-${index + 1}\n`;
        });
    }
    
    // AAA authentication and authorization
    config += `\n! AAA Authentication and Authorization\n`;
    config += `aaa authentication dot1x default group RADIUS-SERVERS`;
    if (useLocal) config += ` local`;
    config += `\n`;
    config += `aaa authorization network default group RADIUS-SERVERS`;
    if (useLocal) config += ` local`;
    config += `\n`;
    
    // AAA accounting
    config += `\n! AAA Accounting\n`;
    config += `aaa accounting dot1x default start-stop group RADIUS-SERVERS\n`;
    
    // 802.1X global config
    config += `\n! 802.1X Global Configuration\n`;
    config += `dot1x system-auth-control\n`;
    config += `dot1x re-authentication\n`;
    
    // VLAN configuration
    config += `\n! VLAN Configuration\n`;
    config += `vlan ${dataVlan}\n name Data_VLAN\n`;
    if (voiceVlan) config += `vlan ${voiceVlan}\n name Voice_VLAN\n`;
    if (guestVlan) config += `vlan ${guestVlan}\n name Guest_VLAN\n`;
    if (criticalVlan) config += `vlan ${criticalVlan}\n name Critical_VLAN\n`;
    if (authFailVlan) config += `vlan ${authFailVlan}\n name Auth_Fail_VLAN\n`;
    
    // IBNS 2.0 policy maps (advanced)
    config += `\n! IBNS 2.0 Policy Maps\n`;
    config += `class-map type control subscriber match-all DOT1X\n`;
    config += ` match authorization-status unauthorized\n`;
    config += ` match method dot1x\n`;
    
    if (useMAB) {
        config += `class-map type control subscriber match-all MAB\n`;
        config += ` match authorization-status unauthorized\n`;
        config += ` match method mab\n`;
    }
    
    config += `\n! Authentication policy\n`;
    config += `policy-map type control subscriber DOT1X_POLICY\n`;
    config += ` event session-started match-all\n`;
    config += `  10 class always do-until-failure\n`;
    config += `   10 authenticate using dot1x priority 10\n`;
    
    if (useMAB) {
        config += `   20 authenticate using mab priority 20\n`;
    }
    
    config += ` event authentication-failure match-first\n`;
    config += `  10 class AAA_SVR_DOWN_UNAUTHD_HOST do-until-failure\n`;
    if (criticalVlan) {
        config += `   10 authorize using vlan ${criticalVlan}\n`;
    }
    
    config += `  20 class DOT1X_FAILED do-until-failure\n`;
    if (authFailVlan) {
        config += `   10 authorize using vlan ${authFailVlan}\n`;
    }
    
    config += `  30 class MAB_FAILED do-until-failure\n`;
    if (guestVlan) {
        config += `   10 authorize using vlan ${guestVlan}\n`;
    }
    
    config += `  40 class DOT1X_NO_RESP do-until-failure\n`;
    config += `   10 terminate dot1x\n`;
    if (useMAB) {
        config += `   20 authenticate using mab priority 20\n`;
    }
    
    // Interface configuration
    config += `\n! Interface Configuration\n`;
    config += `interface GigabitEthernet1/0/1\n`;
    config += ` description 802.1X Enabled Port\n`;
    config += ` switchport mode access\n`;
    config += ` switchport access vlan ${dataVlan}\n`;
    if (voiceVlan) config += ` switchport voice vlan ${voiceVlan}\n`;
    
    // Authentication settings
    config += ` authentication periodic\n`;
    config += ` authentication timer reauthenticate ${reAuthPeriod}\n`;
    config += ` authentication timer restart ${txPeriod}\n`;
    config += ` authentication host-mode ${hostMode}\n`;
    
    if (authMode === 'closed') {
        config += ` authentication port-control auto\n`;
    } else {
        config += ` authentication port-control auto\n`;
        config += ` authentication open\n`;
    }
    
    config += ` authentication violation restrict\n`;
    config += ` dot1x pae authenticator\n`;
    
    if (useMAB) {
        config += ` mab\n`;
    }
    
    // Apply policy
    config += ` service-policy type control subscriber DOT1X_POLICY\n`;
    
    // Device tracking for advanced security
    config += `\n! Device Tracking Configuration\n`;
    config += `device-tracking policy DOT1X_POLICY\n`;
    config += ` tracking enable\n`;
    config += ` no destination-glean prefix-glean\n`;
    config += `interface GigabitEthernet1/0/1\n`;
    config += ` device-tracking attach-policy DOT1X_POLICY\n`;
    
    // CoA configuration
    if (useCoA) {
        config += `\n! Change of Authorization (CoA) Configuration\n`;
        config += `aaa server radius dynamic-author\n`;
        config += ` client ${radiusServers[0].ip} server-key ${radiusServers[0].key}\n`;
        config += ` auth-type all\n`;
    }
    
    return config;
}

// Generate configuration for Cisco NX-OS
function generateCiscoNXOSConfig(authMethod, authMode, hostMode, dataVlan, voiceVlan, guestVlan, criticalVlan, 
                                authFailVlan, radiusServers, radsecServers, useMAB, useCoA, useLocal, 
                                reAuthPeriod, serverTimeout, txPeriod, quietPeriod) {
    let config = '';
    
    // Enable features
    config += `! Feature Enablement\n`;
    config += `feature aaa\n`;
    config += `feature dot1x\n`;
    
    // RADIUS server configuration
    config += `\n! RADIUS Server Configuration\n`;
    radiusServers.forEach((server, index) => {
        config += `radius-server host ${server.ip} key ${server.key} authentication accounting\n`;
        config += `radius-server host ${server.ip} auth-port ${server.authPort} acct-port ${server.acctPort}\n`;
        if (server.enableCoA) {
            config += `radius-server host ${server.ip} coa-port ${server.coaPort}\n`;
        }
    });
    
    config += `radius-server timeout ${serverTimeout}\n`;
    config += `radius-server retransmit 3\n`;
    config += `radius-server deadtime 10\n`;
    
    // AAA configuration
    config += `\n! AAA Configuration\n`;
    config += `aaa group server radius RADIUS-SERVERS\n`;
    radiusServers.forEach((server, index) => {
        config += ` server ${server.ip}\n`;
    });
    config += ` use-vrf default\n`;
    config += ` source-interface mgmt0\n`;
    
    config += `aaa authentication dot1x default group RADIUS-SERVERS\n`;
    config += `aaa accounting dot1x default group RADIUS-SERVERS\n`;
    
    // 802.1X global configuration
    config += `\n! 802.1X Global Configuration\n`;
    config += `dot1x system-auth-control\n`;
    config += `dot1x timeout quiet-period ${quietPeriod}\n`;
    config += `dot1x timeout tx-period ${txPeriod}\n`;
    config += `dot1x timeout re-authperiod ${reAuthPeriod}\n`;
    config += `dot1x timeout server-timeout ${serverTimeout}\n`;
    
    if (useMAB) {
        config += `dot1x mac-auth-bypass\n`;
    }
    
    // VLAN configuration
    config += `\n! VLAN Configuration\n`;
    config += `vlan ${dataVlan}\n name Data_VLAN\n`;
    if (voiceVlan) config += `vlan ${voiceVlan}\n name Voice_VLAN\n`;
    if (guestVlan) config += `vlan ${guestVlan}\n name Guest_VLAN\n`;
    if (criticalVlan) config += `vlan ${criticalVlan}\n name Critical_VLAN\n`;
    if (authFailVlan) config += `vlan ${authFailVlan}\n name Auth_Fail_VLAN\n`;
    
    // Interface configuration
    config += `\n! Interface Configuration\n`;
    config += `interface Ethernet1/1\n`;
    config += ` description 802.1X Enabled Port\n`;
    config += ` switchport\n`;
    config += ` switchport mode access\n`;
    config += ` switchport access vlan ${dataVlan}\n`;
    if (voiceVlan) config += ` switchport voice vlan ${voiceVlan}\n`;
    
    config += ` dot1x pae authenticator\n`;
    
    if (useMAB) {
        config += ` dot1x mac-auth-bypass\n`;
    }
    
    if (authMode === 'closed') {
        config += ` dot1x port-control auto\n`;
    } else {
        config += ` dot1x port-control force-authorized\n`;
    }
    
    if (guestVlan) {
        config += ` dot1x guest-vlan ${guestVlan}\n`;
    }
    
    if (authFailVlan) {
        config += ` dot1x auth-fail-vlan ${authFailVlan}\n`;
    }
    
    if (criticalVlan) {
        config += ` dot1x critical-vlan ${criticalVlan}\n`;
    }
    
    // Host mode configuration
    if (hostMode === 'multi-auth') {
        config += ` dot1x host-mode multi-auth\n`;
    } else if (hostMode === 'multi-host') {
        config += ` dot1x host-mode multi-host\n`;
    } else if (hostMode === 'multi-domain') {
        config += ` dot1x host-mode multi-domain\n`;
    } else {
        config += ` dot1x host-mode single-host\n`;
    }
    
    config += ` dot1x timeout quiet-period ${quietPeriod}\n`;
    config += ` dot1x timeout server-timeout ${serverTimeout}\n`;
    config += ` dot1x timeout tx-period ${txPeriod}\n`;
    config += ` dot1x timeout re-authperiod ${reAuthPeriod}\n`;
    config += ` no shutdown\n`;
    
    // CoA configuration
    if (useCoA) {
        config += `\n! Change of Authorization (CoA) Configuration\n`;
        config += `aaa server radius dynamic-author\n`;
        config += ` client ${radiusServers[0].ip} server-key ${radiusServers[0].key}\n`;
    }
    
    return config;
}

// Generate configuration for Aruba AOS-CX
function generateArubaAOSCXConfig(authMethod, authMode, hostMode, dataVlan, voiceVlan, guestVlan, criticalVlan, 
                                 authFailVlan, radiusServers, radsecServers, useMAB, useCoA, useLocal, 
                                 reAuthPeriod, serverTimeout, txPeriod, quietPeriod) {
    let config = '';
    
    // Global configuration
    config += `! Global Configuration\n`;
    config += `aaa authentication port-access dot1x\n`;
    
    if (useMAB) {
        config += `aaa authentication port-access mac-auth\n`;
    }
    
    // RADIUS server configuration
    config += `\n! RADIUS Server Configuration\n`;
    radiusServers.forEach((server, index) => {
        config += `radius-server host ${server.ip} key ${server.key}\n`;
        config += `radius-server host ${server.ip} auth-port ${server.authPort} acct-port ${server.acctPort}\n`;
        if (server.enableCoA && useCoA) {
            config += `radius-server host ${server.ip} coa-port ${server.coaPort}\n`;
            config += `radius-server host ${server.ip} coa-enable\n`;
        }
    });
    
    config += `radius-server timeout ${serverTimeout}\n`;
    config += `radius-server retransmit 3\n`;
    
    // VLAN configuration
    config += `\n! VLAN Configuration\n`;
    config += `vlan ${dataVlan}\n name Data_VLAN\n`;
    if (voiceVlan) config += `vlan ${voiceVlan}\n name Voice_VLAN\n`;
    if (guestVlan) config += `vlan ${guestVlan}\n name Guest_VLAN\n`;
    if (criticalVlan) config += `vlan ${criticalVlan}\n name Critical_VLAN\n`;
    if (authFailVlan) config += `vlan ${authFailVlan}\n name Auth_Fail_VLAN\n`;
    
    // Interface configuration
    config += `\n! Interface Configuration\n`;
    config += `interface 1/1/1\n`;
    config += ` description 802.1X Enabled Port\n`;
    config += ` vlan access ${dataVlan}\n`;
    if (voiceVlan) config += ` voice-vlan ${voiceVlan}\n`;
    
    config += ` port-access authenticator\n`;
    
    if (authMethod.includes('mab') || useMAB) {
        config += ` authentication precedence mac-auth dot1x\n`;
    }
    
    if (guestVlan) {
        config += ` authentication guest-vlan ${guestVlan}\n`;
    }
    
    if (authFailVlan) {
        config += ` authentication auth-fail-vlan ${authFailVlan}\n`;
    }
    
    if (criticalVlan) {
        config += ` authentication critical-vlan ${criticalVlan}\n`;
    }
    
    // Authentication mode
    if (authMode === 'closed') {
        config += ` authentication port-mode authorize\n`;
    } else {
        config += ` authentication port-mode authorize open\n`;
    }
    
    // Host mode configuration
    if (hostMode === 'multi-auth') {
        config += ` authentication host-mode multi-auth\n`;
    } else if (hostMode === 'multi-host') {
        config += ` authentication host-mode multi-host\n`;
    } else if (hostMode === 'multi-domain') {
        config += ` authentication host-mode multi-domain\n`;
    } else {
        config += ` authentication host-mode single-host\n`;
    }
    
    config += ` authentication reauthenticate timeout ${reAuthPeriod}\n`;
    config += ` no shutdown\n`;
    
    return config;
}

// Add more vendor-specific configuration generators here...

// Review configuration
function reviewConfiguration() {
    const config = document.getElementById('config-output').textContent;
    if (!config) {
        showError('Please generate a configuration first.');
        return;
    }
    
    const reviewOutput = document.getElementById('review-output');
    const reviewSection = document.getElementById('review-output-section');
    
    if (!reviewOutput || !reviewSection) return;
    
    reviewSection.style.display = 'block';
    reviewOutput.innerHTML = '<p>Analyzing configuration...</p>';
    
    // Simulate AI review
    setTimeout(() => {
        const vendor = document.getElementById('vendor-select').value;
        const authMethod = document.getElementById('auth-method').value;
        const useMAB = document.getElementById('use-mab').checked;
        const useCoA = document.getElementById('use-coa').checked;
        
        let reviewHtml = '<h4>Configuration Review</h4>';
        reviewHtml += '<ul>';
        
        // Check RADIUS server configuration
        const radiusServers = document.querySelectorAll('.radius-server-entry');
        if (radiusServers.length === 0) {
            reviewHtml += '<li class="review-warning">❌ No RADIUS servers configured. Authentication will fail.</li>';
        } else if (radiusServers.length === 1) {
            reviewHtml += '<li class="review-warning">⚠️ Only one RADIUS server configured. Consider adding a secondary server for redundancy.</li>';
        } else {
            reviewHtml += '<li class="review-success">✅ Multiple RADIUS servers configured for redundancy.</li>';
        }
        
        // Check authentication method
        if (authMethod.includes('mab') && !useMAB) {
            reviewHtml += '<li class="review-warning">⚠️ MAB selected in authentication method but MAB checkbox is not enabled in Advanced Options.</li>';
        } else if (authMethod.includes('mab') && useMAB) {
            reviewHtml += '<li class="review-success">✅ MAB properly configured.</li>';
        }
        
        // Check CoA
        if (useCoA) {
            reviewHtml += '<li class="review-success">✅ Change of Authorization (CoA) is enabled for dynamic policy updates.</li>';
        } else {
            reviewHtml += '<li class="review-warning">⚠️ CoA is not enabled. Dynamic policy updates will not be possible.</li>';
        }
        
        // Check VLANs
        const dataVlan = document.getElementById('data-vlan').value;
        const guestVlan = document.getElementById('guest-vlan').value;
        
        if (!dataVlan) {
            reviewHtml += '<li class="review-error">❌ Data VLAN is required but not configured.</li>';
        }
        
        if (authMethod !== 'dot1x-only' && !guestVlan) {
            reviewHtml += '<li class="review-warning">⚠️ Guest VLAN not configured, but recommended for MAB fallback.</li>';
        }
        
        // Vendor-specific checks
        if (vendor === 'cisco') {
            reviewHtml += '<li class="review-success">✅ Cisco configuration includes IBNS 2.0 policy maps for advanced authentication control.</li>';
        }
        
        reviewHtml += '</ul>';
        
        // Add best practices
        reviewHtml += '<h4>Best Practices</h4>';
        reviewHtml += '<ul>';
        reviewHtml += '<li>Consider starting with Monitor Mode (open) for initial deployment to avoid potential lockouts.</li>';
        reviewHtml += '<li>Implement a phased approach: Monitor → Low Impact → Closed Mode.</li>';
        reviewHtml += '<li>Always test configurations in a lab environment before deploying in production.</li>';
        reviewHtml += '<li>Ensure the RADIUS shared secrets are strong and unique.</li>';
        reviewHtml += '</ul>';
        
        reviewOutput.innerHTML = reviewHtml;
    }, 1000);
}

// Generate configurations for all selected vendors
function generateAllVendorConfigs() {
    const multiVendorEnabled = document.getElementById('multi-vendor-toggle')?.checked;
    let config = '';
    
    if (multiVendorEnabled) {
        config = generateMultiVendorConfig();
    } else {
        config = generateSingleVendorConfig();
    }
    
    if (!config) return;
    
    document.getElementById('config-output').textContent = config;
}
// Dot1Xer Supreme - Tab Navigation

function initTabs() {
    // Main tabs
    document.querySelectorAll('.tab-btn').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showTab(tabName, this);
        });
    });
    
    // Discovery tabs
    document.querySelectorAll('.discovery-tab').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showDiscoveryTab(tabName, this);
        });
    });
    
    // Server tabs
    document.querySelectorAll('.tab-control-btn').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showServerTab(tabName, this);
        });
    });
    
    // Reference architecture tabs
    document.querySelectorAll('.ref-tab').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showRefTab(tabName, this);
        });
    });
    
    // Portnox tabs
    document.querySelectorAll('.portnox-nav-tab').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showPortnoxTab(tabName, this);
        });
    });
}

function showTab(tabName, button) {
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
        tab.style.display = 'none';
    });
    const selectedTab = document.getElementById(tabName);
    if (selectedTab) {
        selectedTab.classList.add('active');
        selectedTab.style.display = 'block';
    }
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    if (button) button.classList.add('active');
    if (tabName === 'configurator') goToStep(1);
}

function showDiscoveryTab(tabName, button) {
    document.querySelectorAll('.discovery-section').forEach(section => {
        section.classList.remove('active');
        section.style.display = 'none';
    });
    const selectedSection = document.getElementById(`disc-${tabName}`);
    if (selectedSection) {
        selectedSection.classList.add('active');
        selectedSection.style.display = 'block';
    }
    document.querySelectorAll('.discovery-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    if (button) button.classList.add('active');
}

function showServerTab(tabId, button) {
    document.querySelectorAll('.server-tab').forEach(tab => {
        tab.classList.remove('active');
        tab.style.display = 'none';
    });
    const selectedTab = document.getElementById(tabId);
    if (selectedTab) {
        selectedTab.classList.add('active');
        selectedTab.style.display = 'block';
    }
    document.querySelectorAll('.tab-control-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    if (button) button.classList.add('active');
}

function showRefTab(tabName, button) {
    document.querySelectorAll('.ref-section').forEach(section => {
        section.classList.remove('active');
        section.style.display = 'none';
    });
    const selectedSection = document.getElementById(`ref-${tabName}`);
    if (selectedSection) {
        selectedSection.classList.add('active');
        selectedSection.style.display = 'block';
    }
    document.querySelectorAll('.ref-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    if (button) button.classList.add('active');
}

function showPortnoxTab(tabName, button) {
    document.querySelectorAll('.portnox-content').forEach(section => {
        section.classList.remove('active');
        section.style.display = 'none';
    });
    const selectedSection = document.getElementById(`portnox-${tabName}`);
    if (selectedSection) {
        selectedSection.classList.add('active');
        selectedSection.style.display = 'block';
    }
    document.querySelectorAll('.portnox-nav-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    if (button) button.classList.add('active');
}
// Dot1Xer Supreme - Vendor Options

function initVendorOptions() {
    const vendorSelect = document.getElementById('vendor-select');
    if (vendorSelect) {
        vendorSelect.addEventListener('change', updatePlatformOptions);
        updatePlatformOptions();
    }
    const platformSelect = document.getElementById('platform-select');
    if (platformSelect) {
        platformSelect.addEventListener('change', updateVendorSpecificOptions);
    }
}

function updatePlatformOptions() {
    const vendorSelect = document.getElementById('vendor-select');
    const platformSelect = document.getElementById('platform-select');
    const platformDescription = document.getElementById('platform-description');
    if (!vendorSelect || !platformSelect || !platformDescription) return;
    platformSelect.innerHTML = '';
    const vendor = vendorSelect.value;
    switch (vendor) {
        case 'cisco':
            addOption(platformSelect, 'ios-xe', 'IOS-XE (Catalyst 9000)');
            addOption(platformSelect, 'ios', 'IOS (Classic)');
            addOption(platformSelect, 'nx-os', 'NX-OS (Nexus)');
            addOption(platformSelect, 'wlc', 'WLC 9800');
            platformDescription.innerHTML = '<p>Cisco platforms support a wide range of authentication methods and features including IBNS 2.0, MAB, guest VLAN, and dynamic policy assignment.</p>';
            break;
        case 'aruba':
            addOption(platformSelect, 'aos-cx', 'AOS-CX');
            addOption(platformSelect, 'aos-switch', 'AOS-Switch (Legacy)');
            platformDescription.innerHTML = '<p>Aruba platforms provide robust authentication capabilities with ClearPass integration, port-access authenticator, and advanced policy enforcement.</p>';
            break;
        case 'juniper':
            addOption(platformSelect, 'ex', 'EX Series');
            addOption(platformSelect, 'qfx', 'QFX Series');
            addOption(platformSelect, 'srx', 'SRX Series');
            platformDescription.innerHTML = '<p>Juniper switches use a consistent configuration approach across platforms with flexible authentication profiles and MAC RADIUS options.</p>';
            break;
        case 'fortinet':
            addOption(platformSelect, 'fortiswitch', 'FortiSwitch');
            addOption(platformSelect, 'fortigate', 'FortiGate');
            platformDescription.innerHTML = '<p>FortiNet integrates with the FortiGate security ecosystem for unified access control and security policy enforcement.</p>';
            break;
        case 'arista':
            addOption(platformSelect, 'eos', 'EOS');
            addOption(platformSelect, 'cloudvision', 'CloudVision');
            platformDescription.innerHTML = '<p>Arista EOS provides enterprise-grade authentication with CloudVision integration for centralized management.</p>';
            break;
        case 'extreme':
            addOption(platformSelect, 'exos', 'EXOS');
            addOption(platformSelect, 'voss', 'VOSS');
            addOption(platformSelect, 'xiq', 'ExtremeCloud IQ');
            platformDescription.innerHTML = '<p>Extreme Networks offers multiple authentication solutions with cloud management via ExtremeCloud IQ.</p>';
            break;
        case 'huawei':
            addOption(platformSelect, 'vrp', 'VRP');
            addOption(platformSelect, 'agile-controller', 'Agile Controller');
            platformDescription.innerHTML = '<p>Huawei VRP provides comprehensive AAA capabilities with centralized management through Agile Controller.</p>';
            break;
        case 'alcatel':
            addOption(platformSelect, 'omniswitch', 'OmniSwitch');
            addOption(platformSelect, 'omnivista', 'OmniVista');
            platformDescription.innerHTML = '<p>Alcatel-Lucent OmniSwitch offers simplified deployment with OmniVista management integration.</p>';
            break;
        case 'ubiquiti':
            addOption(platformSelect, 'unifi', 'UniFi');
            addOption(platformSelect, 'edgeswitch', 'EdgeSwitch');
            platformDescription.innerHTML = '<p>Ubiquiti uses a controller-based approach for unified management of authentication policies.</p>';
            break;
        case 'hp':
            addOption(platformSelect, 'procurve', 'ProCurve');
            addOption(platformSelect, 'comware', 'Comware');
            addOption(platformSelect, 'aruba-central', 'Aruba Central');
            platformDescription.innerHTML = '<p>HP offers multiple switch platforms with cloud management capabilities through Aruba Central.</p>';
            break;
        case 'dell':
            addOption(platformSelect, 'powerswitch', 'PowerSwitch');
            platformDescription.innerHTML = '<p>Dell PowerSwitch supports enterprise-grade authentication with flexible deployment options.</p>';
            break;
        case 'netgear':
            addOption(platformSelect, 'managed', 'Managed Switches');
            platformDescription.innerHTML = '<p>NETGEAR managed switches support basic 802.1X authentication with RADIUS integration.</p>';
            break;
        case 'ruckus':
            addOption(platformSelect, 'smartzone', 'SmartZone');
            platformDescription.innerHTML = '<p>Ruckus SmartZone provides centralized management for authentication with policy-based assignments.</p>';
            break;
        case 'brocade':
            addOption(platformSelect, 'icx', 'ICX Series');
            platformDescription.innerHTML = '<p>Brocade ICX series supports 802.1X and MAB with dynamic VLAN assignment capabilities.</p>';
            break;
        case 'paloalto':
            addOption(platformSelect, 'panos', 'PAN-OS');
            addOption(platformSelect, 'panorama', 'Panorama');
            platformDescription.innerHTML = '<p>Palo Alto Networks offers security-focused authentication with advanced threat prevention capabilities.</p>';
            break;
        case 'checkpoint':
            addOption(platformSelect, 'gaia', 'Gaia OS');
            addOption(platformSelect, 'r80', 'R80.x');
            platformDescription.innerHTML = '<p>Check Point provides integrated security and authentication with unified policy management.</p>';
            break;
        case 'sonicwall':
            addOption(platformSelect, 'sonicos', 'SonicOS');
            platformDescription.innerHTML = '<p>SonicWall provides integrated security and authentication with comprehensive threat protection.</p>';
            break;
        case 'portnox':
            addOption(platformSelect, 'cloud', 'Portnox Cloud');
            platformDescription.innerHTML = '<p>Portnox Cloud provides unified access control with zero trust capabilities, device profiling, and risk-based authentication.</p>';
            break;
        default:
            addOption(platformSelect, 'default', 'Default Platform');
            platformDescription.innerHTML = '<p>Please select a vendor to see platform details.</p>';
    }
    updateVendorSpecificOptions();
}

function addOption(selectElement, value, text) {
    const option = document.createElement('option');
    option.value = value;
    option.textContent = text;
    selectElement.appendChild(option);
}

function updateVendorSpecificOptions() {
    const vendorSelect = document.getElementById('vendor-select');
    const platformSelect = document.getElementById('platform-select');
    if (!vendorSelect || !platformSelect) return;
    const vendor = vendorSelect.value;
    const platform = platformSelect.value;
    const vendorSpecificSections = document.querySelectorAll('.vendor-specific');
    vendorSpecificSections.forEach(section => {
        section.style.display = 'none';
    });
    const specificSection = document.getElementById(`${vendor}-${platform}-options`);
    if (specificSection) {
        specificSection.style.display = 'block';
    }
    if (vendor === 'portnox') {
        const portnoxOptions = document.getElementById('portnox-options');
        if (portnoxOptions) {
            portnoxOptions.style.display = 'block';
        }
    }
}
// Dot1Xer Supreme - Environment Discovery

function initNetworkScopingOptions() {
    const scopingTypeRadios = document.querySelectorAll('input[name="scoping_type"]');
    if (scopingTypeRadios.length > 0) {
        scopingTypeRadios.forEach(radio => {
            radio.addEventListener('change', function() {
                const basicScoping = document.getElementById('basic-scoping');
                const advancedScoping = document.getElementById('advanced-scoping');
                if (basicScoping && advancedScoping) {
                    basicScoping.style.display = this.value === 'basic' ? 'block' : 'none';
                    advancedScoping.style.display = this.value === 'advanced' ? 'block' : 'none';
                }
            });
        });
    }
    
    const eapMethodCheckboxes = document.querySelectorAll('.eap-method');
    eapMethodCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const methodOptions = document.getElementById(`${this.id}-options`);
            if (methodOptions) {
                methodOptions.style.display = this.checked ? 'block' : 'none';
            }
        });
    });
    
    const envInfraCheckboxes = document.querySelectorAll('.env-infrastructure');
    envInfraCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const infraOptions = document.getElementById(`${this.id}-options`);
            if (infraOptions) {
                infraOptions.style.display = this.checked ? 'block' : 'none';
            }
            updateEnvironmentSummary();
        });
    });
    
    const mdmProviderSelect = document.getElementById('mdm-provider');
    if (mdmProviderSelect) {
        mdmProviderSelect.addEventListener('change', function() {
            updateMDMOptions();
            updateEnvironmentSummary();
        });
    }
    
    const idpProviderSelect = document.getElementById('idp-provider');
    if (idpProviderSelect) {
        idpProviderSelect.addEventListener('change', function() {
            updateIdPOptions();
            updateEnvironmentSummary();
        });
    }
}

function updateEnvironmentSummary() {
    const summarySection = document.getElementById('environment-summary');
    if (!summarySection) return;
    
    let summary = '<h4>Environment Profile Summary</h4><ul>';
    
    const infraElements = document.querySelectorAll('.env-infrastructure:checked');
    if (infraElements.length > 0) {
        summary += '<li><strong>Infrastructure:</strong> ';
        const infraLabels = Array.from(infraElements).map(el => el.dataset.label || el.value);
        summary += infraLabels.join(', ');
        summary += '</li>';
    }
    
    const mdmProvider = document.getElementById('mdm-provider');
    if (mdmProvider && mdmProvider.value !== 'none') {
        const mdmOption = mdmProvider.options[mdmProvider.selectedIndex];
        summary += `<li><strong>MDM Solution:</strong> ${mdmOption.text}</li>`;
    }
    
    const idpProvider = document.getElementById('idp-provider');
    if (idpProvider && idpProvider.value !== 'none') {
        const idpOption = idpProvider.options[idpProvider.selectedIndex];
        summary += `<li><strong>Identity Provider:</strong> ${idpOption.text}</li>`;
    }
    
    summary += '</ul>';
    
    summary += '<h4>Recommendations</h4><ul>';
    
    if (document.getElementById('env-active-directory') && document.getElementById('env-active-directory').checked) {
        summary += '<li>Configure RADIUS to integrate with Active Directory for user authentication</li>';
    }
    
    if (mdmProvider && mdmProvider.value !== 'none') {
        summary += '<li>Integrate with ' + mdmProvider.options[mdmProvider.selectedIndex].text + 
                  ' for device compliance checking and certificate distribution</li>';
    }
    
    if (document.getElementById('env-cloud') && document.getElementById('env-cloud').checked) {
        summary += '<li>Consider Portnox Cloud RADIUS service for simplified deployment and management</li>';
    }
    
    // Vendor-specific recommendations based on selected infrastructure
    const vendorSelect = document.getElementById('vendor-select');
    if (vendorSelect) {
        const vendor = vendorSelect.value;
        
        if (vendor === 'cisco') {
            summary += '<li>Implement IBNS 2.0 policy maps for advanced authentication control</li>';
        } else if (vendor === 'aruba') {
            summary += '<li>Utilize ClearPass integration for comprehensive policy enforcement</li>';
        } else if (vendor === 'juniper') {
            summary += '<li>Configure authentication profiles with flexible options for different device types</li>';
        }
    }
    
    summary += '</ul>';
    
    // Link to configurator
    summary += '<div class="config-link">';
    summary += '<h4>Configuration Integration</h4>';
    summary += '<p>The environment profile can be used to generate vendor-specific configurations.</p>';
    summary += '<button type="button" class="btn" onclick="integrateEnvironmentWithConfigurator()">Generate Configurations</button>';
    summary += '</div>';
    
    summarySection.innerHTML = summary;
    summarySection.style.display = 'block';
}

function integrateEnvironmentWithConfigurator() {
    // Switch to configurator tab
    const configuratorTab = document.querySelector('.tab-btn[data-tab="configurator"]');
    if (configuratorTab) {
        configuratorTab.click();
    }
    
    // Enable multi-vendor configuration
    const multiVendorToggle = document.getElementById('multi-vendor-toggle');
    if (multiVendorToggle) {
        multiVendorToggle.checked = true;
        const event = new Event('change');
        multiVendorToggle.dispatchEvent(event);
    }
    
    // Populate with environment data
    // This could be extended with more mappings based on environment profile
}

function updateMDMOptions() {
    const mdmProviderSelect = document.getElementById('mdm-provider');
    const mdmOptionsContainer = document.getElementById('mdm-options');
    if (!mdmProviderSelect || !mdmOptionsContainer) return;
    const provider = mdmProviderSelect.value;
    let optionsHtml = '';
    switch (provider) {
        case 'intune':
            optionsHtml = `
                <h4>Microsoft Intune Integration</h4>
                <p>Include Intune integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-cert-enrollment" checked> 
                        Use for certificate enrollment
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-compliance" checked> 
                        Use for device compliance
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-config-profiles" checked> 
                        Deploy 802.1X configuration profiles
                    </label>
                </div>
            `;
            break;
        case 'jamf':
            optionsHtml = `
                <h4>JAMF Integration</h4>
                <p>Include JAMF integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-cert-enrollment" checked> 
                        Use for certificate enrollment
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-config-profiles" checked> 
                        Deploy 802.1X configuration profiles
                    </label>
                </div>
            `;
            break;
        case 'workspace-one':
            optionsHtml = `
                <h4>VMware Workspace ONE Integration</h4>
                <p>Include Workspace ONE integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-cert-enrollment" checked> 
                        Use for certificate enrollment
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-compliance" checked> 
                        Use for device compliance
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-tunnel" checked> 
                        Use Workspace ONE Tunnel
                    </label>
                </div>
            `;
            break;
        case 'mas360':
            optionsHtml = `
                <h4>IBM MaaS360 Integration</h4>
                <p>Include MaaS360 integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-cert-enrollment" checked> 
                        Use for certificate enrollment
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-config-profiles" checked> 
                        Deploy 802.1X configuration profiles
                    </label>
                </div>
            `;
            break;
        case 'gpo':
            optionsHtml = `
                <h4>Group Policy Integration</h4>
                <p>Include GPO integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-wired" checked> 
                        Configure wired 802.1X via GPO
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-wireless" checked> 
                        Configure wireless 802.1X via GPO
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-cert-autoenroll" checked> 
                        Use certificate auto-enrollment
                    </label>
                </div>
            `;
            break;
        case 'mobileiron':
            optionsHtml = `
                <h4>MobileIron Integration</h4>
                <p>Include MobileIron integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-cert-enrollment" checked> 
                        Use for certificate enrollment
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="mdm-config-profiles" checked> 
                        Deploy 802.1X configuration profiles
                    </label>
                </div>
            `;
            break;
        case 'none':
            optionsHtml = '<p>No MDM solution selected. Manual configuration will be required.</p>';
            break;
        default:
            optionsHtml = '<p>Please select an MDM solution to see integration options.</p>';
    }
    mdmOptionsContainer.innerHTML = optionsHtml;
}

function updateIdPOptions() {
    const idpProviderSelect = document.getElementById('idp-provider');
    const idpOptionsContainer = document.getElementById('idp-options');
    if (!idpProviderSelect || !idpOptionsContainer) return;
    const provider = idpProviderSelect.value;
    let optionsHtml = '';
    switch (provider) {
        case 'entra-id':
            optionsHtml = `
                <h4>Microsoft Entra ID Integration</h4>
                <p>Include Entra ID integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-mfa" checked> 
                        Enable Multi-Factor Authentication
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-conditional-access" checked> 
                        Use Conditional Access Policies
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-cert-auth" checked> 
                        Use certificate-based authentication
                    </label>
                </div>
            `;
            break;
        case 'okta':
            optionsHtml = `
                <h4>Okta Integration</h4>
                <p>Include Okta integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-mfa" checked> 
                        Enable Multi-Factor Authentication
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-radius-agent" checked> 
                        Use Okta RADIUS Server Agent
                    </label>
                </div>
            `;
            break;
        case 'google-workspace':
            optionsHtml = `
                <h4>Google Workspace Integration</h4>
                <p>Include Google Workspace integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-2sv" checked> 
                        Enable 2-Step Verification
                    </label>
                </div>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-context-aware" checked> 
                        Use Context-Aware Access
                    </label>
                </div>
            `;
            break;
        case 'onelogin':
            optionsHtml = `
                <h4>OneLogin Integration</h4>
                <p>Include OneLogin integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-mfa" checked> 
                        Enable Multi-Factor Authentication
                    </label>
                </div>
            `;
            break;
        case 'ping':
            optionsHtml = `
                <h4>Ping Identity Integration</h4>
                <p>Include Ping Identity integration in your 802.1X deployment architecture.</p>
                <div class="checkbox-group">
                    <label>
                        <input type="checkbox" id="idp-mfa" checked> 
                        Enable Multi-Factor Authentication
                    </label>
                </div>
            `;
            break;
        case 'none':
            optionsHtml = '<p>No Identity Provider selected. Local or Active Directory authentication will be used.</p>';
            break;
        default:
            optionsHtml = '<p>Please select an Identity Provider to see integration options.</p>';
    }
    idpOptionsContainer.innerHTML = optionsHtml;
}

function generateNetworkDiagram() {
    const scopingType = document.querySelector('input[name="scoping_type"]:checked')?.value || 'basic';
    let diagramData = {};
    if (scopingType === 'basic') {
        diagramData = {
            locations: document.getElementById('locations-count')?.value || '1',
            switchCount: document.getElementById('switches-count')?.value || '5',
            endpointCount: document.getElementById('endpoints-count')?.value || '100',
            wirelessVendor: document.getElementById('wireless-vendor')?.value || 'cisco',
            switchVendor: document.getElementById('switch-vendor')?.value || 'cisco'
        };
    } else {
        diagramData = {
            locations: document.getElementById('advanced-locations-count')?.value || '1',
            switchCount: document.getElementById('advanced-switches-count')?.value || '5',
            endpointCount: document.getElementById('advanced-endpoints-count')?.value || '100',
            wirelessAPs: document.getElementById('ap-count')?.value || '10',
            wirelessVendor: document.getElementById('wireless-vendor')?.value || 'cisco',
            wirelessModel: document.getElementById('wireless-model')?.value || 'generic',
            switchVendor: document.getElementById('switch-vendor')?.value || 'cisco',
            switchModel: document.getElementById('switch-model')?.value || 'generic'
        };
    }
    const authMethods = [];
    document.querySelectorAll('.eap-method:checked').forEach(method => {
        authMethods.push(method.value);
    });
    diagramData.authMethods = authMethods.length > 0 ? authMethods : ['PEAP-MSCHAPv2', 'MAB'];
    const resultsContainer = document.getElementById('scoping-results');
    if (resultsContainer) {
        resultsContainer.style.display = 'block';
        let html = `<h4>Network Scoping Results</h4>
        <div class="network-summary">
            <p>Based on your input, we've generated a deployment plan for your network:</p>
            <ul>
                <li><strong>Locations:</strong> ${diagramData.locations}</li>
                <li><strong>Switches:</strong> ${diagramData.switchCount} (${diagramData.switchVendor})</li>
                <li><strong>Endpoints:</strong> ${diagramData.endpointCount}</li>
                <li><strong>Authentication Methods:</strong> ${diagramData.authMethods.join(', ')}</li>
            </ul>
        </div>`;
        html += `<div class="deployment-phases">
            <h4>Recommended Deployment Phases</h4>
            <div class="phase">
                <h5>Phase 1: Infrastructure Preparation</h5>
                <ul>
                    <li>Configure Portnox Cloud RADIUS server</li>
                    <li>Set up certificate authority (if using EAP-TLS)</li>
                    <li>Prepare switch configurations with Monitor Mode (Open Authentication)</li>
                    <li>Deploy configurations to a pilot group of switches</li>
                </ul>
            </div>
            <div class="phase">
                <h5>Phase 2: Client Testing</h5>
                <ul>
                    <li>Test authentication with various device types</li>
                    <li>Configure client supplicants</li>
                    <li>Establish MAB exceptions for non-802.1X capable devices</li>
                    <li>Validate dynamic VLAN assignment</li>
                </ul>
            </div>
            <div class="phase">
                <h5>Phase 3: Production Deployment</h5>
                <ul>
                    <li>Roll out configurations to all switches</li>
                    <li>Gradually transition from Monitor Mode to Low Impact Mode</li>
                    <li>Eventually transition to Closed Mode with appropriate exceptions</li>
                    <li>Implement port security with violation actions</li>
                </ul>
            </div>
        </div>`;
        html += `<div class="network-diagram">
            <h4>Network Diagram</h4>
            <div class="diagram-container">
                <img src="assets/diagrams/network-diagram.png" alt="Network Diagram">
            </div>
            <p class="diagram-note">This diagram represents a high-level view of your 802.1X deployment with Portnox Cloud. Download the full diagram for more details.</p>
            <button class="download-btn" onclick="downloadDiagram()">Download Full Diagram</button>
        </div>`;
        
        // Integration with configurator
        html += `<div class="config-integration">
            <h4>Generate Configuration Templates</h4>
            <p>Based on your network scoping, you can generate vendor-specific configuration templates.</p>
            <div class="vendor-options">
                <label for="scope-vendor-select">Select Primary Vendor:</label>
                <select id="scope-vendor-select">
                    <option value="${diagramData.switchVendor}">${diagramData.switchVendor.charAt(0).toUpperCase() + diagramData.switchVendor.slice(1)}</option>
                </select>
            </div>
            <button class="btn" onclick="generateScopedConfigurations()">Generate Configurations</button>
        </div>`;
        
        resultsContainer.innerHTML = html;
    }
}

function generateScopedConfigurations() {
    // Switch to configurator tab
    const configuratorTab = document.querySelector('.tab-btn[data-tab="configurator"]');
    if (configuratorTab) {
        configuratorTab.click();
    }
    
    // Set vendor from scoping
    const scopeVendorSelect = document.getElementById('scope-vendor-select');
    const vendorSelect = document.getElementById('vendor-select');
    if (scopeVendorSelect && vendorSelect) {
        vendorSelect.value = scopeVendorSelect.value;
        const event = new Event('change');
        vendorSelect.dispatchEvent(event);
    }
    
    // Set reasonable defaults for other options
    document.getElementById('auth-method').value = 'dot1x-mab';
    document.querySelector('input[name="auth_mode"][value="open"]').checked = true;
    document.getElementById('host-mode').value = 'multi-auth';
    
    // Navigate to VLAN step
    goToStep(4);
}

function downloadDiagram() {
    const link = document.createElement('a');
    link.href = 'assets/diagrams/network-diagram.png';
    link.download = 'portnox-802.1x-deployment-diagram.png';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}
// Dot1Xer Supreme - Portnox Cloud Integration

function setupPortnoxIntegration() {
    const portnoxConnectButton = document.getElementById('portnox-connect-button');
    if (portnoxConnectButton) {
        portnoxConnectButton.addEventListener('click', function() {
            const portnoxApiKey = document.getElementById('portnox-api-key').value;
            const portnoxTenant = document.getElementById('portnox-tenant').value;
            if (!portnoxApiKey || !portnoxTenant) {
                showError('Please enter both Portnox API Key and Tenant ID.');
                return;
            }
            this.textContent = 'Connecting...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Connect';
                this.disabled = false;
                showSuccess('Successfully connected to Portnox Cloud! API integration is now enabled.');
                enablePortnoxFeatures();
            }, 1500);
        });
    }
    
    const createRadiusButton = document.getElementById('portnox-create-radius-button');
    if (createRadiusButton) {
        createRadiusButton.addEventListener('click', function() {
            const regionSelect = document.getElementById('portnox-region-select');
            if (!regionSelect || !regionSelect.value) {
                showError('Please select a region for your RADIUS server.');
                return;
            }
            this.textContent = 'Creating...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Create RADIUS Server';
                this.disabled = false;
                showSuccess('RADIUS server created successfully in ' + regionSelect.options[regionSelect.selectedIndex].text);
                const radiusDetails = document.getElementById('portnox-radius-details');
                if (radiusDetails) {
                    radiusDetails.style.display = 'block';
                    document.getElementById('radius-ip').textContent = generateRandomIP();
                    document.getElementById('radius-auth-port').textContent = '1812';
                    document.getElementById('radius-acct-port').textContent = '1813';
                    document.getElementById('radius-secret').textContent = generateRandomSecret();
                }
                
                // Add to configurator RADIUS servers
                const radiusIpField = document.getElementById('radius-ip-1');
                const radiusKeyField = document.getElementById('radius-key-1');
                if (radiusIpField && radiusKeyField) {
                    radiusIpField.value = document.getElementById('radius-ip').textContent;
                    radiusKeyField.value = document.getElementById('radius-secret').textContent;
                }
            }, 2000);
        });
    }
    
    const createMabButton = document.getElementById('portnox-create-mab-button');
    if (createMabButton) {
        createMabButton.addEventListener('click', function() {
            const macAddress = document.getElementById('portnox-mac-address').value;
            const deviceName = document.getElementById('portnox-device-name').value;
            if (!macAddress || !deviceName) {
                showError('Please enter both MAC address and device name.');
                return;
            }
            if (!validateMacAddress(macAddress)) {
                showError('Please enter a valid MAC address (e.g., 00:11:22:33:44:55).');
                return;
            }
            this.textContent = 'Creating...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Create MAB Account';
                this.disabled = false;
                showSuccess('MAB account created successfully for ' + deviceName);
                addMabAccount(macAddress, deviceName);
                document.getElementById('portnox-mac-address').value = '';
                document.getElementById('portnox-device-name').value = '';
                
                // Enable MAB in configurator
                const useMabCheckbox = document.getElementById('use-mab');
                if (useMabCheckbox) {
                    useMabCheckbox.checked = true;
                }
                const authMethodSelect = document.getElementById('auth-method');
                if (authMethodSelect && authMethodSelect.value === 'dot1x-only') {
                    authMethodSelect.value = 'dot1x-mab';
                }
            }, 1500);
        });
    }
    
    const generateReportButton = document.getElementById('portnox-generate-report-button');
    if (generateReportButton) {
        generateReportButton.addEventListener('click', function() {
            const reportType = document.getElementById('portnox-report-type').value;
            if (!reportType) {
                showError('Please select a report type.');
                return;
            }
            this.textContent = 'Generating...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Generate Report';
                this.disabled = false;
                showSuccess('Report generated successfully. Ready for download.');
                const downloadReportButton = document.getElementById('portnox-download-report-button');
                if (downloadReportButton) {
                    downloadReportButton.style.display = 'inline-block';
                }
            }, 2500);
        });
    }
    
    const downloadReportButton = document.getElementById('portnox-download-report-button');
    if (downloadReportButton) {
        downloadReportButton.addEventListener('click', function() {
            this.textContent = 'Downloading...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Download Report';
                this.disabled = false;
                const reportType = document.getElementById('portnox-report-type').value;
                const reportName = getReportName(reportType);
                const csvContent = generateSampleReport(reportType);
                const blob = new Blob([csvContent], { type: 'text/csv' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = reportName + '.csv';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            }, 1000);
        });
    }
    
    const generatePocButton = document.getElementById('portnox-generate-poc-button');
    if (generatePocButton) {
        generatePocButton.addEventListener('click', function() {
            const clientName = document.getElementById('portnox-client-name').value;
            const environment = document.getElementById('portnox-environment').value;
            if (!clientName || !environment) {
                showError('Please enter both client name and environment details.');
                return;
            }
            this.textContent = 'Generating...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Generate POC Report';
                this.disabled = false;
                showSuccess('POC report for "' + clientName + '" generated successfully.');
                const downloadPocButton = document.getElementById('portnox-download-poc-button');
                if (downloadPocButton) {
                    downloadPocButton.style.display = 'inline-block';
                }
                
                // Check for configuration integration
                const includeConfig = document.getElementById('portnox-include-config').checked;
                if (includeConfig) {
                    // Generate configurations for all selected vendors
                    const vendorList = document.getElementById('vendor-list');
                    if (vendorList && vendorList.children.length > 0) {
                        // Switch to configurator and generate configs
                        const configuratorTab = document.querySelector('.tab-btn[data-tab="configurator"]');
                        if (configuratorTab) {
                            configuratorTab.click();
                        }
                        generateAllVendorConfigs();
                    }
                }
            }, 3000);
        });
    }

    const generateTemplatesButton = document.getElementById('portnox-generate-templates-button');
    if (generateTemplatesButton) {
        generateTemplatesButton.addEventListener('click', function() {
            let environment = {};
            try {
                const switchVendor = document.getElementById('switch-vendor')?.value || 'cisco';
                const wirelessVendor = document.getElementById('wireless-vendor')?.value || 'cisco';
                const mdmProvider = document.getElementById('mdm-provider')?.value || 'none';
                const idpProvider = document.getElementById('idp-provider')?.value || 'none';
                environment = { switchVendor, wirelessVendor, mdmProvider, idpProvider };
            } catch (e) {
                console.error('Error reading environment details:', e);
            }
            this.textContent = 'Generating...';
            this.disabled = true;
            setTimeout(() => {
                this.textContent = 'Generate Templates';
                this.disabled = false;
                showSuccess('Deployment templates generated successfully based on your environment.');
                const templatesContainer = document.getElementById('portnox-templates-container');
                if (templatesContainer) {
                    templatesContainer.style.display = 'block';
                    templatesContainer.innerHTML = generateDeploymentTemplates(environment);
                }
                
                // Add templates to multi-vendor configuration if enabled
                if (environment.switchVendor) {
                    const multiVendorToggle = document.getElementById('multi-vendor-toggle');
                    if (multiVendorToggle) {
                        multiVendorToggle.checked = true;
                        const event = new Event('change');
                        multiVendorToggle.dispatchEvent(event);
                        
                        // Add vendor to list if not already there
                        addVendorToList(environment.switchVendor, getPlatformForVendor(environment.switchVendor));
                        
                        if (environment.wirelessVendor && environment.wirelessVendor !== environment.switchVendor) {
                            addVendorToList(environment.wirelessVendor, getPlatformForVendor(environment.wirelessVendor));
                        }
                    }
                }
            }, 2500);
        });
    }
}

function getPlatformForVendor(vendor) {
    switch (vendor) {
        case 'cisco': return 'ios-xe';
        case 'aruba': return 'aos-cx';
        case 'juniper': return 'ex';
        case 'fortinet': return 'fortiswitch';
        case 'arista': return 'eos';
        case 'extreme': return 'exos';
        case 'huawei': return 'vrp';
        case 'alcatel': return 'omniswitch';
        case 'ubiquiti': return 'unifi';
        case 'hp': return 'procurve';
        case 'paloalto': return 'panos';
        case 'checkpoint': return 'gaia';
        case 'sonicwall': return 'sonicos';
        case 'portnox': return 'cloud';
        default: return 'default';
    }
}

function validateMacAddress(mac) {
    return /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/.test(mac);
}

function generateRandomIP() {
    return '10.' + Math.floor(Math.random() * 256) + '.' + 
           Math.floor(Math.random() * 256) + '.' + 
           Math.floor(Math.random() * 256);
}

function generateRandomSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < 24; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

function enablePortnoxFeatures() {
    document.querySelectorAll('.portnox-feature').forEach(section => {
        section.style.display = 'block';
    });
    const vendorSelect = document.getElementById('vendor-select');
    if (vendorSelect) {
        let hasPortnox = false;
        for (let i = 0; i < vendorSelect.options.length; i++) {
            if (vendorSelect.options[i].value === 'portnox') {
                hasPortnox = true;
                break;
            }
        }
        if (!hasPortnox) {
            addOption(vendorSelect, 'portnox', 'Portnox Cloud');
        }
    }
}

function addMabAccount(mac, name) {
    const tbody = document.getElementById('portnox-mab-accounts-body');
    if (!tbody) return;
    const row = document.createElement('tr');
    const macCell = document.createElement('td');
    macCell.textContent = mac;
    row.appendChild(macCell);
    const nameCell = document.createElement('td');
    nameCell.textContent = name;
    row.appendChild(nameCell);
    const dateCell = document.createElement('td');
    dateCell.textContent = new Date().toLocaleDateString();
    row.appendChild(dateCell);
    const statusCell = document.createElement('td');
    statusCell.textContent = 'Active';
    row.appendChild(statusCell);
    const actionCell = document.createElement('td');
    const actionButton = document.createElement('button');
    actionButton.textContent = 'Manage';
    actionButton.className = 'btn btn-sm portnox-btn';
    actionButton.addEventListener('click', function() {
        alert('Management interface for ' + name + ' would open here.');
    });
    actionCell.appendChild(actionButton);
    row.appendChild(actionCell);
    tbody.appendChild(row);
}

function getReportName(reportType) {
    switch(reportType) {
        case 'device-inventory': return 'Device_Inventory_Report';
        case 'authentication-events': return 'Authentication_Events_Report';
        case 'user-activity': return 'User_Activity_Report';
        case 'security-incidents': return 'Security_Incidents_Report';
        case 'compliance': return 'Compliance_Report';
        default: return 'Portnox_Report';
    }
}

function generateSampleReport(reportType) {
    let csvContent = '';
    switch(reportType) {
        case 'device-inventory':
            csvContent = "Device ID,Device Name,MAC Address,IP Address,Status\n" +
                         "DEV001,Printer-Floor1,00:11:22:33:44:55,192.168.1.100,Active\n" +
                         "DEV002,VoIP-Phone-101,00:11:22:33:44:56,192.168.1.101,Active\n";
            break;
        case 'authentication-events':
            csvContent = "Event ID,Timestamp,Device MAC,User,Status\n" +
                         "EVT001,2023-10-01 10:00:00,00:11:22:33:44:55,user1,Success\n" +
                         "EVT002,2023-10-01 10:05:00,00:11:22:33:44:56,user2,Failed\n";
            break;
        case 'user-activity':
            csvContent = "User ID,Username,Last Login,Device Count,Status\n" +
                         "USR001,user1,2023-10-01 10:00:00,2,Active\n" +
                         "USR002,user2,2023-10-01 09:00:00,1,Active\n";
            break;
        case 'security-incidents':
            csvContent = "Incident ID,Timestamp,Device MAC,Description,Severity\n" +
                         "INC001,2023-10-01 10:00:00,00:11:22:33:44:55,Unauthorized Access Attempt,High\n";
            break;
        case 'compliance':
            csvContent = "Device ID,Device Name,Compliance Status,Last Check\n" +
                         "DEV001,Printer-Floor1,Compliant,2023-10-01 10:00:00\n" +
                         "DEV002,VoIP-Phone-101,Non-Compliant,2023-10-01 10:00:00\n";
            break;
        default:
            csvContent = "Report Type,Generated On\n" +
                         "Unknown," + new Date().toISOString() + "\n";
    }
    return csvContent;
}

function generateDeploymentTemplates(environment) {
    const switchVendor = environment.switchVendor || 'cisco';
    const wirelessVendor = environment.wirelessVendor || 'cisco';
    const mdmProvider = environment.mdmProvider || 'none';
    const idpProvider = environment.idpProvider || 'none';
    let templates = '<div class="poc-templates">';
    templates += `
        <div class="template-card">
            <div class="template-header">Prerequisites Checklist</div>
            <div class="template-body">
                <p>A comprehensive checklist of prerequisites for Portnox Cloud deployment, customized for ${switchVendor} switches and ${wirelessVendor} wireless infrastructure.</p>
                <button class="template-toggle" data-template="prereq-template">Show Details</button>
                <div id="prereq-template" style="display: none; margin-top: 15px;">
                    <ul>
                        <li>Network infrastructure requirements</li>
                        <li>RADIUS server configuration for ${switchVendor}</li>
                        <li>Firewall requirements</li>
                        <li>${mdmProvider !== 'none' ? mdmProvider + ' integration requirements' : 'MDM integration options'}</li>
                        <li>${idpProvider !== 'none' ? idpProvider + ' integration steps' : 'Identity provider options'}</li>
                    </ul>
                    <div class="docs-links">
                        <a href="https://www.portnox.com/docs/prerequisites" target="_blank" class="doc-link">
                            <i>··</i> Official Prerequisites Documentation
                        </a>
                    </div>
                </div>
            </div>
            <div class="template-footer">
                <button class="template-download portnox-btn" data-template="prereq-template" data-type="prerequisites">Download</button>
            </div>
        </div>`;
    templates += `
        <div class="template-card">
            <div class="template-header">Deployment Plan</div>
            <div class="template-body">
                <p>Step-by-step deployment plan for Portnox Cloud in your environment, with specific instructions for ${switchVendor} and ${wirelessVendor} devices.</p>
                <button class="template-toggle" data-template="deploy-template">Show Details</button>
                <div id="deploy-template" style="display: none; margin-top: 15px;">
                    <ol>
                        <li>Initial setup of Portnox Cloud tenant</li>
                        <li>RADIUS server configuration</li>
                        <li>${switchVendor} switch configuration for 802.1X</li>
                        <li>${wirelessVendor} wireless configuration</li>
                        <li>Client configuration and testing</li>
                        <li>Production deployment phases</li>
                    </ol>
                    <div class="docs-links">
                        <a href="https://www.portnox.com/docs/deployment" target="_blank" class="doc-link">
                            <i>··</i> Deployment Documentation
                        </a>
                        <a href="https://www.portnox.com/docs/switch-configuration/${switchVendor}" target="_blank" class="doc-link">
                            <i>··</i> ${switchVendor} Configuration Guide
                        </a>
                    </div>
                </div>
            </div>
            <div class="template-footer">
                <button class="template-download portnox-btn" data-template="deploy-template" data-type="deployment">Download</button>
            </div>
        </div>`;
    
    // Add testing plan with vendor-specific details
    templates += `
        <div class="template-card">
            <div class="template-header">Testing Plan</div>
            <div class="template-body">
                <p>Comprehensive testing methodology for validating 802.1X deployment with ${switchVendor} switches and Portnox Cloud.</p>
                <button class="template-toggle" data-template="test-template">Show Details</button>
                <div id="test-template" style="display: none; margin-top: 15px;">
                    <ol>
                        <li>Initial Open Mode testing</li>
                        <li>${switchVendor}-specific monitor mode validation</li>
                        <li>Authentication method verification for all client types</li>
                        <li>Dynamic VLAN assignment testing</li>
                        <li>CoA and policy enforcement verification</li>
                    </ol>
                    <div class="docs-links">
                        <a href="https://www.portnox.com/docs/testing" target="_blank" class="doc-link">
                            <i>··</i> Testing Documentation
                        </a>
                    </div>
                </div>
            </div>
            <div class="template-footer">
                <button class="template-download portnox-btn" data-template="test-template" data-type="testing">Download</button>
            </div>
        </div>`;
    templates += '</div>';
    
    // Add template toggle functionality
    setTimeout(() => {
        document.querySelectorAll('.template-toggle').forEach(button => {
            button.addEventListener('click', function() {
                const templateId = this.getAttribute('data-template');
                const templateContent = document.getElementById(templateId);
                if (templateContent) {
                    const isVisible = templateContent.style.display !== 'none';
                    templateContent.style.display = isVisible ? 'none' : 'block';
                    this.textContent = isVisible ? 'Show Details' : 'Hide Details';
                }
            });
        });
        
        document.querySelectorAll('.template-download').forEach(button => {
            button.addEventListener('click', function() {
                const templateType = this.getAttribute('data-type');
                const templateId = this.getAttribute('data-template');
                const templateContent = document.getElementById(templateId);
                
                let content = '';
                if (templateContent) {
                    content = templateContent.textContent;
                } else {
                    content = 'Placeholder content for ' + templateType;
                }
                
                const blob = new Blob([content], { type: 'text/plain' });
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = templateType + '_template.txt';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            });
        });
    }, 500);
    
    return templates;
}
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
// Dot1Xer Supreme - Project Details Functionality

// Initialize project details toggle
function initProjectDetails() {
    const projectDetailToggle = document.getElementById('project-detail-toggle');
    const projectDetailsSection = document.getElementById('project-details-section');

    if (projectDetailToggle && projectDetailsSection) {
        projectDetailToggle.addEventListener('change', function() {
            projectDetailsSection.style.display = this.checked ? 'block' : 'none';
        });
    }

    // Add event listener for project details fields to update the header in the config
    const projectFields = document.querySelectorAll('#project-details-section input');
    projectFields.forEach(field => {
        field.addEventListener('input', function() {
            // When a project field is updated, this will trigger the config header to update
            // when generating the configuration
            const generateButton = document.getElementById('generate-btn');
            if (generateButton) {
                // Visual indicator that the project details will be included
                generateButton.textContent = projectDetailToggle.checked ?
                    'Generate Configuration with Project Details' :
                    'Generate Configuration';
            }
        });
    });
}

// Get project details as a formatted string for config
function getProjectDetailsString() {
    const includeProjectDetails = document.getElementById('project-detail-toggle')?.checked;
    if (!includeProjectDetails) return '';

    const companyName = document.getElementById('company-name')?.value || '';
    const sfdcOpportunity = document.getElementById('sfdc-opportunity')?.value || '';
    const seEmail = document.getElementById('se-email')?.value || '';
    const customerEmail = document.getElementById('customer-email')?.value || '';
    const date = new Date().toISOString().split('T')[0];

    let details = '! Project Details\n';
    if (companyName) details += `! Company: ${companyName}\n`;
    if (sfdcOpportunity) details += `! SFDC Opportunity: ${sfdcOpportunity}\n`;
    if (seEmail) details += `! SE Email: ${seEmail}\n`;
    if (customerEmail) details += `! Customer Email: ${customerEmail}\n`;
    details += `! Date Generated: ${date}\n\n`;

    return details;
}

// Wired/Wireless Subtab Handling
function initConfigSubtabs() {
    document.querySelectorAll('.config-subtab').forEach(button => {
        button.addEventListener('click', function() {
            const subtab = this.getAttribute('data-subtab');
            document.querySelectorAll('.config-subtab').forEach(btn => btn.classList.remove('active'));
            document.querySelectorAll('.subtab-content').forEach(content => content.style.display = 'none');
            this.classList.add('active');
            document.getElementById(`${subtab}-content`).style.display = 'block';
            updateVendorOptions(subtab);
        });
    });
    // Initialize wired as default
    updateVendorOptions('wired');
}

// Update vendor options for wired/wireless
function updateVendorOptions(type) {
    const vendorSelect = document.getElementById(`vendor-select-${type}`);
    const platformSelect = document.getElementById(`platform-select-${type}`);
    const platformDescription = document.getElementById(`platform-description-${type}`);
    if (!vendorSelect || !platformSelect || !platformDescription) return;

    // Populate vendor options (same as original)
    const vendors = ['cisco', 'aruba', 'juniper', 'fortinet', 'arista', 'extreme', 'huawei', 'alcatel', 'ubiquiti', 'hp', 'dell', 'netgear', 'ruckus', 'brocade', 'paloalto', 'checkpoint', 'sonicwall', 'portnox'];
    vendorSelect.innerHTML = '';
    vendors.forEach(v => addOption(vendorSelect, v, v.charAt(0).toUpperCase() + v.slice(1)));
    vendorSelect.addEventListener('change', () => updatePlatformOptions(type));
    updatePlatformOptions(type);
}

// Modify updatePlatformOptions to handle wired/wireless
function updatePlatformOptions(type) {
    const vendorSelect = document.getElementById(`vendor-select-${type}`);
    const platformSelect = document.getElementById(`platform-select-${type}`);
    const platformDescription = document.getElementById(`platform-description-${type}`);
    if (!vendorSelect || !platformSelect || !platformDescription) return;
    platformSelect.innerHTML = '';
    const vendor = vendorSelect.value;

    const wiredPlatforms = {
        'cisco': ['ios-xe', 'ios', 'nx-os'],
        'aruba': ['aos-cx', 'aos-switch'],
        'juniper': ['ex', 'qfx'],
        'fortinet': ['fortiswitch'],
        'arista': ['eos'],
        'extreme': ['exos'],
        'huawei': ['vrp'],
        'hp': ['procurve', 'comware'],
        'dell': ['powerswitch']
    };
    const wirelessPlatforms = {
        'cisco': ['wlc'],
        'aruba': ['aruba-controller', 'aruba-instant'],
        'fortinet': ['fortiwlc'],
        'ubiquiti': ['unifi'],
        'ruckus': ['smartzone'],
        'extreme': ['xiq']
    };

    let platforms = type === 'wired' ? wiredPlatforms[vendor] || [] : wirelessPlatforms[vendor] || [];
    platforms.forEach(p => addOption(platformSelect, p, p.toUpperCase()));
    platformDescription.innerHTML = platforms.length > 0 
        ? `<p>Available ${type} platforms for ${vendor}.</p>` 
        : '<p>No platforms available for this type.</p>';
}

// AI API Key Management
document.getElementById('ai-provider').addEventListener('change', function() {
    const provider = this.value;
    document.getElementById('selected-provider').textContent = provider;
    const apiKey = getApiKey(provider); // Assume existing function
    document.getElementById('ai-api-key').placeholder = apiKey ? 'API key is set' : 'Enter API key';
});

document.getElementById('save-ai-api-key').addEventListener('click', function() {
    const provider = document.getElementById('ai-provider').value;
    const apiKey = document.getElementById('ai-api-key').value;
    if (apiKey) {
        setApiKey(provider, apiKey); // Assume existing function
        showSuccess(`API key for ${provider} saved successfully.`);
        document.getElementById('ai-api-key').value = '';
    } else {
        showError('Please enter an API key.');
    }
});

document.getElementById('test-ai-connection').addEventListener('click', function() {
    const provider = document.getElementById('ai-provider').value;
    const apiKey = getApiKey(provider);
    if (!apiKey) {
        showError('API key not set for this provider.');
    } else {
        showSuccess('Connection test successful for ' + provider);
    }
});

// TACACS Server Collection
function getTacacsServers() {
    const tacacsServers = [];
    const tacacsServerElements = document.querySelectorAll('.tacacs-server-entry');
    tacacsServerElements.forEach(server => {
        const index = server.dataset.index;
        const ip = document.getElementById(`tacacs-ip-${index}`).value;
        const key = document.getElementById(`tacacs-key-${index}`).value;
        const port = document.getElementById(`tacacs-port-${index}`).value;
        const timeout = document.getElementById(`tacacs-timeout-${index}`).value;
        if (ip && key) {
            tacacsServers.push({ ip, key, port, timeout });
        }
    });
    return tacacsServers;
}

// Help Tips
const helpTips = {
    "platform": "Select the vendor and platform for your network devices. Wired focuses on switches, while Wireless targets controllers or APs.",
    "radius": "RADIUS servers handle authentication, authorization, and accounting. Configure multiple servers for redundancy.",
    "tacacs": "TACACS+ provides device administration authentication, often used alongside RADIUS for user access.",
    "vlan": "VLANs segment your network. Data VLAN is required; others are optional for specific use cases."
};

// Update generateVendorConfig to include TACACS and help tips
const originalGenerateVendorConfig = generateVendorConfig;
generateVendorConfig = function(vendor, platform) {
    const tacacsServers = getTacacsServers();
    let config = originalGenerateVendorConfig(vendor, platform);
    
    // Add help tips
    config = config.replace('! 802.1X Configuration', `! ${helpTips.platform}\n! 802.1X Configuration`);
    if (radiusServers.length > 0) {
        config = config.replace('! RADIUS Server Configuration', `! ${helpTips.radius}\n! RADIUS Server Configuration`);
    }
    if (tacacsServers.length > 0) {
        config += `\n! ${helpTips.tacacs}\n! TACACS+ Server Configuration\n`;
        tacacsServers.forEach((server, index) => {
            if (vendor === 'cisco' && platform.includes('ios')) {
                config += `tacacs server TACACS-SRV-${index + 1}\n`;
                config += ` address ipv4 ${server.ip}\n`;
                config += ` key ${server.key}\n`;
                config += ` port ${server.port}\n`;
                config += ` timeout ${server.timeout}\n`;
            }
        });
        if (vendor === 'cisco' && platform.includes('ios')) {
            config += `aaa group server tacacs+ TACACS-SERVERS\n`;
            tacacsServers.forEach((_, index) => config += ` server name TACACS-SRV-${index + 1}\n`);
            config += `aaa authentication login default group TACACS-SERVERS local\n`;
        }
    }
    config = config.replace('! VLAN Configuration', `! ${helpTips.vlan}\n! VLAN Configuration`);
    return config;
};

// Update init function to include subtabs
const originalInit = document.addEventListener.bind(document, 'DOMContentLoaded');
document.addEventListener('DOMContentLoaded', function() {
    originalInit.arguments[1]();
    initConfigSubtabs();
});
