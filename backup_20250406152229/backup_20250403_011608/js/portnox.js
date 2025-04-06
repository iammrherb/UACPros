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
