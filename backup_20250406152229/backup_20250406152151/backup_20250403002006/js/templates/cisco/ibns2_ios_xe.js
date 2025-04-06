const ciscoIbns2IosXeTemplate = {
    name: "Cisco IOS-XE IBNS 2.0",
    template: `
! IBNS 2.0 Configuration
aaa new-model
radius server ISE-1
 address ipv4 {{radius.primary.ip}} auth-port 1812 acct-port 1813
 key {{radius.primary.key}}
interface {{interface}}
 switchport mode access
 dot1x pae authenticator
    `,
    variables: {
        "radius.primary.ip": { default: "10.1.1.1" },
        "radius.primary.key": { default: "secret" },
        "interface": { default: "GigabitEthernet1/0/1" }
    }
};
window.registerTemplate('ibns2_ios_xe', ciscoIbns2IosXeTemplate);
