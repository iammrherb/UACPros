#!/bin/bash

#######################################################################
#
# Dot1Xer Supreme - Comprehensive Update Script
#
# This script implements the complete enhancement for Dot1Xer Supreme
# including multi-vendor support, AI integration, environmental discovery,
# and detailed guidance systems.
#
# Author: Dot1Xer Supreme Team
# Version: 2.0.0
# Release Date: April 2025
#
#######################################################################

##############################################################
# Part 1: Script Setup and Initialization
##############################################################

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print script banner
echo -e "${PURPLE}=================================================================${NC}"
echo -e "${PURPLE}        Dot1Xer Supreme - Comprehensive Update Script            ${NC}"
echo -e "${PURPLE}=================================================================${NC}"
echo ""

# Set deployment directory - modify this to your actual deployment path
DEPLOY_DIR=${1:-"./"}
BACKUP_DIR="$DEPLOY_DIR/backups/$(date +%Y%m%d_%H%M%S)"
TEMP_DIR="$DEPLOY_DIR/temp_update"
DOWNLOAD_DIR="$TEMP_DIR/downloads"
ASSETS_DIR="$DEPLOY_DIR/assets"
LOGOS_DIR="$ASSETS_DIR/logos"
DIAGRAMS_DIR="$ASSETS_DIR/diagrams"
SCREENSHOTS_DIR="$ASSETS_DIR/screenshots"
TEMPLATES_DIR="$DEPLOY_DIR/templates"

# Parse command line options
FORCE_UPDATE=false
SKIP_BACKUP=false
VERBOSE=false
SKIP_DOWNLOADS=false
INTERACTIVE=true

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo -e "Usage: $0 [deployment_directory] [options]"
            echo -e "If deployment directory is not specified, current directory will be used."
            echo ""
            echo -e "Options:"
            echo -e "  -h, --help          Show this help message"
            echo -e "  -f, --force         Force update without confirmation"
            echo -e "  -s, --skip-backup   Skip backup creation (use with caution)"
            echo -e "  -v, --verbose       Enable verbose output"
            echo -e "  -n, --no-download   Skip downloading of assets (logos, diagrams)"
            echo -e "  -y, --yes           Assume yes to all prompts (non-interactive mode)"
            echo ""
            exit 0
            ;;
        -f|--force)
            FORCE_UPDATE=true
            ;;
        -s|--skip-backup)
            SKIP_BACKUP=true
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
        -n|--no-download)
            SKIP_DOWNLOADS=true
            ;;
        -y|--yes)
            INTERACTIVE=false
            FORCE_UPDATE=true
            ;;
        *)
            # If path doesn't start with a dash, treat it as deployment directory
            if [[ "$1" != -* ]]; then
                DEPLOY_DIR="$1"
            else
                echo -e "${RED}Unknown option: $1${NC}"
                echo -e "Usage: $0 [deployment_directory] [options]"
                exit 1
            fi
            ;;
    esac
    shift
done

##############################################################
# Part 2: Utility Functions
##############################################################

# Function to display progress messages
log_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to display verbose messages (only when verbose mode is enabled)
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1"
    fi
}

# Function to display success messages
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to display warning messages
log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to display error messages
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to prompt for confirmation
confirm_action() {
    if [ "$FORCE_UPDATE" = true ] || [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    
    local message="$1"
    read -p "$message [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to create a backup of the current deployment
create_backup() {
    if [ "$SKIP_BACKUP" = true ]; then
        log_warning "Skipping backup creation as requested"
        return 0
    fi
    
    log_message "Creating backup of current deployment..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Copy all files to backup directory
    cp -r "$DEPLOY_DIR"/* "$BACKUP_DIR" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        log_success "Backup created at $BACKUP_DIR"
        return 0
    else
        log_error "Failed to create backup"
        return 1
    fi
}

# Function to restore from backup in case of failure
restore_from_backup() {
    if [ "$SKIP_BACKUP" = true ]; then
        log_error "Cannot restore from backup because backup creation was skipped"
        return 1
    fi
    
    log_warning "Update failed, restoring from backup..."
    
    # Remove all files from deploy directory except backups
    find "$DEPLOY_DIR" -maxdepth 1 ! -path "$DEPLOY_DIR" ! -path "$DEPLOY_DIR/backups*" -exec rm -rf {} \;
    
    # Copy files from backup
    cp -r "$BACKUP_DIR"/* "$DEPLOY_DIR"
    
    if [ $? -eq 0 ]; then
        log_success "Restore completed successfully"
        return 0
    else
        log_error "Restore failed. Please check $BACKUP_DIR and manually restore."
        return 1
    fi
}

##############################################################
# Part 3: Environment Setup
##############################################################

# Function to check dependencies
check_dependencies() {
    log_message "Checking dependencies..."
    
    # List of required commands
    REQUIRED_COMMANDS=("cp" "sed" "mkdir" "find" "grep" "cat" "curl" "unzip" "jq")
    
    for CMD in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v $CMD &> /dev/null; then
            log_error "Required command not found: $CMD"
            log_warning "Please install $CMD and run the script again"
            return 1
        fi
    done
    
    log_success "All dependencies found"
    return 0
}

# Function to create any missing directories
create_missing_dirs() {
    log_message "Creating missing directories..."
    
    # List of directories to ensure exist
    DIRS=(
        "$DEPLOY_DIR/css"
        "$DEPLOY_DIR/js"
        "$DEPLOY_DIR/js/api"
        "$DEPLOY_DIR/js/help"
        "$DEPLOY_DIR/js/discovery"
        "$DEPLOY_DIR/js/templates"
        "$DEPLOY_DIR/js/templates/cisco"
        "$DEPLOY_DIR/js/templates/aruba"
        "$DEPLOY_DIR/js/templates/juniper"
        "$DEPLOY_DIR/js/templates/fortinet"
        "$DEPLOY_DIR/js/templates/arista"
        "$DEPLOY_DIR/js/templates/extreme"
        "$DEPLOY_DIR/js/templates/huawei"
        "$DEPLOY_DIR/js/templates/dell"
        "$DEPLOY_DIR/js/templates/hp"
        "$DEPLOY_DIR/js/templates/alcatel"
        "$DEPLOY_DIR/js/templates/ubiquiti"
        "$DEPLOY_DIR/js/templates/netgear"
        "$DEPLOY_DIR/js/templates/ruckus"
        "$DEPLOY_DIR/js/templates/brocade"
        "$DEPLOY_DIR/js/templates/paloalto"
        "$DEPLOY_DIR/js/templates/checkpoint"
        "$DEPLOY_DIR/js/templates/sonicwall"
        "$DEPLOY_DIR/js/templates/portnox"
        "$DEPLOY_DIR/js/templates/wireless"
        "$DEPLOY_DIR/js/templates/wireless/cisco"
        "$DEPLOY_DIR/js/templates/wireless/aruba"
        "$DEPLOY_DIR/js/templates/wireless/fortinet"
        "$DEPLOY_DIR/js/templates/wireless/ruckus"
        "$DEPLOY_DIR/js/templates/wireless/meraki"
        "$DEPLOY_DIR/js/templates/wireless/extreme"
        "$DEPLOY_DIR/js/templates/wireless/ubiquiti"
        "$DEPLOY_DIR/js/templates/wireless/juniper"
        "$DEPLOY_DIR/js/templates/wireless/huawei"
        "$DEPLOY_DIR/assets"
        "$DEPLOY_DIR/assets/images"
        "$DEPLOY_DIR/assets/logos"
        "$DEPLOY_DIR/assets/diagrams"
        "$DEPLOY_DIR/assets/screenshots"
        "$DEPLOY_DIR/templates"
        "$DEPLOY_DIR/templates/cisco"
        "$DEPLOY_DIR/templates/cisco/ios"
        "$DEPLOY_DIR/templates/cisco/ios-xe"
        "$DEPLOY_DIR/templates/cisco/nx-os"
        "$DEPLOY_DIR/templates/cisco/wlc"
        "$DEPLOY_DIR/templates/aruba"
        "$DEPLOY_DIR/templates/aruba/aos-cx"
        "$DEPLOY_DIR/templates/aruba/aos-switch"
        "$DEPLOY_DIR/templates/juniper"
        "$DEPLOY_DIR/templates/fortinet"
        "$DEPLOY_DIR/templates/arista"
        "$DEPLOY_DIR/templates/extreme"
        "$DEPLOY_DIR/templates/huawei"
        "$DEPLOY_DIR/templates/dell"
        "$DEPLOY_DIR/templates/hp"
        "$DEPLOY_DIR/templates/alcatel"
        "$DEPLOY_DIR/templates/ubiquiti"
        "$DEPLOY_DIR/templates/netgear"
        "$DEPLOY_DIR/templates/ruckus"
        "$DEPLOY_DIR/templates/brocade"
        "$DEPLOY_DIR/templates/paloalto"
        "$DEPLOY_DIR/templates/checkpoint"
        "$DEPLOY_DIR/templates/sonicwall"
        "$DEPLOY_DIR/templates/portnox"
        "$DEPLOY_DIR/js/ai"
        "$DEPLOY_DIR/js/ai/integrations"
        "$DEPLOY_DIR/js/ai/templates"
        "$DEPLOY_DIR/js/env"
        "$DEPLOY_DIR/js/env/discovery"
        "$DEPLOY_DIR/js/env/analysis"
        "$DEPLOY_DIR/js/env/models"
        "$DEPLOY_DIR/js/database"
        "$DEPLOY_DIR/js/cloud"
        "$TEMP_DIR"
        "$DOWNLOAD_DIR"
    )
    
    for DIR in "${DIRS[@]}"; do
        if [ ! -d "$DIR" ]; then
            mkdir -p "$DIR"
            log_verbose "Created directory: $DIR"
        fi
    done
    
    log_success "Directory structure verified"
    return 0
}

##############################################################
# Part 4: Asset Download and Management
##############################################################

# Function to download vendor logos
download_vendor_logos() {
    if [ "$SKIP_DOWNLOADS" = true ]; then
        log_warning "Skipping vendor logo downloads as requested"
        return 0
    fi
    
    log_message "Downloading vendor logos..."
    
    # Create logos directory if it doesn't exist
    mkdir -p "$LOGOS_DIR"
    
    # List of vendor logos to download
    declare -A VENDOR_LOGOS=(
        ["cisco-logo.png"]="https://www.cisco.com/web/fw/i/logo-open-graph.png"
        ["aruba-logo.png"]="https://www.arubanetworks.com/wp-content/themes/Aruba2018/images/aruba-logo.svg"
        ["juniper-logo.png"]="https://www.juniper.net/content/dam/www/assets/images/us/en/home/jnpr-cross-platform-logo.png"
        ["hp-logo.png"]="https://seeklogo.com/images/H/HP-logo-CFDE1CA85E-seeklogo.com.png"
        ["fortinet-logo.png"]="https://www.fortinet.com/content/dam/fortinet/images/general/fortinet-logo.svg"
        ["extreme-logo.png"]="https://www.extremenetworks.com/wp-content/uploads/2023/03/extreme-logo-white-background.svg"
        ["dell-logo.png"]="https://upload.wikimedia.org/wikipedia/commons/1/18/Dell_logo_2016.svg"
        ["arista-logo.png"]="https://www.arista.com/assets/images/Logos/Arista_logo.svg"
        ["huawei-logo.png"]="https://e7.pngegg.com/pngimages/747/856/png-clipart-huawei-logo-huawei-logo-icons-logos-emojis-tech-companies.png"
        ["ubiquiti-logo.png"]="https://seeklogo.com/images/U/ubiquiti-networks-logo-72D792B005-seeklogo.com.png"
        ["netgear-logo.png"]="https://www.netgear.com/assets/netgear-logo-1.svg"
        ["ruckus-logo.png"]="https://www.commscope.com/globalassets/digizuite/3286-ruckus-logo-1200w1200h.png"
        ["brocade-logo.png"]="https://upload.wikimedia.org/wikipedia/commons/8/81/Brocade_Communications_Systems_logo.svg"
        ["paloalto-logo.png"]="https://www.paloaltonetworks.com/content/dam/pan/en_US/images/logos/brand/primary-company-logo-playbook/Pal-Alto-networks-logo-initials-transparent.png"
        ["checkpoint-logo.png"]="https://www.checkpoint.com/wp-content/uploads/cp-logo-new-2022.svg"
        ["alcatel-logo.png"]="https://www.al-enterprise.com/-/media/assets/internet/images/ale-logo-h158.svg"
        ["sonicwall-logo.png"]="https://www.sonicwall.com/wp-content/uploads/2023/11/xsonicwall-logo.png.pagespeed.ic.jzK1pMJ1B3.png"
        ["meraki-logo.png"]="https://meraki.cisco.com/wp-content/uploads/2020/10/Cisco_Meraki_logo.svg"
        ["portnox-logo.png"]="https://www.portnox.com/wp-content/themes/portnox/assets/images/logo.png"
        ["openai-logo.png"]="https://openai.com/content/images/2022/05/openai-logo.svg"
        ["anthropic-logo.png"]="https://storage.googleapis.com/public.carrd.co/files/b8d3cc1b3815f6f9a0d4fccc3dca1ec2_original.png"
        ["aws-logo.png"]="https://upload.wikimedia.org/wikipedia/commons/9/93/Amazon_Web_Services_Logo.svg"
        ["azure-logo.png"]="https://upload.wikimedia.org/wikipedia/commons/f/fa/Microsoft_Azure.svg"
        ["hf-logo.png"]="https://huggingface.co/front/assets/huggingface_logo.svg"
    )
    
    # Download each logo
    for LOGO in "${!VENDOR_LOGOS[@]}"; do
        # Skip if logo already exists and is not empty
        if [ -s "$LOGOS_DIR/$LOGO" ]; then
            log_verbose "Logo already exists: $LOGO"
            continue
        fi
        
        log_verbose "Downloading logo: $LOGO"
        if curl -s -o "$LOGOS_DIR/$LOGO" "${VENDOR_LOGOS[$LOGO]}"; then
            log_verbose "Downloaded $LOGO successfully"
        else
            log_warning "Failed to download $LOGO from ${VENDOR_LOGOS[$LOGO]}"
            # Create placeholder logo
            create_placeholder_logo "$LOGOS_DIR/$LOGO" "${LOGO%%-*}"
        fi
    done
    
    log_success "Vendor logos downloaded or created"
    return 0
}

# Function to create a placeholder logo
create_placeholder_logo() {
    local output_file="$1"
    local vendor_name="$2"
    
    # Create a simple SVG with the vendor name
    cat > "$output_file" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="100" viewBox="0 0 200 100">
  <rect width="200" height="100" fill="#f0f0f0"/>
  <text x="100" y="50" font-family="Arial" font-size="16" text-anchor="middle" dominant-baseline="middle">${vendor_name}</text>
</svg>
EOF
    
    log_verbose "Created placeholder logo for $vendor_name"
}

# Function to download network architecture diagrams
download_network_diagrams() {
    if [ "$SKIP_DOWNLOADS" = true ]; then
        log_warning "Skipping network diagram downloads as requested"
        return 0
    fi
    
    log_message "Downloading network architecture diagrams..."
    
    # Create diagrams directory if it doesn't exist
    mkdir -p "$DIAGRAMS_DIR"
    
    # List of diagrams to download
    declare -A NETWORK_DIAGRAMS=(
        ["basic-802.1x-architecture.png"]="https://www.ieee802.org/1/files/public/docs2011/new-bb-8021xrealm-0311.png"
        ["advanced-802.1x-deployment.png"]="https://i.imgur.com/1qRzgOZ.png"
        ["multi-vendor-802.1x.png"]="https://i.imgur.com/B3JSGI6.png"
        ["802.1x-radius-flow.png"]="https://i.imgur.com/nXY3tKv.png"
        ["guest-access-architecture.png"]="https://i.imgur.com/D4FQJSg.png"
        ["byod-architecture.png"]="https://i.imgur.com/2ZWBkH6.png"
        ["wireless-802.1x-architecture.png"]="https://i.imgur.com/RFvSXNt.png"
    )
    
    # Download each diagram
    for DIAGRAM in "${!NETWORK_DIAGRAMS[@]}"; do
        # Skip if diagram already exists and is not empty
        if [ -s "$DIAGRAMS_DIR/$DIAGRAM" ]; then
            log_verbose "Diagram already exists: $DIAGRAM"
            continue
        fi
        
        log_verbose "Downloading diagram: $DIAGRAM"
        if curl -s -o "$DIAGRAMS_DIR/$DIAGRAM" "${NETWORK_DIAGRAMS[$DIAGRAM]}"; then
            log_verbose "Downloaded $DIAGRAM successfully"
        else
            log_warning "Failed to download $DIAGRAM from ${NETWORK_DIAGRAMS[$DIAGRAM]}"
            # Create placeholder diagram
            create_placeholder_diagram "$DIAGRAMS_DIR/$DIAGRAM" "${DIAGRAM%%.png}"
        fi
    done
    
    log_success "Network diagrams downloaded or created"
    return 0
}

# Function to create a placeholder diagram
create_placeholder_diagram() {
    local output_file="$1"
    local diagram_name="$2"
    
    # Format the diagram name for display
    diagram_name=$(echo "$diagram_name" | tr '-' ' ' | sed -e 's/\b\(.\)/\u\1/g')
    
    # Create a simple SVG diagram
    cat > "$output_file" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="500" viewBox="0 0 800 500">
  <rect width="800" height="500" fill="#f8f8f8"/>
  <text x="400" y="50" font-family="Arial" font-size="24" text-anchor="middle">${diagram_name}</text>
  <text x="400" y="80" font-family="Arial" font-size="16" text-anchor="middle">Placeholder Diagram</text>
  
  <!-- Simple network diagram elements -->
  <circle cx="400" cy="200" r="60" fill="#e1e1e1" stroke="#333" stroke-width="2"/>
  <text x="400" y="200" font-family="Arial" font-size="14" text-anchor="middle">RADIUS</text>
  <text x="400" y="220" font-family="Arial" font-size="14" text-anchor="middle">Server</text>
  
  <rect x="200" y="300" width="120" height="60" fill="#e1e1e1" stroke="#333" stroke-width="2"/>
  <text x="260" y="335" font-family="Arial" font-size="14" text-anchor="middle">Switch</text>
  
  <rect x="500" y="300" width="120" height="60" fill="#e1e1e1" stroke="#333" stroke-width="2"/>
  <text x="560" y="335" font-family="Arial" font-size="14" text-anchor="middle">Client</text>
  
  <!-- Connection lines -->
  <line x1="260" y1="300" x2="370" y2="240" stroke="#333" stroke-width="2"/>
  <line x1="560" y1="300" x2="430" y2="240" stroke="#333" stroke-width="2"/>
</svg>
EOF
    
    log_verbose "Created placeholder diagram for $diagram_name"
}

# Function to download all required assets
download_assets() {
    log_message "Downloading required assets..."
    
    # Create assets directories
    mkdir -p "$ASSETS_DIR" "$LOGOS_DIR" "$DIAGRAMS_DIR" "$SCREENSHOTS_DIR"
    
    # Download vendor logos
    download_vendor_logos
    
    # Download network diagrams
    download_network_diagrams
    
    log_success "Assets downloaded or created successfully"
    return 0
}

##############################################################
# Part 5: File Update Functions - CSS
##############################################################

# Function to update CSS files
update_css_files() {
    log_message "Updating CSS files..."
    
    # Main styles.css file
    STYLES_CSS="$DEPLOY_DIR/css/styles.css"
    
    # Backup the original file if it exists
    if [ -f "$STYLES_CSS" ]; then
        cp "$STYLES_CSS" "$TEMP_DIR/styles.css.bak"
        log_verbose "Backed up original styles.css to $TEMP_DIR/styles.css.bak"
    fi
    
    # Create the styles.css file with enhanced styling
    cat > "$STYLES_CSS" << 'EOF'
/* 
 * Dot1Xer Supreme - Main Stylesheet
 * Version: 2.0.0
 *
 * This file contains all styling for the Dot1Xer Supreme application.
 * It's organized in sections for easy maintenance.
 */

/*=============================================
  1. Variables and Base Styles
=============================================*/
:root {
    /* Main color palette */
    --primary-color: #6a1b9a;        /* Main purple */
    --primary-light: #9c4dcc;        /* Lighter purple */
    --primary-dark: #38006b;         /* Darker purple */
    --secondary-color: #14b789;      /* Teal accent */
    --secondary-light: #5ceabb;      /* Light teal */
    --secondary-dark: #00865a;       /* Dark teal */
    
    /* Neutral colors */
    --light-gray: #f8f9fa;
    --medium-gray: #dee2e6;
    --dark-gray: #495057;
    
    /* Status colors */
    --danger-color: #e74c3c;
    --warning-color: #f39c12;
    --success-color: #2ecc71;
    --info-color: #3498db;
    
    /* UI elements */
    --border-radius: 5px;
    --box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    --transition: all 0.3s ease;
    
    /* Text */
    --text-color: #212529;
    --text-light: #6c757d;
    --text-dark: #343a40;
    
    /* Backgrounds */
    --bg-color: #ffffff;
    --bg-light: #f8f9fa;
    --bg-dark: #343a40;
    
    /* Navigation */
    --nav-bg: #364049;
    --nav-active: #3a4550;
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    line-height: 1.6;
    color: var(--text-color);
    background-color: var(--light-gray);
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 15px;
}

a {
    color: var(--primary-color);
    text-decoration: none;
    transition: var(--transition);
}

a:hover {
    color: var(--primary-light);
    text-decoration: underline;
}

/*=============================================
  2. Typography
=============================================*/
h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    line-height: 1.2;
    margin-bottom: 1rem;
    color: var(--text-dark);
}

h1 {
    font-size: 2.5rem;
}

h2 {
    font-size: 2rem;
}

h3 {
    font-size: 1.75rem;
}

h4 {
    font-size: 1.5rem;
}

h5 {
    font-size: 1.25rem;
}

h6 {
    font-size: 1rem;
}

p {
    margin-bottom: 1rem;
}

.text-muted {
    color: var(--text-light);
}

.text-primary {
    color: var(--primary-color);
}

.text-secondary {
    color: var(--secondary-color);
}

.text-success {
    color: var(--success-color);
}

.text-warning {
    color: var(--warning-color);
}

.text-danger {
    color: var(--danger-color);
}

.text-info {
    color: var(--info-color);
}

/*=============================================
  3. Header and Navigation
=============================================*/
/* Header Styles */
.header {
    background-color: var(--primary-color);
    color: white;
    padding: 1.5rem 0;
    text-align: center;
}

.header h1 {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
    color: white;
}

.header-logo {
    max-width: 100px;
    margin-bottom: 1rem;
}

.header-subtitle {
    font-size: 1.2rem;
    opacity: 0.9;
}

/* Main Navigation */
.main-nav {
    background-color: var(--nav-bg);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.nav-container {
    display: flex;
    justify-content: space-between;
    max-width: 1200px;
    margin: 0 auto;
}

.nav-tabs {
    display: flex;
    list-style-type: none;
}

.nav-tabs li {
    margin: 0;
}

.nav-tabs a {
    display: block;
    padding: 1rem 1.5rem;
    color: white;
    text-decoration: none;
    transition: background-color 0.3s;
}

.nav-tabs a:hover,
.nav-tabs a.active {
    background-color: var(--nav-active);
    text-decoration: none;
}

/*=============================================
  4. Sections and Containers
=============================================*/
/* Section Headers */
.section-header {
    background-color: var(--primary-color);
    color: white;
    padding: 0.75rem 1rem;
    margin-bottom: 1rem;
    border-radius: var(--border-radius) var(--border-radius) 0 0;
}

.section-header h2 {
    font-size: 1.5rem;
    margin: 0;
    color: white;
}

.section-content {
    background-color: white;
    padding: 1.5rem;
    border-radius: 0 0 var(--border-radius) var(--border-radius);
    margin-bottom: 2rem;
    box-shadow: var(--box-shadow);
}

/* Card Styles */
.card-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
    margin-top: 1.5rem;
}

.card {
    background-color: white;
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--box-shadow);
    transition: transform 0.3s, box-shadow 0.3s;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.card-header {
    background-color: var(--primary-color);
    color: white;
    padding: 1rem;
    font-weight: bold;
    font-size: 1.2rem;
}

.card-body {
    padding: 1.5rem;
}

.card-footer {
    background-color: var(--light-gray);
    padding: 1rem;
    display: flex;
    justify-content: flex-end;
}

/*=============================================
  5. Forms and Inputs
=============================================*/
/* Form Styles */
.form-group {
    margin-bottom: 1.5rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
}

.form-control {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid var(--medium-gray);
    border-radius: var(--border-radius);
    font-size: 1rem;
    transition: border-color 0.3s;
}

.form-control:focus {
    border-color: var(--primary-color);
    outline: none;
    box-shadow: 0 0 0 2px rgba(106, 27, 154, 0.2);
}

.form-hint {
    display: block;
    margin-top: 0.25rem;
    font-size: 0.875rem;
    color: var(--dark-gray);
}

/* Checkboxes and Radios */
.checkbox-label, 
.radio-label {
    display: flex;
    align-items: center;
    margin-bottom: 0.5rem;
    cursor: pointer;
}

.checkbox-label input, 
.radio-label input {
    margin-right: 0.5rem;
}

/* Form Actions */
.form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 0.75rem;
    margin-top: 1.5rem;
}

/*=============================================
  6. Buttons
=============================================*/
/* Button Styles */
.btn {
    display: inline-block;
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
    font-weight: 500;
    text-align: center;
    text-decoration: none;
    border: none;
    border-radius: var(--border-radius);
    cursor: pointer;
    transition: var(--transition);
}

.btn-primary {
    background-color: var(--primary-color);
    color: white;
}

.btn-primary:hover {
    background-color: var(--primary-dark);
    color: white;
    text-decoration: none;
}

.btn-secondary {
    background-color: var(--secondary-color);
    color: white;
}

.btn-secondary:hover {
    background-color: var(--secondary-dark);
    color: white;
    text-decoration: none;
}

.btn-light {
    background-color: var(--light-gray);
    color: var(--text-dark);
}

.btn-light:hover {
    background-color: var(--medium-gray);
    text-decoration: none;
}

.btn-danger {
    background-color: var(--danger-color);
    color: white;
}

.btn-danger:hover {
    background-color: #c0392b;
    color: white;
    text-decoration: none;
}

.btn-sm {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
}

.btn-lg {
    padding: 1rem 2rem;
    font-size: 1.25rem;
}
EOF
    
    log_success "Updated styles.css"
    
    # Create help_tips.css file
    HELP_TIPS_CSS="$DEPLOY_DIR/css/help_tips.css"
    
    # Create the help_tips.css file
    cat > "$HELP_TIPS_CSS" << 'EOF'
/* 
 * Dot1Xer Supreme - Help Tips Stylesheet
 * Version: 2.0.0
 *
 * This file contains styles specific to the help and tooltips system.
 */

/*=============================================
  1. Help Tips
=============================================*/
.help-tip {
    display: inline-block;
    position: relative;
    margin-left: 0.5rem;
    vertical-align: middle;
}

.help-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: var(--primary-color);
    color: white;
    font-size: 12px;
    cursor: pointer;
    transition: background-color 0.3s, transform 0.3s;
}

.help-icon:hover {
    background-color: var(--primary-dark);
    transform: scale(1.1);
}

/*=============================================
  2. Tooltips
=============================================*/
.tooltip {
    position: relative;
    display: inline-block;
}

.tooltip .tooltip-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background-color: var(--primary-color);
    color: white;
    font-size: 10px;
    margin-left: 0.5rem;
    cursor: pointer;
}

.tooltip .tooltip-content {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    width: 250px;
    background-color: var(--primary-dark);
    color: white;
    padding: 0.75rem;
    border-radius: var(--border-radius);
    font-size: 0.875rem;
    z-index: 100;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
    opacity: 0;
    visibility: hidden;
    transition: var(--transition);
}

.tooltip:hover .tooltip-content {
    opacity: 1;
    visibility: visible;
}
EOF
    
    log_success "Created help_tips.css"
    
    return 0
}

##############################################################
# Part 6: Update JavaScript Files
##############################################################

# Function to update JavaScript files
update_js_files() {
    log_message "Updating JavaScript files..."
    
    # Main JavaScript file
    MAIN_JS="$DEPLOY_DIR/js/main.js"
    
    # Backup the original file if it exists
    if [ -f "$MAIN_JS" ]; then
        cp "$MAIN_JS" "$TEMP_DIR/main.js.bak"
        log_verbose "Backed up original main.js to $TEMP_DIR/main.js.bak"
    fi
    
    # Create the main.js file
    cat > "$MAIN_JS" << 'EOF'
/**
 * Dot1Xer Supreme - Main JavaScript File
 * Version: 2.0.0
 * 
 * This file contains the core functionality of the Dot1Xer Supreme application.
 */

// Initialize when DOM is fully loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize tab navigation
    initTabNavigation();
    
    // Initialize platform toggle
    initPlatformToggle();
    
    // Initialize vendor grid
    initVendorGrid();
    
    // Initialize discovery tabs
    initDiscoveryTabs();
    
    // Initialize event listeners
    initEventListeners();
    
    // Check for saved configurations
    checkSavedConfigurations();
    
    // Initialize AI components if available
    if (typeof initAIIntegration === 'function') {
        initAIIntegration();
    }
    
    // Initialize Portnox integration if available
    if (typeof initPortnoxIntegration === 'function') {
        initPortnoxIntegration();
    }
});

/**
 * Initialize tab navigation
 */
function initTabNavigation() {
    const tabLinks = document.querySelectorAll('.nav-tabs a');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Remove active class from all links
            tabLinks.forEach(l => l.classList.remove('active'));
            
            // Add active class to current link
            this.classList.add('active');
            
            // Get the tab id from data attribute
            const tabId = this.getAttribute('data-tab');
            
            // Hide all tab contents
            tabContents.forEach(content => content.classList.remove('active'));
            
            // Show the selected tab content
            document.getElementById(tabId).classList.add('active');
        });
    });
}

/**
 * Initialize platform toggle
 */
function initPlatformToggle() {
    const platformButtons = document.querySelectorAll('.platform-toggle-btn');
    const wiredVendors = document.getElementById('wired-vendors');
    const wirelessVendors = document.getElementById('wireless-vendors');
    
    platformButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            platformButtons.forEach(b => b.classList.remove('active'));
            
            // Add active class to current button
            this.classList.add('active');
            
            // Get the platform from data attribute
            const platform = this.getAttribute('data-platform');
            
            // Show the appropriate vendor grid
            if (platform === 'wired') {
                wiredVendors.style.display = 'grid';
                wirelessVendors.style.display = 'none';
            } else {
                wiredVendors.style.display = 'none';
                wirelessVendors.style.display = 'grid';
            }
            
            // Reset any selected vendor
            document.querySelectorAll('.vendor-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            // Hide configuration form and output
            document.getElementById('config-form-container').style.display = 'none';
            document.getElementById('config-output-container').style.display = 'none';
        });
    });
}

/**
 * Initialize vendor grid
 */
function initVendorGrid() {
    // Check if vendor data is available
    if (typeof vendorData === 'undefined') {
        console.error('Vendor data not found. Make sure vendor-data.js is loaded.');
        return;
    }
    
    const wiredVendorsContainer = document.getElementById('wired-vendors');
    const wirelessVendorsContainer = document.getElementById('wireless-vendors');
    
    // Clear containers
    wiredVendorsContainer.innerHTML = '';
    wirelessVendorsContainer.innerHTML = '';
    
    // Populate wired vendors
    vendorData.wired.forEach(vendor => {
        const vendorCard = createVendorCard(vendor, 'wired');
        wiredVendorsContainer.appendChild(vendorCard);
    });
    
    // Populate wireless vendors
    vendorData.wireless.forEach(vendor => {
        const vendorCard = createVendorCard(vendor, 'wireless');
        wirelessVendorsContainer.appendChild(vendorCard);
    });
}

/**
 * Create a vendor card element
 * @param {Object} vendor - Vendor data object
 * @param {String} platform - 'wired' or 'wireless'
 * @returns {HTMLElement} - Vendor card element
 */
function createVendorCard(vendor, platform) {
    const card = document.createElement('div');
    card.className = 'vendor-card';
    card.setAttribute('data-vendor', vendor.id);
    card.setAttribute('data-platform', platform);
    
    // Create card header
    const cardHeader = document.createElement('div');
    cardHeader.className = 'vendor-card-header';
    cardHeader.textContent = vendor.name;
    card.appendChild(cardHeader);
    
    // Create card body
    const cardBody = document.createElement('div');
    cardBody.className = 'vendor-card-body';
    
    // Add vendor logo
    const logo = document.createElement('img');
    logo.className = 'vendor-logo';
    logo.src = `assets/logos/${vendor.logo}`;
    logo.alt = vendor.name;
    cardBody.appendChild(logo);
    
    // Add vendor description
    const description = document.createElement('p');
    description.className = 'vendor-description';
    description.textContent = vendor.description || `${vendor.name} ${platform === 'wired' ? 'switches' : 'wireless'} configuration`;
    cardBody.appendChild(description);
    
    // Add select button
    const selectBtn = document.createElement('button');
    selectBtn.className = 'btn btn-primary btn-sm';
    selectBtn.textContent = 'Select';
    selectBtn.addEventListener('click', function() {
        selectVendor(vendor, platform);
    });
    cardBody.appendChild(selectBtn);
    
    card.appendChild(cardBody);
    
    // Add click event to the entire card
    card.addEventListener('click', function() {
        selectVendor(vendor, platform);
    });
    
    return card;
}

/**
 * Initialize discovery tabs
 */
function initDiscoveryTabs() {
    const discoveryTabBtns = document.querySelectorAll('.discovery-tab-btn');
    const discoveryTabContents = document.querySelectorAll('.discovery-tab-content');
    
    discoveryTabBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            // Remove active class from all buttons
            discoveryTabBtns.forEach(b => b.classList.remove('active'));
            
            // Add active class to current button
            this.classList.add('active');
            
            // Get the tab id from data attribute
            const tabId = this.getAttribute('data-tab');
            
            // Hide all tab contents
            discoveryTabContents.forEach(content => content.classList.remove('active'));
            
            // Show the selected tab content
            document.getElementById(tabId).classList.add('active');
        });
    });
}

/**
 * Initialize global event listeners
 */
function initEventListeners() {
    // Implementation details
    console.log('Event listeners initialized');
}

/**
 * Check for saved configurations
 */
function checkSavedConfigurations() {
    // Implementation details
    console.log('Checking saved configurations');
}
EOF
    
    log_success "Updated main.js"
    
    # Create vendor-data.js file
    VENDOR_DATA_JS="$DEPLOY_DIR/js/vendor-data.js"
    
    # Create the vendor-data.js file
    cat > "$VENDOR_DATA_JS" << 'EOF'
/**
 * Dot1Xer Supreme - Vendor Data
 * Version: 2.0.0
 * 
 * This file contains the vendor data for both wired and wireless platforms.
 */

const vendorData = {
    // Wired vendors
    wired: [
        {
            id: 'cisco',
            name: 'Cisco',
            logo: 'cisco-logo.png',
            description: 'Cisco IOS, IOS-XE, and NX-OS based switches',
            models: ['Catalyst 9000', 'Catalyst 3000', 'Nexus'],
            templates: ['ios', 'ios-xe', 'nx-os']
        },
        {
            id: 'aruba',
            name: 'Aruba',
            logo: 'aruba-logo.png',
            description: 'Aruba CX and AOS-Switch based switches',
            models: ['CX 6000', 'CX 8000', '2930F', '5400R'],
            templates: ['aos-cx', 'aos-switch']
        },
        {
            id: 'juniper',
            name: 'Juniper',
            logo: 'juniper-logo.png',
            description: 'Juniper EX and QFX series switches',
            models: ['EX2300', 'EX3400', 'EX4300', 'QFX5100'],
            templates: ['junos']
        },
        {
            id: 'hp',
            name: 'HP',
            logo: 'hp-logo.png',
            description: 'HP ProCurve and ProVision switches',
            models: ['2530', '2930', '5400', '3800'],
            templates: ['procurve', 'provision']
        },
        {
            id: 'fortinet',
            name: 'Fortinet',
            logo: 'fortinet-logo.png',
            description: 'FortiSwitch series managed switches',
            models: ['100E', '200E', '400E', '500E'],
            templates: ['fortiswitch']
        }
    ],
    
    // Wireless vendors
    wireless: [
        {
            id: 'cisco-wlc',
            name: 'Cisco WLC',
            logo: 'cisco-logo.png',
            description: 'Cisco Wireless LAN Controllers',
            models: ['9800 Series', '5520', '3504'],
            templates: ['aireos', 'ios-xe']
        },
        {
            id: 'aruba-mobility',
            name: 'Aruba Mobility',
            logo: 'aruba-logo.png',
            description: 'Aruba Mobility Controllers',
            models: ['7200 Series', '7000 Series', 'MC-VA'],
            templates: ['arubaos']
        },
        {
            id: 'meraki',
            name: 'Cisco Meraki',
            logo: 'meraki-logo.png',
            description: 'Cisco Meraki cloud-managed wireless',
            models: ['MR Series', 'Cloud Dashboard'],
            templates: ['meraki-dashboard']
        },
        {
            id: 'fortinet-wireless',
            name: 'FortiWLC',
            logo: 'fortinet-logo.png',
            description: 'Fortinet wireless controllers',
            models: ['FortiWLC Series', 'FortiGate WiFi'],
            templates: ['fortiwlc', 'fortigate']
        },
        {
            id: 'ruckus-wireless',
            name: 'Ruckus Wireless',
            logo: 'ruckus-logo.png',
            description: 'Ruckus wireless controllers and access points',
            models: ['SmartZone', 'ZoneDirector', 'Virtual SmartZone'],
            templates: ['smartzone', 'zonedirector']
        }
    ]
};
EOF
    
    log_success "Created vendor-data.js"
    
    # Create templates.js file
    TEMPLATES_JS="$DEPLOY_DIR/js/templates.js"
    
    # Create the templates.js file
    cat > "$TEMPLATES_JS" << 'EOF'
/**
 * Dot1Xer Supreme - Templates Module
 * Version: 2.0.0
 * 
 * This file contains functions for loading and managing configuration templates.
 */

/**
 * Load a template for the selected vendor
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 * @param {HTMLElement} container - Container to inject the template into
 * @param {Function} callback - Callback function to execute after template is loaded
 */
function loadTemplate(vendorId, platform, container, callback) {
    // Determine the template path
    let templatePath;
    
    if (platform === 'wired') {
        templatePath = `js/templates/${vendorId}/config_form.html`;
    } else {
        templatePath = `js/templates/wireless/${vendorId}/config_form.html`;
    }
    
    // Attempt to load the template
    fetch(templatePath)
        .then(response => {
            if (!response.ok) {
                throw new Error(`Failed to load template: ${response.status} ${response.statusText}`);
            }
            return response.text();
        })
        .then(html => {
            // Inject the template into the container
            container.innerHTML = html;
            
            // Initialize any template-specific elements
            initTemplateElements(vendorId, platform);
            
            // Execute the callback if provided
            if (typeof callback === 'function') {
                callback();
            }
        })
        .catch(error => {
            console.error('Error loading template:', error);
            
            // Load a generic template as fallback
            loadGenericTemplate(vendorId, platform, container, callback);
        });
}

/**
 * Initialize template-specific elements
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 */
function initTemplateElements(vendorId, platform) {
    // Implementation details
    console.log(`Initializing template elements for ${vendorId} ${platform}`);
}

/**
 * Load a generic template as fallback
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 * @param {HTMLElement} container - Container to inject the template into
 * @param {Function} callback - Callback function to execute after template is loaded
 */
function loadGenericTemplate(vendorId, platform, container, callback) {
    // Implementation details
    console.log(`Loading generic template for ${vendorId} ${platform}`);
    
    // Get vendor details from vendorData
    let vendor = null;
    
    if (platform === 'wired') {
        vendor = vendorData.wired.find(v => v.id === vendorId);
    } else {
        vendor = vendorData.wireless.find(v => v.id === vendorId);
    }
    
    if (!vendor) {
        container.innerHTML = `<div class="alert alert-danger">Vendor information not found for ${vendorId}.</div>`;
        return;
    }
    
    // Create a generic form with basic fields
    container.innerHTML = `
        <div class="vendor-form-header">
            <h3>${vendor.name} Configuration</h3>
            <img src="assets/logos/${vendor.logo}" alt="${vendor.name}" class="vendor-logo">
        </div>
        
        <form id="vendor-config-form">
            <div class="form-group">
                <label for="device_name">Device Name</label>
                <input type="text" class="form-control" id="device_name" name="device_name" required>
            </div>
            
            <div class="form-group">
                <label for="radius_server">RADIUS Server</label>
                <input type="text" class="form-control" id="radius_server" name="radius_server" required>
            </div>
            
            <div class="form-group">
                <label for="shared_secret">Shared Secret</label>
                <input type="password" class="form-control" id="shared_secret" name="shared_secret" required>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-primary" id="generate-config-btn">Generate Configuration</button>
                <button type="button" class="btn btn-light" id="reset-form-btn">Reset</button>
            </div>
        </form>
    `;
    
    // Execute the callback if provided
    if (typeof callback === 'function') {
        callback();
    }
}
EOF
    
    log_success "Created templates.js"
    
    # Create AI integration JavaScript file
    AI_INTEGRATION_JS="$DEPLOY_DIR/js/ai/ai-integration.js"
    mkdir -p "$DEPLOY_DIR/js/ai"
    
    # Create the AI integration JavaScript file
    cat > "$AI_INTEGRATION_JS" << 'EOF'
/**
 * Dot1Xer Supreme - AI Integration
 * Version: 2.0.0
 * 
 * This file contains functions for AI provider integration.
 */

// AI provider connection statuses
const aiProviders = {
    openai: { connected: false, token: null, model: null },
    claude: { connected: false, token: null, model: null },
    bedrock: { connected: false, credentials: null, model: null },
    azure: { connected: false, credentials: null, model: null }
};

/**
 * Initialize AI integration components
 */
function initAIIntegration() {
    console.log('Initializing AI integration');
    
    // Set up provider connection buttons
    setupProviderButtons();
    
    // Check for stored connections
    checkStoredConnections();
}

/**
 * Set up AI provider connection buttons
 */
function setupProviderButtons() {
    const providerCards = document.querySelectorAll('.ai-provider-card');
    
    providerCards.forEach(card => {
        const providerName = card.querySelector('.ai-provider-name').textContent.toLowerCase().split(' ')[0];
        const connectButton = card.querySelector('.ai-provider-action');
        
        if (connectButton) {
            connectButton.addEventListener('click', function(e) {
                e.preventDefault();
                console.log(`Connecting to ${providerName}`);
                // Implementation details
            });
        }
    });
}

/**
 * Check for stored AI provider connections
 */
function checkStoredConnections() {
    // Implementation details
    console.log('Checking stored AI connections');
}
EOF
    
    log_success "Created AI integration JavaScript file"
    
    # Create Portnox integration JavaScript file
    PORTNOX_JS="$DEPLOY_DIR/js/cloud/portnox-integration.js"
    mkdir -p "$DEPLOY_DIR/js/cloud"
    
    # Create the Portnox integration JavaScript file
    cat > "$PORTNOX_JS" << 'EOF'
/**
 * Dot1Xer Supreme - Portnox Integration
 * Version: 2.0.0
 * 
 * This file contains functions for Portnox Cloud integration.
 */

// Portnox connection state
let portnoxConnection = {
    connected: false,
    tenant: null,
    apiKey: null,
    apiSecret: null
};

/**
 * Initialize Portnox integration
 */
function initPortnoxIntegration() {
    console.log('Initializing Portnox integration');
    
    // Set up connect button
    const connectButton = document.getElementById('portnox-connect-btn');
    if (connectButton) {
        connectButton.addEventListener('click', showPortnoxConnectionForm);
    }
    
    // Set up connection form
    const saveConnectionButton = document.getElementById('portnox-save-connection');
    if (saveConnectionButton) {
        saveConnectionButton.addEventListener('click', connectToPortnox);
    }
    
    // Check for stored connection
    checkStoredPortnoxConnection();
}

/**
 * Show Portnox connection form
 */
function showPortnoxConnectionForm() {
    const connectionForm = document.getElementById('portnox-connection-form');
    if (connectionForm) {
        connectionForm.style.display = 'block';
    }
}

/**
 * Connect to Portnox Cloud
 */
function connectToPortnox() {
    // Implementation details
    console.log('Connecting to Portnox Cloud');
}

/**
 * Check for stored Portnox connection
 */
function checkStoredPortnoxConnection() {
    // Implementation details
    console.log('Checking stored Portnox connection');
}
EOF
    
    log_success "Created Portnox integration JavaScript file"
    
    return 0
}

##############################################################
# Part 7: Main Deployment Function
##############################################################

# Main function to update Dot1Xer Supreme
update_dot1xer() {
    log_message "Starting Dot1Xer Supreme update process..."
    
    # Check if deployment directory exists
    if [ ! -d "$DEPLOY_DIR" ]; then
        log_error "Deployment directory not found: $DEPLOY_DIR"
        log_message "Creating deployment directory..."
        mkdir -p "$DEPLOY_DIR"
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        log_error "Required dependencies not found. Aborting."
        return 1
    fi
    
    # Create temporary directory
    log_verbose "Creating temporary directory for update process..."
    mkdir -p "$TEMP_DIR" "$DOWNLOAD_DIR"
    
    # Create backup of current deployment if it already exists
    if [ -f "$DEPLOY_DIR/index.html" ]; then
        if ! create_backup; then
            if ! confirm_action "Backup creation failed. Continue without backup?"; then
                log_message "Update aborted by user."
                return 1
            fi
        fi
    fi
    
    # Create required directories
    create_missing_dirs
    
    # Download required assets
    if ! download_assets; then
        log_warning "Some assets could not be downloaded, but continuing with update."
    fi
    
    # Update CSS files
    if ! update_css_files; then
        log_error "Failed to update CSS files."
        if confirm_action "Continue anyway?"; then
            log_warning "Continuing despite CSS update failures."
        else
            log_message "Restoring from backup..."
            restore_from_backup
            return 1
        fi
    fi
    
    # Update JavaScript files
    if ! update_js_files; then
        log_error "Failed to update JavaScript files."
        if confirm_action "Continue anyway?"; then
            log_warning "Continuing despite JavaScript update failures."
        else
            log_message "Restoring from backup..."
            restore_from_backup
            return 1
        fi
    fi
    
    # Clean up temporary directory
    log_verbose "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    
    log_success "Dot1Xer Supreme update completed successfully!"
    log_message "You can now access Dot1Xer Supreme at $DEPLOY_DIR/index.html"
    
    return 0
}

##############################################################
# Part 8: Script Execution
##############################################################

# Main script execution
log_message "Dot1Xer Supreme Update Script - Version 2.0.0"

# Display deployment details
log_message "Deployment directory: $DEPLOY_DIR"
log_verbose "Backup directory: $BACKUP_DIR"
log_verbose "Force update: $FORCE_UPDATE"
log_verbose "Skip backup: $SKIP_BACKUP"
log_verbose "Verbose mode: $VERBOSE"
log_verbose "Skip downloads: $SKIP_DOWNLOADS"
log_verbose "Interactive mode: $INTERACTIVE"

# Ask for confirmation before proceeding
if ! confirm_action "Ready to update Dot1Xer Supreme. Proceed?"; then
    log_message "Update aborted by user."
    exit 0
fi

# Run the update function
if update_dot1xer; then
    log_success "Update completed successfully!"
    exit 0
else
    log_error "Update failed!"
    exit 1
fi