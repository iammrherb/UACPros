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
