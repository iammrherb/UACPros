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


##############################################################
# Part 0: Optional GitHub Repository Cloning
##############################################################

clone_repository() {
    local repo_url="$1"
    if [ -z "$repo_url" ]; then
        log_warning "No repository URL provided for cloning."
        return 1
    fi

    log_message "Cloning repository from $repo_url..."
    
    if git clone "$repo_url" "$DEPLOY_DIR"; then
        log_success "Repository cloned into $DEPLOY_DIR"
    else
        log_error "Failed to clone repository."
        exit 1
    fi
}

# Check for GIT_REPO env var or prompt if interactive
if [ -z "$GIT_REPO" ] && [ "$INTERACTIVE" = true ]; then
    read -p "Enter GitHub repository URL to clone (or leave blank to skip): " GIT_REPO
fi

if [ -n "$GIT_REPO" ]; then
    clone_repository "$GIT_REPO"
fi


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

/*=============================================
  7. Platform Selection
=============================================*/
.platform-toggle {
    display: flex;
    margin-bottom: 1.5rem;
    background-color: var(--light-gray);
    border-radius: var(--border-radius);
    overflow: hidden;
}

.platform-toggle-btn {
    flex: 1;
    padding: 0.75rem;
    border: none;
    background-color: transparent;
    cursor: pointer;
    transition: background-color 0.3s;
    font-weight: 500;
}

.platform-toggle-btn.active {
    background-color: var(--primary-color);
    color: white;
}

.platform-toggle-btn:hover:not(.active) {
    background-color: var(--medium-gray);
}

/*=============================================
  8. Vendor Grid
=============================================*/
.vendor-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 1rem;
}

.vendor-card {
    border: 1px solid var(--medium-gray);
    border-radius: var(--border-radius);
    overflow: hidden;
    transition: var(--transition);
    background-color: white;
}

.vendor-card:hover {
    transform: translateY(-3px);
    box-shadow: var(--box-shadow);
}

.vendor-card.selected {
    border: 2px solid var(--primary-color);
    box-shadow: 0 0 0 2px rgba(106, 27, 154, 0.2);
}

.vendor-card-header {
    background-color: var(--primary-color);
    color: white;
    padding: 0.75rem;
    text-align: center;
    font-weight: 500;
}

.vendor-card-body {
    padding: 1rem;
    text-align: center;
}

.vendor-logo {
    max-width: 100%;
    height: 50px;
    object-fit: contain;
    margin-bottom: 0.5rem;
}

.vendor-name {
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.vendor-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
    margin-bottom: 1rem;
    min-height: 40px;
}

/*=============================================
  9. AI Integration Cards
=============================================*/
.ai-provider-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-top: 1.5rem;
}

.ai-provider-card {
    background-color: white;
    border-radius: var(--border-radius);
    border: 1px solid var(--medium-gray);
    overflow: hidden;
    transition: var(--transition);
}

.ai-provider-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.ai-provider-header {
    background-color: var(--primary-color);
    color: white;
    padding: 1rem;
    font-weight: bold;
}

.ai-provider-body {
    padding: 1.5rem;
}

.ai-provider-logo {
    max-width: 100%;
    height: 40px;
    object-fit: contain;
    margin-bottom: 1rem;
}

.ai-provider-name {
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.ai-provider-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
    margin-bottom: 1.5rem;
}

.ai-provider-footer {
    background-color: var(--light-gray);
    padding: 1rem;
    display: flex;
    justify-content: flex-end;
}

/* Status badges */
.status-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.75rem;
    font-weight: 600;
}

.status-active {
    background-color: #d1e7dd;
    color: #0f5132;
}

.status-inactive {
    background-color: #f8d7da;
    color: #842029;
}

/*=============================================
  10. Configuration Output
=============================================*/
.config-output {
    background-color: #1e1e1e;
    color: #d4d4d4;
    padding: 1.5rem;
    border-radius: var(--border-radius);
    margin-top: 1.5rem;
    overflow-x: auto;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    line-height: 1.5;
    max-height: 500px;
    overflow-y: auto;
}

.config-header {
    background-color: var(--primary-dark);
    color: white;
    padding: 0.75rem 1rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-radius: var(--border-radius) var(--border-radius) 0 0;
}

.config-actions {
    display: flex;
    gap: 0.5rem;
}

.copy-btn {
    background-color: var(--primary-color);
    color: white;
    border: none;
    border-radius: var(--border-radius);
    padding: 0.25rem 0.5rem;
    cursor: pointer;
    font-size: 0.875rem;
    transition: var(--transition);
}

.copy-btn:hover {
    background-color: var(--primary-dark);
}

/* Syntax highlighting */
.token.comment {
    color: #6A9955;
}

.token.string {
    color: #CE9178;
}

.token.number {
    color: #B5CEA8;
}

.token.keyword {
    color: #569CD6;
}

.token.function {
    color: #DCDCAA;
}

/*=============================================
  11. Tooltips and Modals
=============================================*/
/* Tooltips */
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
    width: 18px;
    height: 18px;
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

/* Modal base styles */
.modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: rgba(0, 0, 0, 0.5);
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.3s, visibility 0.3s;
    z-index: 1000;
}

.modal.active {
    opacity: 1;
    visibility: visible;
}

.modal-content {
    background-color: white;
    border-radius: var(--border-radius);
    max-width: 600px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
    transform: translateY(20px);
    transition: transform 0.3s;
}

.modal.active .modal-content {
    transform: translateY(0);
}

.modal-header {
    background-color: var(--primary-color);
    color: white;
    padding: 1rem;
    position: relative;
}

.modal-title {
    margin: 0;
    font-size: 1.25rem;
}

.modal-close {
    position: absolute;
    top: 10px;
    right: 10px;
    background: transparent;
    color: white;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    line-height: 1;
}

.modal-body {
    padding: 1.5rem;
}

.modal-footer {
    padding: 1rem;
    background-color: var(--light-gray);
    display: flex;
    justify-content: flex-end;
    gap: 0.75rem;
}

/*=============================================
  12. Info and Alert Boxes
=============================================*/
.info-box {
    background-color: #e3f2fd;
    border-left: 4px solid #2196f3;
    padding: 1rem;
    margin: 1rem 0;
    border-radius: 0 var(--border-radius) var(--border-radius) 0;
}

.info-box h4 {
    margin-top: 0;
    color: #0d47a1;
}

.info-box p {
    margin-bottom: 0;
}

.alert {
    padding: 1rem;
    margin-bottom: 1rem;
    border-radius: var(--border-radius);
}

.alert-success {
    background-color: #d1e7dd;
    color: #0f5132;
    border: 1px solid #badbcc;
}

.alert-warning {
    background-color: #fff3cd;
    color: #664d03;
    border: 1px solid #ffecb5;
}

.alert-danger {
    background-color: #f8d7da;
    color: #842029;
    border: 1px solid #f5c2c7;
}

.alert-info {
    background-color: #cff4fc;
    color: #055160;
    border: 1px solid #b6effb;
}

/*=============================================
  13. Footer
=============================================*/
.footer {
    background-color: var(--primary-dark);
    color: white;
    padding: 1.5rem 0;
    text-align: center;
    margin-top: 3rem;
}

.footer a {
    color: #bb86fc;
    text-decoration: none;
}

.footer a:hover {
    color: white;
    text-decoration: underline;
}

/*=============================================
  14. Responsive Styles
=============================================*/
@media (max-width: 992px) {
    .container {
        max-width: 960px;
    }
    
    .card-container {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .ai-provider-container {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 768px) {
    .container {
        max-width: 720px;
    }
    
    .card-container {
        grid-template-columns: 1fr;
    }
    
    .ai-provider-container {
        grid-template-columns: 1fr;
    }
    
    .vendor-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .nav-tabs {
        flex-wrap: wrap;
    }
    
    .nav-tabs a {
        padding: 0.75rem 1rem;
    }
}

@media (max-width: 576px) {
    .container {
        max-width: 100%;
        padding: 0 10px;
    }
    
    .platform-toggle {
        flex-direction: column;
    }
    
    .form-group {
        margin-bottom: 1rem;
    }
    
    .section-content {
        padding: 1rem;
    }
    
    .vendor-grid {
        grid-template-columns: 1fr;
    }
    
    .form-actions {
        flex-direction: column;
    }
    
    .form-actions .btn {
        width: 100%;
        margin-bottom: 0.5rem;
    }
    
    .header h1 {
        font-size: 2rem;
    }
}
EOF
    
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

/*=============================================
  3. Help Modal
=============================================*/
.help-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: rgba(0, 0, 0, 0.5);
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.3s, visibility 0.3s;
    z-index: 1000;
    backdrop-filter: blur(2px);
}

.help-modal.active {
    opacity: 1;
    visibility: visible;
}

.help-modal-content {
    background-color: white;
    border-radius: var(--border-radius);
    max-width: 600px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
    transform: translateY(20px);
    transition: transform 0.3s;
}

.help-modal.active .help-modal-content {
    transform: translateY(0);
}

.help-modal-header {
    background-color: var(--primary-color);
    color: white;
    padding: 1rem;
    position: relative;
    display: flex;
    align-items: center;
}

.help-modal-title {
    margin: 0;
    font-size: 1.25rem;
    flex: 1;
}

.help-modal-close {
    background: transparent;
    color: white;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    line-height: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 30px;
    height: 30px;
}

.help-modal-body {
    padding: 1.5rem;
}

.help-modal-body ul {
    margin-left: 1.5rem;
    margin-bottom: 1rem;
}

.help-modal-body li {
    margin-bottom: 0.5rem;
}

.help-modal-body h4 {
    margin-top: 1.5rem;
    margin-bottom: 0.75rem;
    color: var(--primary-color);
}

.help-modal-body code {
    background-color: var(--light-gray);
    padding: 0.2rem 0.4rem;
    border-radius: 0.25rem;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 0.9em;
}

.help-modal-body pre {
    background-color: var(--dark-gray);
    color: white;
    padding: 1rem;
    border-radius: var(--border-radius);
    overflow-x: auto;
    margin-bottom: 1rem;
}

.help-modal-body table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1rem;
}

.help-modal-body th,
.help-modal-body td {
    padding: 0.5rem;
    border: 1px solid var(--medium-gray);
    text-align: left;
}

.help-modal-body th {
    background-color: var(--light-gray);
    font-weight: 600;
}

.help-note {
    background-color: #e3f2fd;
    border-left: 4px solid #2196f3;
    padding: 1rem;
    margin: 1rem 0;
    border-radius: 0 var(--border-radius) var(--border-radius) 0;
}

.help-warning {
    background-color: #fff3cd;
    border-left: 4px solid #ffc107;
    padding: 1rem;
    margin: 1rem 0;
    border-radius: 0 var(--border-radius) var(--border-radius) 0;
}

.help-recommendation {
    background-color: #d1e7dd;
    border-left: 4px solid #198754;
    padding: 1rem;
    margin: 1rem 0;
    border-radius: 0 var(--border-radius) var(--border-radius) 0;
}

/*=============================================
  4. Vendor-Specific Help
=============================================*/
.vendor-help-section {
    margin-bottom: 1.5rem;
}

.vendor-help-title {
    font-weight: 600;
    color: var(--primary-color);
    margin-bottom: 0.5rem;
}

.vendor-help-image {
    max-width: 100%;
    border-radius: var(--border-radius);
    margin: 1rem 0;
    box-shadow: var(--box-shadow);
}

.vendor-help-tip {
    display: flex;
    margin-bottom: 1rem;
}

.vendor-help-tip-icon {
    flex-shrink: 0;
    font-size: 1.25rem;
    color: var(--primary-color);
    margin-right: 0.75rem;
}

.vendor-help-tip-content {
    flex: 1;
}

/*=============================================
  5. Responsive Styles
=============================================*/
@media (max-width: 768px) {
    .help-modal-content {
        width: 95%;
    }
}

@media (max-width: 576px) {
    .help-modal-header {
        padding: 0.75rem;
    }
    
    .help-modal-body {
        padding: 1rem;
    }
}
EOF
    
    # Create environment_discovery.css file
    ENV_DISCOVERY_CSS="$DEPLOY_DIR/css/environment_discovery.css"
    
    # Create the environment_discovery.css file
    cat > "$ENV_DISCOVERY_CSS" << 'EOF'
/* 
 * Dot1Xer Supreme - Environment Discovery Stylesheet
 * Version: 2.0.0
 *
 * This file contains styles specific to the environment discovery functionality.
 */

/*=============================================
  1. Environment Discovery Components
=============================================*/
.discovery-tabs {
    display: flex;
    overflow-x: auto;
    margin-bottom: 1.5rem;
    background-color: var(--light-gray);
    border-radius: var(--border-radius);
}

.discovery-tab-btn {
    padding: 0.75rem 1.25rem;
    background-color: transparent;
    border: none;
    cursor: pointer;
    white-space: nowrap;
    transition: var(--transition);
    font-weight: 500;
}

.discovery-tab-btn.active {
    background-color: var(--primary-color);
    color: white;
}

.discovery-tab-btn:hover:not(.active) {
    background-color: var(--medium-gray);
}

.discovery-tab-content {
    display: none;
}

.discovery-tab-content.active {
    display: block;
}

/*=============================================
  2. Network Scan Styles
=============================================*/
.scan-options {
    background-color: var(--light-gray);
    padding: 1.5rem;
    border-radius: var(--border-radius);
    margin-bottom: 1.5rem;
}

.scan-type-options {
    display: flex;
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.scan-option {
    flex: 1;
    background-color: white;
    padding: 1rem;
    border-radius: var(--border-radius);
    border: 1px solid var(--medium-gray);
    cursor: pointer;
    transition: var(--transition);
}

.scan-option:hover {
    box-shadow: var(--box-shadow);
}

.scan-option.selected {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 2px rgba(106, 27, 154, 0.2);
}

.scan-option-header {
    font-weight: 600;
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
}

.scan-option-header input[type="radio"] {
    margin-right: 0.5rem;
}

.scan-option-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
}

.scan-progress {
    background-color: white;
    padding: 1.5rem;
    border-radius: var(--border-radius);
    box-shadow: var(--box-shadow);
    margin-bottom: 1.5rem;
    display: none;
}

.scan-progress.active {
    display: block;
}

.progress-bar-container {
    height: 20px;
    background-color: var(--light-gray);
    border-radius: 10px;
    overflow: hidden;
    margin: 1rem 0;
}

.progress-bar {
    height: 100%;
    background-color: var(--primary-color);
    width: 0%;
    transition: width 0.5s ease;
}

.scan-progress-text {
    text-align: center;
    font-weight: 500;
}

.scan-results {
    display: none;
}

.scan-results.active {
    display: block;
}

.results-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.results-title {
    font-size: 1.25rem;
    font-weight: 600;
}

.results-actions {
    display: flex;
    gap: 0.5rem;
}

.scan-results-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1.5rem;
}

.scan-results-table th,
.scan-results-table td {
    padding: 0.75rem;
    border-bottom: 1px solid var(--medium-gray);
    text-align: left;
}

.scan-results-table th {
    background-color: var(--light-gray);
    font-weight: 600;
}

.scan-results-table tbody tr:hover {
    background-color: var(--light-gray);
}

.device-status {
    display: inline-block;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    margin-right: 0.5rem;
}

.status-online {
    background-color: var(--success-color);
}

.status-offline {
    background-color: var(--danger-color);
}

.status-unknown {
    background-color: var(--warning-color);
}

/*=============================================
  3. Device Details Styles
=============================================*/
.device-details {
    background-color: white;
    border-radius: var(--border-radius);
    box-shadow: var(--box-shadow);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
    display: none;
}

.device-details.active {
    display: block;
}

.device-details-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--medium-gray);
}

.device-details-name {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0;
}

.device-details-close {
    background-color: var(--light-gray);
    border: none;
    border-radius: var(--border-radius);
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: var(--transition);
}

.device-details-close:hover {
    background-color: var(--medium-gray);
}

.device-details-body {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
}

.device-info-group {
    margin-bottom: 1.5rem;
}

.device-info-title {
    font-weight: 600;
    margin-bottom: 0.5rem;
    color: var(--primary-color);
}

.device-info-item {
    display: flex;
    margin-bottom: 0.5rem;
}

.device-info-label {
    font-weight: 500;
    min-width: 120px;
    color: var(--dark-gray);
}

.device-info-value {
    flex: 1;
}

.device-actions {
    margin-top: 1.5rem;
    padding-top: 1.5rem;
    border-top: 1px solid var(--medium-gray);
    display: flex;
    justify-content: flex-end;
    gap: 0.75rem;
}

/*=============================================
  4. Network Profile Styles
=============================================*/
.environment-profile {
    background-color: white;
    border-radius: var(--border-radius);
    box-shadow: var(--box-shadow);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
}

.profile-section {
    margin-bottom: 1.5rem;
}

.profile-section-title {
    font-weight: 600;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--medium-gray);
}

.profile-subsection {
    margin-bottom: 1rem;
}

.profile-subsection-title {
    font-weight: 500;
    margin-bottom: 0.5rem;
    color: var(--primary-color);
}

.profile-options {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
    margin-bottom: 1rem;
}

.profile-option {
    background-color: var(--light-gray);
    padding: 1rem;
    border-radius: var(--border-radius);
    cursor: pointer;
    transition: var(--transition);
}

.profile-option:hover {
    background-color: var(--medium-gray);
}

.profile-option.selected {
    background-color: rgba(106, 27, 154, 0.1);
    border: 1px solid var(--primary-color);
}

.profile-option-title {
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.profile-option-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
}

/*=============================================
  5. Analysis Dashboard Styles
=============================================*/
.analysis-dashboard {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.dashboard-card {
    background-color: white;
    border-radius: var(--border-radius);
    box-shadow: var(--box-shadow);
    padding: 1.5rem;
}

.dashboard-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--medium-gray);
}

.dashboard-card-title {
    font-weight: 600;
    margin: 0;
}

.dashboard-card-body {
    flex: 1;
}

.metric-group {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
}

.metric {
    flex: 1;
    background-color: var(--light-gray);
    padding: 1rem;
    border-radius: var(--border-radius);
    text-align: center;
}

.metric-value {
    font-size: 2rem;
    font-weight: 700;
    margin-bottom: 0.5rem;
}

.metric-label {
    font-size: 0.875rem;
    color: var(--dark-gray);
}

.chart-container {
    height: 250px;
    margin-top: 1rem;
}

.recommendation-list {
    margin-top: 1rem;
}

.recommendation-item {
    display: flex;
    margin-bottom: 1rem;
    background-color: var(--light-gray);
    padding: 1rem;
    border-radius: var(--border-radius);
}

.recommendation-icon {
    margin-right: 1rem;
    color: var(--primary-color);
    font-size: 1.5rem;
    flex-shrink: 0;
}

.recommendation-content {
    flex: 1;
}

.recommendation-title {
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.recommendation-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
}

.priority-high {
    border-left: 4px solid var(--danger-color);
}

.priority-medium {
    border-left: 4px solid var(--warning-color);
}

.priority-low {
    border-left: 4px solid var(--success-color);
}

/*=============================================
  6. Responsive Styles
=============================================*/
@media (max-width: 992px) {
    .analysis-dashboard {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 768px) {
    .scan-type-options {
        flex-direction: column;
    }
    
    .device-details-body {
        grid-template-columns: 1fr;
    }
    
    .profile-options {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 576px) {
    .discovery-tabs {
        flex-wrap: wrap;
    }
    
    .discovery-tab-btn {
        flex: 1;
        min-width: 120px;
        text-align: center;
    }
    
    .scan-results-table {
        display: block;
        overflow-x: auto;
    }
}
EOF
    
    # Create additional CSS files for AI integration
    AI_INTEGRATION_CSS="$DEPLOY_DIR/css/ai_integration.css"
    
    # Create the ai_integration.css file
    cat > "$AI_INTEGRATION_CSS" << 'EOF'
/* 
 * Dot1Xer Supreme - AI Integration Stylesheet
 * Version: 2.0.0
 *
 * This file contains styles specific to the AI integration functionality.
 */

/*=============================================
  1. AI Integration Base Styles
=============================================*/
.ai-container {
    background-color: white;
    border-radius: var(--border-radius);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
    box-shadow: var(--box-shadow);
}

.ai-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid var(--medium-gray);
}

.ai-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: var(--primary-color);
    margin: 0;
}

.ai-description {
    margin-bottom: 1.5rem;
    color: var(--dark-gray);
}

/*=============================================
  2. AI Provider Cards
=============================================*/
.ai-provider-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 1.5rem;
    margin-bottom: 1.5rem;
}

.ai-provider-card {
    border: 1px solid var(--medium-gray);
    border-radius: var(--border-radius);
    padding: 1.5rem;
    transition: var(--transition);
    position: relative;
    overflow: hidden;
}

.ai-provider-card:hover {
    transform: translateY(-5px);
    box-shadow: var(--box-shadow);
}

.ai-provider-card.active {
    border-color: var(--primary-color);
    box-shadow: 0 0 0 2px rgba(106, 27, 154, 0.1);
}

.ai-provider-logo {
    height: 40px;
    width: auto;
    object-fit: contain;
    margin-bottom: 1rem;
}

.ai-provider-name {
    font-weight: 600;
    font-size: 1.2rem;
    margin-bottom: 0.5rem;
}

.ai-provider-models {
    margin-bottom: 1rem;
}

.ai-provider-model {
    font-size: 0.875rem;
    padding: 0.25rem 0.5rem;
    margin-right: 0.5rem;
    margin-bottom: 0.5rem;
    display: inline-block;
    background-color: var(--light-gray);
    border-radius: 4px;
}

.ai-provider-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--light-gray);
}

.ai-status {
    font-size: 0.875rem;
    display: flex;
    align-items: center;
}

.ai-status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    margin-right: 0.5rem;
}

.ai-status-connected .ai-status-dot {
    background-color: var(--success-color);
}

.ai-status-disconnected .ai-status-dot {
    background-color: var(--danger-color);
}

.ai-provider-action {
    font-size: 0.875rem;
}

/*=============================================
  3. AI Configuration Form
=============================================*/
.ai-config-form {
    background-color: var(--light-gray);
    padding: 1.5rem;
    border-radius: var(--border-radius);
    margin-bottom: 1.5rem;
}

.ai-config-form h3 {
    margin-top: 0;
    margin-bottom: 1rem;
}

.ai-form-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
}

.ai-form-header h3 {
    margin: 0;
}

.ai-form-section {
    margin-bottom: 1.5rem;
}

.ai-form-section-title {
    font-weight: 600;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--medium-gray);
}

.ai-settings-toggle {
    display: flex;
    margin-bottom: 1rem;
    background-color: white;
    border-radius: var(--border-radius);
    overflow: hidden;
}

.ai-settings-btn {
    flex: 1;
    padding: 0.75rem;
    border: none;
    background-color: transparent;
    cursor: pointer;
    transition: var(--transition);
}

.ai-settings-btn.active {
    background-color: var(--primary-color);
    color: white;
}

.ai-model-select {
    margin-bottom: 1rem;
}

.ai-model-option {
    display: flex;
    align-items: center;
    padding: 0.75rem;
    margin-bottom: 0.5rem;
    background-color: white;
    border-radius: var(--border-radius);
    cursor: pointer;
    transition: var(--transition);
}

.ai-model-option:hover {
    background-color: var(--light-gray);
}

.ai-model-option.selected {
    background-color: rgba(106, 27, 154, 0.1);
    border: 1px solid var(--primary-color);
}

.ai-model-option input[type="radio"] {
    margin-right: 0.75rem;
}

.ai-model-info {
    display: flex;
    flex-direction: column;
}

.ai-model-name {
    font-weight: 600;
    margin-bottom: 0.25rem;
}

.ai-model-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
}

/*=============================================
  4. AI Assistant Interface
=============================================*/
.ai-assistant {
    background-color: white;
    border-radius: var(--border-radius);
    overflow: hidden;
    box-shadow: var(--box-shadow);
    margin-bottom: 1.5rem;
}

.ai-assistant-header {
    background-color: var(--primary-color);
    color: white;
    padding: 1rem 1.5rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.ai-assistant-title {
    font-size: 1.2rem;
    font-weight: 600;
    margin: 0;
    display: flex;
    align-items: center;
}

.ai-assistant-icon {
    margin-right: 0.75rem;
    font-size: 1.5rem;
}

.ai-assistant-controls {
    display: flex;
    gap: 0.75rem;
}

.ai-assistant-control {
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    background-color: rgba(255, 255, 255, 0.2);
    color: white;
    cursor: pointer;
    transition: var(--transition);
}

.ai-assistant-control:hover {
    background-color: rgba(255, 255, 255, 0.3);
}

.ai-chat-container {
    max-height: 400px;
    overflow-y: auto;
    padding: 1.5rem;
}

.ai-message {
    margin-bottom: 1.5rem;
    display: flex;
    align-items: flex-start;
}

.ai-message:last-child {
    margin-bottom: 0;
}

.ai-message-user {
    justify-content: flex-end;
}

.ai-message-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    margin-right: 1rem;
    background-color: var(--light-gray);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
}

.ai-message-user .ai-message-avatar {
    order: 1;
    margin-right: 0;
    margin-left: 1rem;
    background-color: var(--primary-light);
    color: white;
}

.ai-message-content {
    max-width: 70%;
    padding: 1rem;
    border-radius: var(--border-radius);
    background-color: var(--light-gray);
    position: relative;
}

.ai-message-user .ai-message-content {
    background-color: var(--primary-color);
    color: white;
}

.ai-message-text {
    margin: 0;
    line-height: 1.5;
}

.ai-message-time {
    font-size: 0.75rem;
    color: var(--dark-gray);
    margin-top: 0.5rem;
    text-align: right;
}

.ai-message-user .ai-message-time {
    color: rgba(255, 255, 255, 0.7);
}

.ai-input-container {
    display: flex;
    padding: 1rem 1.5rem;
    border-top: 1px solid var(--light-gray);
}

.ai-input {
    flex: 1;
    padding: 0.75rem 1rem;
    border: 1px solid var(--medium-gray);
    border-radius: var(--border-radius) 0 0 var(--border-radius);
    font-size: 1rem;
    resize: none;
    min-height: 24px;
    max-height: 120px;
    overflow-y: auto;
}

.ai-input:focus {
    outline: none;
    border-color: var(--primary-color);
}

.ai-send-btn {
    padding: 0.75rem 1.5rem;
    background-color: var(--primary-color);
    color: white;
    border: none;
    border-radius: 0 var(--border-radius) var(--border-radius) 0;
    cursor: pointer;
    transition: var(--transition);
}

.ai-send-btn:hover {
    background-color: var(--primary-dark);
}

.ai-send-btn:disabled {
    background-color: var(--medium-gray);
    cursor: not-allowed;
}

/*=============================================
  5. AI Suggestion UI
=============================================*/
.ai-suggestions {
    margin-top: 1.5rem;
}

.ai-suggestions-title {
    font-weight: 600;
    margin-bottom: 1rem;
}

.ai-suggestions-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1rem;
}

.ai-suggestion-card {
    background-color: white;
    border-radius: var(--border-radius);
    padding: 1.25rem;
    box-shadow: var(--box-shadow);
    transition: var(--transition);
    cursor: pointer;
}

.ai-suggestion-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.ai-suggestion-header {
    display: flex;
    align-items: center;
    margin-bottom: 0.75rem;
}

.ai-suggestion-icon {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background-color: var(--primary-light);
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: 0.75rem;
    font-size: 12px;
}

.ai-suggestion-title {
    font-weight: 600;
    margin: 0;
}

.ai-suggestion-description {
    font-size: 0.875rem;
    color: var(--dark-gray);
    margin-bottom: 0.75rem;
}

.ai-suggestion-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
}

.ai-suggestion-tag {
    font-size: 0.75rem;
    padding: 0.2rem 0.5rem;
    background-color: var(--light-gray);
    border-radius: 999px;
    color: var(--dark-gray);
}

/*=============================================
  6. Responsive Styles
=============================================*/
@media (max-width: 992px) {
    .ai-provider-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .ai-suggestions-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

@media (max-width: 768px) {
    .ai-provider-grid {
        grid-template-columns: 1fr;
    }
    
    .ai-suggestions-grid {
        grid-template-columns: 1fr;
    }
    
    .ai-message-content {
        max-width: 80%;
    }
}

@media (max-width: 576px) {
    .ai-settings-toggle {
        flex-direction: column;
    }
    
    .ai-message-content {
        max-width: 90%;
    }
    
    .ai-input-container {
        flex-direction: column;
        gap: 0.5rem;
    }
    
    .ai-input {
        border-radius: var(--border-radius);
    }
    
    .ai-send-btn {
        border-radius: var(--border-radius);
    }
}
EOF

    # Create portnox-integration.css file
    PORTNOX_CSS="$DEPLOY_DIR/css/portnox_integration.css"
    
    # Create the portnox-integration.css file
    cat > "$PORTNOX_CSS" << 'EOF'
/* 
 * Dot1Xer Supreme - Portnox Integration Stylesheet
 * Version: 2.0.0
 *
 * This file contains styles specific to the Portnox Cloud integration.
 */

/*=============================================
  1. Portnox Integration Base Styles
=============================================*/
.portnox-container {
    background-color: white;
    border-radius: var(--border-radius);
    padding: 1.5rem;
    margin-bottom: 1.5rem;
    box-shadow: var(--box-shadow);
}

.portnox-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    padding-bottom: 0.75rem;
    border-bottom: 1px solid var(--medium-gray);
}

.portnox-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: var(--primary-color);
    margin: 0;
    display: flex;
    align-items: center;
}

.portnox-logo {
    height: 30px;
    margin-right: 1rem;
}

.portnox-description {
    margin-bottom: 1.5rem;
    color: var(--dark-gray);
}

/*=============================================
  2. Portnox Connection Status
=============================================*/
.portnox-status {
    display: flex;
    align-items: center;
    padding: 1rem;
    background-color: var(--light-gray);
    border-radius: var(--border-radius);
    margin-bottom: 1.5rem;
}

.portnox-status-icon {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    margin-right: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    color: white;
}

.portnox-status-connected .portnox-status-icon {
    background-color: var(--success-color);
}

.portnox-status-disconnected .portnox-status-icon {
    background-color: var(--danger-color);
}

.portnox-status-text {
    flex: 1;
}

.portnox-status-title {
    font-weight: 600;
    margin-bottom: 0.25rem;
}

.portnox-status-message {
    font-size: 0.875rem;
    color: var(--dark-gray);
}

.portnox-status-action {
    margin-left: 1rem;
}

/*=============================================
  3. Portnox Connection Form
=============================================*/
.portnox-form {
    background-color: var(--light-gray);
    padding: 1.5rem;
    border-radius: var(--border-radius);
    margin-bottom: 1.5rem;
}

.portnox-form-title {
    margin-top: 0;
    margin-bottom: 1.5rem;
    font-size: 1.25rem;
}

.portnox-form-section {
    margin-bottom: 1.5rem;
}

.portnox-form-section-title {
    font-weight: 600;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--medium-gray);
}

/*=============================================
  4. Portnox Device Management
=============================================*/
.portnox-devices {
    margin-top: 2rem;
}

.portnox-devices-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.portnox-devices-title {
    font-size: 1.25rem;
    font-weight: 600;
    margin: 0;
}

.portnox-devices-actions {
    display: flex;
    gap: 0.75rem;
}

.portnox-devices-table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 1.5rem;
}

.portnox-devices-table th,
.portnox-devices-table td {
    padding: 0.75rem;
    border-bottom: 1px solid var(--medium-gray);
    text-align: left;
}

.portnox-devices-table th {
    font-weight: 600;
    background-color: var(--light-gray);
}

.portnox-devices-table tbody tr:hover {
    background-color: var(--light-gray);
}

.portnox-device-status {
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    margin-right: 0.5rem;
}

.portnox-device-active .portnox-device-status {
    background-color: var(--success-color);
}

.portnox-device-inactive .portnox-device-status {
    background-color: var(--danger-color);
}

.portnox-device-pending .portnox-device-status {
    background-color: var(--warning-color);
}

.portnox-device-actions {
    display: flex;
    gap: 0.5rem;
}

.portnox-device-action {
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
    border-radius: var(--border-radius);
    cursor: pointer;
    transition: var(--transition);
}

.portnox-action-view {
    background-color: var(--light-gray);
    color: var(--text-dark);
}

.portnox-action-view:hover {
    background-color: var(--medium-gray);
}

.portnox-action-edit {
    background-color: var(--primary-light);
    color: white;
}

.portnox-action-edit:hover {
    background-color: var(--primary-color);
}

.portnox-action-delete {
    background-color: var(--danger-color);
    color: white;
}

.portnox-action-delete:hover {
    background-color: #c0392b;
}

/*=============================================
  5. Portnox Policy Management
=============================================*/
.portnox-policies {
    margin-top: 2rem;
}

.portnox-policies-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.portnox-policies-title {
    font-size: 1.25rem;
    font-weight: 600;
    margin: 0;
}

.portnox-policies-actions {
    display: flex;
    gap: 0.75rem;
}

.portnox-policy-card {
    background-color: white;
    border-radius: var(--border-radius);
    border: 1px solid var(--medium-gray);
    margin-bottom: 1rem;
    overflow: hidden;
    transition: var(--transition);
}

.portnox-policy-card:hover {
    box-shadow: var(--box-shadow);
}

.portnox-policy-header {
    padding: 1rem;
    background-color: var(--light-gray);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.portnox-policy-name {
    font-weight: 600;
    margin: 0;
}

.portnox-policy-status {
    font-size: 0.75rem;
    padding: 0.25rem 0.5rem;
    border-radius: 999px;
}

.portnox-policy-active {
    background-color: #d1e7dd;
    color: #0f5132;
}

.portnox-policy-inactive {
    background-color: #f8d7da;
    color: #842029;
}

.portnox-policy-draft {
    background-color: #fff3cd;
    color: #664d03;
}

.portnox-policy-body {
    padding: 1rem;
}

.portnox-policy-description {
    color: var(--dark-gray);
    margin-bottom: 1rem;
}

.portnox-policy-details {
    font-size: 0.875rem;
}

.portnox-policy-detail {
    display: flex;
    margin-bottom: 0.5rem;
}

.portnox-policy-label {
    font-weight: 500;
    min-width: 140px;
    color: var(--dark-gray);
}

.portnox-policy-value {
    flex: 1;
}

.portnox-policy-footer {
    padding: 1rem;
    background-color: var(--light-gray);
    display: flex;
    justify-content: flex-end;
    gap: 0.75rem;
}

/*=============================================
  6. Responsive Styles
=============================================*/
@media (max-width: 992px) {
    .portnox-devices-table {
        display: block;
        overflow-x: auto;
    }
}

@media (max-width: 768px) {
    .portnox-devices-actions,
    .portnox-policies-actions {
        flex-direction: column;
        gap: 0.5rem;
    }
    
    .portnox-policy-header {
        flex-direction: column;
        align-items: flex-start;
    }
    
    .portnox-policy-status {
        margin-top: 0.5rem;
    }
}

@media (max-width: 576px) {
    .portnox-form {
        padding: 1rem;
    }
    
    .portnox-device-actions {
        flex-direction: column;
        gap: 0.5rem;
    }
}
# Function to update HTML files
update_html_files() {
    log_message "Updating HTML files..."
    
    # Main index.html file
    INDEX_HTML="$DEPLOY_DIR/index.html"
    
    # Backup the original file if it exists
    if [ -f "$INDEX_HTML" ]; then
        cp "$INDEX_HTML" "$TEMP_DIR/index.html.bak"
        log_verbose "Backed up original index.html to $TEMP_DIR/index.html.bak"
    fi
    
    # Create the index.html file with enhanced UI
    cat > "$INDEX_HTML" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dot1Xer Supreme - Multi-Vendor 802.1X Configuration Tool</title>
    
    <!-- Stylesheets -->
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="css/help_tips.css">
    <link rel="stylesheet" href="css/environment_discovery.css">
    <link rel="stylesheet" href="css/ai_integration.css">
    <link rel="stylesheet" href="css/portnox_integration.css">
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>
    <!-- Header -->
    <header class="header">
        <h1>Dot1Xer Supreme</h1>
        <p class="header-subtitle">Multi-Vendor 802.1X Configuration Tool</p>
    </header>
    
    <!-- Main Navigation -->
    <nav class="main-nav">
        <div class="nav-container">
            <ul class="nav-tabs">
                <li><a href="#configurator" class="active" data-tab="configurator">Configurator</a></li>
                <li><a href="#discovery" data-tab="discovery">Network Discovery</a></li>
                <li><a href="#reference" data-tab="reference">Reference</a></li>
                <li><a href="#ai" data-tab="ai">AI</a></li>
                <li><a href="#portnox" data-tab="portnox">Portnox</a></li>
            </ul>
        </div>
    </nav>
    
    <!-- Main Content -->
    <main class="container">
        <!-- Configurator Tab -->
        <div id="configurator" class="tab-content active">
            <div class="section-header">
                <h2>802.1X Configuration</h2>
            </div>
            <div class="section-content">
                <!-- Platform Selection -->
                <div class="platform-toggle">
                    <button class="platform-toggle-btn active" data-platform="wired">Wired</button>
                    <button class="platform-toggle-btn" data-platform="wireless">Wireless</button>
                </div>
                
                <!-- Vendor Selection -->
                <h3>Select Vendor</h3>
                <div class="vendor-grid" id="wired-vendors">
                    <!-- Wired vendors will be populated here via JavaScript -->
                </div>
                
                <div class="vendor-grid" id="wireless-vendors" style="display: none;">
                    <!-- Wireless vendors will be populated here via JavaScript -->
                </div>
                
                <!-- Configuration Form -->
                <div id="config-form-container" style="display: none;">
                    <!-- Form will be dynamically generated based on vendor selection -->
                </div>
                
                <!-- Configuration Output -->
                <div id="config-output-container" style="display: none;">
                    <div class="config-header">
                        <h3>Generated Configuration</h3>
                        <div class="config-actions">
                            <button class="copy-btn" id="copy-config">
                                <i class="fas fa-copy"></i> Copy
                            </button>
                            <button class="copy-btn" id="save-config">
                                <i class="fas fa-save"></i> Save
                            </button>
                        </div>
                    </div>
                    <pre class="config-output" id="config-output"></pre>
                </div>
            </div>
        </div>
        
        <!-- Network Discovery Tab -->
        <div id="discovery" class="tab-content">
            <div class="section-header">
                <h2>Network Discovery & Analysis</h2>
            </div>
            <div class="section-content">
                <div class="discovery-tabs">
                    <button class="discovery-tab-btn active" data-tab="network-scan">Network Scan</button>
                    <button class="discovery-tab-btn" data-tab="environment">Environment</button>
                    <button class="discovery-tab-btn" data-tab="assessment">Assessment</button>
                    <button class="discovery-tab-btn" data-tab="import">Import</button>
                    <button class="discovery-tab-btn" data-tab="report">Report</button>
                </div>
                
                <!-- Network Scan Tab -->
                <div id="network-scan" class="discovery-tab-content active">
                    <div class="scan-options">
                        <h3>Scan Options</h3>
                        <div class="form-group">
                            <label for="ip-range">IP Range</label>
                            <input type="text" id="ip-range" class="form-control" placeholder="e.g., 192.168.1.0/24">
                            <span class="form-hint">Enter CIDR notation or IP range (e.g., 192.168.1.1-192.168.1.254)</span>
                        </div>
                        
                        <div class="scan-type-options">
                            <div class="scan-option">
                                <div class="scan-option-header">
                                    <input type="radio" name="scan-type" id="scan-type-quick" checked>
                                    <label for="scan-type-quick">Quick Scan</label>
                                </div>
                                <p class="scan-option-description">Basic ping sweep and SNMP discovery. Recommended for initial network assessment.</p>
                            </div>
                            
                            <div class="scan-option">
                                <div class="scan-option-header">
                                    <input type="radio" name="scan-type" id="scan-type-detailed">
                                    <label for="scan-type-detailed">Detailed Scan</label>
                                </div>
                                <p class="scan-option-description">Comprehensive device identification with port scanning and service detection.</p>
                            </div>
                            
                            <div class="scan-option">
                                <div class="scan-option-header">
                                    <input type="radio" name="scan-type" id="scan-type-dot1x">
                                    <label for="scan-type-dot1x">802.1X Readiness</label>
                                </div>
                                <p class="scan-option-description">Specialized scan to assess network readiness for 802.1X deployment.</p>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Advanced Options</label>
                            <div class="checkbox-label">
                                <input type="checkbox" id="snmp-discovery" checked>
                                <label for="snmp-discovery">Enable SNMP Discovery</label>
                            </div>
                            
                            <div class="form-group" id="snmp-options">
                                <label for="snmp-community">SNMP Community</label>
                                <input type="text" id="snmp-community" class="form-control" value="public">
                            </div>
                            
                            <div class="checkbox-label">
                                <input type="checkbox" id="dns-resolution">
                                <label for="dns-resolution">Perform DNS Resolution</label>
                            </div>
                            
                            <div class="checkbox-label">
                                <input type="checkbox" id="vendor-identification" checked>
                                <label for="vendor-identification">Identify Vendor Information</label>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn btn-primary" id="start-scan">Start Scan</button>
                            <button class="btn btn-light">Cancel</button>
                        </div>
                    </div>
                    
                    <div class="scan-progress">
                        <h3>Scan in Progress</h3>
                        <div class="progress-bar-container">
                            <div class="progress-bar" style="width: 0%"></div>
                        </div>
                        <p class="scan-progress-text">Initializing scan...</p>
                        <div class="form-actions">
                            <button class="btn btn-danger">Cancel Scan</button>
                        </div>
                    </div>
                    
                    <div class="scan-results">
                        <div class="results-header">
                            <h3 class="results-title">Scan Results</h3>
                            <div class="results-actions">
                                <button class="btn btn-primary btn-sm">Export</button>
                                <button class="btn btn-light btn-sm">Filter</button>
                            </div>
                        </div>
                        
                        <table class="scan-results-table">
                            <thead>
                                <tr>
                                    <th>Status</th>
                                    <th>IP Address</th>
                                    <th>Hostname</th>
                                    <th>Type</th>
                                    <th>Vendor</th>
                                    <th>Model</th>
                                    <th>802.1X Support</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="scan-results-body">
                                <!-- Results will be populated here via JavaScript -->
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Environment Tab -->
                <div id="environment" class="discovery-tab-content">
                    <div class="environment-profile">
                        <h3>Network Environment Profile</h3>
                        
                        <div class="profile-section">
                            <h4 class="profile-section-title">Network Type</h4>
                            <div class="profile-options">
                                <div class="profile-option">
                                    <h5 class="profile-option-title">Enterprise</h5>
                                    <p class="profile-option-description">Large corporate network with multiple VLANs and complex segmentation.</p>
                                </div>
                                
                                <div class="profile-option">
                                    <h5 class="profile-option-title">Campus</h5>
                                    <p class="profile-option-description">Educational institution with mixed user types and multiple buildings.</p>
                                </div>
                                
                                <div class="profile-option">
                                    <h5 class="profile-option-title">Small Business</h5>
                                    <p class="profile-option-description">Smaller network with limited segmentation and simpler structure.</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="profile-section">
                            <h4 class="profile-section-title">Access Requirements</h4>
                            <div class="form-group">
                                <div class="checkbox-label">
                                    <input type="checkbox" id="employee-access" checked>
                                    <label for="employee-access">Employee Access</label>
                                </div>
                                
                                <div class="checkbox-label">
                                    <input type="checkbox" id="guest-access" checked>
                                    <label for="guest-access">Guest Access</label>
                                </div>
                                
                                <div class="checkbox-label">
                                    <input type="checkbox" id="byod-access">
                                    <label for="byod-access">BYOD Support</label>
                                </div>
                                
                                <div class="checkbox-label">
                                    <input type="checkbox" id="iot-devices">
                                    <label for="iot-devices">IoT Devices</label>
                                </div>
                            </div>
                        </div>
                        
                        <div class="profile-section">
                            <h4 class="profile-section-title">Authentication Infrastructure</h4>
                            <div class="profile-options">
                                <div class="profile-option">
                                    <h5 class="profile-option-title">Active Directory</h5>
                                    <p class="profile-option-description">Microsoft AD with integrated RADIUS services.</p>
                                </div>
                                
                                <div class="profile-option">
                                    <h5 class="profile-option-title">Dedicated RADIUS</h5>
                                    <p class="profile-option-description">Standalone RADIUS server (e.g., FreeRADIUS).</p>
                                </div>
                                
                                <div class="profile-option">
                                    <h5 class="profile-option-title">Cloud Identity</h5>
                                    <p class="profile-option-description">Cloud-based identity provider with RADIUS proxy.</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn btn-primary">Save Profile</button>
                            <button class="btn btn-secondary">Generate Report</button>
                        </div>
                    </div>
                </div>
                
                <!-- Assessment Tab -->
                <div id="assessment" class="discovery-tab-content">
                    <div class="analysis-dashboard">
                        <div class="dashboard-card">
                            <div class="dashboard-card-header">
                                <h4 class="dashboard-card-title">Network Readiness</h4>
                            </div>
                            <div class="dashboard-card-body">
                                <div class="metric-group">
                                    <div class="metric">
                                        <div class="metric-value">76%</div>
                                        <div class="metric-label">Overall Readiness</div>
                                    </div>
                                    
                                    <div class="metric">
                                        <div class="metric-value">92%</div>
                                        <div class="metric-label">Switch Compatibility</div>
                                    </div>
                                    
                                    <div class="metric">
                                        <div class="metric-value">68%</div>
                                        <div class="metric-label">Client Readiness</div>
                                    </div>
                                </div>
                                
                                <div class="chart-container">
                                    <!-- Readiness chart will be rendered here via JavaScript -->
                                </div>
                            </div>
                        </div>
                        
                        <div class="dashboard-card">
                            <div class="dashboard-card-header">
                                <h4 class="dashboard-card-title">Recommendations</h4>
                            </div>
                            <div class="dashboard-card-body">
                                <div class="recommendation-list">
                                    <div class="recommendation-item priority-high">
                                        <div class="recommendation-icon">
                                            <i class="fas fa-exclamation-triangle"></i>
                                        </div>
                                        <div class="recommendation-content">
                                            <h5 class="recommendation-title">Update Switch Firmware</h5>
                                            <p class="recommendation-description">3 switches require firmware updates for full 802.1X compatibility.</p>
                                        </div>
                                    </div>
                                    
                                    <div class="recommendation-item priority-medium">
                                        <div class="recommendation-icon">
                                            <i class="fas fa-sync"></i>
                                        </div>
                                        <div class="recommendation-content">
                                            <h5 class="recommendation-title">Configure RADIUS Server</h5>
                                            <p class="recommendation-description">Set up RADIUS server with appropriate client entries for network devices.</p>
                                        </div>
                                    </div>
                                    
                                    <div class="recommendation-item priority-low">
                                        <div class="recommendation-icon">
                                            <i class="fas fa-info-circle"></i>
                                        </div>
                                        <div class="recommendation-content">
                                            <h5 class="recommendation-title">Client Certificate Deployment</h5>
                                            <p class="recommendation-description">Prepare deployment strategy for client certificates if using EAP-TLS.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="dashboard-card">
                        <div class="dashboard-card-header">
                            <h4 class="dashboard-card-title">Deployment Roadmap</h4>
                        </div>
                        <div class="dashboard-card-body">
                            <!-- Roadmap content will be added here -->
                        </div>
                    </div>
                </div>
                
                <!-- Import Tab -->
                <div id="import" class="discovery-tab-content">
                    <div class="section-content">
                        <h3>Import Device Data</h3>
                        <div class="form-group">
                            <label for="import-file">Upload File</label>
                            <input type="file" id="import-file" class="form-control">
                            <span class="form-hint">Supported formats: CSV, Excel, XML</span>
                        </div>
                        
                        <div class="form-group">
                            <label>Import Options</label>
                            <div class="checkbox-label">
                                <input type="checkbox" id="merge-data" checked>
                                <label for="merge-data">Merge with existing data</label>
                            </div>
                            
                            <div class="checkbox-label">
                                <input type="checkbox" id="override-existing">
                                <label for="override-existing">Override existing entries</label>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn btn-primary">Import</button>
                            <button class="btn btn-light">Cancel</button>
                        </div>
                    </div>
                </div>
                
                <!-- Report Tab -->
                <div id="report" class="discovery-tab-content">
                    <div class="section-content">
                        <h3>Generate Reports</h3>
                        <div class="form-group">
                            <label>Report Type</label>
                            <div class="radio-label">
                                <input type="radio" name="report-type" id="report-inventory" checked>
                                <label for="report-inventory">Device Inventory</label>
                            </div>
                            
                            <div class="radio-label">
                                <input type="radio" name="report-type" id="report-readiness">
                                <label for="report-readiness">802.1X Readiness</label>
                            </div>
                            
                            <div class="radio-label">
                                <input type="radio" name="report-type" id="report-compliance">
                                <label for="report-compliance">Compliance Status</label>
                            </div>
                            
                            <div class="radio-label">
                                <input type="radio" name="report-type" id="report-custom">
                                <label for="report-custom">Custom Report</label>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label>Report Format</label>
                            <div class="radio-label">
                                <input type="radio" name="report-format" id="format-pdf" checked>
                                <label for="format-pdf">PDF</label>
                            </div>
                            
                            <div class="radio-label">
                                <input type="radio" name="report-format" id="format-html">
                                <label for="format-html">HTML</label>
                            </div>
                            
                            <div class="radio-label">
                                <input type="radio" name="report-format" id="format-csv">
                                <label for="format-csv">CSV</label>
                            </div>
                            
                            <div class="radio-label">
                                <input type="radio" name="report-format" id="format-json">
                                <label for="format-json">JSON</label>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn btn-primary">Generate Report</button>
                            <button class="btn btn-light">Cancel</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Reference Tab -->
        <div id="reference" class="tab-content">
            <div class="section-header">
                <h2>Reference & Documentation</h2>
            </div>
            <div class="section-content">
                <div class="card-container">
                    <div class="card">
                        <div class="card-header">802.1X Architecture</div>
                        <div class="card-body">
                            <p>Reference diagrams and explanations of 802.1X network architecture.</p>
                            <img src="assets/diagrams/basic-802.1x-architecture.png" alt="802.1X Architecture" style="max-width: 100%; margin-top: 1rem;">
                        </div>
                        <div class="card-footer">
                            <a href="#" class="btn btn-primary btn-sm">View Details</a>
                        </div>
                    </div>
                    
                    <div class="card">
                        <div class="card-header">Vendor Implementation Guides</div>
                        <div class="card-body">
                            <p>Vendor-specific implementation guides and best practices.</p>
                            <ul style="margin-top: 1rem; padding-left: 1.5rem;">
                                <li>Cisco IOS Configuration Guide</li>
                                <li>Aruba Configuration Guide</li>
                                <li>Juniper Configuration Guide</li>
                                <li>HP Configuration Guide</li>
                            </ul>
                        </div>
                        <div class="card-footer">
                            <a href="#" class="btn btn-primary btn-sm">Browse Guides</a>
                        </div>
                    </div>
                    
                    <div class="card">
                        <div class="card-header">Troubleshooting Guide</div>
                        <div class="card-body">
                            <p>Common issues and troubleshooting steps for 802.1X deployments.</p>
                        </div>
                        <div class="card-footer">
                            <a href="#" class="btn btn-primary btn-sm">View Guide</a>
                        </div>
                    </div>
                    
                    <div class="card">
                        <div class="card-header">Best Practices</div>
                        <div class="card-body">
                            <p>Industry best practices for 802.1X deployment and management.</p>
                        </div>
                        <div class="card-footer">
                            <a href="#" class="btn btn-primary btn-sm">View Best Practices</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- AI Integration Tab -->
        <div id="ai" class="tab-content">
            <div class="section-header">
                <h2>AI Integration</h2>
            </div>
            <div class="section-content">
                <div class="ai-container">
                    <div class="ai-header">
                        <h3 class="ai-title">Configure AI Assistant</h3>
                    </div>
                    <div class="ai-description">
                        <p>Connect to AI providers to enhance your 802.1X configuration experience. Get intelligent recommendations, troubleshooting assistance, and automatic configuration generation.</p>
                    </div>
                    
                    <div class="ai-provider-grid">
                        <!-- OpenAI Card -->
                        <div class="ai-provider-card">
                            <img src="assets/logos/openai-logo.png" alt="OpenAI" class="ai-provider-logo">
                            <h4 class="ai-provider-name">OpenAI</h4>
                            <div class="ai-provider-models">
                                <span class="ai-provider-model">GPT-4o</span>
                                <span class="ai-provider-model">GPT-4</span>
                                <span class="ai-provider-model">GPT-3.5 Turbo</span>
                            </div>
                            <p>Powerful language models for configuration generation and troubleshooting assistance.</p>
                            <div class="ai-provider-footer">
                                <div class="ai-status ai-status-disconnected">
                                    <span class="ai-status-dot"></span>
                                    <span>Disconnected</span>
                                </div>
                                <a href="#" class="ai-provider-action btn-primary btn-sm">Connect</a>
                            </div>
                        </div>
                        
                        <!-- Anthropic Card -->
                        <div class="ai-provider-card">
                            <img src="assets/logos/anthropic-logo.png" alt="Anthropic" class="ai-provider-logo">
                            <h4 class="ai-provider-name">Anthropic Claude</h4>
                            <div class="ai-provider-models">
                                <span class="ai-provider-model">Claude Opus</span>
                                <span class="ai-provider-model">Claude Sonnet</span>
                                <span class="ai-provider-model">Claude Haiku</span>
                            </div>
                            <p>Advanced models focused on helpfulness, harmlessness, and honesty.</p>
                            <div class="ai-provider-footer">
                                <div class="ai-status ai-status-disconnected">
                                    <span class="ai-status-dot"></span>
                                    <span>Disconnected</span>
                                </div>
                                <a href="#" class="ai-provider-action btn-primary btn-sm">Connect</a>
                            </div>
                        </div>
                        
                        <!-- AWS Bedrock Card -->
                        <div class="ai-provider-card">
                            <img src="assets/logos/aws-logo.png" alt="AWS Bedrock" class="ai-provider-logo">
                            <h4 class="ai-provider-name">AWS Bedrock</h4>
                            <div class="ai-provider-models">
                                <span class="ai-provider-model">Claude 3</span>
                                <span class="ai-provider-model">Titan</span>
                                <span class="ai-provider-model">Llama 2</span>
                            </div>
                            <p>Access multiple foundation models through AWS with enterprise security.</p>
                            <div class="ai-provider-footer">
                                <div class="ai-status ai-status-disconnected">
                                    <span class="ai-status-dot"></span>
                                    <span>Disconnected</span>
                                </div>
                                <a href="#" class="ai-provider-action btn-primary btn-sm">Connect</a>
                            </div>
                        </div>
                        
                        <!-- Azure OpenAI Card -->
                        <div class="ai-provider-card">
                            <img src="assets/logos/azure-logo.png" alt="Azure OpenAI" class="ai-provider-logo">
                            <h4 class="ai-provider-name">Azure OpenAI</h4>
                            <div class="ai-provider-models">
                                <span class="ai-provider-model">GPT-4</span>
                                <span class="ai-provider-model">GPT-3.5</span>
                                <span class="ai-provider-model">DALL-E</span>
                            </div>
                            <p>OpenAI models with Azure's enterprise-grade security and compliance.</p>
                            <div class="ai-provider-footer">
                                <div class="ai-status ai-status-disconnected">
                                    <span class="ai-status-dot"></span>
                                    <span>Disconnected</span>
                                </div>
                                <a href="#" class="ai-provider-action btn-primary btn-sm">Connect</a>
                            </div>
                        </div>
                    </div>
                    
                    <div id="ai-assistant-container" style="display: none;">
                        <div class="ai-assistant">
                            <div class="ai-assistant-header">
                                <h3 class="ai-assistant-title">
                                    <i class="fas fa-robot ai-assistant-icon"></i>
                                    802.1X Configuration Assistant
                                </h3>
                                <div class="ai-assistant-controls">
                                    <span class="ai-assistant-control" title="Settings">
                                        <i class="fas fa-cog"></i>
                                    </span>
                                    <span class="ai-assistant-control" title="Clear Conversation">
                                        <i class="fas fa-trash"></i>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="ai-chat-container" id="ai-chat-messages">
                                <!-- Message from AI -->
                                <div class="ai-message">
                                    <div class="ai-message-avatar">
                                        <i class="fas fa-robot"></i>
                                    </div>
                                    <div class="ai-message-content">
                                        <p class="ai-message-text">Hello! I'm your 802.1X configuration assistant. How can I help you today?</p>
                                        <div class="ai-message-time">Just now</div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="ai-input-container">
                                <textarea class="ai-input" id="ai-input" placeholder="Type your message here..." rows="1"></textarea>
                                <button class="ai-send-btn" id="ai-send-btn">
                                    <i class="fas fa-paper-plane"></i>
                                </button>
                            </div>
                        </div>
                        
                        <div class="ai-suggestions">
    <h4 class="ai-suggestions-title">Suggested Questions</h4>
    <div class="ai-suggestions-grid">
        <div class="ai-suggestion-card">
            <div class="ai-suggestion-header">
                <div class="ai-suggestion-icon">
                    <i class="fas fa-network-wired"></i>
                </div>
                <h5 class="ai-suggestion-title">Cisco 802.1X Configuration</h5>
            </div>
            <p class="ai-suggestion-description">How do I configure 802.1X on a Cisco switch with MAB fallback?</p>
        </div>
        
        <div class="ai-suggestion-card">
            <div class="ai-suggestion-header">
                <div class="ai-suggestion-icon">
                    <i class="fas fa-wifi"></i>
                </div>
                <h5 class="ai-suggestion-title">Wireless Implementation</h5>
            </div>
            <p class="ai-suggestion-description">What's the best way to deploy 802.1X for wireless networks?</p>
        </div>
        
        <div class="ai-suggestion-card">
            <div class="ai-suggestion-header">
                <div class="ai-suggestion-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h5 class="ai-suggestion-title">Best Practices</h5>
            </div>
            <p class="ai-suggestion-description">What are the current best practices for 802.1X deployment?</p>
        </div>
    </div>
</div>
<!-- Portnox Integration Tab -->
<div id="portnox" class="tab-content">
    <div class="section-header">
        <h2>Portnox Cloud Integration</h2>
    </div>
    <div class="section-content">
        <div class="portnox-container">
            <div class="portnox-header">
                <h3 class="portnox-title">
                    <img src="assets/logos/portnox-logo.png" alt="Portnox" class="portnox-logo">
                    Portnox Cloud Integration
                </h3>
            </div>
            <div class="portnox-description">
                <p>Integrate with Portnox Cloud for centralized network access control management. Deploy 802.1X configurations directly to your Portnox environment and synchronize device data.</p>
            </div>
            
            <div class="portnox-status portnox-status-disconnected">
                <div class="portnox-status-icon">
                    <i class="fas fa-times"></i>
                </div>
                <div class="portnox-status-text">
                    <h4 class="portnox-status-title">Disconnected</h4>
                    <p class="portnox-status-message">Connect to your Portnox Cloud account to enable synchronization and deployment.</p>
                </div>
                <div class="portnox-status-action">
                    <button class="btn btn-primary" id="portnox-connect-btn">Connect</button>
                </div>
            </div>
            
            <div class="portnox-form" id="portnox-connection-form">
                <h3 class="portnox-form-title">Connect to Portnox Cloud</h3>
                
                <div class="form-group">
                    <label for="portnox-tenant">Tenant URL</label>
                    <input type="text" id="portnox-tenant" class="form-control" placeholder="https://your-tenant.portnox.cloud">
                </div>
                
                <div class="form-group">
                    <label for="portnox-api-key">API Key</label>
                    <input type="password" id="portnox-api-key" class="form-control">
                </div>
                
                <div class="form-group">
                    <label for="portnox-api-secret">API Secret</label>
                    <input type="password" id="portnox-api-secret" class="form-control">
                </div>
                
                <div class="form-group">
                    <div class="checkbox-label">
                        <input type="checkbox" id="portnox-remember" checked>
                        <label for="portnox-remember">Remember connection</label>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button class="btn btn-primary" id="portnox-save-connection">Connect</button>
                    <button class="btn btn-light">Cancel</button>
                </div>
            </div>
            
            <div id="portnox-connected-view" style="display: none;">
                <div class="portnox-devices">
                    <div class="portnox-devices-header">
                        <h3 class="portnox-devices-title">Synchronized Devices</h3>
                        <div class="portnox-devices-actions">
                            <button class="btn btn-primary btn-sm">
                                <i class="fas fa-sync"></i> Sync Now
                            </button>
                            <button class="btn btn-light btn-sm">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                        </div>
                    </div>
                    
                    <table class="portnox-devices-table">
                        <thead>
                            <tr>
                                <th>Status</th>
                                <th>Device Name</th>
                                <th>IP Address</th>
                                <th>Type</th>
                                <th>Vendor</th>
                                <th>Last Sync</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="portnox-devices-body">
                            <!-- Will be populated via JavaScript -->
                        </tbody>
                    </table>
                </div>
                
                <div class="portnox-policies">
                    <div class="portnox-policies-header">
                        <h3 class="portnox-policies-title">Access Policies</h3>
                        <div class="portnox-policies-actions">
                            <button class="btn btn-primary btn-sm">
                                <i class="fas fa-plus"></i> New Policy
                            </button>
                        </div>
                    </div>
                    
                    <div id="portnox-policies-container">
                        <!-- Will be populated via JavaScript -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
        </div>
    </main>
    
    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <p>Dot1Xer Supreme - Version 2.0.0 | &copy; 2025 Dot1Xer Supreme Team</p>
        </div>
    </footer>
    
    <!-- JavaScript Files -->
    <script src="js/vendor-data.js"></script>
    <script src="js/templates.js"></script>
    <script src="js/configurator.js"></script>
    <script src="js/discovery.js"></script>
    <script src="js/help.js"></script>
    <script src="js/ai/ai-integration.js"></script>
    <script src="js/cloud/portnox-integration.js"></script>
    <script src="js/main.js"></script>
</body>
</html>
EOF
    
    log_success "Updated index.html"
    return 0
}
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
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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

EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    card.addEventListener('click', function() {
        selectVendor(vendor, platform);
    });
    
    return card;
}

/**
 * Handle vendor selection
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
function selectVendor(vendor, platform) {
    // Remove selected class from all vendor cards
    document.querySelectorAll('.vendor-card').forEach(card => {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        card.classList.remove('selected');
    });
    
    // Add selected class to the chosen vendor card
    document.querySelector(`.vendor-card[data-vendor="${vendor.id}"][data-platform="${platform}"]`).classList.add('selected');
    
    // Load and display the configuration form for the selected vendor
    loadVendorForm(vendor, platform);
}

/**
 * Load and display the configuration form for the selected vendor
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
function loadVendorForm(vendor, platform) {
    const formContainer = document.getElementById('config-form-container');
    
    // Show form container
    formContainer.style.display = 'block';
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    // Load form template
    if (typeof loadTemplate === 'function') {
        loadTemplate(vendor.id, platform, formContainer, function() {
            initFormEventListeners(vendor, platform);
        });
    } else {
        formContainer.innerHTML = `<div class="alert alert-warning">Form templates not available. Please make sure templates.js is loaded.</div>`;
    }
    
    // Hide configuration output
    document.getElementById('config-output-container').style.display = 'none';
}

/**
 * Initialize event listeners for the configuration form
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
function initFormEventListeners(vendor, platform) {
    const generateBtn = document.getElementById('generate-config-btn');
    
    if (generateBtn) {
        generateBtn.addEventListener('click', function() {
            generateConfiguration(vendor, platform);
        });
    }
    
    const resetBtn = document.getElementById('reset-form-btn');
    
    if (resetBtn) {
        resetBtn.addEventListener('click', function() {
            resetConfigurationForm();
        });
    }
    
    const saveTemplateBtn = document.getElementById('save-template-btn');
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    
    if (saveTemplateBtn) {
        saveTemplateBtn.addEventListener('click', function() {
            saveAsTemplate(vendor, platform);
        });
    }
    
    const aiAssistBtn = document.getElementById('ai-assist-btn');
    
    if (aiAssistBtn) {
        aiAssistBtn.addEventListener('click', function() {
            openAIAssistant(vendor, platform);
        });
    }
}

/**
 * Generate configuration based on the form values
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
function generateConfiguration(vendor, platform) {
    // Get form values
    const formValues = getFormValues();
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    // Validate form
    if (!validateForm(formValues)) {
        return;
    }
    
    // Generate configuration
    let config = '';
    
    if (typeof generateVendorConfig === 'function') {
        config = generateVendorConfig(vendor.id, platform, formValues);
    } else {
        config = `# ${vendor.name} ${platform === 'wired' ? 'Switch' : 'Wireless'} Configuration\n# Generated by Dot1Xer Supreme\n\n`;
        config += `# Configuration generation function not available.\n`;
        config += `# Please make sure the vendor-specific templates are loaded.`;
    }
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    // Display configuration
    displayConfiguration(config, vendor, platform);
}

/**
 * Get all form values from the configuration form
 * @returns {Object} - Form values
 */
function getFormValues() {
    const form = document.getElementById('vendor-config-form');
    if (!form) return {};
    
    const formData = new FormData(form);
    const values = {};
    
    for (const [key, value] of formData.entries()) {
        values[key] = value;
    }
    
    return values;
}

/**
 * Validate the configuration form
 * @param {Object} formValues - Form values to validate
 * @returns {Boolean} - True if valid, false otherwise
 */
function validateForm(formValues) {
    let isValid = true;
    let errorMessage = '';
    
    // Check for required fields
    const requiredFields = document.querySelectorAll('[required]');
    requiredFields.forEach(field => {
        if (!formValues[field.name] || formValues[field.name].trim() === '') {
            field.classList.add('invalid');
            errorMessage += `Field "${field.getAttribute('data-label') || field.name}" is required.\n`;
            isValid = false;
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        } else {
            field.classList.remove('invalid');
        }
    });
    
    // Display error message if validation fails
    if (!isValid) {
        const errorContainer = document.getElementById('form-error-container') || document.createElement('div');
        errorContainer.id = 'form-error-container';
        errorContainer.className = 'alert alert-danger';
        errorContainer.innerHTML = `<strong>Validation Error:</strong> Please correct the following issues:<br>${errorMessage.replace(/\n/g, '<br>')}`;
        
        const form = document.getElementById('vendor-config-form');
        form.prepend(errorContainer);
    } else {
        const errorContainer = document.getElementById('form-error-container');
        if (errorContainer) {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            errorContainer.remove();
        }
    }
    
    return isValid;
}

/**
 * Display the generated configuration
 * @param {String} config - Generated configuration
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
function displayConfiguration(config, vendor, platform) {
    const outputContainer = document.getElementById('config-output-container');
    const outputElement = document.getElementById('config-output');
    
    outputElement.textContent = config;
    outputContainer.style.display = 'block';
    
    // Scroll to output
    outputContainer.scrollIntoView({ behavior: 'smooth' });
    
    // Initialize copy button
    initCopyButton();
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    
    // Initialize save button
    initSaveButton(config, vendor, platform);
}

/**
 * Initialize the copy configuration button
 */
function initCopyButton() {
    const copyBtn = document.getElementById('copy-config');
    const outputElement = document.getElementById('config-output');
    
    copyBtn.addEventListener('click', function() {
        // Create a temporary textarea to copy from
        const tempTextarea = document.createElement('textarea');
        tempTextarea.value = outputElement.textContent;
        document.body.appendChild(tempTextarea);
        tempTextarea.select();
        document.execCommand('copy');
        document.body.removeChild(tempTextarea);
        
        // Show success message
        const originalText = copyBtn.innerHTML;
        copyBtn.innerHTML = '<i class="fas fa-check"></i> Copied!';
        setTimeout(() => {
            copyBtn.innerHTML = originalText;
        }, 2000);
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    });
}

/**
 * Initialize the save configuration button
 * @param {String} config - Generated configuration
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
function initSaveButton(config, vendor, platform) {
    const saveBtn = document.getElementById('save-config');
    
    saveBtn.addEventListener('click', function() {
        // Get form values to use as filename
        const formValues = getFormValues();
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `${vendor.id}_${platform}_config_${timestamp}.txt`;
        
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        // Create download link
        const downloadLink = document.createElement('a');
        downloadLink.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(config));
        downloadLink.setAttribute('download', filename);
        downloadLink.style.display = 'none';
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
        
        // Show success message
        const originalText = saveBtn.innerHTML;
        saveBtn.innerHTML = '<i class="fas fa-check"></i> Saved!';
        setTimeout(() => {
            saveBtn.innerHTML = originalText;
        }, 2000);
    });
}

/**
 * Reset the configuration form
 */
function resetConfigurationForm() {
    const form = document.getElementById('vendor-config-form');
    if (form) {
        form.reset();
    }
    
    // Hide configuration output
    document.getElementById('config-output-container').style.display = 'none';
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    
    // Remove error container if exists
    const errorContainer = document.getElementById('form-error-container');
    if (errorContainer) {
        errorContainer.remove();
    }
}

/**
 * Save the current configuration as a template
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
function saveAsTemplate(vendor, platform) {
    const formValues = getFormValues();
    
    // Prompt for template name
    const templateName = prompt('Enter a name for this template:', `${vendor.name} ${platform} Template`);
    
    if (!templateName) return;
    
    // Generate a unique ID
    const templateId = `${vendor.id}_${platform}_${Date.now()}`;
    
    // Create template object
    const template = {
        id: templateId,
        name: templateName,
        vendor: vendor.id,
        platform: platform,
        values: formValues,
        created: new Date().toISOString()
    };
    
    // Save to localStorage
    saveTemplate(template);
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    // Show success message
    alert(`Template "${templateName}" saved successfully.`);
}

/**
 * Save a template to localStorage
 * @param {Object} template - Template object to save
 */
function saveTemplate(template) {
    // Get existing templates
    let templates = JSON.parse(localStorage.getItem('dot1xer_templates') || '[]');
    
    // Add new template
    templates.push(template);
    
    // Save to localStorage
    localStorage.setItem('dot1xer_templates', JSON.stringify(templates));
}

/**
 * Open AI assistant with context about the current vendor
 * @param {Object} vendor - Selected vendor data
 * @param {String} platform - 'wired' or 'wireless'
 */
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
function openAIAssistant(vendor, platform) {
    // Check if AI integration is available
    if (typeof showAIAssistant !== 'function') {
        alert('AI assistant is not available. Please connect to an AI provider first.');
        return;
    }
    
    // Get form values
    const formValues = getFormValues();
    
    // Create context for AI
    const context = {
        vendor: vendor,
        platform: platform,
        formValues: formValues
    };
    
    // Show AI assistant with context
    showAIAssistant(context);
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    // Switch to AI tab
    document.querySelector('.nav-tabs a[data-tab="ai"]').click();
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
    // Initialize scan button
    const startScanBtn = document.getElementById('start-scan');
    if (startScanBtn) {
        startScanBtn.addEventListener('click', function() {
            startNetworkScan();
        });
    }
    
    // Initialize SNMP discovery checkbox
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    const snmpDiscoveryCheckbox = document.getElementById('snmp-discovery');
    const snmpOptionsDiv = document.getElementById('snmp-options');
    
    if (snmpDiscoveryCheckbox && snmpOptionsDiv) {
        snmpDiscoveryCheckbox.addEventListener('change', function() {
            snmpOptionsDiv.style.display = this.checked ? 'block' : 'none';
        });
    }
}

/**
 * Start network discovery scan
 */
function startNetworkScan() {
    // Get scan parameters
    const ipRange = document.getElementById('ip-range').value;
    const scanType = document.querySelector('input[name="scan-type"]:checked').id;
    const useSnmp = document.getElementById('snmp-discovery').checked;
    const snmpCommunity = document.getElementById('snmp-community').value;
    const useDns = document.getElementById('dns-resolution').checked;
    const identifyVendor = document.getElementById('vendor-identification').checked;
    
    // Validate IP range
    if (!ipRange) {
        alert('Please enter an IP range to scan');
        return;
    }
    
    // Hide scan options
    document.querySelector('.scan-options').style.display = 'none';
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    
    // Show scan progress
    const scanProgress = document.querySelector('.scan-progress');
    scanProgress.style.display = 'block';
    
    // Prepare scan parameters
    const scanParams = {
        ipRange: ipRange,
        scanType: scanType,
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        useSnmp: useSnmp,
        snmpCommunity: snmpCommunity,
        useDns: useDns,
        identifyVendor: identifyVendor
    };
    
    // If discovery.js is loaded, use its scan function
    if (typeof performNetworkScan === 'function') {
        performNetworkScan(scanParams, updateScanProgress, scanCompleted);
    } else {
        // Simulate scan for demo purposes
        simulateScan(scanParams, updateScanProgress, scanCompleted);
    }
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
}

/**
 * Simulate a network scan (for demo purposes)
 * @param {Object} params - Scan parameters
 * @param {Function} progressCallback - Progress update callback
 * @param {Function} completionCallback - Scan completion callback
 */
function simulateScan(params, progressCallback, completionCallback) {
    // Demo data
    const demoDevices = [
        { status: 'online', ip: '192.168.1.1', hostname: 'gateway.local', type: 'Router', vendor: 'Cisco', model: 'ISR 4331', dot1x: 'Supported' },
        { status: 'online', ip: '192.168.1.2', hostname: 'core-switch.local', type: 'Switch', vendor: 'Cisco', model: 'Catalyst 9300', dot1x: 'Supported' },
        { status: 'online', ip: '192.168.1.10', hostname: 'access-switch-1.local', type: 'Switch', vendor: 'HP', model: 'Aruba 2930F', dot1x: 'Supported' },
        { status: 'online', ip: '192.168.1.11', hostname: 'access-switch-2.local', type: 'Switch', vendor: 'Juniper', model: 'EX3400', dot1x: 'Supported' },
        { status: 'offline', ip: '192.168.1.12', hostname: '', type: '', vendor: '', model: '', dot1x: 'Unknown' },
        { status: 'online', ip: '192.168.1.20', hostname: 'ap-01.local', type: 'Access Point', vendor: 'Aruba', model: 'AP-515', dot1x: 'N/A' },
        { status: 'online', ip: '192.168.1.21', hostname: 'ap-02.local', type: 'Access Point', vendor: 'Cisco', model: 'Catalyst 9120', dot1x: 'N/A' },
        { status: 'online', ip: '192.168.1.100', hostname: 'fileserver.local', type: 'Server', vendor: 'Dell', model: 'PowerEdge R740', dot1x: 'N/A' }
    ];
    
    // Simulate progress updates
    let progress = 0;
    const progressInterval = setInterval(() => {
        progress += 10;
        progressCallback(progress, `Scanning ${params.ipRange}... (${progress}% complete)`);
        
        if (progress >= 100) {
            clearInterval(progressInterval);
            setTimeout(() => {
                completionCallback(demoDevices);
            }, 500);
        }
    }, 1000);
}

/**
 * Update scan progress UI
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
 * @param {Number} percentage - Scan progress percentage
 * @param {String} message - Progress message
 */
function updateScanProgress(percentage, message) {
    const progressBar = document.querySelector('.progress-bar');
    const progressText = document.querySelector('.scan-progress-text');
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    progressBar.style.width = `${percentage}%`;
    progressText.textContent = message;
}

/**
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
 * Handle scan completion
 * @param {Array} devices - Discovered devices
 */
function scanCompleted(devices) {
    // Hide scan progress
    document.querySelector('.scan-progress').style.display = 'none';
    
    // Show scan results
    const scanResults = document.querySelector('.scan-results');
    scanResults.style.display = 'block';
    
    // Populate results table
    populateScanResults(devices);
}

/**
 * Populate scan results table
 * @param {Array} devices - Discovered devices
 */
function populateScanResults(devices) {
    const resultsBody = document.getElementById('scan-results-body');
    resultsBody.innerHTML = '';
    
    devices.forEach(device => {
        const row = document.createElement('tr');
        
        // Status cell
        const statusCell = document.createElement('td');
        const statusDot = document.createElement('span');
        statusDot.className = `device-status status-${device.status}`;
        statusCell.appendChild(statusDot);
        statusCell.appendChild(document.createTextNode(device.status));
        row.appendChild(statusCell);
        
        // Other cells
        row.appendChild(createCell(device.ip));
        row.appendChild(createCell(device.hostname));
        row.appendChild(createCell(device.type));
        row.appendChild(createCell(device.vendor));
        row.appendChild(createCell(device.model));
        row.appendChild(createCell(device.dot1x));
        
        // Actions cell
        const actionsCell = document.createElement('td');
        const viewBtn = document.createElement('button');
        viewBtn.className = 'btn btn-primary btn-sm';
        viewBtn.textContent = 'View';
        viewBtn.addEventListener('click', () => viewDeviceDetails(device));
        actionsCell.appendChild(viewBtn);
        row.appendChild(actionsCell);
        
        resultsBody.appendChild(row);
    });
}

/**
 * Create a table cell with the given content
 * @param {String} content - Cell content
 * @returns {HTMLElement} - Table cell element
 */
function createCell(content) {
    const cell = document.createElement('td');
    cell.textContent = content || '-';
    return cell;
}

/**
 * View device details
 * @param {Object} device - Device data
 */
function viewDeviceDetails(device) {
    // Implement device details view
    alert(`Device details for ${device.ip} (${device.hostname || 'Unknown'}) will be displayed here.`);
}

/**
 * Check for saved configurations
 */
function checkSavedConfigurations() {
    // Implementation will depend on how configurations are saved
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
        },
        {
            id: 'extreme',
            name: 'Extreme',
            logo: 'extreme-logo.png',
            description: 'Extreme Networks switches',
            models: ['X400', 'X600', 'Summit X Series'],
            templates: ['exos', 'voss']
        },
        {
            id: 'dell',
            name: 'Dell',
            logo: 'dell-logo.png',
            description: 'Dell EMC Networking switches',
            models: ['PowerSwitch N Series', 'PowerSwitch S Series'],
            templates: ['os10', 'os9']
        },
        {
            id: 'arista',
            name: 'Arista',
            logo: 'arista-logo.png',
            description: 'Arista EOS-based switches',
            models: ['7050X3', '7060X4', '7500R'],
            templates: ['eos']
        },
        {
            id: 'huawei',
            name: 'Huawei',
            logo: 'huawei-logo.png',
            description: 'Huawei CloudEngine and S series switches',
            models: ['CE8800', 'S6700', 'S5700'],
            templates: ['vrp']
        },
        {
            id: 'alcatel',
            name: 'Alcatel-Lucent',
            logo: 'alcatel-logo.png',
            description: 'Alcatel-Lucent Enterprise OmniSwitch',
            models: ['6900', '6850E', '6560'],
            templates: ['aos']
        },
        {
            id: 'brocade',
            name: 'Brocade',
            logo: 'brocade-logo.png',
            description: 'Brocade ICX and VDX switches',
            models: ['ICX 7150', 'ICX 7250', 'ICX 7450'],
            templates: ['fastiron', 'netiron']
        },
        {
            id: 'ruckus',
            name: 'Ruckus',
            logo: 'ruckus-logo.png',
            description: 'Ruckus ICX switches (formerly Brocade)',
            models: ['ICX 7150', 'ICX 7250', 'ICX 7650'],
            templates: ['fastiron']
        }
    ],
    
    // Wireless vendors
    wireless: [
        {
            id: 'cisco-wlc',
            name: 'Cisco WLC',
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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
        },
        {
            id: 'extreme-wireless',
            name: 'Extreme Wireless',
            logo: 'extreme-logo.png',
            description: 'Extreme Networks wireless solutions',
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            models: ['ExtremeWireless', 'ExtremeCloud'],
            templates: ['wing', 'exos-wireless']
        },
        {
            id: 'juniper-mist',
            name: 'Juniper Mist',
            logo: 'juniper-logo.png',
            description: 'Juniper Mist cloud-managed wireless',
            models: ['Mist AP Series', 'Mist Cloud'],
            templates: ['mist-cloud']
        },
        {
            id: 'huawei-wireless',
            name: 'Huawei Wireless',
            logo: 'huawei-logo.png',
            description: 'Huawei wireless controllers and APs',
            models: ['AC Series Controllers', 'AP Series'],
            templates: ['ac-series']
        }
    ]
};
EOF
    
    log_success "Created vendor-data.js"
    
    # Create templates.js file
    TEMPLATES_JS="$DEPLOY_DIR/js/templates.js"
    
cat > "$STYLES_CSS" << 'EOF'
/* Dot1Xer CSS content */
/* Add your CSS content here */
EOF
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 * @param {HTMLElement} container - Container to inject the template into
 * @param {Function} callback - Callback function to execute after template is loaded
 */
EOF
EOF
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
 * Load a generic template as fallback
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 * @param {HTMLElement} container - Container to inject the template into
 * @param {Function} callback - Callback function to execute after template is loaded
 */
function loadGenericTemplate(vendorId, platform, container, callback) {
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
    
    // Create a generic template based on the platform
    let formHtml = '';
    
    if (platform === 'wired') {
        formHtml = generateGenericWiredTemplate(vendor);
    } else {
        formHtml = generateGenericWirelessTemplate(vendor);
    }
    
    // Inject the template into the container
    container.innerHTML = formHtml;
    
    // Initialize any template-specific elements
    initTemplateElements(vendorId, platform);
    
    // Execute the callback if provided
    if (typeof callback === 'function') {
        callback();
    }
}

/**
 * Generate a generic template for wired vendors
 * @param {Object} vendor - Vendor data
 * @returns {String} - HTML template
 */
function generateGenericWiredTemplate(vendor) {
    return `
        <div class="vendor-form-header">
            <h3>${vendor.name} Configuration</h3>
            <img src="assets/logos/${vendor.logo}" alt="${vendor.name}" class="vendor-logo">
        </div>
        
        <form id="vendor-config-form">
            <div class="form-group">
                <label for="auth_method">Authentication Method</label>
                <select class="form-control" id="auth_method" name="auth_method" required data-label="Authentication Method">
                    <option value="dot1x">802.1X</option>
                    <option value="dot1x_mab" selected>802.1X with MAB Fallback</option>
                    <option value="dot1x_web_auth">802.1X with Web Authentication</option>
                    <option value="mab">MAC Authentication Bypass (MAB) Only</option>
                </select>
                <span class="form-hint">Select the authentication method for port security</span>
            </div>
            
            <div class="form-group">
                <label for="primary_radius">Primary RADIUS Server</label>
                <input type="text" class="form-control" id="primary_radius" name="primary_radius" required data-label="Primary RADIUS Server">
                <span class="form-hint">IP address or hostname of your primary RADIUS server</span>
            </div>
            
            <div class="form-group">
                <label for="secondary_radius">Secondary RADIUS Server (Optional)</label>
                <input type="text" class="form-control" id="secondary_radius" name="secondary_radius">
                <span class="form-hint">IP address or hostname of your backup RADIUS server</span>
            </div>
            
            <div class="form-group">
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                <label for="radius_secret">RADIUS Shared Secret</label>
                <input type="password" class="form-control" id="radius_secret" name="radius_secret" required data-label="RADIUS Shared Secret">
                <span class="form-hint">Shared secret for RADIUS authentication</span>
            </div>
            
            <div class="form-group">
                <label for="radius_auth_port">RADIUS Authentication Port</label>
                <input type="number" class="form-control" id="radius_auth_port" name="radius_auth_port" value="1812">
                <span class="form-hint">UDP port for RADIUS authentication (default: 1812)</span>
            </div>
            
            <div class="form-group">
                <label for="radius_acct_port">RADIUS Accounting Port</label>
                <input type="number" class="form-control" id="radius_acct_port" name="radius_acct_port" value="1813">
                <span class="form-hint">UDP port for RADIUS accounting (default: 1813)</span>
            </div>
            
            <div class="form-group">
                <label for="auth_vlan">Authentication VLAN</label>
                <input type="number" class="form-control" id="auth_vlan" name="auth_vlan" required data-label="Authentication VLAN">
                <span class="form-hint">VLAN ID for authenticated devices</span>
            </div>
            
            <div class="form-group">
                <label for="guest_vlan">Guest VLAN (Optional)</label>
                <input type="number" class="form-control" id="guest_vlan" name="guest_vlan">
                <span class="form-hint">VLAN ID for guest or unauthenticated devices</span>
            </div>
            
            <div class="form-group">
                <label for="auth_fail_vlan">Auth-Fail VLAN (Optional)</label>
                <input type="number" class="form-control" id="auth_fail_vlan" name="auth_fail_vlan">
                <span class="form-hint">VLAN ID for devices that fail authentication</span>
            </div>
            
            <div class="form-group">
                <label for="critical_vlan">Critical VLAN (Optional)</label>
                <input type="number" class="form-control" id="critical_vlan" name="critical_vlan">
                <span class="form-hint">VLAN ID when RADIUS servers are unreachable</span>
            </div>
            
            <div class="form-group">
                <label for="port_range">Port Range</label>
                <input type="text" class="form-control" id="port_range" name="port_range" placeholder="e.g., Gi1/0/1-48">
                <span class="form-hint">Range of ports to apply configuration to</span>
            </div>
            
            <div class="form-group">
                <label>Advanced Options</label>
                <div class="checkbox-label">
                    <input type="checkbox" id="enable_accounting" name="enable_accounting" checked>
                    <label for="enable_accounting">Enable RADIUS Accounting</label>
                </div>
                
                <div class="checkbox-label">
                    <input type="checkbox" id="enable_reauth" name="enable_reauth" checked>
                    <label for="enable_reauth">Enable Periodic Reauthentication</label>
                </div>
                
                <div class="form-group">
                    <label for="reauth_timer">Reauthentication Timer (seconds)</label>
                    <input type="number" class="form-control" id="reauth_timer" name="reauth_timer" value="3600">
                </div>
                
                <div class="checkbox-label">
                    <input type="checkbox" id="enable_preauth" name="enable_preauth">
                    <label for="enable_preauth">Enable Pre-Authentication Open Access</label>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-primary" id="generate-config-btn">Generate Configuration</button>
                <button type="button" class="btn btn-light" id="reset-form-btn">Reset</button>
                <button type="button" class="btn btn-secondary" id="save-template-btn">Save as Template</button>
                <button type="button" class="btn btn-primary" id="ai-assist-btn">
                    <i class="fas fa-robot"></i> AI Assistant
                </button>
            </div>
        </form>
    `;
}

/**
 * Generate a generic template for wireless vendors
 * @param {Object} vendor - Vendor data
 * @returns {String} - HTML template
 */
function generateGenericWirelessTemplate(vendor) {
    return `
        <div class="vendor-form-header">
            <h3>${vendor.name} Configuration</h3>
            <img src="assets/logos/${vendor.logo}" alt="${vendor.name}" class="vendor-logo">
        </div>
        
        <form id="vendor-config-form">
            <div class="form-group">
                <label for="ssid_name">SSID Name</label>
                <input type="text" class="form-control" id="ssid_name" name="ssid_name" required data-label="SSID Name">
                <span class="form-hint">Name of the wireless network (SSID)</span>
            </div>
            
            <div class="form-group">
                <label for="auth_method">Authentication Method</label>
                <select class="form-control" id="auth_method" name="auth_method" required data-label="Authentication Method">
                    <option value="wpa2-enterprise" selected>WPA2-Enterprise (802.1X)</option>
                    <option value="wpa3-enterprise">WPA3-Enterprise</option>
                    <option value="wpa2-psk">WPA2-Personal (Pre-Shared Key)</option>
                    <option value="wpa3-psk">WPA3-Personal</option>
                    <option value="open">Open (No Authentication)</option>
                </select>
                <span class="form-hint">Authentication method for the wireless network</span>
            </div>
            
            <div id="enterprise-auth-options">
                <div class="form-group">
                    <label for="primary_radius">Primary RADIUS Server</label>
                    <input type="text" class="form-control" id="primary_radius" name="primary_radius" required data-label="Primary RADIUS Server">
                    <span class="form-hint">IP address or hostname of your primary RADIUS server</span>
                </div>
                
                <div class="form-group">
                    <label for="secondary_radius">Secondary RADIUS Server (Optional)</label>
                    <input type="text" class="form-control" id="secondary_radius" name="secondary_radius">
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                    <span class="form-hint">IP address or hostname of your backup RADIUS server</span>
                </div>
                
                <div class="form-group">
                    <label for="radius_secret">RADIUS Shared Secret</label>
                    <input type="password" class="form-control" id="radius_secret" name="radius_secret" required data-label="RADIUS Shared Secret">
                    <span class="form-hint">Shared secret for RADIUS authentication</span>
                </div>
                
                <div class="form-group">
                    <label for="radius_auth_port">RADIUS Authentication Port</label>
                    <input type="number" class="form-control" id="radius_auth_port" name="radius_auth_port" value="1812">
                    <span class="form-hint">UDP port for RADIUS authentication (default: 1812)</span>
                </div>
                
                <div class="form-group">
                    <label for="radius_acct_port">RADIUS Accounting Port</label>
                    <input type="number" class="form-control" id="radius_acct_port" name="radius_acct_port" value="1813">
                    <span class="form-hint">UDP port for RADIUS accounting (default: 1813)</span>
                </div>
            </div>
            
            <div id="psk-auth-options" style="display: none;">
                <div class="form-group">
                    <label for="wpa_passphrase">WPA Passphrase</label>
                    <input type="password" class="form-control" id="wpa_passphrase" name="wpa_passphrase">
                    <span class="form-hint">WPA Pre-Shared Key (8-63 characters)</span>
                </div>
            </div>
            
            <div class="form-group">
                <label for="vlan_id">VLAN ID</label>
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                <input type="number" class="form-control" id="vlan_id" name="vlan_id" required data-label="VLAN ID">
                <span class="form-hint">VLAN ID for this wireless network</span>
            </div>
            
            <div class="form-group">
                <label for="encryption">Encryption</label>
                <select class="form-control" id="encryption" name="encryption">
                    <option value="aes" selected>AES/CCMP Only</option>
                    <option value="tkip-aes">TKIP+AES</option>
                </select>
                <span class="form-hint">Encryption protocol for the wireless network</span>
            </div>
            
            <div class="form-group">
                <label>Advanced Options</label>
                <div class="checkbox-label">
                    <input type="checkbox" id="broadcast_ssid" name="broadcast_ssid" checked>
                    <label for="broadcast_ssid">Broadcast SSID</label>
                </div>
                
                <div class="checkbox-label">
                    <input type="checkbox" id="client_isolation" name="client_isolation">
                    <label for="client_isolation">Enable Client Isolation</label>
                </div>
                
                <div class="checkbox-label">
                    <input type="checkbox" id="enable_accounting" name="enable_accounting" checked>
                    <label for="enable_accounting">Enable RADIUS Accounting</label>
                </div>
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                
                <div class="checkbox-label">
                    <input type="checkbox" id="enable_fast_roaming" name="enable_fast_roaming" checked>
                    <label for="enable_fast_roaming">Enable Fast Roaming (802.11r)</label>
                </div>
                
                <div class="checkbox-label">
                    <input type="checkbox" id="enable_band_steering" name="enable_band_steering">
                    <label for="enable_band_steering">Enable Band Steering</label>
                </div>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-primary" id="generate-config-btn">Generate Configuration</button>
                <button type="button" class="btn btn-light" id="reset-form-btn">Reset</button>
                <button type="button" class="btn btn-secondary" id="save-template-btn">Save as Template</button>
                <button type="button" class="btn btn-primary" id="ai-assist-btn">
                    <i class="fas fa-robot"></i> AI Assistant
                </button>
            </div>
        </form>
    `;
}

/**
 * Initialize template-specific elements
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 */
function initTemplateElements(vendorId, platform) {
    // Example: For wireless templates, toggle authentication options based on selected auth method
    if (platform === 'wireless') {
        const authMethodSelect = document.getElementById('auth_method');
        const enterpriseAuthOptions = document.getElementById('enterprise-auth-options');
        const pskAuthOptions = document.getElementById('psk-auth-options');
        
        if (authMethodSelect && enterpriseAuthOptions && pskAuthOptions) {
            authMethodSelect.addEventListener('change', function() {
                const method = this.value;
                
                if (method.includes('enterprise')) {
                    enterpriseAuthOptions.style.display = 'block';
                    pskAuthOptions.style.display = 'none';
                } else if (method.includes('psk')) {
                    enterpriseAuthOptions.style.display = 'none';
                    pskAuthOptions.style.display = 'block';
                } else {
                    enterpriseAuthOptions.style.display = 'none';
                    pskAuthOptions.style.display = 'none';
                }
            });
        }
    }
    
    // Add more vendor-specific initializations as needed
}

/**
 * Generate vendor-specific configuration
 * @param {String} vendorId - Vendor identifier
 * @param {String} platform - 'wired' or 'wireless'
 * @param {Object} formValues - Form values
 * @returns {String} - Generated configuration
 */
function generateVendorConfig(vendorId, platform, formValues) {
    // Determine which generator to use
    let generator;
    
    if (platform === 'wired') {
        // Check if a vendor-specific generator exists
        if (typeof window[`generate${capitalize(vendorId)}Config`] === 'function') {
            generator = window[`generate${capitalize(vendorId)}Config`];
        } else {
            // Use default generator
            generator = generateDefaultWiredConfig;
        }
    } else {
        // Check if a vendor-specific generator exists
        if (typeof window[`generate${capitalize(vendorId)}WirelessConfig`] === 'function') {
            generator = window[`generate${capitalize(vendorId)}WirelessConfig`];
        } else {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            // Use default generator
            generator = generateDefaultWirelessConfig;
        }
    }
    
    // Generate the configuration
    return generator(vendorId, formValues);
}

/**
 * Generate default wired configuration
 * @param {String} vendorId - Vendor identifier
 * @param {Object} formValues - Form values
 * @returns {String} - Generated configuration
 */
function generateDefaultWiredConfig(vendorId, formValues) {
    // Get vendor info
    const vendor = vendorData.wired.find(v => v.id === vendorId);
    
    if (!vendor) {
        return `# Error: Vendor information not found for ${vendorId}.`;
    }
    
    // Basic configuration template with vendor adaptations
    let config = '';
    
    // Header
    config += `# ${vendor.name} 802.1X Configuration\n`;
    config += `# Generated by Dot1Xer Supreme on ${new Date().toLocaleString()}\n\n`;
    
    // Vendor-specific configuration
    switch (vendorId) {
        case 'cisco':
            config += generateCiscoWiredConfig(formValues);
            break;
        case 'aruba':
            config += generateArubaWiredConfig(formValues);
            break;
        case 'juniper':
            config += generateJuniperWiredConfig(formValues);
            break;
        case 'hp':
            config += generateHPWiredConfig(formValues);
            break;
        default:
            // Generic configuration as fallback
            config += `# This is a generic template. For specific syntax, please consult vendor documentation.\n\n`;
            config += `# RADIUS Server Configuration\n`;
            config += `radius-server host ${formValues.primary_radius} auth-port ${formValues.radius_auth_port} acct-port ${formValues.radius_acct_port} key ${formValues.radius_secret}\n`;
            
            if (formValues.secondary_radius) {
                config += `radius-server host ${formValues.secondary_radius} auth-port ${formValues.radius_auth_port} acct-port ${formValues.radius_acct_port} key ${formValues.radius_secret}\n`;
            }
            
            config += `\n# 802.1X Global Configuration\n`;
            config += `aaa authentication dot1x default group radius\n`;
            config += `aaa authorization network default group radius\n`;
            
            if (formValues.enable_accounting) {
                config += `aaa accounting dot1x default start-stop group radius\n`;
            }
            
            config += `\n# Interface Configuration (${formValues.port_range || 'all interfaces'})\n`;
            config += `interface range ${formValues.port_range || 'all'}\n`;
            config += `  dot1x port-control auto\n`;
            
            if (formValues.auth_method === 'dot1x_mab') {
                config += `  mab\n`;
            }
            
            if (formValues.enable_reauth) {
                config += `  dot1x timeout re-authperiod ${formValues.reauth_timer}\n`;
                config += `  dot1x re-authentication\n`;
            }
            
            if (formValues.guest_vlan) {
                config += `  dot1x guest-vlan ${formValues.guest_vlan}\n`;
            }
            
            if (formValues.auth_fail_vlan) {
                config += `  dot1x auth-fail vlan ${formValues.auth_fail_vlan}\n`;
            }
            
            if (formValues.critical_vlan) {
                config += `  dot1x critical vlan ${formValues.critical_vlan}\n`;
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            }
            
            config += `  end\n`;
    }
    
    return config;
}

/**
 * Generate default wireless configuration
 * @param {String} vendorId - Vendor identifier
 * @param {Object} formValues - Form values
 * @returns {String} - Generated configuration
 */
function generateDefaultWirelessConfig(vendorId, formValues) {
    // Get vendor info
    const vendor = vendorData.wireless.find(v => v.id === vendorId);
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    if (!vendor) {
        return `# Error: Vendor information not found for ${vendorId}.`;
    }
    
    // Basic configuration template with vendor adaptations
    let config = '';
    
    // Header
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    config += `# ${vendor.name} Wireless 802.1X Configuration\n`;
    config += `# Generated by Dot1Xer Supreme on ${new Date().toLocaleString()}\n\n`;
    
    // Vendor-specific configuration
    switch (vendorId) {
        case 'cisco-wlc':
            config += generateCiscoWirelessConfig(formValues);
            break;
        case 'aruba-mobility':
            config += generateArubaWirelessConfig(formValues);
            break;
        case 'meraki':
            config += generateMerakiWirelessConfig(formValues);
            break;
        default:
            // Generic configuration as fallback
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            config += `# This is a generic template. For specific syntax, please consult vendor documentation.\n\n`;
            config += `# WLAN Configuration\n`;
            config += `wlan create ${formValues.ssid_name} ${formValues.vlan_id}\n`;
            config += `wlan enable ${formValues.ssid_name}\n`;
            
            if (formValues.broadcast_ssid) {
                config += `wlan broadcast-ssid enable ${formValues.ssid_name}\n`;
            } else {
                config += `wlan broadcast-ssid disable ${formValues.ssid_name}\n`;
            }
            
            // Authentication settings
            config += `\n# Authentication Configuration\n`;
            
            if (formValues.auth_method === 'wpa2-enterprise' || formValues.auth_method === 'wpa3-enterprise') {
                config += `wlan security wpa type enterprise ${formValues.ssid_name}\n`;
                config += `wlan security encryption ${formValues.encryption} ${formValues.ssid_name}\n`;
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                
                config += `\n# RADIUS Configuration\n`;
                config += `radius server add ${formValues.primary_radius} ${formValues.radius_auth_port} ${formValues.radius_acct_port} ${formValues.radius_secret}\n`;
                
                if (formValues.secondary_radius) {
                    config += `radius server add ${formValues.secondary_radius} ${formValues.radius_auth_port} ${formValues.radius_acct_port} ${formValues.radius_secret}\n`;
                }
                
                if (formValues.enable_accounting) {
                    config += `radius accounting enable\n`;
                }
            } else if (formValues.auth_method === 'wpa2-psk' || formValues.auth_method === 'wpa3-psk') {
                config += `wlan security wpa type personal ${formValues.ssid_name}\n`;
                config += `wlan security encryption ${formValues.encryption} ${formValues.ssid_name}\n`;
                config += `wlan security wpa passphrase ${formValues.wpa_passphrase} ${formValues.ssid_name}\n`;
            } else {
                config += `wlan security none ${formValues.ssid_name}\n`;
            }
            
            // Advanced options
            config += `\n# Advanced Options\n`;
            
            if (formValues.client_isolation) {
                config += `wlan client-isolation enable ${formValues.ssid_name}\n`;
            }
            
            if (formValues.enable_fast_roaming) {
                config += `wlan fast-roaming enable ${formValues.ssid_name}\n`;
            }
            
            if (formValues.enable_band_steering) {
                config += `wlan band-steering enable ${formValues.ssid_name}\n`;
            }
    }
    
    return config;
}

/**
 * Capitalize first letter of a string
 * @param {String} string - Input string
 * @returns {String} - Capitalized string
 */
function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}
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
                showProviderConnectionForm(providerName);
            });
        }
    });
}

/**
 * Check for stored AI provider connections
 */
function checkStoredConnections() {
    // Check localStorage for stored connections
    const storedConnections = localStorage.getItem('dot1xer_ai_connections');
    
    if (storedConnections) {
        const connections = JSON.parse(storedConnections);
        
        // Update provider status
        for (const provider in connections) {
            if (connections[provider].connected) {
                updateProviderStatus(provider, true, connections[provider].model);
            }
        }
    }
}

/**
 * Show connection form for the selected AI provider
 * @param {String} provider - Provider name
 */
function showProviderConnectionForm(provider) {
    // Create modal with provider-specific form
    const modalId = `${provider}-connection-modal`;
    let modalHTML = `
        <div class="modal active" id="${modalId}">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Connect to ${capitalize(provider)}</h3>
                    <button class="modal-close" id="${modalId}-close">&times;</button>
                </div>
                <div class="modal-body">
    `;
    
    // Provider-specific form fields
    switch (provider) {
        case 'openai':
            modalHTML += `
                <div class="form-group">
                    <label for="openai-api-key">API Key</label>
                    <input type="password" id="openai-api-key" class="form-control" placeholder="sk-...">
                    <span class="form-hint">Your OpenAI API key</span>
                </div>
                
                <div class="form-group">
                    <label for="openai-model">Model</label>
                    <select id="openai-model" class="form-control">
                        <option value="gpt-4o">GPT-4o</option>
                        <option value="gpt-4-turbo">GPT-4 Turbo</option>
                        <option value="gpt-3.5-turbo">GPT-3.5 Turbo</option>
                    </select>
                </div>
            `;
            break;
            
        case 'claude':
            modalHTML += `
                <div class="form-group">
                    <label for="claude-api-key">API Key</label>
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                    <input type="password" id="claude-api-key" class="form-control" placeholder="sk-ant-...">
                    <span class="form-hint">Your Anthropic API key</span>
                </div>
                
                <div class="form-group">
                    <label for="claude-model">Model</label>
                    <select id="claude-model" class="form-control">
                        <option value="claude-3-opus">Claude 3 Opus</option>
                        <option value="claude-3-sonnet">Claude 3 Sonnet</option>
                        <option value="claude-3-haiku">Claude 3 Haiku</option>
                    </select>
                </div>
            `;
            break;
            
        case 'aws':
            modalHTML += `
                <div class="form-group">
                    <label for="aws-access-key">AWS Access Key</label>
                    <input type="text" id="aws-access-key" class="form-control">
                </div>
                
                <div class="form-group">
                    <label for="aws-secret-key">AWS Secret Key</label>
                    <input type="password" id="aws-secret-key" class="form-control">
                </div>
                
                <div class="form-group">
                    <label for="aws-region">AWS Region</label>
                    <select id="aws-region" class="form-control">
                        <option value="us-east-1">US East (N. Virginia)</option>
                        <option value="us-west-2">US West (Oregon)</option>
                        <option value="eu-west-1">EU (Ireland)</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="bedrock-model">Model</label>
                    <select id="bedrock-model" class="form-control">
                        <option value="anthropic.claude-3-sonnet">Claude 3 Sonnet</option>
                        <option value="amazon.titan">Amazon Titan</option>
                        <option value="meta.llama2">Meta Llama 2</option>
                    </select>
                </div>
            `;
            break;
            
        case 'azure':
            modalHTML += `
                <div class="form-group">
                    <label for="azure-endpoint">Azure OpenAI Endpoint</label>
                    <input type="text" id="azure-endpoint" class="form-control" placeholder="https://*.openai.azure.com">
                </div>
                
                <div class="form-group">
                    <label for="azure-api-key">API Key</label>
                    <input type="password" id="azure-api-key" class="form-control">
                </div>
                
                <div class="form-group">
                    <label for="azure-deployment">Deployment Name</label>
                    <input type="text" id="azure-deployment" class="form-control">
                </div>
            `;
            break;
            
        default:
            modalHTML += `<p>Connection form for ${provider} is not available.</p>`;
    }
    
    // Add remember checkbox and buttons
    modalHTML += `
                <div class="form-group">
                    <div class="checkbox-label">
                        <input type="checkbox" id="${provider}-remember" checked>
                        <label for="${provider}-remember">Remember connection</label>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-light" id="${modalId}-cancel">Cancel</button>
                <button class="btn btn-primary" id="${modalId}-connect">Connect</button>
            </div>
        </div>
    </div>
    `;
    
    // Add modal to the DOM
    const modalContainer = document.createElement('div');
    modalContainer.innerHTML = modalHTML;
    document.body.appendChild(modalContainer);
    
    // Set up event listeners
    const modal = document.getElementById(modalId);
    const closeBtn = document.getElementById(`${modalId}-close`);
    const cancelBtn = document.getElementById(`${modalId}-cancel`);
    const connectBtn = document.getElementById(`${modalId}-connect`);
    
    closeBtn.addEventListener('click', () => {
        document.body.removeChild(modalContainer);
    });
    
    cancelBtn.addEventListener('click', () => {
        document.body.removeChild(modalContainer);
    });
    
    connectBtn.addEventListener('click', () => {
        connectToProvider(provider, modal);
        document.body.removeChild(modalContainer);
    });
}

/**
 * Connect to the selected AI provider
 * @param {String} provider - Provider name
 * @param {HTMLElement} modal - Modal element containing form
 */
function connectToProvider(provider, modal) {
    switch (provider) {
        case 'openai':
            const openaiApiKey = document.getElementById('openai-api-key').value;
            const openaiModel = document.getElementById('openai-model').value;
            const openaiRemember = document.getElementById('openai-remember').checked;
            
            if (!openaiApiKey) {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
                alert('Please enter an API key');
                return;
            }
            
            // Connect to OpenAI (in a real app, validate the key)
            aiProviders.openai.connected = true;
            aiProviders.openai.token = openaiApiKey;
            aiProviders.openai.model = openaiModel;
            
            // Store connection if remember is checked
            if (openaiRemember) {
                storeConnection('openai', openaiModel);
            }
            
            // Update UI to show connected status
            updateProviderStatus('openai', true, openaiModel);
            
            // Initialize AI assistant
            initAIAssistant('openai');
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            break;
            
        case 'claude':
            const claudeApiKey = document.getElementById('claude-api-key').value;
            const claudeModel = document.getElementById('claude-model').value;
            const claudeRemember = document.getElementById('claude-remember').checked;
            
            if (!claudeApiKey) {
                alert('Please enter an API key');
                return;
            }
            
            // Connect to Claude
            aiProviders.claude.connected = true;
            aiProviders.claude.token = claudeApiKey;
            aiProviders.claude.model = claudeModel;
            
            // Store connection if remember is checked
            if (claudeRemember) {
                storeConnection('claude', claudeModel);
            }
            
            // Update UI to show connected status
            updateProviderStatus('claude', true, claudeModel);
            
            // Initialize AI assistant
            initAIAssistant('claude');
            break;
            
        case 'aws':
            const awsAccessKey = document.getElementById('aws-access-key').value;
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            const awsSecretKey = document.getElementById('aws-secret-key').value;
            const awsRegion = document.getElementById('aws-region').value;
            const bedrockModel = document.getElementById('bedrock-model').value;
            const awsRemember = document.getElementById('aws-remember').checked;
            
            if (!awsAccessKey || !awsSecretKey) {
                alert('Please enter AWS credentials');
                return;
            }
            
            // Connect to AWS Bedrock
            aiProviders.bedrock.connected = true;
            aiProviders.bedrock.credentials = {
                accessKey: awsAccessKey,
                secretKey: awsSecretKey,
                region: awsRegion
            };
            aiProviders.bedrock.model = bedrockModel;
            
            // Store connection if remember is checked
            if (awsRemember) {
                storeConnection('bedrock', bedrockModel);
            }
            
            // Update UI to show connected status
            updateProviderStatus('aws', true, bedrockModel);
            
            // Initialize AI assistant
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
            initAIAssistant('bedrock');
            break;
            
        case 'azure':
            const azureEndpoint = document.getElementById('azure-endpoint').value;
            const azureApiKey = document.getElementById('azure-api-key').value;
            const azureDeployment = document.getElementById('azure-deployment').value;
            const azureRemember = document.getElementById('azure-remember').checked;
            
            if (!azureEndpoint || !azureApiKey || !azureDeployment) {
                alert('Please enter all Azure OpenAI credentials');
                return;
            }
            
            // Connect to Azure OpenAI
            aiProviders.azure.connected = true;
            aiProviders.azure.credentials = {
                endpoint: azureEndpoint,
                apiKey: azureApiKey,
                deployment: azureDeployment
            };
            aiProviders.azure.model = azureDeployment;
            
            // Store connection if remember is checked
            if (azureRemember) {
                storeConnection('azure', azureDeployment);
            }
            
            // Update UI to show connected status
            updateProviderStatus('azure', true, azureDeployment);
            
            // Initialize AI assistant
            initAIAssistant('azure');
            break;
    }
}

/**
 * Store provider connection in localStorage
 * @param {String} provider - Provider name
 * @param {String} model - Selected model
 */
function storeConnection(provider, model) {
    // Get existing connections
    const storedConnections = localStorage.getItem('dot1xer_ai_connections') || '{}';
    const connections = JSON.parse(storedConnections);
    
    // Update with new connection
    connections[provider] = {
        connected: true,
        model: model,
        timestamp: new Date().toISOString()
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    };
    
    // Save back to localStorage
    localStorage.setItem('dot1xer_ai_connections', JSON.stringify(connections));
}

/**
 * Update provider status in the UI
 * @param {String} provider - Provider name
 * @param {Boolean} connected - Connection status
 * @param {String} model - Connected model
 */
function updateProviderStatus(provider, connected, model) {
    // Find the provider card
    let card;
    if (provider === 'bedrock') {
        card = document.querySelector('.ai-provider-card .ai-provider-name:contains("AWS Bedrock")').closest('.ai-provider-card');
    } else {
        card = document.querySelector(`.ai-provider-card .ai-provider-name:contains("${capitalize(provider)}")`).closest('.ai-provider-card');
    }
    
    if (!card) return;
    
    // Update status display
    const statusElement = card.querySelector('.ai-status');
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    const actionButton = card.querySelector('.ai-provider-action');
    
    if (connected) {
        statusElement.className = 'ai-status ai-status-connected';
        statusElement.innerHTML = `<span class="ai-status-dot"></span><span>Connected (${model})</span>`;
        actionButton.textContent = 'Disconnect';
        actionButton.setAttribute('data-action', 'disconnect');
        card.classList.add('active');
    } else {
        statusElement.className = 'ai-status ai-status-disconnected';
        statusElement.innerHTML = '<span class="ai-status-dot"></span><span>Disconnected</span>';
        actionButton.textContent = 'Connect';
        actionButton.setAttribute('data-action', 'connect');
        card.classList.remove('active');
    }
}

EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
/**
 * Initialize AI assistant interface
 * @param {String} provider - Provider name
 */
function initAIAssistant(provider) {
    // Show the AI assistant container
    const assistantContainer = document.getElementById('ai-assistant-container');
    if (assistantContainer) {
        assistantContainer.style.display = 'block';
    }
    
    // Initialize message sending
    const sendButton = document.getElementById('ai-send-btn');
    const input = document.getElementById('ai-input');
    
    if (sendButton && input) {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        // Remove any existing event listeners
        sendButton.removeEventListener('click', sendAIMessage);
        
        // Add event listener for sending messages
        sendButton.addEventListener('click', sendAIMessage);
        
        // Add keypress event for Enter key
        input.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendAIMessage();
            }
        });
    }
}

/**
 * Send message to AI assistant
 */
function sendAIMessage() {
    const input = document.getElementById('ai-input');
    const message = input.value.trim();
    
    if (!message) return;
    
    // Clear input
    input.value = '';
    
    // Add user message to chat
    addMessageToChat('user', message);
    
    // Get active provider
    const activeProvider = getActiveProvider();
    
    if (!activeProvider) {
        addMessageToChat('ai', 'No AI provider is connected. Please connect to an AI provider first.');
        return;
    }
    
    // Add thinking indicator
    const chatContainer = document.getElementById('ai-chat-messages');
    const thinkingMsg = document.createElement('div');
    thinkingMsg.id = 'ai-thinking';
    thinkingMsg.className = 'ai-message';
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    thinkingMsg.innerHTML = `
        <div class="ai-message-avatar">
            <i class="fas fa-robot"></i>
        </div>
        <div class="ai-message-content">
            <p class="ai-message-text">Thinking...</p>
        </div>
    `;
    chatContainer.appendChild(thinkingMsg);
    chatContainer.scrollTop = chatContainer.scrollHeight;
    
    // In a real application, we would send the message to the AI provider's API
    // For this demo, we'll simulate a response
    setTimeout(() => {
        // Remove thinking indicator
        document.getElementById('ai-thinking').remove();
        
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        // Generate a demo response based on the message
        let aiResponse = generateDemoAIResponse(message, activeProvider);
        
        // Add AI response to chat
        addMessageToChat('ai', aiResponse);
    }, 1500);
}

EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
/**
 * Add message to chat interface
 * @param {String} sender - 'user' or 'ai'
 * @param {String} message - Message text
 */
function addMessageToChat(sender, message) {
    const chatContainer = document.getElementById('ai-chat-messages');
    
    if (!chatContainer) return;
    
    const messageElement = document.createElement('div');
    messageElement.className = `ai-message${sender === 'user' ? ' ai-message-user' : ''}`;
    
    let avatarContent = sender === 'user' ? 
        '<div class="ai-message-avatar"><i class="fas fa-user"></i></div>' :
        '<div class="ai-message-avatar"><i class="fas fa-robot"></i></div>';
    
    messageElement.innerHTML = `
        ${avatarContent}
        <div class="ai-message-content">
            <p class="ai-message-text">${message}</p>
            <div class="ai-message-time">${new Date().toLocaleTimeString()}</div>
        </div>
    `;
    
    chatContainer.appendChild(messageElement);
    chatContainer.scrollTop = chatContainer.scrollHeight;
}

/**
 * Get the currently active AI provider
 * @returns {Object|null} - Provider details or null if none active
 */
function getActiveProvider() {
    if (aiProviders.openai.connected) {
        return { name: 'openai', model: aiProviders.openai.model };
    } else if (aiProviders.claude.connected) {
        return { name: 'claude', model: aiProviders.claude.model };
    } else if (aiProviders.bedrock.connected) {
        return { name: 'bedrock', model: aiProviders.bedrock.model };
    } else if (aiProviders.azure.connected) {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        return { name: 'azure', model: aiProviders.azure.model };
    }
    
    return null;
}

/**
 * Generate a demo AI response for testing
 * @param {String} message - User message
 * @param {Object} provider - Provider details
 * @returns {String} - AI response
 */
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
function generateDemoAIResponse(message, provider) {
    // Simple demo response logic
    if (message.toLowerCase().includes('802.1x')) {
        return `I can help with 802.1X configuration! 802.1X is a network access control standard that provides authentication to devices connected to a port. Let me know which specific vendor you're working with.`;
    } else if (message.toLowerCase().includes('cisco')) {
        return `For Cisco switches, the basic 802.1X configuration involves:<br><br>1. Configure RADIUS server(s)<br>2. Enable AAA<br>3. Configure 802.1X globally<br>4. Configure 802.1X on interfaces<br><br>Would you like me to provide a detailed configuration example?`;
    } else if (message.toLowerCase().includes('aruba')) {
        return `Aruba switches use a slightly different approach for 802.1X. On ArubaOS-CX, you would:<br><br>1. Configure RADIUS server(s)<br>2. Create an AAA authentication group<br>3. Configure 802.1X globally<br>4. Apply to interfaces<br><br>I can provide specific commands if needed.`;
    } else if (message.toLowerCase().includes('help')) {
        return `I'm your 802.1X configuration assistant! I can help with:<br><br>- Generating device configurations<br>- Troubleshooting authentication issues<br>- Explaining 802.1X concepts<br>- Providing vendor-specific guidance<br>- Suggesting best practices<br><br>What would you like to know?`;
    } else {
        return `I'm using the ${provider.model} model. How can I assist with your 802.1X deployment today? I can help with configuration templates, troubleshooting, or best practices.`;
    }
}

/**
 * Show AI assistant with context for configuration help
 * @param {Object} context - Context information
 */
function showAIAssistant(context) {
    // Check if any AI provider is connected
    const activeProvider = getActiveProvider();
    
    if (!activeProvider) {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
        alert('Please connect to an AI provider first.');
        return;
    }
    
    // Show the AI assistant container
    const assistantContainer = document.getElementById('ai-assistant-container');
    if (assistantContainer) {
        assistantContainer.style.display = 'block';
    }
    
    // Generate a context-aware message
    let contextMessage = `I need help configuring 802.1X on a ${context.vendor.name} ${context.platform === 'wired' ? 'switch' : 'wireless controller'}.`;
    
    // Add form values to the context
    if (context.formValues) {
        contextMessage += ` I'm using ${context.formValues.primary_radius} as my RADIUS server.`;
    }
    
    // Set the input value
    const input = document.getElementById('ai-input');
    if (input) {
        input.value = contextMessage;
    }
}
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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
    // Set up connect button
    const connectButton = document.getElementById('portnox-connect-btn');
    if (connectButton) {
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
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
 /**
 * Connect to Portnox Cloud
 */
function connectToPortnox() {
    // Get form values
    const tenant = document.getElementById('portnox-tenant').value;
    const apiKey = document.getElementById('portnox-api-key').value;
    const apiSecret = document.getElementById('portnox-api-secret').value;
    const remember = document.getElementById('portnox-remember').checked;
    
    // Validate inputs
    if (!tenant || !apiKey || !apiSecret) {
        alert('Please fill in all Portnox connection details.');
        return;
    }
    
    // In a real app, we would validate the connection with Portnox API
    // For this demo, we'll simulate a successful connection
    portnoxConnection = {
        connected: true,
        tenant: tenant,
        apiKey: apiKey,
        apiSecret: apiSecret
    };
    
    // Store connection if remember is checked
    if (remember) {
        storePortnoxConnection(portnoxConnection);
    }
    
    // Update UI to show connected status
    updatePortnoxStatus(true);
    
    // Hide connection form
    document.getElementById('portnox-connection-form').style.display = 'none';
    
    // Show connected view
    document.getElementById('portnox-connected-view').style.display = 'block';
    
    // Load demo data
    loadPortnoxDemoData();
}

/**
 * Store Portnox connection in localStorage
 * @param {Object} connection - Connection details
 */
function storePortnoxConnection(connection) {
    const connectionData = {
        connected: true,
        tenant: connection.tenant,
        // Don't store sensitive data in localStorage in a real app
        hasStoredCredentials: true,
        timestamp: new Date().toISOString()
    };
    
    localStorage.setItem('dot1xer_portnox_connection', JSON.stringify(connectionData));
}

/**
 * Check for stored Portnox connection
 */
function checkStoredPortnoxConnection() {
    const storedConnection = localStorage.getItem('dot1xer_portnox_connection');
    
    if (storedConnection) {
        const connection = JSON.parse(storedConnection);
        
        if (connection.connected) {
            // In a real app, we would prompt for credentials again
            // or use a more secure storage method
            
            // Update UI to show connected status
            updatePortnoxStatus(true);
            
            // Show connected view
            document.getElementById('portnox-connection-form').style.display = 'none';
            document.getElementById('portnox-connected-view').style.display = 'block';
            
            // Load demo data
            loadPortnoxDemoData();
        }
    }
}

/**
 * Update Portnox status in the UI
 * @param {Boolean} connected - Connection status
 */
function updatePortnoxStatus(connected) {
    const statusElement = document.querySelector('.portnox-status');
    const statusIcon = statusElement.querySelector('.portnox-status-icon i');
    const statusTitle = statusElement.querySelector('.portnox-status-title');
    const statusMessage = statusElement.querySelector('.portnox-status-message');
    const statusAction = statusElement.querySelector('.portnox-status-action button');
    
    if (connected) {
        statusElement.className = 'portnox-status portnox-status-connected';
        statusIcon.className = 'fas fa-check';
        statusTitle.textContent = 'Connected';
        statusMessage.textContent = `Connected to ${portnoxConnection.tenant}`;
        statusAction.textContent = 'Disconnect';
        statusAction.onclick = disconnectFromPortnox;
    } else {
        statusElement.className = 'portnox-status portnox-status-disconnected';
        statusIcon.className = 'fas fa-times';
        statusTitle.textContent = 'Disconnected';
        statusMessage.textContent = 'Connect to your Portnox Cloud account to enable synchronization and deployment.';
        statusAction.textContent = 'Connect';
        statusAction.onclick = showPortnoxConnectionForm;
    }
}

/**
 * Disconnect from Portnox Cloud
 */
function disconnectFromPortnox() {
    // Reset connection state
    portnoxConnection = {
        connected: false,
        tenant: null,
        apiKey: null,
        apiSecret: null
    };
    
EOF

cat > "$DEPLOY_DIR/js/temp_js_file.js" << 'EOF'
    // Remove stored connection
    localStorage.removeItem('dot1xer_portnox_connection');
    
    // Update UI to show disconnected status
    updatePortnoxStatus(false);
    
    // Hide connected view
    document.getElementById('portnox-connected-view').style.display = 'none';
    
    // Show connection form
    document.getElementById('portnox-connection-form').style.display = 'block';
}

/**
 * Load Portnox demo data
 */
function loadPortnoxDemoData() {
    // Demo devices data
    const demoDevices = [
        { status: 'active', name: 'SW-CORE-01', ip: '192.168.1.1', type: 'Switch', vendor: 'Cisco', lastSync: '2025-04-04 10:23:15' },
        { status: 'active', name: 'SW-ACCESS-12', ip: '192.168.1.12', type: 'Switch', vendor: 'HP', lastSync: '2025-04-04 10:23:18' },
        { status: 'active', name: 'SW-ACCESS-14', ip: '192.168.1.14', type: 'Switch', vendor: 'Juniper', lastSync: '2025-04-04 10:23:22' },
        { status: 'inactive', name: 'SW-OLD-05', ip: '192.168.1.5', type: 'Switch', vendor: 'Cisco', lastSync: '2025-04-01 08:45:30' },
        { status: 'pending', name: 'SW-NEW-20', ip: '192.168.1.20', type: 'Switch', vendor: 'Aruba', lastSync: 'Never' }
    ];
    
    // Demo policies data
    const demoPolicies = [
        { 
            name: 'Corporate Access',
            status: 'active',
            description: 'Standard 802.1X policy for corporate devices',
            details: {
                'Authentication': '802.1X (EAP-TLS)',
                'VLAN': '10 (Corporate)',
                'Fallback': 'MAB',
                'Guest Access': 'Disabled'
            }
        },
        { 
            name: 'Guest Access',
            status: 'active',
            description: 'Limited access policy for guest devices',
            details: {
                'Authentication': 'Web Authentication',
                'VLAN': '20 (Guest)',
                'Session Timeout': '12 hours',
                'Bandwidth': 'Limited (5Mbps)'
            }
        },
        { 
            name: 'IoT Devices',
            status: 'draft',
            description: 'Specialized policy for IoT devices with MAC authentication',
            details: {
                'Authentication': 'MAB',
                'VLAN': '30 (IoT)',
                'ACLs': 'Restricted',
                'Monitoring': 'Enhanced'
            }
        }
    ];
    
    // Populate devices table
    const devicesBody = document.getElementById('portnox-devices-body');
    devicesBody.innerHTML = '';
    
    demoDevices.forEach(device => {
        const row = document.createElement('tr');
        
        // Status cell with icon
        const statusCell = document.createElement('td');
        statusCell.className = `portnox-device-${device.status}`;
        statusCell.innerHTML = `<span class="portnox-device-status"></span>${device.status}`;
        row.appendChild(statusCell);
        
        // Other cells
        row.appendChild(createPortnoxCell(device.name));
        row.appendChild(createPortnoxCell(device.ip));
        row.appendChild(createPortnoxCell(device.type));
        row.appendChild(createPortnoxCell(device.vendor));
        row.appendChild(createPortnoxCell(device.lastSync));
        
        // Actions cell
        const actionsCell = document.createElement('td');
        actionsCell.className = 'portnox-device-actions';
        actionsCell.innerHTML = `
            <button class="portnox-device-action portnox-action-view">View</button>
            <button class="portnox-device-action portnox-action-edit">Edit</button>
        `;
        row.appendChild(actionsCell);
        
        devicesBody.appendChild(row);
    });
    
    // Populate policies container
    const policiesContainer = document.getElementById('portnox-policies-container');
    policiesContainer.innerHTML = '';
    
    demoPolicies.forEach(policy => {
        const policyCard = document.createElement('div');
        policyCard.className = 'portnox-policy-card';
        
        // Policy header
        const policyHeader = document.createElement('div');
        policyHeader.className = 'portnox-policy-header';
        policyHeader.innerHTML = `
            <h4 class="portnox-policy-name">${policy.name}</h4>
            <span class="portnox-policy-status portnox-policy-${policy.status}">${policy.status}</span>
        `;
        policyCard.appendChild(policyHeader);
        
        // Policy body
        const policyBody = document.createElement('div');
        policyBody.className = 'portnox-policy-body';
        
        // Policy description
        const policyDescription = document.createElement('p');
        policyDescription.className = 'portnox-policy-description';
        policyDescription.textContent = policy.description;
        policyBody.appendChild(policyDescription);
        
        // Policy details
        const policyDetails = document.createElement('div');
        policyDetails.className = 'portnox-policy-details';
        
        // Add policy detail items
        for (const [key, value] of Object.entries(policy.details)) {
            const detailItem = document.createElement('div');
            detailItem.className = 'portnox-policy-detail';
            detailItem.innerHTML = `
                <span class="portnox-policy-label">${key}:</span>
                <span class="portnox-policy-value">${value}</span>
            `;
            policyDetails.appendChild(detailItem);
        }
        
        policyBody.appendChild(policyDetails);
        policyCard.appendChild(policyBody);
        
        // Policy footer
        const policyFooter = document.createElement('div');
        policyFooter.className = 'portnox-policy-footer';
        policyFooter.innerHTML = `
            <button class="btn btn-light">View</button>
            <button class="btn btn-primary">Edit</button>
        `;
        policyCard.appendChild(policyFooter);
        
        policiesContainer.appendChild(policyCard);
    });
    
    // Add event listeners to device action buttons
    document.querySelectorAll('.portnox-device-action').forEach(button => {
        button.addEventListener('click', function() {
            const action = this.classList.contains('portnox-action-view') ? 'view' : 'edit';
            const deviceName = this.closest('tr').querySelector('td:nth-child(2)').textContent;
            
            alert(`${action} device: ${deviceName}`);
        });
    });
}

/**
 * Create a table cell with the given content
 * @param {String} content - Cell content
 * @returns {HTMLElement} - Table cell element
 */
function createPortnoxCell(content) {
    const cell = document.createElement('td');
    cell.textContent = content || '-';
    return cell;
}
##############################################################
# Part 6: Main Deployment Function
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
    
    # Update HTML files
    if ! update_html_files; then
        log_error "Failed to update HTML files."
        if confirm_action "Continue anyway?"; then
            log_warning "Continuing despite HTML update failures."
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
# Part 7: Script Execution
##############################################################

# Main script execution
log_message "Dot1Xer Supreme Update Script - Version 2.0.0"

# Check if help option was provided
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
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
fi

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

##############################################################
# Part 6: Additional File Update Functions
##############################################################

update_js_files() {
    log_message "Updating JavaScript files..."
    # TODO: Implement JS update logic
    log_success "JavaScript files updated."
}

update_html_files() {
    log_message "Updating HTML files..."
    # TODO: Implement HTML update logic
    log_success "HTML files updated."
}

update_template_files() {
    log_message "Updating template configuration files..."
    # TODO: Implement template update logic
    log_success "Template files updated."
}

##############################################################
# Part 7: Main Execution Flow
##############################################################

main() {
    check_dependencies || exit 1
    create_missing_dirs || exit 1
    $SKIP_BACKUP || create_backup
    download_assets || { restore_from_backup; exit 1; }
    update_css_files || { restore_from_backup; exit 1; }
    update_js_files || { restore_from_backup; exit 1; }
    update_html_files || { restore_from_backup; exit 1; }
    update_template_files || { restore_from_backup; exit 1; }
    log_success "✅ Dot1Xer Supreme update completed successfully!"
}

# Trap INT/TERM signals to handle interruptions
trap 'log_error "Script interrupted."; restore_from_backup; exit 1' INT TERM

# Run main
main "$@"