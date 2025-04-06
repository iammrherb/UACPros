#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Updating index.html..."
if [ -f index.html ] && grep -q "</body></html>" index.html; then
    sed -i.bak '/<\/body><\/html>/d' index.html
    cat >> index.html << 'EOF'
    <link rel="stylesheet" href="css/main.css">
    <link rel="stylesheet" href="css/accordion.css">
    <link rel="stylesheet" href="css/help_tips.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.7.7/handlebars.min.js"></script>
    <script src="js/accordion.js"></script>
    <script src="js/template_loader.js"></script>
    <script src="js/platform_menu.js"></script>
    <script src="js/help/help_tips.js"></script>
    <script src="js/api/ai_integration.js"></script>
    <script src="js/api/portnox_api.js"></script>
    <script src="js/api/api_config_ui.js"></script>
    <div class="container">
        <header>
            <div class="container">
                <div class="logo">Dot1Xer Supreme</div>
                <nav>
                    <ul>
                        <li><a href="#platforms">Platforms</a></li>
                        <li><a href="#api-config">API Settings</a></li>
                    </ul>
                </nav>
            </div>
        </header>
        <div id="platform-menu" class="tab-container"></div>
        <div id="api-config-container" class="tab-container"></div>
        <footer>© 2025 Dot1Xer Supreme Team</footer>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initAccordions();
            initHelpTips();
            initPlatformMenu();
            createApiConfigUI();
        });
    </script>
</body></html>
EOF
    echo "index.html updated successfully."
else
    echo "Error updating index.html."
fi

echo "Run completed. Open index.html in your browser."
