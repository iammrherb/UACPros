/**
 * Dot1Xer Supreme - Main JavaScript File
 * Version: 2.0.0
 * 
 * This file contains the core functionality of the Dot1Xer Supreme application.
 */
document.addEventListener('DOMContentLoaded', function() {
    console.log('Dot1Xer Supreme initialized');
    initTabNavigation();
    initPlatformToggle();
    initVendorGrid();
    initDiscoveryTabs();
    initEventListeners();
    checkSavedConfigurations();
    if (typeof initAIIntegration === 'function') initAIIntegration();
    if (typeof initPortnoxIntegration === 'function') initPortnoxIntegration();
});

function initTabNavigation() {
    const tabLinks = document.querySelectorAll('.nav-tabs a');
    const tabContents = document.querySelectorAll('.tab-content');
    tabLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            tabLinks.forEach(l => l.classList.remove('active'));
            this.classList.add('active');
            const tabId = this.getAttribute('data-tab');
            tabContents.forEach(content => content.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
        });
    });
}

function initPlatformToggle() {
    const platformButtons = document.querySelectorAll('.platform-toggle-btn');
    const wiredVendors = document.getElementById('wired-vendors');
    const wirelessVendors = document.getElementById('wireless-vendors');
    platformButtons.forEach(button => {
        button.addEventListener('click', function() {
            platformButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            const platform = this.getAttribute('data-platform');
            wiredVendors.style.display = platform === 'wired' ? 'grid' : 'none';
            wirelessVendors.style.display = platform === 'wireless' ? 'grid' : 'none';
            document.querySelectorAll('.vendor-card').forEach(card => card.classList.remove('selected'));
            document.getElementById('config-form-container').style.display = 'none';
            document.getElementById('config-output-container').style.display = 'none';
        });
    });
}

function initVendorGrid() {
    if (typeof vendorData === 'undefined') {
        console.error('Vendor data not found.');
        return;
    }
    const wiredVendorsContainer = document.getElementById('wired-vendors');
    const wirelessVendorsContainer = document.getElementById('wireless-vendors');
    wiredVendorsContainer.innerHTML = '';
    wirelessVendorsContainer.innerHTML = '';
    vendorData.wired.forEach(vendor => wiredVendorsContainer.appendChild(createVendorCard(vendor, 'wired')));
    vendorData.wireless.forEach(vendor => wirelessVendorsContainer.appendChild(createVendorCard(vendor, 'wireless')));
}

function createVendorCard(vendor, platform) {
    const card = document.createElement('div');
    card.className = 'vendor-card';
    card.setAttribute('data-vendor', vendor.id);
    card.setAttribute('data-platform', platform);
    card.innerHTML = `
        <div class="vendor-card-header">${vendor.name}</div>
        <div class="vendor-card-body">
            <img class="vendor-logo" src="assets/logos/${vendor.logo}" alt="${vendor.name}">
            <p class="vendor-description">${vendor.description}</p>
            <button class="btn btn-primary btn-sm">Select</button>
        </div>
    `;
    card.addEventListener('click', () => selectVendor(vendor, platform));
    return card;
}

function selectVendor(vendor, platform) {
    document.querySelectorAll('.vendor-card').forEach(card => card.classList.remove('selected'));
    document.querySelector(`.vendor-card[data-vendor="${vendor.id}"][data-platform="${platform}"]`).classList.add('selected');
    loadVendorForm(vendor, platform);
}

function loadVendorForm(vendor, platform) {
    const formContainer = document.getElementById('config-form-container');
    formContainer.style.display = 'block';
    if (typeof loadTemplate === 'function') {
        loadTemplate(vendor.id, platform, formContainer, () => initFormEventListeners(vendor, platform));
    } else {
        formContainer.innerHTML = '<div class="alert alert-warning">Form templates not available.</div>';
    }
    document.getElementById('config-output-container').style.display = 'none';
}

function initFormEventListeners(vendor, platform) {
    const generateBtn = document.getElementById('generate-config-btn');
    if (generateBtn) generateBtn.addEventListener('click', () => generateConfiguration(vendor, platform));
    const resetBtn = document.getElementById('reset-form-btn');
    if (resetBtn) resetBtn.addEventListener('click', resetConfigurationForm);
    const saveTemplateBtn = document.getElementById('save-template-btn');
    if (saveTemplateBtn) saveTemplateBtn.addEventListener('click', () => saveAsTemplate(vendor, platform));
    const aiAssistBtn = document.getElementById('ai-assist-btn');
    if (aiAssistBtn) aiAssistBtn.addEventListener('click', () => openAIAssistant(vendor, platform));
}

function initDiscoveryTabs() {
    const discoveryTabBtns = document.querySelectorAll('.discovery-tab-btn');
    const discoveryTabContents = document.querySelectorAll('.discovery-tab-content');
    discoveryTabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            discoveryTabBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            const tabId = this.getAttribute('data-tab');
            discoveryTabContents.forEach(content => content.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
        });
    });
}

function initEventListeners() {
    const startScanBtn = document.getElementById('start-scan');
    if (startScanBtn) startScanBtn.addEventListener('click', startNetworkScan);
    const snmpDiscoveryCheckbox = document.getElementById('snmp-discovery');
    const snmpOptionsDiv = document.getElementById('snmp-options');
    if (snmpDiscoveryCheckbox && snmpOptionsDiv) {
        snmpDiscoveryCheckbox.addEventListener('change', function() {
            snmpOptionsDiv.style.display = this.checked ? 'block' : 'none';
        });
    }
}

function startNetworkScan() { console.log('Network scan functionality to be implemented'); }
function checkSavedConfigurations() { console.log('Saved configurations check to be implemented'); }
function generateConfiguration(vendor, platform) { console.log(`Generating config for ${vendor.name} (${platform})`); }
function resetConfigurationForm() { console.log('Resetting form'); }
function saveAsTemplate(vendor, platform) { console.log(`Saving template for ${vendor.name} (${platform})`); }
function openAIAssistant(vendor, platform) { console.log(`Opening AI assistant for ${vendor.name} (${platform})`); }
