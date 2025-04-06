/* Improved Accordion Initialization */
function initAccordions() {
  const headers = document.querySelectorAll('.accordion-header');
  headers.forEach(header => {
    header.addEventListener("click", function() {
      const content = this.nextElementSibling;
      const icon = this.querySelector(".accordion-icon");
      // Close all other accordions
      document.querySelectorAll(".accordion-content").forEach(acc => {
        if (acc !== content) {
          acc.classList.remove("active");
          acc.style.display = "none";
          const otherHeader = acc.previousElementSibling;
          if (otherHeader) {
            otherHeader.classList.remove("active");
            const otherIcon = otherHeader.querySelector(".accordion-icon");
            if (otherIcon) otherIcon.textContent = "+";
          }
        }
      });
      // Toggle current accordion
      content.classList.toggle("active");
      this.classList.toggle("active");
      if (content.classList.contains("active")) {
        content.style.display = "block";
        if (icon) icon.textContent = "-";
      } else {
        content.style.display = "none";
        if (icon) icon.textContent = "+";
      }
    });
  });
}
/* Improved Accordion Initialization */
/* Improved Accordion Initialization */
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
