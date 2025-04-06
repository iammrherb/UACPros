#!/bin/bash

# Function to remove sections from an HTML file
remove_sections() {
  local file=$1
  shift
  local sections=("$@")
  for section in "${sections[@]}"; do
    # Remove the section and its contents (assumes <div class="section_name"> structure)
    sed -i "/<div class=\"${section}\"/,/<\/div>/d" "$file"
  done
}

# Function to move API Settings to AI Integration
move_api_settings() {
  local file=$1
  # Extract the API Settings section
  local api_settings=$(sed -n '/<div class="API Settings"/,/<\/div>/p' "$file")
  # Append it after the opening of AI Integration section
  sed -i "/<div class=\"AI Integration\"/a ${api_settings}" "$file"
  # Remove the original API Settings section
  sed -i '/<div class="API Settings"/,/<\/div>/d' "$file"
}

# List of sections to remove
sections_to_remove=(
  "Dot1Xer Supreme"
  "Platforms"
  "API Settings"
  "Wired"
  "Wireless"
  "Cisco IOS/IOS-XE"
  "Select"
  "Aruba AOS-CX"
  "Juniper EX"
  "Fortinet FortiSwitch"
  "HPE Comware"
  "Extreme EXOS"
  "Dell OS10"
  "Cisco WLC 9800"
  "Aruba Controller"
  "Fortinet FortiWLC"
  "Ruckus Wireless"
  "Cisco Meraki"
  "Extreme Wireless"
  "Ubiquiti UniFi"
  "API Configuration"
  "OpenAI API Key"
  "Save"
  "Portnox API URL"
  "Portnox API Key"
)

# List of HTML files to update
html_files=("index.html" "configurator.html" "ai.html" "reference.html" "discovery.html" "help.html")

# Process each HTML file
for file in "${html_files[@]}"; do
  if [ -f "$file" ]; then
    echo "Processing $file..."
    remove_sections "$file" "${sections_to_remove[@]}"
  else
    echo "Warning: $file not found."
  fi
done

# Move API Settings to AI Integration in ai.html (assuming it’s the relevant page)
if [ -f "ai.html" ]; then
  echo "Moving API Settings to AI Integration in ai.html..."
  move_api_settings "ai.html"
else
  echo "Error: ai.html not found. Please manually move API Settings to AI Integration."
fi

echo "Update complete."