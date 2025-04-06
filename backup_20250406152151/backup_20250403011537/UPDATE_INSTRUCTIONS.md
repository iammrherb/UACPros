# Dot1Xer Supreme Update Instructions

This document provides detailed instructions for the latest updates to Dot1Xer Supreme, including all new features and how to use them.

## New Features Overview

### 1. Project Details Integration

You can now add project details to your configurations, including:
- Company name
- SFDC opportunity number
- SE contact information
- Customer contact information

These details are included in the generated configurations and in exported files for better tracking and documentation.

### 2. Multi-Vendor Configuration

Generate configurations for multiple vendors simultaneously using the same authentication settings. This feature is perfect for:
- Multi-vendor environments
- Migration projects
- POC documentation

### 3. Enhanced RADIUS Server Management

- Add multiple RADIUS servers with individual settings
- Configure per-server authentication, accounting, and CoA ports
- Set advanced options for server testing and load balancing

### 4. Comprehensive Device Tracking

Added support for device tracking to enhance security:
- Track IPv4 and IPv6 addresses
- Configure prefix glean options
- Integrate with policy enforcement

### 5. Unlocked Navigation

All steps in the configurator are now clickable, allowing you to:
- Navigate freely between steps
- Edit settings in any order
- Review and revise configurations more efficiently

### 6. POC Integration

Integration between the configurator and POC generator:
- Include your configurations in POC documentation
- Generate vendor-specific deployment templates
- Integrate environmental discovery findings with configuration

## How to Use the New Features

### Project Details

1. Check "Include Project Details" at the top of the Configurator tab
2. Fill in the company name, SFDC opportunity, and contact information
3. Generate your configuration to include these details in the header

### Multi-Vendor Configuration

1. Check "Configure Multiple Vendors" at the top of the Configurator tab
2. Select your primary vendor and platform
3. Click "Add Current Vendor" to add it to the list
4. Repeat for additional vendors
5. Click "Generate Configuration" to create configs for all selected vendors

### Enhanced RADIUS Server Management

1. Configure your primary RADIUS server in Step 3
2. Click "Add Another RADIUS Server" for additional servers
3. Configure individual ports and settings for each server
4. Use the "RADIUS Advanced Settings" accordion for global settings

### Using Unlocked Navigation

- Click on any step in the step indicator to jump directly to that step
- Steps remain accessible in any order
- All inputs and selections are preserved when navigating between steps

## Updating From Previous Versions

If you're updating from a previous version, here's how to ensure a smooth transition:

1. Backup your existing installation:
cp -r your-dot1xer-directory your-dot1xer-backup
Copy
2. Run the update script:
./update-your-dot1xer.sh
Copy
3. Refresh your browser to see the changes

## Known Issues

- When adding multiple RADIUS servers, ensure each has a unique IP address
- For multi-vendor configurations, some vendor-specific options may not apply to all platforms
- Project details are included in configuration headers but not in file names unless downloaded

## Getting Help

If you encounter any issues with the new features, please check the Help tab or refer to the documentation at:
- https://docs.portnox.com
