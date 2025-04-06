#!/bin/bash
# update-your-dot1xer.sh
# Helper script for users to update their existing Dot1Xer installation

echo "This script will update your existing Dot1Xer installation with the latest features."
echo "Please ensure you have a backup of your current installation before proceeding."
echo "Do you want to continue? (y/n)"
read -r continue

if [ "$continue" != "y" ]; then
    echo "Update cancelled."
    exit 0
fi

# Check if the current directory is a Dot1Xer installation
if [ ! -f "index.html" ] || [ ! -d "css" ] || [ ! -d "js" ]; then
    echo "This doesn't appear to be a Dot1Xer installation directory."
    echo "Please run this script from your Dot1Xer root directory."
    exit 1
fi

# Backup existing files
echo "Creating backup of existing files..."
timestamp=$(date +%Y%m%d%H%M%S)
backup_dir="backup_${timestamp}"
mkdir -p "$backup_dir"
cp -r * "$backup_dir/" 2>/dev/null
echo "Backup complete in directory: $backup_dir"

# Download latest files
echo "Downloading latest files..."
curl -s -o index.html.new https://raw.githubusercontent.com/username/dot1xer-supreme/main/index.html
curl -s -o css/styles.css.new https://raw.githubusercontent.com/username/dot1xer-supreme/main/css/styles.css
curl -s -o js/app.js.new https://raw.githubusercontent.com/username/dot1xer-supreme/main/js/app.js

# Check if downloads were successful
if [ ! -f "index.html.new" ] || [ ! -f "css/styles.css.new" ] || [ ! -f "js/app.js.new" ]; then
    echo "Failed to download update files. Please check your internet connection."
    exit 1
fi

# Apply updates
mv index.html.new index.html
mv css/styles.css.new css/styles.css
mv js/app.js.new js/app.js

# Create directory structure if needed
mkdir -p templates/portnox 2>/dev/null
mkdir -p assets/portnox 2>/dev/null

# Create Portnox logo if missing
if [ ! -f "assets/portnox/portnox-logo.svg" ]; then
    cat > assets/portnox/portnox-logo.svg << 'SVG_EOF'
<svg width="200" height="60" xmlns="http://www.w3.org/2000/svg">
  <rect width="200" height="60" fill="#6c27be" rx="5" ry="5"/>
  <text x="20" y="40" font-family="Arial" font-size="24" fill="white" font-weight="bold">PORTNOX</text>
</svg>
SVG_EOF
fi

echo "Update completed successfully!"
echo "Please refresh your browser to see the changes."
