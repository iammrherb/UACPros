const arubaWirelessTemplate = {
    name: "Aruba Wireless",
    template: `
! Aruba Wireless Configuration
aaa authentication-server radius "ISE-1"
 host "{{radius.server1.ip}}"
 key "{{radius.server1.key}}"
wlan ssid-profile "{{ssid.name}}"
 essid "{{ssid.name}}"
 opmode wpa2-aes
    `,
    variables: {
        "radius.server1.ip": { default: "10.1.1.1" },
        "radius.server1.key": { default: "secret" },
        "ssid.name": { default: "Corporate-WLAN" }
    }
};
window.registerTemplate('aruba_wireless', arubaWirelessTemplate);
