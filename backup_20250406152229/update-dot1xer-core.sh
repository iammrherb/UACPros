#!/bin/bash
# update-dot1xer-core.sh
# =======================================================================
# Core update script for Dot1Xer Supreme that:
# - Creates a backup
# - Sets up directory structure
# - Fixes accordion functionality
# - Updates CSS styles
# - Adds help tip system
# =======================================================================

set -e

echo "=== Dot1Xer Supreme Core Update ==="
echo "This script will update core functionality while preserving existing configurations."
echo

# Create backup
timestamp=$(date +%Y%m%d%H%M%S)
backup_dir="backup_${timestamp}"
echo "Creating backup in ${backup_dir}..."
mkdir -p "${backup_dir}"
cp -r * "${backup_dir}/" 2>/dev/null || true
echo "Backup created successfully."
echo

# Setup required directories
echo "Setting up required directories..."
mkdir -p js/templates/cisco
mkdir -p js/templates/aruba
mkdir -p js/templates/juniper
mkdir -p js/templates/fortinet
mkdir -p js/templates/hpe
mkdir -p js/templates/extreme
mkdir -p js/templates/dell
mkdir -p js/templates/wireless/cisco
mkdir -p js/templates/wireless/aruba
mkdir -p js/templates/wireless/fortinet
mkdir -p js/templates/wireless/juniper
mkdir -p js/templates/wireless/ruckus
mkdir -p js/templates/wireless/meraki
mkdir -p js/templates/wireless/extreme
mkdir -p js/templates/wireless/ubiquiti
mkdir -p js/help
mkdir -p js/api
echo "Directories created successfully."
echo

# Fix index.html - remove any debug output
echo "Cleaning up index.html..."
if grep -q "# Finalize installation" index.html; then
    sed -i.bak '/# Finalize installation/,$d' index.html
    echo "</body></html>" >> index.html
    echo "Debug output removed from index.html."
else
    echo "No debug output found in index.html."
fi
echo

# Fix accordion functionality
echo "Updating accordion functionality..."
cat > js/accordion.js << 'EOL'
/**
 * Enhanced accordion functionality for Dot1Xer Supreme
 */
function initAccordions() {
    const accordionHeaders = document.querySelectorAll('.accordion-header');
    
    accordionHeaders.forEach(header => {
        header.addEventListener("click", function() {
            // Get the accordion content and icon
            const content = this.nextElementSibling;
            const icon = this.querySelector(".accordion-icon");
            
            // Toggle the current accordion
            this.classList.toggle("active");
            
            // If the accordion is now active
            if (this.classList.contains("active")) {
                // Show content and change icon
                content.style.maxHeight = content.scrollHeight + "px";
                content.style.display = "block";
                if (icon) icon.textContent = "-"; // Unicode minus sign
            } else {
                // Hide content and change icon
                content.style.maxHeight = null;
                content.style.display = "none";
                if (icon) icon.textContent = "+";
            }
        });
    });
    
    // Initially open the first accordion section
    const firstAccordion = document.querySelector('.accordion-header');
    if (firstAccordion) {
        firstAccordion.click();
    }
}

// Initialize accordions on page load
document.addEventListener('DOMContentLoaded', function() {
    initAccordions();
});
EOL
echo "Accordion functionality updated."
echo

# Update CSS for accordions and main styles
echo "Updating CSS styles..."
cat > css/accordion.css << 'EOL'
/* Enhanced Accordion Styles */
.accordion-container {
    width: 100%;
    margin-bottom: 20px;
    border-radius: 5px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.accordion-header {
    background-color: #f1f1f1;
    color: #333;
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
}

.accordion-header:hover {
    background-color: #e7e7e7;
}

.accordion-header.active {
    background-color: #4CAF50;
    color: white;
}

.accordion-content {
    padding: 0;
    max-height: 0;
    overflow: hidden;
    transition: max-height 0.2s ease-out;
    background-color: white;
}

.accordion-icon {
    font-size: 18px;
    font-weight: bold;
    transition: transform 0.3s ease;
}

.accordion-header.active .accordion-icon {
    transform: rotate(90deg);
}

.accordion-inner {
    padding: 15px;
}
EOL

cat > css/main.css << 'EOL'
/* Main Styles for Dot1Xer Supreme */
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: #333;
    margin: 0;
    padding: 0;
    background-color: #f8f9fa;
}

.container {
    width: 90%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

header {
    background-color: #4CAF50;
    color: white;
    padding: 15px 0;
    margin-bottom: 30px;
}

header .container {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    font-size: 24px;
    font-weight: bold;
}

nav ul {
    display: flex;
    list-style: none;
    margin: 0;
    padding: 0;
}

nav ul li {
    margin-left: 20px;
}

nav ul li a {
    color: white;
    text-decoration: none;
}

nav ul li a:hover {
    text-decoration: underline;
}

.tab-container {
    margin-bottom: 30px;
}

.tabs {
    display: flex;
    list-style: none;
    padding: 0;
    margin: 0;
    border-bottom: 1px solid #ddd;
}

.tabs li {
    padding: 10px 20px;
    cursor: pointer;
    border: 1px solid transparent;
    border-bottom: none;
    margin-bottom: -1px;
    background-color: #f1f1f1;
}

.tabs li.active {
    background-color: white;
    border-color: #ddd;
    border-bottom: 1px solid white;
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

button {
    background-color: #4CAF50;
    color: white;
    border: none;
    padding: 10px 15px;
    cursor: pointer;
    font-size: 14px;
    border-radius: 4px;
}

button:hover {
    background-color: #45a049;
}

input[type="text"],
input[type="password"],
input[type="number"],
select,
textarea {
    width: 100%;
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #ddd;
    border-radius: 4px;
    box-sizing: border-box;
}

.form-group {
    margin-bottom: 15px;
}

label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
}

.card {
    background-color: white;
    border-radius: 5px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 20px;
    margin-bottom: 20px;
}

.card-header {
    border-bottom: 1px solid #eee;
    padding-bottom: 10px;
    margin-bottom: 15px;
}

.card-title {
    margin: 0;
    font-size: 18px;
}

footer {
    text-align: center;
    padding: 20px 0;
    margin-top: 30px;
    background-color: #f1f1f1;
    border-top: 1px solid #ddd;
}

.grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

@media screen and (max-width: 768px) {
    .grid {
        grid-template-columns: 1fr;
    }
    
    header .container {
        flex-direction: column;
    }
    
    nav ul {
        margin-top: 15px;
    }
    
    nav ul li {
        margin-left: 0;
        margin-right: 20px;
    }
}
EOL
echo "CSS styles updated."
echo

# Add help tips CSS
cat > css/help_tips.css << 'EOL'
/* Help Tip Styles */
.help-icon {
    display: inline-block;
    width: 16px;
    height: 16px;
    line-height: 16px;
    text-align: center;
    background-color: #4CAF50;
    color: white;
    border-radius: 50%;
    margin-left: 5px;
    cursor: pointer;
    font-size: 12px;
    font-weight: bold;
}

.help-icon:hover {
    background-color: #45a049;
}

.help-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
    opacity: 0;
    transition: opacity 0.3s ease;
}

.help-modal-content {
    background-color: white;
    padding: 20px;
    border-radius: 5px;
    width: 80%;
    max-width: 600px;
    max-height: 80vh;
    overflow-y: auto;
    position: relative;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
}

.help-modal-close {
    position: absolute;
    top: 10px;
    right: 15px;
    font-size: 24px;
    font-weight: bold;
    cursor: pointer;
    color: #666;
}

.help-modal-close:hover {
    color: #000;
}
EOL
echo "Help tips CSS added."
echo

# Add help tips integration
cat > js/help/help_tips.js << 'EOL'
/**
 * Help tip system for Dot1Xer Supreme
 * Provides detailed explanations of configuration options
 */

// Help tip data store
const helpTips = {
    // 802.1X Concepts
    "dot1x": {
        "title": "802.1X Authentication",
        "content": "802.1X is an IEEE standard for port-based Network Access Control (PNAC). It provides an authentication mechanism for devices wishing to connect to a LAN or WLAN. 802.1X authentication involves three parties: a supplicant (client device), an authenticator (network device), and an authentication server (e.g., RADIUS)."
    },
    "mab": {
        "title": "MAC Authentication Bypass (MAB)",
        "content": "MAB is used for devices that don't support 802.1X. Instead of using EAP, the switch sends the device's MAC address to the authentication server. This allows legacy devices to connect to the network without 802.1X support."
    },
    "eap": {
        "title": "Extensible Authentication Protocol (EAP)",
        "content": "EAP is an authentication framework frequently used in wireless networks and point-to-point connections. It defines the message format and supports multiple authentication methods like EAP-TLS, PEAP, EAP-FAST, etc."
    },
    "radius": {
        "title": "RADIUS (Remote Authentication Dial-In User Service)",
        "content": "RADIUS is a networking protocol that provides centralized Authentication, Authorization, and Accounting (AAA) management for users who connect to and use a network service. RADIUS servers are commonly used as the authentication server in 802.1X deployments."
    },
    "tacacs": {
        "title": "TACACS+ (Terminal Access Controller Access-Control System Plus)",
        "content": "TACACS+ is a protocol developed by Cisco that provides detailed access control for managing device administration. Unlike RADIUS, TACACS+ separates authentication, authorization, and accounting."
    },
    
    // Cisco Specific
    "ibns": {
        "title": "Identity-Based Networking Services (IBNS)",
        "content": "IBNS is Cisco's implementation of 802.1X that provides identity-aware networking. IBNS 2.0 improves upon the original with more flexible authentication policies and better host mode capabilities."
    },
    "ise": {
        "title": "Cisco Identity Services Engine (ISE)",
        "content": "ISE is Cisco's policy management platform that enables context-aware identity and access control policies. It functions as a RADIUS server and provides advanced features like profiling, posture assessment, and guest services."
    },
    
    // RADIUS Features
    "coa": {
        "title": "Change of Authorization (CoA)",
        "content": "CoA allows a RADIUS server to dynamically change the attributes of an active session. This enables actions like quarantining, session termination, or VLAN reassignment without requiring reauthentication."
    },
    "radsec": {
        "title": "RADIUS over TLS (RadSec)",
        "content": "RadSec tunnels RADIUS traffic over TLS, providing encryption and mutual authentication between RADIUS clients and servers. This addresses security concerns with traditional RADIUS, which uses UDP and shared secrets."
    },
    
    // Device Tracking
    "device_tracking": {
        "title": "IP Device Tracking",
        "content": "IP Device Tracking monitors attached hosts using ARP and DHCP to maintain an address table. This feature is essential for dynamic security features that depend on knowing the IP addresses of connected devices."
    },
    "dhcp_snooping": {
        "title": "DHCP Snooping",
        "content": "DHCP snooping is a security feature that filters untrusted DHCP messages and builds a binding database of legitimate IP-to-MAC mappings. This prevents rogue DHCP servers and various DHCP-based attacks."
    },
    
    // Authentication Modes
    "multi_auth": {
        "title": "Multi-Auth Mode",
        "content": "In multi-auth mode, the switch authenticates each host independently, allowing multiple devices on a single port with different authentication results. This is useful for environments with IP phones and computers sharing ports."
    },
    "multi_domain": {
        "title": "Multi-Domain Authentication Mode",
        "content": "Multi-domain mode allows up to two devices to authenticate per port: one in the voice domain and one in the data domain. This is commonly used for IP phone deployments."
    },
    "multi_host": {
        "title": "Multi-Host Mode",
        "content": "In multi-host mode, only one host needs to be authenticated for all hosts on the port to gain access. After the first host authentication, other devices can access the network without authentication."
    },
    "single_host": {
        "title": "Single-Host Mode",
        "content": "Single-host mode only allows one authenticated device per port. If another device is detected, the port will either violate or ignore the new device, depending on the configuration."
    },
    
    // Templates
    "templates": {
        "title": "Configuration Templates",
        "content": "Templates provide pre-configured settings for various device types and deployment scenarios. You can customize these templates by modifying the variables to match your environment."
    },
    
    // Wireless Concepts
    "wpa2": {
        "title": "WPA2 (Wi-Fi Protected Access 2)",
        "content": "WPA2 is a security protocol developed by the Wi-Fi Alliance to secure wireless networks. It implements the mandatory elements of IEEE 802.11i standard and provides enterprise-grade authentication and encryption for wireless networks."
    },
    "wpa3": {
        "title": "WPA3 (Wi-Fi Protected Access 3)",
        "content": "WPA3 is the next generation of Wi-Fi security, offering improved encryption and authentication methods compared to WPA2. It includes features like Simultaneous Authentication of Equals (SAE) which provides stronger protection against password cracking attacks."
    },
    "pmf": {
        "title": "Protected Management Frames (PMF)",
        "content": "PMF provides protection for special management frames in Wi-Fi networks, preventing certain types of denial-of-service attacks. It helps ensure that critical management frames are authenticated and can't be spoofed by attackers."
    },
    "wids_wips": {
        "title": "Wireless Intrusion Detection/Prevention System (WIDS/WIPS)",
        "content": "WIDS/WIPS systems monitor the radio spectrum for unauthorized access points and suspicious activities. They can detect rogue access points, man-in-the-middle attacks, and other wireless security threats."
    }
};

// Function to initialize help tips on page load
function initHelpTips() {
    // Find all elements with data-help attribute
    const helpElements = document.querySelectorAll('[data-help]');
    
    helpElements.forEach(element => {
        // Get the help key from the data attribute
        const helpKey = element.getAttribute('data-help');
        
        // Only proceed if we have help content for this key
        if (helpTips[helpKey]) {
            // Create help icon
            const helpIcon = document.createElement('span');
            helpIcon.className = 'help-icon';
            helpIcon.innerHTML = '?';
            helpIcon.title = 'Click for help';
            
            // Add click event to show help modal
            helpIcon.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                showHelpModal(helpKey);
            });
            
            // Add the help icon next to the element
            element.parentNode.insertBefore(helpIcon, element.nextSibling);
        }
    });
}

// Function to show the help modal
function showHelpModal(helpKey) {
    // Get help content
    const help = helpTips[helpKey];
    if (!help) return;
    
    // Create modal elements
    const modal = document.createElement('div');
    modal.className = 'help-modal';
    
    const modalContent = document.createElement('div');
    modalContent.className = 'help-modal-content';
    
    const closeBtn = document.createElement('span');
    closeBtn.className = 'help-modal-close';
    closeBtn.innerHTML = '&times;';
    closeBtn.title = 'Close';
    
    const title = document.createElement('h3');
    title.textContent = help.title;
    
    const content = document.createElement('div');
    content.innerHTML = help.content;
    
    // Assemble the modal
    modalContent.appendChild(closeBtn);
    modalContent.appendChild(title);
    modalContent.appendChild(content);
    modal.appendChild(modalContent);
    document.body.appendChild(modal);
    
    // Show the modal
    setTimeout(() => {
        modal.style.opacity = '1';
    }, 10);
    
    // Close button event
    closeBtn.addEventListener('click', () => {
        closeHelpModal(modal);
    });
    
    // Close when clicking outside the modal
    modal.addEventListener('click', (e) => {
        if (e.target === modal) {
            closeHelpModal(modal);
        }
    });
    
    // Close with ESC key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeHelpModal(modal);
        }
    });
}

// Function to close the help modal
function closeHelpModal(modal) {
    modal.style.opacity = '0';
    setTimeout(() => {
        document.body.removeChild(modal);
    }, 300);
}

// Add help tips to elements dynamically
function addHelpTip(element, helpKey) {
    if (!helpTips[helpKey]) return;
    
    element.setAttribute('data-help', helpKey);
    
    // Create help icon
    const helpIcon = document.createElement('span');
    helpIcon.className = 'help-icon';
    helpIcon.innerHTML = '?';
    helpIcon.title = 'Click for help';
    
    // Add click event to show help modal
    helpIcon.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        showHelpModal(helpKey);
    });
    
    // Add the help icon next to the element
    element.parentNode.insertBefore(helpIcon, element.nextSibling);
}

// Initialize help tips on page load
document.addEventListener('DOMContentLoaded', initHelpTips);

// Export functions for use in other modules
if (typeof module !== 'undefined') {
    module.exports = {
        helpTips,
        initHelpTips,
        showHelpModal,
        addHelpTip
    };
}
EOL
echo "Help tips integration added."
echo

echo "=== Core Update Complete ==="
echo "Core functionality has been updated successfully."
echo "Next, run update-dot1xer-templates.sh to add configuration templates."