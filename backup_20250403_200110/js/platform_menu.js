const platformMenu = {
    wired: {
        name: "Wired",
        platforms: {
            "cisco-ios": { name: "Cisco IOS/IOS-XE", templates: ["ibns2_ios_xe", "tacacs"] },
            "aruba-aoscx": { name: "Aruba AOS-CX", templates: ["aos_cx"] },
            "juniper-ex": { name: "Juniper EX", templates: ["juniper_ex"] },
            "fortinet-switch": { name: "Fortinet FortiSwitch", templates: ["fortiswitch"] },
            "hpe-comware": { name: "HPE Comware", templates: ["comware_dot1x"] },
            "extreme-exos": { name: "Extreme EXOS", templates: ["exos_dot1x"] },
            "dell-os10": { name: "Dell OS10", templates: ["dell_os10"] }
        }
    },
    wireless: {
        name: "Wireless",
        platforms: {
            "cisco-wlc9800": { name: "Cisco WLC 9800", templates: ["wlc_9800"] },
            "aruba-controller": { name: "Aruba Controller", templates: ["aruba_wireless"] },
            "fortinet-fortiwlc": { name: "Fortinet FortiWLC", templates: ["fortinet_wireless"] },
            "ruckus-wireless": { name: "Ruckus Wireless", templates: ["ruckus_wireless"] },
            "cisco-meraki": { name: "Cisco Meraki", templates: ["meraki_wireless"] },
            "extreme-wireless": { name: "Extreme Wireless", templates: ["extreme_wireless"] },
            "ubiquiti-unifi": { name: "Ubiquiti UniFi", templates: ["unifi_wireless"] }
        }
    }
};

function initPlatformMenu() {
    const menu = document.getElementById('platform-menu');
    if (!menu) return;
    
    let html = '<ul class="platform-tabs">';
    Object.keys(platformMenu).forEach((cat, i) => {
        html += `<li class="${i === 0 ? 'active' : ''}" data-category="${cat}">${platformMenu[cat].name}</li>`;
    });
    html += '</ul>';
    
    Object.keys(platformMenu).forEach((cat, i) => {
        html += `<div id="platform-${cat}" style="display: ${i === 0 ? 'block' : 'none'}">`;
        for (const plat in platformMenu[cat].platforms) {
            html += `
                <div class="platform-card">
                    <h3>${platformMenu[cat].platforms[plat].name}</h3>
                    <button onclick="selectPlatform('${cat}', '${plat}')">Select</button>
                </div>
            `;
        }
        html += '</div>';
    });
    
    menu.innerHTML = html;
    
    menu.querySelectorAll('.platform-tabs li').forEach(tab => {
        tab.addEventListener('click', function() {
            menu.querySelectorAll('.platform-tabs li').forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            menu.querySelectorAll('.platform-content').forEach(c => c.style.display = 'none');
            document.getElementById(`platform-${this.getAttribute('data-category')}`).style.display = 'block';
        });
    });
}

function selectPlatform(category, platform) {
    const templates = platformMenu[category].platforms[platform].templates;
    Promise.all(templates.map(t => window.loadTemplate(t)))
        .then(() => alert(`Selected ${platformMenu[category].platforms[platform].name}`));
}

document.addEventListener('DOMContentLoaded', initPlatformMenu);
