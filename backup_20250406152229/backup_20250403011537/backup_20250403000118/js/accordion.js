/**
 * Enhanced accordion functionality for Dot1Xer Supreme
 */
function initAccordions() {
    console.log("Initializing accordions...");
    const accordionHeaders = document.querySelectorAll('.accordion-header');
    
    if (accordionHeaders.length === 0) {
        console.warn("No accordion headers found on page!");
        return;
    }
    
    console.log(`Found ${accordionHeaders.length} accordion headers`);
    
    accordionHeaders.forEach((header, index) => {
        // Make sure the next element is actually the content
        const content = header.nextElementSibling;
        if (!content || !content.classList.contains('accordion-content')) {
            console.error(`Accordion header #${index} is missing proper content element!`);
            return;
        }
        
        // Ensure proper icon exists
        let icon = header.querySelector('.accordion-icon');
        if (!icon) {
            icon = document.createElement('span');
            icon.className = 'accordion-icon';
            icon.innerHTML = '+';
            header.appendChild(icon);
        }
        
        // Start with all accordions closed except the first one
        if (index === 0) {
            header.classList.add('active');
            content.classList.add('active');
            content.style.display = 'block';
            content.style.maxHeight = content.scrollHeight + 'px';
            if (icon) icon.textContent = "-"; // Unicode minus sign
        } else {
            content.style.display = 'none';
            content.style.maxHeight = null;
        }
        
        // Remove any existing click handlers to prevent duplicates
        const newHeader = header.cloneNode(true);
        header.parentNode.replaceChild(newHeader, header);
        
        // Add click event handler
        newHeader.addEventListener("click", function(e) {
            console.log(`Accordion ${index} clicked`);
            e.preventDefault(); // Prevent any default anchor behavior
            
            // Get the accordion content and icon
            const content = this.nextElementSibling;
            const icon = this.querySelector(".accordion-icon");
            
            // Toggle the current accordion
            this.classList.toggle("active");
            content.classList.toggle("active");
            
            // If the accordion is now active
            if (this.classList.contains("active")) {
                // Show content and change icon
                content.style.display = "block";
                // Force a reflow before setting maxHeight for transition to work
                void content.offsetWidth;
                content.style.maxHeight = content.scrollHeight + "px";
                if (icon) icon.textContent = "-"; // Unicode minus sign
            } else {
                // Hide content and change icon
                content.style.maxHeight = "0";
                if (icon) icon.textContent = "+";
                // Add delay to hide the element after transition
                setTimeout(() => {
                    if (!this.classList.contains("active")) {
                        content.style.display = "none";
                    }
                }, 300);
            }
        });
    });
}

// Make sure DOM is loaded before initializing
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAccordions);
} else {
    // If DOM is already loaded, wait a short while to ensure all content is in place
    setTimeout(initAccordions, 100);
}

// Add a console helper to debug accordions
window.debugAccordions = function() {
    const headers = document.querySelectorAll('.accordion-header');
    console.log(`Found ${headers.length} accordion headers`);
    headers.forEach((header, i) => {
        const content = header.nextElementSibling;
        console.log(`Accordion #${i}:`, {
            header: header,
            content: content,
            isActive: header.classList.contains('active'),
            contentDisplay: content ? content.style.display : 'N/A',
            contentMaxHeight: content ? content.style.maxHeight : 'N/A'
        });
    });
};

// Function to manually open an accordion by index
window.openAccordion = function(index) {
    const headers = document.querySelectorAll('.accordion-header');
    if (headers[index]) {
        headers[index].click();
        return true;
    }
    return false;
};
