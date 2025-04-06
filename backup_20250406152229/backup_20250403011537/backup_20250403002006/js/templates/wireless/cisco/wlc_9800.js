const ciscoWlc9800Template = {
    name: "Cisco WLC 9800",
    template: `
! WLC 9800 Configuration
radius server ISE-1
 address ipv4 {{radius.server1.ip}} auth-port 1812 acct-port 1813
 key {{radius.server1.key}}
wlan {{ssid.name}} 1 {{ssid.name}}
 security wpa wpa2
    `,
    variables: {
        "radius.server1.ip": { default: "10.1.1.1" },
        "radius.server1.key": { default: "secret" },
        "ssid.name": { default: "Enterprise-WLAN" }
    }
};
window.registerTemplate('wlc_9800', ciscoWlc9800Template);
