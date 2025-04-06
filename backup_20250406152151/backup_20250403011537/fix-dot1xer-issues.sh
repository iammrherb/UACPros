#!/bin/bash
# Update script for Dot1Xer Supreme
# This script updates the UI structure, specifically moving the Wired and Wireless tabs
# to become subtabs under the Configurator tab and improves section visibility.

# Set colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
echo -e "${GREEN}=========================================="
echo -e "      Dot1Xer Supreme Update Script       "
echo -e "==========================================${NC}"

# Create backup folder
BACKUP_DIR="./backup_$(date +"%Y%m%d_%H%M%S")"
echo -e "${YELLOW}Creating backup directory: ${BACKUP_DIR}${NC}"
mkdir -p "$BACKUP_DIR"

# Backup current files
echo -e "${YELLOW}Backing up current files...${NC}"
cp -r css "$BACKUP_DIR/" 2>/dev/null || echo -e "${YELLOW}No css directory found, skipping backup${NC}"
cp -r js "$BACKUP_DIR/" 2>/dev/null || echo -e "${YELLOW}No js directory found, skipping backup${NC}"
cp index.html "$BACKUP_DIR/" 2>/dev/null || echo -e "${YELLOW}No index.html found, skipping backup${NC}"
# Create or update CSS directory
mkdir -p css
echo -e "${GREEN}Creating updated CSS styles...${NC}"

# Create or update JS directory
mkdir -p js
echo -e "${GREEN}Creating updated JavaScript files...${NC}"
# Update or create main.css with improved contrast
cat > css/main.css << 'EOF'
/* Main Styles for Dot1Xer Supreme */
:root {
    --primary-color: #6300c4;
    --primary-dark: #4a0091;
    --primary-light: #9951ff;
    --secondary-color: #00b894;
    --tertiary-color: #e84393;
    --light-gray: #f8f9fa;
    --medium-gray: #dee2e6;
    --dark-gray: #495057;
    --danger-color: #e74c3c;
    --warning-color: #f39c12;
    --success-color: #2ecc71;
    --border-radius: 6px;
    --box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    --transition: all 0.3s ease;
    --text-color: #212529;
    --bg-color: #ffffff;
    --portnox-purple: #6c27be;
    --portnox-dark: #4c1d80;
    --portnox-light: #a776e0;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: var(--text-color);
    background-color: var(--light-gray);
    margin: 0;
    padding: 0;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 15px;
}

header {
    background: linear-gradient(to right, #4a148c, #6a1b9a, #8e24aa);
    color: white;
    padding: 1em;
    text-align: center;
}

.logo {
    font-size: 24px;
    font-weight: bold;
}

footer {
    text-align: center;
    padding: 20px 0;
    margin-top: 30px;
    background-color: #f1f1f1;
    border-top: 1px solid #ddd;
}
EOF
# Update accordion.css with better visibility
cat > css/accordion.css << 'EOF'
/* Enhanced Accordion Styles */
.accordion-container {
    width: 100%;
    margin-bottom: 20px;
    border-radius: 5px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.accordion-header {
    background-color: #6300c4;
    color: white;
    cursor: pointer;
    padding: 15px;
    width: 100%;
    text-align: left;
    border: none;
    outline: none;
    transition: 0.4s;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-weight: bold;
    border-bottom: 1px solid #ddd;
    position: relative;
    user-select: none;
}

.accordion-header:hover {
    background-color: #4a0091;
}

.accordion-header.active {
    background-color: #4a0091;
    color: white;
}

.accordion-content {
    padding: 0;
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.3s ease-out;
    background-color: white;
}

.accordion-content.active {
    display: block !important;
}

.accordion-icon {
    font-size: 18px;
    font-weight: bold;
    transition: transform 0.3s ease;
    margin-left: 10px;
    min-width: 20px;
    text-align: center;
    color: white;
}

.accordion-header.active .accordion-icon {
    transform: rotate(90deg);
}

.accordion-inner {
    padding: 15px;
}

/* Improve visibility of accordion state */
.accordion-header::after {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    width: 4px;
    height: 100%;
    background-color: #2E8B57;
    transition: background-color 0.3s ease;
}

.accordion-header.active::after {
    background-color: #00b894;
}
EOF
# Update styles.css for better visibility and the subtabs
cat > css/styles.css << 'EOF'
/* styles.css for Dot1Xer Supreme */
:root {
    --primary-color: #6300c4;
    --primary-dark: #4a0091;
    --primary-light: #9951ff;
    --secondary-color: #00b894;
    --light-gray: #f8f9fa;
    --medium-gray: #dee2e6;
    --dark-gray: #495057;
    --danger-color: #e74c3c;
    --warning-color: #f39c12;
    --success-color: #2ecc71;
    --border-radius: 6px;
    --box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    --transition: all 0.3s ease;
    --text-color: #212529;
    --bg-color: #ffffff;
    --portnox-purple: #6c27be;
    --portnox-dark: #4c1d80;
    --portnox-light: #a776e0;
}

/* Tab container with subtabs support */
.tab-container {
    margin-bottom: 30px;
}

.tabs {
    display: flex;
    list-style: none;
    padding: 0;
    margin: 0;
    border-bottom: 1px solid #ddd;
    flex-wrap: wrap;
}

.tabs li {
    padding: 10px 20px;
    cursor: pointer;
    border: 1px solid transparent;
    border-bottom: none;
    margin-bottom: -1px;
    background-color: #f1f1f1;
    transition: background-color 0.3s;
}

.tabs li:hover {
    background-color: #e0e0e0;
}

.tabs li.active {
    background-color: var(--primary-color);
    color: white;
    border-color: var(--primary-color);
}

.tab-content {
    display: none;
    padding: 20px;
    border: 1px solid #ddd;
    border-top: none;
    background-color: white;
}

.tab-content.active {
    display: block;
}

/* Configurator Subtabs */
#configurator-subtabs {
    display: none;
    padding: 10px 20px;
    background-color: #f8f8f8;
    border-left: 1px solid #ddd;
    border-right: 1px solid #ddd;
}

.configurator-subtabs {
    display: flex;
    list-style: none;
    padding: 0;
    margin: 0;
}

.configurator-subtab {
    padding: 8px 15px;
    cursor: pointer;
    background-color: #e8e8e8;
    margin-right: 5px;
    border-radius: 4px 4px 0 0;
    transition: background-color 0.3s;
}

.configurator-subtab:hover {
    background-color: #d8d8d8;
}

.configurator-subtab.active {
    background-color: var(--secondary-color);
    color: white;
}

.configurator-subtab-content {
    display: none;
    padding: 15px;
    background-color: white;
}

.configurator-subtab-content.active {
    display: block;
}

/* Section colors for better visibility */
.section-header {
    background-color: var(--primary-color);
    color: white;
    padding: 10px 15px;
    margin-bottom: 15px;
    border-radius: 4px;
}

.subsection-header {
    background-color: var(--secondary-color);
    color: white;
    padding: 8px 12px;
    margin-bottom: 10px;
    border-radius: 3px;
}

/* Step indicator */
.step-indicator {
    display: flex;
    justify-content: space-between;
    margin: 1em 0;
    flex-wrap: wrap;
}

.step {
    background: #bdc3c7;
    color: #333;
    padding: 0.5em 1em;
    cursor: pointer;
    border-radius: var(--border-radius);
    transition: var(--transition);
    flex: 1;
    text-align: center;
    margin: 0.2em;
}

.step:hover {
    background: #a7adb3;
}

.step.active {
    background: var(--primary-color);
    color: white;
}

/* Device type grid */
.device-type-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.device-card {
    background-color: white;
    border-radius: 5px;
    border: 1px solid #ddd;
    overflow: hidden;
    transition: transform 0.3s, box-shadow 0.3s;
}

.device-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.device-card-header {
    background-color: var(--primary-color);
    color: white;
    padding: 15px;
    font-weight: bold;
}

.device-card-body {
    padding: 15px;
}

.device-card-footer {
    padding: 10px 15px;
    background-color: #f8f9fa;
    border-top: 1px solid #ddd;
    text-align: right;
}

/* Platform tabs */
.platform-tabs {
    display: flex;
    list-style: none;
    padding: 0;
    margin: 0 0 20px 0;
    border-bottom: 1px solid #ddd;
}

.platform-tabs li {
    padding: 10px 20px;
    cursor: pointer;
    background-color: #e0e0e0;
    border: 1px solid #ddd;
    border-bottom: none;
    margin-right: 5px;
    border-radius: 4px 4px 0 0;
}

.platform-tabs li.active {
    background-color: var(--secondary-color);
    color: white;
    border-color: var(--secondary-color);
}

/* Vendor list */
.vendor-list {
    list-style: none;
    padding: 0;
    margin: 10px 0;
}

.vendor-list-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 10px;
    background-color: #f8f9fa;
    border: 1px solid #ddd;
    border-radius: 4px;
    margin-bottom: 5px;
}

.remove-vendor-btn {
    background: var(--danger-color);
    color: white;
    border: none;
    border-radius: 50%;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 10px;
}

/* Alert messages */
.alert {
    padding: 12px 15px;
    margin-bottom: 15px;
    border-radius: var(--border-radius);
    display: none;
}

.alert-success {
    background-color: #d4edda;
    border-color: #c3e6cb;
    color: #155724;
}

.alert-danger {
    background-color: #f8d7da;
    border-color: #f5c6cb;
    color: #721c24;
}

/* Button styles */
.btn {
    display: inline-block;
    font-weight: 400;
    text-align: center;
    white-space: nowrap;
    vertical-align: middle;
    user-select: none;
    border: 1px solid transparent;
    padding: 0.375rem 0.75rem;
    font-size: 1rem;
    line-height: 1.5;
    border-radius: 0.25rem;
    transition: background-color .15s ease-in-out,border-color .15s ease-in-out;
    background-color: var(--primary-color);
    color: white;
    cursor: pointer;
}

.btn:hover {
    background-color: var(--primary-dark);
}

.btn-secondary {
    background-color: var(--secondary-color);
    color: white;
}

.btn-secondary:hover {
    background-color: #00a583;
}

.btn-danger {
    background-color: var(--danger-color);
    color: white;
}

.btn-danger:hover {
    background-color: #c0392b;
}

@media (max-width: 768px) {
    .step-indicator {
        flex-direction: column;
    }
    
    .step {
        margin-bottom: 5px;
    }
    
    .device-type-grid {
        grid-template-columns: 1fr;
    }
}
EOF
# Create updated tabs.js
cat > js/tabs.js << 'EOF'
// Dot1Xer Supreme - Tab Navigation

function initTabs() {
    // Main tabs
    document.querySelectorAll('.tab-btn').forEach(button => {
        button.addEventListener('click', function() {
            const tabName = this.getAttribute('data-tab');
            showTab(tabName, this);
            
            // Show/hide subtabs for Configurator
            const configuratorSubtabs = document.getElementById('configurator-subtabs');
            if (configuratorSubtabs) {
                configuratorSubtabs.style.display = tabName === 'configurator' ? 'flex' : 'none';
            }
        });
    });
    
    // Configurator subtabs (Wired/Wireless)
    document.querySelectorAll('.configurator-subtab').forEach(button => {
        button.addEventListener('click', function() {
            const subtabName = this.getAttribute('data-subtab');
            showConfiguratorSubtab(subtabName, this);
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
    
    // If configurator tab is selected, show first subtab content
    if (tabName === 'configurator') {
        // Show first subtab by default
        const firstSubtab = document.querySelector('.configurator-subtab');
        if (firstSubtab) {
            firstSubtab.click();
        } else {
            goToStep(1); // Fallback to original behavior
        }
    }
}

function showConfiguratorSubtab(subtabName, button) {
    document.querySelectorAll('.configurator-subtab-content').forEach(content => {
        content.classList.remove('active');
        content.style.display = 'none';
    });
    const selectedContent = document.getElementById(`subtab-${subtabName}`);
    if (selectedContent) {
        selectedContent.classList.add('active');
        selectedContent.style.display = 'block';
    }
    document.querySelectorAll('.configurator-subtab').forEach(btn => {
        btn.classList.remove('active');
    });
    if (button) button.classList.add('active');
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
EOF
# Update app.js with the new structure initialization
cat > js/app.js << 'EOF'
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

    // Show the Configurator tab and Wired subtab by default
    const configuratorTab = document.querySelector('.tab-btn[data-tab="configurator"]');
    if (configuratorTab) {
        configuratorTab.click();
    }

    // Show configurator subtabs
    const configuratorSubtabs = document.getElementById('configurator-subtabs');
    if (configuratorSubtabs) {
        configuratorSubtabs.style.display = 'flex';
    }

    // Show the first subtab by default
    const firstSubtab = document.querySelector('.configurator-subtab');
    if (firstSubtab) {
        firstSubtab.click();
    }

    // Initialize platform menu for wired/wireless devices
    initPlatformMenu();

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

// Initialize multi-vendor configuration
function initMultiVendorSelection() {
    const multiVendorToggle = document.getElementById('multi-vendor-toggle');
    const multiVendorSection = document.getElementById('multi-vendor-section');
    
    if (multiVendorToggle && multiVendorSection) {
        multiVendorToggle.addEventListener('change', function() {
            multiVendorSection.style.display = this.checked ? 'block' : 'none';
        });
        
        // Initialize vendor list if not already done
        if (!document.getElementById('vendor-list')) {
            const vendorListHtml = `
                <div class="vendor-selection">
                    <h4>Selected Vendors</h4>
                    <ul id="vendor-list" class="vendor-list"></ul>
                    <div class="vendor-actions">
                        <button id="add-vendor-button" type="button" class="btn">Add Current Vendor</button>
                    </div>
                </div>
            `;
            multiVendorSection.innerHTML = vendorListHtml;
            
            // Add event listener for the add vendor button
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
        <button type="button" class="remove-vendor-btn" onclick="removeVendorFromList(this)">?</button>
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

// Initialize platform menu
function initPlatformMenu() {
    const platformMenus = document.querySelectorAll('.platform-menu');
    platformMenus.forEach(menu => {
        const tabs = menu.querySelectorAll('.platform-tabs li');
        tabs.forEach((tab, index) => {
            tab.addEventListener('click', function() {
                // Remove active class from all tabs
                tabs.forEach(t => t.classList.remove('active'));
                // Add active class to clicked tab
                this.classList.add('active');
                
                // Hide all platform content
                menu.querySelectorAll('.platform-content').forEach(content => {
                    content.style.display = 'none';
                });
                
                // Show selected platform content
                const category = this.getAttribute('data-category');
                const platformContent = menu.querySelector(`#platform-${category}`);
                if (platformContent) {
                    platformContent.style.display = 'block';
                }
            });
            
            // Activate first tab by default
            if (index === 0) {
                tab.click();
            }
        });
    });
}

// Show error messages
function showError(message) {
    const errorElement = document.getElementById('error-message');
    if (!errorElement) {
        // Create error message element if it doesn't exist
        const errorDiv = document.createElement('div');
        errorDiv.id = 'error-message';
        errorDiv.className = 'alert alert-danger';
        document.querySelector('.container').insertBefore(errorDiv, document.querySelector('.tab-container'));
    }
    
    const errorDisplay = document.getElementById('error-message');
    errorDisplay.textContent = message;
    errorDisplay.style.display = 'block';
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
        errorDisplay.style.display = 'none';
    }, 5000);
}

// Show success messages
function showSuccess(message) {
    const successElement = document.getElementById('success-message');
    if (!successElement) {
        // Create success message element if it doesn't exist
        const successDiv = document.createElement('div');
        successDiv.id = 'success-message';
        successDiv.className = 'alert alert-success';
        document.querySelector('.container').insertBefore(successDiv, document.querySelector('.tab-container'));
    }
    
    const successDisplay = document.getElementById('success-message');
    successDisplay.textContent = message;
    successDisplay.style.display = 'block';
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
        successDisplay.style.display = 'none';
    }, 5000);
}
EOF
# Create index.html template with the new structure
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dot1Xer Supreme - Enterprise 802.1X Configuration Tool</title>
    
    <!-- CSS -->
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="css/accordion.css">
    <link rel="stylesheet" href="css/help_tips.css">
    
    <!-- JavaScript -->
    <script src="js/core.js" defer></script>
    <script src="js/tabs.js" defer></script>
    <script src="js/accordion.js" defer></script>
    <script src="js/vendors.js" defer></script>
    <script src="js/environment.js" defer></script>
    <script src="js/portnox.js" defer></script>
    <script src="js/utils.js" defer></script>
    <script src="js/project-details.js" defer></script>
    <script src="js/template_loader.js" defer></script>
    <script src="js/app.js" defer></script>
</head>
<body>
    <header>
        <div class="container">
            <div class="logo">Dot1Xer Supreme</div>
            <nav>
                <ul>
                    <li><a href="#" id="help-link">Help</a></li>
                    <li><a href="#" id="about-link">About</a></li>
                </ul>
            </nav>
        </div>
    </header>
    
    <div class="container">
        <!-- Alert messages -->
        <div id="error-message" class="alert alert-danger"></div>
        <div id="success-message" class="alert alert-success"></div>
        
        <!-- Main tabs -->
        <div class="tab-container">
            <ul class="tabs">
                <li class="tab-btn active" data-tab="configurator">Configurator</li>
                <li class="tab-btn" data-tab="discovery">Network Discovery</li>
                <li class="tab-btn" data-tab="reference">Reference Architectures</li>
                <li class="tab-btn" data-tab="portnox">Portnox Cloud</li>
                <li class="tab-btn" data-tab="settings">Settings</li>
            </ul>
            
            <!-- Configurator Subtabs -->
            <div id="configurator-subtabs">
                <ul class="configurator-subtabs">
                    <li class="configurator-subtab active" data-subtab="wired">Wired</li>
                    <li class="configurator-subtab" data-subtab="wireless">Wireless</li>
                </ul>
            </div>
            
            <!-- Tab content -->
            <div id="configurator" class="tab-content active">
                <!-- Wired subtab content -->
                <div id="subtab-wired" class="configurator-subtab-content active">
                    <!-- Wired content here -->
                    <div class="section-header">
                        <h2>Wired 802.1X Configuration</h2>
                    </div>

                    <!-- Configuration wizard steps -->
                    <div class="step-indicator">
                        <div class="step active" data-step="1">Vendor</div>
                        <div class="step" data-step="2">Authentication</div>
                        <div class="step" data-step="3">RADIUS</div>
                        <div class="step" data-step="4">VLANs</div>
                        <div class="step" data-step="5">Options</div>
                        <div class="step" data-step="6">Generate</div>
                    </div>

                    <!-- Step 1: Vendor Selection -->
                    <div id="step-1" class="step-content">
                        <div class="accordion-container">
                            <div class="accordion-header">
                                <span>Vendor &amp; Platform Selection</span>
                                <span class="accordion-icon">-</span>
                            </div>
                            <div class="accordion-content active">
                                <div class="accordion-inner">
                                    <div class="form-group">
                                        <label for="vendor-select">Select Vendor:</label>
                                        <select id="vendor-select">
                                            <option value="cisco">Cisco</option>
                                            <option value="aruba">Aruba (HPE)</option>
                                            <option value="juniper">Juniper</option>
                                            <option value="fortinet">Fortinet</option>
                                            <option value="extreme">Extreme Networks</option>
                                            <!-- Additional vendors -->
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label for="platform-select">Select Platform:</label>
                                        <select id="platform-select">
                                            <!-- Populated by JavaScript -->
                                        </select>
                                    </div>
                                    <div id="platform-description" class="form-description"></div>
                                </div>
                            </div>
                        </div>

                        <!-- Project Details Section -->
                        <div class="accordion-container">
                            <div class="accordion-header">
                                <span>Project Details</span>
                                <span class="accordion-icon">+</span>
                            </div>
                            <div class="accordion-content">
                                <div class="accordion-inner">
                                    <div class="checkbox-group">
                                        <label>
                                            <input type="checkbox" id="project-detail-toggle"> 
                                            Include project details in configuration
                                        </label>
                                    </div>
                                    <div id="project-details-section" style="display: none;">
                                        <!-- Project details form -->
                                        <div class="form-group">
                                            <label for="company-name">Company Name:</label>
                                            <input type="text" id="company-name" placeholder="e.g., Acme Corp">
                                        </div>
                                        <!-- More project detail fields -->
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Multi-vendor Support -->
                        <div class="accordion-container">
                            <div class="accordion-header">
                                <span>Multi-Vendor Configuration</span>
                                <span class="accordion-icon">+</span>
                            </div>
                            <div class="accordion-content">
                                <div class="accordion-inner">
                                    <div class="checkbox-group">
                                        <label>
                                            <input type="checkbox" id="multi-vendor-toggle"> 
                                            Enable multi-vendor configuration generation
                                        </label>
                                    </div>
                                    <div id="multi-vendor-section" style="display: none;">
                                        <!-- Multi-vendor configuration controls -->
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="nav-buttons">
                            <button onclick="goToStep(2)" class="btn">Next: Authentication</button>
                        </div>
                    </div>

                    <!-- Additional steps would go here -->
                </div>
                
                <!-- Wireless subtab content -->
                <div id="subtab-wireless" class="configurator-subtab-content">
                    <!-- Wireless content here -->
                    <div class="section-header">
                        <h2>Wireless 802.1X Configuration</h2>
                    </div>

                    <!-- Wireless device type selection -->
                    <div class="accordion-container">
                        <div class="accordion-header">
                            <span>Wireless Device Selection</span>
                            <span class="accordion-icon">-</span>
                        </div>
                        <div class="accordion-content active">
                            <div class="accordion-inner">
                                <p>Select the wireless platform to configure:</p>
                                <div class="device-type-grid">
                                    <div class="device-card">
                                        <div class="device-card-header">Cisco WLC</div>
                                        <div class="device-card-body">
                                            <p>Configure Cisco Wireless LAN Controllers for 802.1X authentication.</p>
                                        </div>
                                        <div class="device-card-footer">
                                            <button class="btn">Select</button>
                                        </div>
                                    </div>
                                    <div class="device-card">
                                        <div class="device-card-header">Aruba Controllers</div>
                                        <div class="device-card-body">
                                            <p>Configure Aruba Wireless Controllers for 802.1X authentication.</p>
                                        </div>
                                        <div class="device-card-footer">
                                            <button class="btn">Select</button>
                                        </div>
                                    </div>
                                    <!-- More wireless device cards -->
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Wireless configuration form would go here -->
                </div>
            </div>
            
            <div id="discovery" class="tab-content">
                <!-- Network Discovery content -->
            </div>
            
            <div id="reference" class="tab-content">
                <!-- Reference Architectures content -->
            </div>
            
            <div id="portnox" class="tab-content">
                <!-- Portnox Cloud content -->
            </div>
            
            <div id="settings" class="tab-content">
                <!-- Settings content -->
            </div>
        </div>
    </div>
    
    <footer>
        <div class="container">
            <p>&copy; 2023-2025 Dot1Xer Supreme Team. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
EOF
# Make script executable
echo -e "${GREEN}Making scripts executable...${NC}"
chmod +x *.sh 2>/dev/null

# Completion message
echo -e "${GREEN}=========================================="
echo -e "  Dot1Xer Supreme update completed!  "
echo -e "===========================================${NC}"
echo -e "${YELLOW}The UI has been updated with the following changes:${NC}"
echo -e "1. Wired and Wireless tabs moved as subtabs under Configurator"
echo -e "2. Improved section visibility with better colors and contrast"
echo -e "3. Enhanced accordion headers and expandable sections"
echo -e "${YELLOW}Original files backed up to: ${BACKUP_DIR}${NC}"
echo -e "${GREEN}Launch index.html in your browser to see the changes.${NC}"