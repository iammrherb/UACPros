#!/bin/bash
# update-dot1xer-templates.sh
# =======================================================================
# Template update script for Dot1Xer Supreme that adds:
# - Cisco IOS/IOS-XE templates (IBNS 2.0, TACACS+, RadSec, Device Tracking)
# - Wireless controller templates for multiple vendors
# - Multi-vendor switch configuration templates
# =======================================================================

set -e

echo "=== Dot1Xer Supreme Template Update ==="
echo "This script will add comprehensive configuration templates."
echo

# Check if core update was applied
if [ ! -f "js/help/help_tips.js" ]; then
    echo "Error: Core update hasn't been applied. Please run update-dot1xer-core.sh first."
    exit 1
fi

# Add Cisco IOS-XE IBNS 2.0 template
echo "Adding Cisco IOS-XE IBNS 2.0 templates..."
cat > js/templates/cisco/ibns2_ios_xe.js << 'EOL'
/**
 * Cisco IOS-XE IBNS 2.0 Configuration Template
 * Based on best practices for 802.1X and MAB
 */
const ciscoIbns2IosXeTemplate = {
    name: "Cisco IOS-XE IBNS 2.0",
    description: "IBNS 2.0 configuration for Cisco IOS-XE devices with 802.1X and MAB support",
    template: `! IBNS 2.0 Configuration for Cisco IOS-XE
! AAA Configuration
aaa new-model
aaa authentication dot1x default group radius
aaa authorization network default group radius
aaa accounting dot1x default start-stop group radius

! RADIUS Server Configuration
radius server ISE-1
 address ipv4 {{radius.primary.ip}} auth-port {{radius.primary.auth_port}} acct-port {{radius.primary.acct_port}}
 key {{radius.primary.key}}
radius server ISE-2
 address ipv4 {{radius.secondary.ip}} auth-port {{radius.secondary.auth_port}} acct-port {{radius.secondary.acct_port}}
 key {{radius.secondary.key}}

! RADIUS Server Group Configuration
aaa group server radius ISE
 server name ISE-1
 server name ISE-2
 deadtime {{radius.deadtime}}
 ip radius source-interface {{radius.source_interface}}

! CoA Configuration
aaa server radius dynamic-author
 client {{radius.primary.ip}} server-key {{radius.primary.key}}
 client {{radius.secondary.ip}} server-key {{radius.secondary.key}}
 auth-type any
 port {{radius.coa_port}}

! RadSec Configuration (if enabled)
{{#if radsec.enabled}}
crypto pki trustpoint RADSEC-TP
 enrollment terminal
 revocation-check none
 subject-name cn={{radsec.subject_name}}
crypto pki certificate chain RADSEC-TP
 certificate ca 01
  ! Insert CA certificate here
radius server RADSEC-1
 address ipv4 {{radsec.primary.ip}} auth-port 2083 acct-port 2083
 key {{radsec.primary.key}}
 tls connectiontimeout 5
 tls radius-enable
{{/if}}

! Device Tracking Configuration
device-tracking policy TRACK-POLICY
 tracking enable
 device-role host
device-tracking logging theft
device-tracking tracking
ip dhcp snooping
ip dhcp snooping vlan {{dhcp_snooping.vlans}}

! 802.1X Global Configuration
dot1x system-auth-control
dot1x critical eapol

! MAB Global Configuration
mab request format attribute 1 uppercase
mab request format attribute 2 uppercase
mab request format attribute 3 uppercase
mab request format attribute 4 uppercase
mab request format attribute 6 on

! Authentication Manager Configuration
authentication mac-move permit
authentication critical recovery timeout {{critical_auth.timeout}}
authentication timer restart {{auth_timers.restart}}
authentication timer reauthenticate {{auth_timers.reauthenticate}}
ip device tracking probe delay 10
ip device tracking probe count 3
ip device tracking probe auto-source

! Class Maps
class-map type control subscriber match-all DOT1X
 match method dot1x
class-map type control subscriber match-all MAB
 match method mab
class-map type control subscriber match-all DOT1X_FAILED
 match method dot1x
 match result-type method dot1x failure
class-map type control subscriber match-any IN_CRITICAL_AUTH
 match activated-service-template CRITICAL_AUTH_VLAN
class-map type control subscriber match-all AAA_SVR_DOWN_UNAUTHD_HOST
 match result-type aaa-timeout
 match authorization-status unauthorized
class-map type control subscriber match-all AAA_SVR_DOWN_AUTHD_HOST
 match result-type aaa-timeout
 match authorization-status authorized

! Policy Maps
policy-map type control subscriber PMAP_DOT1X
 event session-started match-all
  10 class always do-until-failure
   10 authenticate using dot1x priority 10
 event authentication-failure match-first
  10 class AAA_SVR_DOWN_UNAUTHD_HOST do-until-failure
   10 activate service-template CRITICAL_AUTH_VLAN
   20 authorize
   30 pause reauthentication
  20 class AAA_SVR_DOWN_AUTHD_HOST do-until-failure
   10 pause reauthentication
   20 authorize
  30 class DOT1X_FAILED do-until-failure
   10 authenticate using mab priority 20
  40 class always do-until-failure
   10 terminate dot1x
   20 terminate mab
   30 authentication-restart {{auth_timers.restart}}
 event agent-found match-all
  10 class always do-until-failure
   10 terminate mab
   20 authenticate using dot1x priority 10
 event aaa-available match-all
  10 class IN_CRITICAL_AUTH do-until-failure
   10 clear-session
  20 class always do-until-failure
   10 resume reauthentication
 event inactivity-timeout match-all
  10 class always do-until-failure
   10 clear-session
 event authentication-success match-all
  10 class always do-until-failure
   10 activate service-template DEFAULT_CRITICAL_VOICE_TEMPLATE
 event violation match-all
  10 class always do-until-failure
   10 restrict

! Interface Template
interface {{interface}}
 switchport mode access
 switchport access vlan {{access_vlan}}
 switchport voice vlan {{voice_vlan}}
 access-session host-mode multi-auth
 access-session port-control auto
 access-session closed
 dot1x pae authenticator
 dot1x timeout tx-period {{dot1x_timers.tx_period}}
 dot1x max-reauth-req {{dot1x_timers.max_reauth_req}}
 dot1x max-req {{dot1x_timers.max_req}}
 spanning-tree portfast
 service-policy type control subscriber PMAP_DOT1X
 device-tracking attach-policy TRACK-POLICY
 ip access-group ACL_PREAUTH in

! Global Templates
service template CRITICAL_AUTH_VLAN
 access-group ACL_ALLOW_ALL
 vlan {{critical_auth.vlan}}
service template DEFAULT_CRITICAL_VOICE_TEMPLATE
 voice vlan {{voice_vlan}}

! ACL Definitions
ip access-list extended ACL_PREAUTH
 permit udp any any eq domain
 permit udp any any eq bootpc
 permit udp any any eq bootps
 deny   ip any any
ip access-list extended ACL_ALLOW_ALL
 permit ip any any

! End of configuration`,
    variables: {
        "radius.primary.ip": {
            description: "Primary RADIUS server IP address",
            default: "10.1.1.1"
        },
        "radius.primary.auth_port": {
            description: "Primary RADIUS authentication port",
            default: "1812"
        },
        "radius.primary.acct_port": {
            description: "Primary RADIUS accounting port",
            default: "1813"
        },
        "radius.primary.key": {
            description: "Primary RADIUS shared secret key",
            default: "secret"
        },
        "radius.secondary.ip": {
            description: "Secondary RADIUS server IP address",
            default: "10.1.1.2"
        },
        "radius.secondary.auth_port": {
            description: "Secondary RADIUS authentication port",
            default: "1812"
        },
        "radius.secondary.acct_port": {
            description: "Secondary RADIUS accounting port",
            default: "1813"
        },
        "radius.secondary.key": {
            description: "Secondary RADIUS shared secret key",
            default: "secret"
        },
        "radius.deadtime": {
            description: "RADIUS server deadtime in minutes",
            default: "15"
        },
        "radius.source_interface": {
            description: "Source interface for RADIUS packets",
            default: "Vlan100"
        },
        "radius.coa_port": {
            description: "CoA port",
            default: "1700"
        },
        "radsec.enabled": {
            description: "Enable RadSec",
            default: false
        },
        "radsec.subject_name": {
            description: "RadSec certificate subject name",
            default: "radsec.example.com"
        },
        "radsec.primary.ip": {
            description: "Primary RadSec server IP address",
            default: "10.1.1.1"
        },
        "radsec.primary.key": {
            description: "Primary RadSec shared secret key",
            default: "radsec_secret"
        },
        "dhcp_snooping.vlans": {
            description: "DHCP snooping VLANs",
            default: "10,20,30"
        },
        "critical_auth.timeout": {
            description: "Critical authentication recovery timeout in seconds",
            default: "180"
        },
        "critical_auth.vlan": {
            description: "Critical authentication VLAN",
            default: "999"
        },
        "auth_timers.restart": {
            description: "Authentication restart timer in seconds",
            default: "60"
        },
        "auth_timers.reauthenticate": {
            description: "Reauthentication timer in seconds",
            default: "7200"
        },
        "interface": {
            description: "Interface to configure",
            default: "GigabitEthernet1/0/1"
        },
        "access_vlan": {
            description: "Access VLAN",
            default: "10"
        },
        "voice_vlan": {
            description: "Voice VLAN",
            default: "20"
        },
        "dot1x_timers.tx_period": {
            description: "Dot1x transmit period in seconds",
            default: "10"
        },
        "dot1x_timers.max_reauth_req": {
            description: "Maximum reauthentication requests",
            default: "2"
        },
        "dot1x_timers.max_req": {
            description: "Maximum authentication requests",
            default: "2"
        }
    }
};

// Export the template
if (typeof module !== 'undefined') {
    module.exports = ciscoIbns2IosXeTemplate;
}
EOL
echo "Cisco IOS-XE IBNS 2.0 template added."
echo

# Add Cisco TACACS+ configuration template
echo "Adding Cisco TACACS+ configuration template..."
cat > js/templates/cisco/tacacs.js << 'EOL'
/**
 * Cisco TACACS+ Configuration Template
 * For device administration
 */
const ciscoTacacsTemplate = {
    name: "Cisco TACACS+",
    description: "TACACS+ configuration for Cisco devices for administrative access",
    template: `! TACACS+ Configuration for Cisco IOS/IOS-XE
! AAA New Model
aaa new-model

! TACACS+ Server Definitions
tacacs server {{tacacs.server1.name}}
 address ipv4 {{tacacs.server1.ip}}
 key {{tacacs.server1.key}}
 timeout {{tacacs.timeout}}
 single-connection
tacacs server {{tacacs.server2.name}}
 address ipv4 {{tacacs.server2.ip}}
 key {{tacacs.server2.key}}
 timeout {{tacacs.timeout}}
 single-connection

! AAA Group Servers
aaa group server tacacs+ {{tacacs.group_name}}
 server name {{tacacs.server1.name}}
 server name {{tacacs.server2.name}}
 ip tacacs source-interface {{tacacs.source_interface}}

! Authentication Methods
aaa authentication login default group {{tacacs.group_name}} local
aaa authentication login CONSOLE local
aaa authentication enable default group {{tacacs.group_name}} enable

! Authorization Methods
aaa authorization config-commands
aaa authorization exec default group {{tacacs.group_name}} local if-authenticated
aaa authorization commands 0 default group {{tacacs.group_name}} local if-authenticated
aaa authorization commands 1 default group {{tacacs.group_name}} local if-authenticated
aaa authorization commands 15 default group {{tacacs.group_name}} local if-authenticated

! Accounting Methods
aaa accounting exec default start-stop group {{tacacs.group_name}}
aaa accounting commands 0 default start-stop group {{tacacs.group_name}}
aaa accounting commands 1 default start-stop group {{tacacs.group_name}}
aaa accounting commands 15 default start-stop group {{tacacs.group_name}}

! Local User (Fallback)
username {{local.admin_user}} privilege 15 secret {{local.admin_password}}

! Console and VTY Configuration
line console 0
 login authentication CONSOLE
 exec-timeout {{console.timeout}} 0
 
line vty 0 15
 login authentication default
 exec-timeout {{vty.timeout}} 0
 transport input ssh

! End of TACACS+ configuration`,
    variables: {
        "tacacs.server1.name": {
            description: "Primary TACACS+ server name",
            default: "TACACS-1"
        },
        "tacacs.server1.ip": {
            description: "Primary TACACS+ server IP address",
            default: "10.1.1.10"
        },
        "tacacs.server1.key": {
            description: "Primary TACACS+ server key",
            default: "tacacs_secret_key"
        },
        "tacacs.server2.name": {
            description: "Secondary TACACS+ server name",
            default: "TACACS-2"
        },
        "tacacs.server2.ip": {
            description: "Secondary TACACS+ server IP address",
            default: "10.1.1.11"
        },
        "tacacs.server2.key": {
            description: "Secondary TACACS+ server key",
            default: "tacacs_secret_key"
        },
        "tacacs.timeout": {
            description: "TACACS+ server timeout (seconds)",
            default: "5"
        },
        "tacacs.group_name": {
            description: "TACACS+ server group name",
            default: "TACACS-SERVERS"
        },
        "tacacs.source_interface": {
            description: "Source interface for TACACS+ packets",
            default: "Loopback0"
        },
        "local.admin_user": {
            description: "Local admin username (fallback)",
            default: "admin"
        },
        "local.admin_password": {
            description: "Local admin password (fallback)",
            default: "StrongP@ssw0rd"
        },
        "console.timeout": {
            description: "Console timeout (minutes)",
            default: "15"
        },
        "vty.timeout": {
            description: "VTY timeout (minutes)",
            default: "10"
        }
    }
};

// Export the template
if (typeof module !== 'undefined') {
    module.exports = ciscoTacacsTemplate;
}
EOL
echo "Cisco TACACS+ template added."
echo

# Add Cisco WLC 9800 template
echo "Adding Cisco WLC 9800 template..."
cat > js/templates/wireless/cisco/wlc_9800.js << 'EOL'
/**
 * Cisco WLC 9800 Configuration Template
 * For wireless controller AAA configuration
 */
const ciscoWlc9800Template = {
    name: "Cisco WLC 9800",
    description: "AAA and RADIUS configuration for Cisco 9800 Series Wireless LAN Controllers",
    template: `! Cisco 9800 WLC AAA Configuration
! AAA New Model
aaa new-model

! RADIUS Server Configuration
radius server {{radius.server1.name}}
 address ipv4 {{radius.server1.ip}} auth-port {{radius.server1.auth_port}} acct-port {{radius.server1.acct_port}}
 key {{radius.server1.key}}
 timeout {{radius.timeout}}
 retransmit {{radius.retransmit}}
radius server {{radius.server2.name}}
 address ipv4 {{radius.server2.ip}} auth-port {{radius.server2.auth_port}} acct-port {{radius.server2.acct_port}}
 key {{radius.server2.key}}
 timeout {{radius.timeout}}
 retransmit {{radius.retransmit}}

! RADIUS Server Groups
aaa group server radius {{radius.group_name}}
 server name {{radius.server1.name}}
 server name {{radius.server2.name}}
 deadtime {{radius.deadtime}}
 ip radius source-interface {{radius.source_interface}}

! Authentication Methods
aaa authentication login default local
aaa authentication login {{radius.auth_list}} group {{radius.group_name}} local
aaa authentication dot1x {{radius.dot1x_list}} group {{radius.group_name}}

! Authorization Methods
aaa authorization network {{radius.auth_list}} group {{radius.group_name}} local
aaa authorization network default group {{radius.group_name}} local
aaa authorization credential-download {{radius.cred_list}} group {{radius.group_name}} local

! Accounting Methods
aaa accounting network {{radius.acct_list}} start-stop group {{radius.group_name}}
aaa accounting identity {{radius.identity_list}} start-stop group {{radius.group_name}}
aaa accounting update newinfo periodic {{radius.acct_update}}

! Local User (Fallback)
username {{local.admin_user}} privilege 15 secret {{local.admin_password}}

! Wireless Management VLAN
interface {{management.interface}}
 ip address {{management.ip}} {{management.mask}}
 no shutdown

! RADIUS CoA Configuration
aaa server radius dynamic-author
 client {{radius.server1.ip}} server-key {{radius.server1.key}}
 client {{radius.server2.ip}} server-key {{radius.server2.key}}
 auth-type all
 port {{radius.coa_port}}

! Wireless AAA Policy
wireless aaa policy {{aaa.policy_name}}
 aaa-override
 nac
 allowed-list list-name preauth_acl

! Wireless Policy Profile
wireless profile policy {{policy.profile_name}}
 aaa-policy {{aaa.policy_name}}
 accounting-list {{radius.acct_list}}
 vlan {{policy.vlan}}
 no shutdown

! Wireless SSID Configuration
wireless tag policy {{ssid.policy_tag}}
 wlan {{ssid.name}} {{ssid.id}} policy {{policy.profile_name}}

! WLAN Configuration
wlan {{ssid.name}} {{ssid.id}} {{ssid.name}}
 security wpa psk set-key ascii {{ssid.passphrase}} SET-KEY
 security wpa wpa2
 security wpa wpa2 ciphers aes
 no security wpa akm dot1x
 security wpa akm psk
 no shutdown

! End of Cisco 9800 WLC configuration`,
    variables: {
        "radius.server1.name": {
            description: "Primary RADIUS server name",
            default: "ISE-1"
        },
        "radius.server1.ip": {
            description: "Primary RADIUS server IP",
            default: "10.1.1.1"
        },
        "radius.server1.auth_port": {
            description: "Primary RADIUS authentication port",
            default: "1812"
        },
        "radius.server1.acct_port": {
            description: "Primary RADIUS accounting port",
            default: "1813"
        },
        "radius.server1.key": {
            description: "Primary RADIUS shared secret",
            default: "secret_key"
        },
        "radius.server2.name": {
            description: "Secondary RADIUS server name",
            default: "ISE-2"
        },
        "radius.server2.ip": {
            description: "Secondary RADIUS server IP",
            default: "10.1.1.2"
        },
        "radius.server2.auth_port": {
            description: "Secondary RADIUS authentication port",
            default: "1812"
        },
        "radius.server2.acct_port": {
            description: "Secondary RADIUS accounting port",
            default: "1813"
        },
        "radius.server2.key": {
            description: "Secondary RADIUS shared secret",
            default: "secret_key"
        },
        "radius.timeout": {
            description: "RADIUS server timeout (seconds)",
            default: "5"
        },
        "radius.retransmit": {
            description: "RADIUS retransmit count",
            default: "3"
        },
        "radius.deadtime": {
            description: "RADIUS server deadtime (minutes)",
            default: "15"
        },
        "radius.group_name": {
            description: "RADIUS server group name",
            default: "ISE-GROUP"
        },
        "radius.source_interface": {
            description: "Source interface for RADIUS packets",
            default: "Vlan100"
        },
        "radius.auth_list": {
            description: "Authentication list name",
            default: "ISE_AUTH"
        },
        "radius.dot1x_list": {
            description: "Dot1x authentication list name",
            default: "ISE_DOT1X"
        },
        "radius.acct_list": {
            description: "Accounting list name",
            default: "ISE_ACCT"
        },
        "radius.identity_list": {
            description: "Identity accounting list name",
            default: "ISE_IDENTITY"
        },
        "radius.cred_list": {
            description: "Credential download list name",
            default: "ISE_CRED"
        },
        "radius.acct_update": {
            description: "Accounting update interval (seconds)",
            default: "1800"
        },
        "radius.coa_port": {
            description: "CoA port number",
            default: "1700"
        },
        "local.admin_user": {
            description: "Local admin username",
            default: "admin"
        },
        "local.admin_password": {
            description: "Local admin password",
            default: "StrongP@ssw0rd"
        },
        "management.interface": {
            description: "Management interface",
            default: "Vlan100"
        },
        "management.ip": {
            description: "Management IP address",
            default: "10.1.100.1"
        },
        "management.mask": {
            description: "Management subnet mask",
            default: "255.255.255.0"
        },
        "aaa.policy_name": {
            description: "Wireless AAA policy name",
            default: "DEFAULT-AAA-POLICY"
        },
        "policy.profile_name": {
            description: "Wireless policy profile name",
            default: "DEFAULT-POLICY-PROFILE"
        },
        "policy.vlan": {
            description: "Wireless policy VLAN",
            default: "10"
        },
        "ssid.policy_tag": {
            description: "SSID policy tag",
            default: "DEFAULT-POLICY-TAG"
        },
        "ssid.name": {
            description: "WLAN SSID name",
            default: "Enterprise-WLAN"
        },
        "ssid.id": {
            description: "WLAN SSID ID",
            default: "1"
        },
        "ssid.passphrase": {
            description: "WLAN PSK passphrase (for PSK WLANs)",
            default: "Passw0rd!"
        }
    }
};

// Export the template
if (typeof module !== 'undefined') {
    module.exports = ciscoWlc9800Template;
}
EOL
echo "Cisco WLC 9800 template added."
echo

# Add Aruba Wireless template
echo "Adding Aruba Wireless template..."
cat > js/templates/wireless/aruba/aruba_wireless.js << 'EOL'
/**
 * Aruba Wireless Configuration Template
 * For enterprise wireless with 802.1X authentication
 */
const arubaWirelessTemplate = {
    name: "Aruba Wireless",
    description: "802.1X configuration for Aruba wireless controllers",
    template: `! Aruba Wireless Configuration with 802.1X

! AAA Configuration
aaa authentication-server radius "{{radius.server1.name}}"
  host "{{radius.server1.ip}}"
  key "{{radius.server1.key}}"
  auth-port {{radius.server1.auth_port}}
  acct-port {{radius.server1.acct_port}}
  retransmit {{radius.retransmit}}
  timeout {{radius.timeout}}
  nas-identifier "{{radius.nas_id}}"
  nas-ip "{{radius.nas_ip}}"
  source-interface "{{radius.source_interface}}"

aaa authentication-server radius "{{radius.server2.name}}"
  host "{{radius.server2.ip}}"
  key "{{radius.server2.key}}"
  auth-port {{radius.server2.auth_port}}
  acct-port {{radius.server2.acct_port}}
  retransmit {{radius.retransmit}}
  timeout {{radius.timeout}}
  nas-identifier "{{radius.nas_id}}"
  nas-ip "{{radius.nas_ip}}"
  source-interface "{{radius.source_interface}}"

aaa server-group "{{radius.group_name}}"
  auth-server "{{radius.server1.name}}"
  auth-server "{{radius.server2.name}}"
  set dead-time {{radius.deadtime}}

aaa authentication dot1x "{{dot1x.profile_name}}"
  server-group "{{radius.group_name}}"
  enable

aaa profile "{{aaa.profile_name}}"
  authentication-dot1x "{{dot1x.profile_name}}"
  dot1x-default-role "{{dot1x.default_role}}"
  dot1x-server-group "{{radius.group_name}}"
  radius-accounting "{{radius.group_name}}"
  radius-interim-accounting

! CoA Configuration
aaa rfc-3576-server {{radius.server1.ip}}
  key {{radius.server1.key}}
aaa rfc-3576-server {{radius.server2.ip}}
  key {{radius.server2.key}}

! User Role Configuration
user-role "{{roles.unauthenticated}}"
  access-list session global-sacl
  access-list session captive-portal-sacl
  captive-portal

user-role "{{roles.authenticated}}"
  access-list session allowall
  access-list session ra-guard
  access-list session allowall
  access-list session ipv6-allowall

! SSID Configuration
wlan ssid-profile "{{ssid.profile_name}}"
  essid "{{ssid.name}}"
  type employee
  opmode wpa2-aes
  wpa-passphrase {{#if ssid.passphrase}}"{{ssid.passphrase}}"{{/if}}
  dtim-period 1
  max-authentication-failures 0
  auth-server {{radius.server1.name}}
  rf-band all
  captive-portal disable
  wmm
  wmm-uapsd
  wlan-beacon-interval {{ssid.beacon_interval}}
  {{#if ssid.dot1x}}
  802.11r 
  802.11r-default-mobility-domain {{ssid.mobility_domain}}
  {{/if}}
  {{#if ssid.pmf}}
  mfp-capable
  mfp-required
  {{/if}}

! End of Aruba Wireless configuration`,
    variables: {
        "radius.server1.name": {
            description: "Primary RADIUS server name",
            default: "ISE-1"
        },
        "radius.server1.ip": {
            description: "Primary RADIUS server IP",
            default: "10.1.1.1"
        },
        "radius.server1.auth_port": {
            description: "Primary RADIUS authentication port",
            default: "1812"
        },
        "radius.server1.acct_port": {
            description: "Primary RADIUS accounting port",
            default: "1813"
        },
        "radius.server1.key": {
            description: "Primary RADIUS shared secret",
            default: "secret_key"
        },
        "radius.server2.name": {
            description: "Secondary RADIUS server name",
            default: "ISE-2"
        },
        "radius.server2.ip": {
            description: "Secondary RADIUS server IP",
            default: "10.1.1.2"
        },
        "radius.server2.auth_port": {
            description: "Secondary RADIUS authentication port",
            default: "1812"
        },
        "radius.server2.acct_port": {
            description: "Secondary RADIUS accounting port",
            default: "1813"
        },
        "radius.server2.key": {
            description: "Secondary RADIUS shared secret",
            default: "secret_key"
        },
        "radius.retransmit": {
            description: "RADIUS retransmit count",
            default: "3"
        },
        "radius.timeout": {
            description: "RADIUS server timeout (seconds)",
            default: "5"
        },
        "radius.deadtime": {
            description: "RADIUS server deadtime (minutes)",
            default: "15"
        },
        "radius.nas_id": {
            description: "RADIUS NAS identifier",
            default: "aruba-controller"
        },
        "radius.nas_ip": {
            description: "RADIUS NAS IP address",
            default: "10.1.100.1"
        },
        "radius.source_interface": {
            description: "Source interface for RADIUS packets",
            default: "vlan 100"
        },
        "radius.group_name": {
            description: "RADIUS server group name",
            default: "RADIUS-GROUP"
        },
        "dot1x.profile_name": {
            description: "802.1X authentication profile name",
            default: "DOT1X-PROFILE"
        },
        "dot1x.default_role": {
            description: "Default role for 802.1X authenticated users",
            default: "authenticated"
        },
        "aaa.profile_name": {
            description: "AAA profile name",
            default: "AAA-PROFILE"
        },
        "roles.unauthenticated": {
            description: "Role for unauthenticated users",
            default: "guest"
        },
        "roles.authenticated": {
            description: "Role for authenticated users",
            default: "employee"
        },
        "ssid.profile_name": {
            description: "SSID profile name",
            default: "CORP-SSID"
        },
        "ssid.name": {
            description: "WLAN SSID name",
            default: "Corporate-WLAN"
        },
        "ssid.passphrase": {
            description: "WPA2 PSK passphrase (if not using 802.1X)",
            default: ""
        },
        "ssid.beacon_interval": {
            description: "Beacon interval (ms)",
            default: "100"
        },
        "ssid.dot1x": {
            description: "Enable 802.1X authentication",
            default: true
        },
        "ssid.mobility_domain": {
            description: "802.11r mobility domain",
            default: "1234"
        },
        "ssid.pmf": {
            description: "Enable Protected Management Frames",
            default: true
        }
    }
};

// Export the template
if (typeof module !== 'undefined') {
    module.exports = arubaWirelessTemplate;
}
EOL
echo "Aruba Wireless template added."
echo

echo "=== Template Update Complete ==="
echo "Configuration templates have been added successfully."
echo "Next, run update-dot1xer-platform.sh to add platform menu and integration features."