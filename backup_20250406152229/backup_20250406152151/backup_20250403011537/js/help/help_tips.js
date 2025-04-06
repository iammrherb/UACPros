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
