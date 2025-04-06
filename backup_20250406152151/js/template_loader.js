/**
 * Template loader for Dot1Xer Supreme
 * Ensures all templates including TACACS are properly loaded
 */
(function() {
    console.log("Initializing template loader...");
    
    // Templates registry
    window.templateRegistry = window.templateRegistry || {};
    
    // Track template loading
    const templateStatus = {
        requested: [],
        loaded: [],
        failed: []
    };
    
    // Load template by path
    function loadTemplateFile(path, name) {
        console.log(`Loading template: ${name} from ${path}`);
        templateStatus.requested.push(name);
        
        return new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = path;
            script.onload = function() {
                console.log(`Template loaded: ${name}`);
                templateStatus.loaded.push(name);
                resolve(name);
            };
            script.onerror = function() {
                console.error(`Failed to load template: ${name} from ${path}`);
                templateStatus.failed.push(name);
                reject(new Error(`Failed to load template: ${name}`));
            };
            document.head.appendChild(script);
        });
    }
    
    // Register template
    window.registerTemplate = function(key, template) {
        console.log(`Registering template: ${key}`);
        window.templateRegistry[key] = template;
        
        // Trigger an event to notify listeners that a template has been added
        const event = new CustomEvent('templateRegistered', { detail: { key, template } });
        document.dispatchEvent(event);
        
        return template;
    };
    
    // Get template
    window.getTemplate = function(key) {
        return window.templateRegistry[key];
    };
    
    // List all available templates
    window.listTemplates = function() {
        return Object.keys(window.templateRegistry);
    };
    
    // Get template loading status
    window.getTemplateStatus = function() {
        return {
            requested: [...templateStatus.requested],
            loaded: [...templateStatus.loaded],
            failed: [...templateStatus.failed]
        };
    };
    
    // Core templates to load immediately
    const coreTemplates = [
        // Cisco templates
        { path: "js/templates/cisco/ibns2_ios_xe.js", name: "ibns2_ios_xe" },
        { path: "js/templates/cisco/tacacs.js", name: "tacacs" },
        { path: "js/templates/cisco/radsec.js", name: "radsec" },
        { path: "js/templates/cisco/device_tracking.js", name: "device_tracking" },
        
        // Wireless templates
        { path: "js/templates/wireless/cisco/wlc_9800.js", name: "wlc_9800" },
        { path: "js/templates/wireless/aruba/aruba_wireless.js", name: "aruba_wireless" }
    ];
    
    // Load core templates
    function loadCoreTemplates() {
        console.log("Loading core templates...");
        const promises = coreTemplates.map(template => 
            loadTemplateFile(template.path, template.name)
        );
        
        return Promise.allSettled(promises).then(results => {
            const loaded = results.filter(r => r.status === 'fulfilled').length;
            console.log(`Loaded ${loaded}/${coreTemplates.length} core templates`);
            
            // Check for specific templates
            setTimeout(() => {
                // Check if TACACS template was loaded
                if (window.templateRegistry.tacacs) {
                    console.log("? TACACS template loaded successfully");
                } else {
                    console.error("? TACACS template failed to load");
                }
                
                // Check wireless templates
                if (window.templateRegistry.wlc_9800) {
                    console.log("? Wireless controller template loaded successfully");
                } else {
                    console.error("? Wireless controller template failed to load");
                }
                
                // Trigger content loaded event
                document.dispatchEvent(new CustomEvent('contentLoaded'));
            }, 500);
        });
    }
    
    // Dynamic template loading
    window.loadTemplate = function(templateId) {
        // Skip already loaded templates
        if (window.templateRegistry[templateId]) {
            console.log(`Template ${templateId} already loaded, skipping`);
            return Promise.resolve(window.templateRegistry[templateId]);
        }
        
        // Determine template path based on ID
        let templatePath = '';
        
        if (templateId.includes('wlc') || templateId.includes('wireless') || templateId.includes('aireos')) {
            // Wireless templates
            if (templateId.includes('cisco')) {
                templatePath = `js/templates/wireless/cisco/${templateId}.js`;
            } else if (templateId.includes('aruba')) {
                templatePath = `js/templates/wireless/aruba/${templateId}.js`;
            } else if (templateId.includes('fortinet')) {
                templatePath = `js/templates/wireless/fortinet/${templateId}.js`;
            } else if (templateId.includes('ruckus')) {
                templatePath = `js/templates/wireless/ruckus/${templateId}.js`;
            } else if (templateId.includes('meraki')) {
                templatePath = `js/templates/wireless/meraki/${templateId}.js`;
            } else if (templateId.includes('extreme')) {
                templatePath = `js/templates/wireless/extreme/${templateId}.js`;
            } else if (templateId.includes('unifi')) {
                templatePath = `js/templates/wireless/ubiquiti/${templateId}.js`;
            } else {
                templatePath = `js/templates/wireless/${templateId}.js`;
            }
        } else {
            // Wired templates
            if (templateId.includes('cisco')) {
                templatePath = `js/templates/cisco/${templateId}.js`;
            } else if (templateId.includes('aruba') || templateId.includes('aos')) {
                templatePath = `js/templates/aruba/${templateId}.js`;
            } else if (templateId.includes('juniper') || templateId.includes('ex')) {
                templatePath = `js/templates/juniper/${templateId}.js`;
            } else if (templateId.includes('hp') || templateId.includes('comware') || templateId.includes('procurve')) {
                templatePath = `js/templates/hpe/${templateId}.js`;
            } else if (templateId.includes('forti')) {
                templatePath = `js/templates/fortinet/${templateId}.js`;
            } else if (templateId.includes('extreme') || templateId.includes('exos')) {
                templatePath = `js/templates/extreme/${templateId}.js`;
            } else if (templateId.includes('dell')) {
                templatePath = `js/templates/dell/${templateId}.js`;
            } else {
                templatePath = `js/templates/${templateId}.js`;
            }
        }
        
        return loadTemplateFile(templatePath, templateId).then(() => {
            return window.templateRegistry[templateId];
        });
    };
    
    // Initialize on page load
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', loadCoreTemplates);
    } else {
        // If DOM is already loaded, wait a short while to ensure all content is in place
        setTimeout(loadCoreTemplates, 100);
    }
    
    // Export functions for use in other modules
    window.templateLoader = {
        loadTemplate: window.loadTemplate,
        registerTemplate: window.registerTemplate,
        getTemplate: window.getTemplate,
        listTemplates: window.listTemplates,
        getTemplateStatus: window.getTemplateStatus
    };
})();
