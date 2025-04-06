// Dot1Xer Supreme - Project Details Functionality

// Initialize project details toggle
function initProjectDetails() {
    const projectDetailToggle = document.getElementById('project-detail-toggle');
    const projectDetailsSection = document.getElementById('project-details-section');

    if (projectDetailToggle && projectDetailsSection) {
        projectDetailToggle.addEventListener('change', function() {
            projectDetailsSection.style.display = this.checked ? 'block' : 'none';
        });
    }

    // Add event listener for project details fields to update the header in the config
    const projectFields = document.querySelectorAll('#project-details-section input');
    projectFields.forEach(field => {
        field.addEventListener('input', function() {
            // When a project field is updated, this will trigger the config header to update
            // when generating the configuration
            const generateButton = document.getElementById('generate-btn');
            if (generateButton) {
                // Visual indicator that the project details will be included
                generateButton.textContent = projectDetailToggle.checked ?
                    'Generate Configuration with Project Details' :
                    'Generate Configuration';
            }
        });
    });
}

// Get project details as a formatted string for config
function getProjectDetailsString() {
    const includeProjectDetails = document.getElementById('project-detail-toggle')?.checked;
    if (!includeProjectDetails) return '';

    const companyName = document.getElementById('company-name')?.value || '';
    const sfdcOpportunity = document.getElementById('sfdc-opportunity')?.value || '';
    const seEmail = document.getElementById('se-email')?.value || '';
    const customerEmail = document.getElementById('customer-email')?.value || '';
    const date = new Date().toISOString().split('T')[0];

    let details = '! Project Details\n';
    if (companyName) details += `! Company: ${companyName}\n`;
    if (sfdcOpportunity) details += `! SFDC Opportunity: ${sfdcOpportunity}\n`;
    if (seEmail) details += `! SE Email: ${seEmail}\n`;
    if (customerEmail) details += `! Customer Email: ${customerEmail}\n`;
    details += `! Date Generated: ${date}\n\n`;

    return details;
}
