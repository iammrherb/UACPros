#!/bin/bash
# update-dot1xer-supreme-enhanced.sh
# =======================================================================
# This script updates Dot1Xer Supreme by:
#  • Backing up your current files.
#  • Removing unwanted debug output from index.html.
#  • Fixing accordion functionality in js/core.js.
#  • Copying an MP4 video as the main logo banner.
#  • Updating index.html to display the video banner.
#  • Appending necessary CSS rules.
#  • Committing and pushing changes to the Git repository.
# =======================================================================

# -------------------------------
# Color Codes for Output
# -------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'  # No Color

# -------------------------------
# Step 1: Backup Files
# -------------------------------
backup_files() {
  echo -e "${BLUE}Backing up current files...${NC}"
  timestamp=$(date +%Y%m%d%H%M%S)
  backup_dir="backup_${timestamp}"
  mkdir -p "$backup_dir"
  cp -r * "$backup_dir/" 2>/dev/null
  echo -e "${GREEN}Backup complete in directory: $backup_dir${NC}"
}

# -------------------------------
# Step 2: Remove Debug Output from index.html
# -------------------------------
fix_debug_output() {
  echo -e "${BLUE}Cleaning debug output from index.html...${NC}"
  if [ -f "index.html" ]; then
    # The script assumes that any unwanted debug output starts at the marker:
    debug_marker="# DEBUG OUTPUT START"
    if grep -q "$debug_marker" index.html; then
      marker_line=$(grep -n "$debug_marker" index.html | cut -d ':' -f 1)
      head -n $((marker_line - 1)) index.html > index_clean.tmp
      # Ensure the HTML is properly closed.
      echo "</body>" >> index_clean.tmp
      echo "</html>" >> index_clean.tmp
      mv index_clean.tmp index.html
      echo -e "${GREEN}Debug output removed from index.html.${NC}"
    else
      echo -e "${YELLOW}No debug marker found in index.html. Skipping removal.${NC}"
    fi
  else
    echo -e "${RED}index.html not found!${NC}"
  fi
}

# -------------------------------
# Step 3: Update Accordion Functionality in js/core.js
# -------------------------------
update_accordions() {
  echo -e "${BLUE}Updating accordion functionality in js/core.js...${NC}"
  if [ -f "js/core.js" ]; then
    # We'll overwrite the initAccordions function with improved logic.
    cat > js/core.js.tmp << 'EOF'
/* Improved Accordion Initialization */
function initAccordions() {
  const headers = document.querySelectorAll('.accordion-header');
  headers.forEach(header => {
    header.addEventListener("click", function() {
      const content = this.nextElementSibling;
      const icon = this.querySelector(".accordion-icon");
      // Close all other accordions
      document.querySelectorAll(".accordion-content").forEach(acc => {
        if (acc !== content) {
          acc.classList.remove("active");
          acc.style.display = "none";
          const otherHeader = acc.previousElementSibling;
          if (otherHeader) {
            otherHeader.classList.remove("active");
            const otherIcon = otherHeader.querySelector(".accordion-icon");
            if (otherIcon) otherIcon.textContent = "+";
          }
        }
      });
      // Toggle current accordion
      content.classList.toggle("active");
      this.classList.toggle("active");
      if (content.classList.contains("active")) {
        content.style.display = "block";
        if (icon) icon.textContent = "-";
      } else {
        content.style.display = "none";
        if (icon) icon.textContent = "+";
      }
    });
  });
}
EOF
    # Replace the existing initAccordions function with our new version.
    # (Assumes the function is defined in js/core.js; create a backup copy first.)
    cp js/core.js js/core.js.bak
    # Use sed to replace from the line that starts with "function initAccordions()" up to the next blank line.
    # For simplicity, we'll replace the entire file's function definition if it exists.
    if grep -q "function initAccordions()" js/core.js; then
      # Replace the function block.
      sed -i '/function initAccordions()/,/^}/d' js/core.js
      # Prepend our new version at the top of the file.
      cat js/core.js.tmp js/core.js > js/core.js.new
      mv js/core.js.new js/core.js
      echo -e "${GREEN}Accordion functionality updated in js/core.js.${NC}"
    else
      echo -e "${YELLOW}initAccordions function not found in js/core.js; please add the updated version manually.${NC}"
    fi
    rm js/core.js.tmp
  else
    echo -e "${YELLOW}js/core.js not found.${NC}"
  fi
}

# -------------------------------
# Step 4: Copy MP4 Video as Main Banner
# -------------------------------
copy_video_banner() {
  echo -e "${BLUE}Copying MP4 video as main banner...${NC}"
  mkdir -p assets/videos
  video_src="20250402_1614_Digital Nexus_simple_compose_01jqw5ph3re5cavv1svnpxcksa.mp4"
  video_dest="assets/videos/main-banner.mp4"
  if [ -f "$video_src" ]; then
    cp "$video_src" "$video_dest"
    echo -e "${GREEN}Video copied to $video_dest${NC}"
  else
    echo -e "${RED}Video file $video_src not found. Please ensure the file is in the current directory.${NC}"
  fi
}

# -------------------------------
# Step 5: Update index.html to Use the Video Banner
# -------------------------------
update_index_banner() {
  echo -e "${BLUE}Updating index.html to include the video banner...${NC}"
  if [ -f "index.html" ]; then
    # Check if there's a div with class "banner-container"
    if grep -q 'class="banner-container"' index.html; then
      # Replace its contents with our video element using sed.
      sed -i.bak '/<div class="banner-container">/,/<\/div>/c\
<div class="banner-container">\
  <video autoplay loop muted playsinline id="main-banner">\
    <source src="assets/videos/main-banner.mp4" type="video/mp4">\
    Your browser does not support the video tag.\
  </video>\
</div>' index.html
      echo -e "${GREEN}index.html updated with video banner.${NC}"
    else
      echo -e "${YELLOW}No banner-container found in index.html. Please add the following snippet manually where you want the banner:" 
      echo '<div class="banner-container">
  <video autoplay loop muted playsinline id="main-banner">
    <source src="assets/videos/main-banner.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
</div>'
    fi
  else
    echo -e "${RED}index.html not found.${NC}"
  fi
}

# -------------------------------
# Step 6: Append CSS for Video Banner (if not already present)
# -------------------------------
append_video_css() {
  echo -e "${BLUE}Appending CSS for video banner to css/styles.css...${NC}"
  if [ -f "css/styles.css" ]; then
    if ! grep -q "#main-banner" css/styles.css; then
      cat >> css/styles.css << 'EOF'

/* Video Banner Styling */
#main-banner {
  width: 100%;
  height: auto;
  max-height: 400px;
  object-fit: cover;
}
.banner-container {
  position: relative;
  overflow: hidden;
}
EOF
      echo -e "${GREEN}CSS for video banner added.${NC}"
    else
      echo -e "${YELLOW}CSS for video banner already exists in css/styles.css.${NC}"
    fi
  else
    echo -e "${YELLOW}css/styles.css not found. Please add CSS manually.${NC}"
  fi
}

# -------------------------------
# (Optional) Commit and Push Changes to Git
# -------------------------------
commit_and_push_changes() {
  echo -e "${BLUE}Staging all changes for Git...${NC}"
  git add .
  echo -e "${BLUE}Committing changes...${NC}"
  git commit -m "Enhanced UI: Clean debug output, fixed accordions, and added MP4 banner" || echo -e "${YELLOW}Nothing to commit.${NC}"
  echo -e "${BLUE}Pushing changes...${NC}"
  git push origin main || { echo -e "${RED}Push failed. Check your Git authentication settings.${NC}"; exit 1; }
  echo -e "${GREEN}Changes pushed successfully.${NC}"
}

# -------------------------------
# Main Execution
# -------------------------------
main() {
  backup_files
  fix_debug_output
  update_accordions
  copy_video_banner
  update_index_banner
  append_video_css
  
  # Uncomment the following line if you want to automatically commit and push changes.
  # commit_and_push_changes
  
  echo -e "${GREEN}Update complete! Please refresh your browser to see the changes.${NC}"
}

# Execute main
main

exit 0
