/**
 * Dot1Xer Supreme - Vendor Data
 * Version: 2.0.0
 */
const vendorData = {
    wired: [
        { id: 'cisco', name: 'Cisco', logo: 'cisco-logo.png', description: 'Cisco IOS, IOS-XE, and NX-OS based switches', models: ['Catalyst 9000', 'Catalyst 3000', 'Nexus'], templates: ['ios', 'ios-xe', 'nx-os'] },
        { id: 'aruba', name: 'Aruba', logo: 'aruba-logo.png', description: 'Aruba CX and AOS-Switch based switches', models: ['CX 6000', 'CX 8000', '2930F', '5400R'], templates: ['aos-cx', 'aos-switch'] },
        { id: 'juniper', name: 'Juniper', logo: 'juniper-logo.png', description: 'Juniper EX and QFX series switches', models: ['EX2300', 'EX3400', 'EX4300', 'QFX5100'], templates: ['junos'] },
        { id: 'hp', name: 'HP', logo: 'hp-logo.png', description: 'HP ProCurve and ProVision switches', models: ['2530', '2930', '5400', '3800'], templates: ['procurve', 'provision'] },
        { id: 'fortinet', name: 'Fortinet', logo: 'fortinet-logo.png', description: 'FortiSwitch series managed switches', models: ['100E', '200E', '400E', '500E'], templates: ['fortiswitch'] }
    ],
    wireless: [
        { id: 'cisco-wlc', name: 'Cisco WLC', logo: 'cisco-logo.png', description: 'Cisco Wireless LAN Controllers', models: ['9800 Series', '5520', '3504'], templates: ['aireos', 'ios-xe'] },
        { id: 'aruba-mobility', name: 'Aruba Mobility', logo: 'aruba-logo.png', description: 'Aruba Mobility Controllers', models: ['7200 Series', '7000 Series', 'MC-VA'], templates: ['arubaos'] },
        { id: 'meraki', name: 'Cisco Meraki', logo: 'meraki-logo.png', description: 'Cisco Meraki cloud-managed wireless', models: ['MR Series', 'Cloud Dashboard'], templates: ['meraki-dashboard'] }
    ]
};
