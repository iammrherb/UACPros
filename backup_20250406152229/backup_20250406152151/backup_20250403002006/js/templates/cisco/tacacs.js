const ciscoTacacsTemplate = {
    name: "Cisco TACACS+",
    template: `
! TACACS+ Configuration
tacacs server TACACS-1
 address ipv4 {{tacacs.server1.ip}}
 key {{tacacs.server1.key}}
aaa authentication login default group tacacs+ local
    `,
    variables: {
        "tacacs.server1.ip": { default: "10.1.1.10" },
        "tacacs.server1.key": { default: "tacacs_secret" }
    }
};
window.registerTemplate('tacacs', ciscoTacacsTemplate);
