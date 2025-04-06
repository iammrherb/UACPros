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
