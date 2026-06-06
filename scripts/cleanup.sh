#!/bin/bash

# Cleanup Script for Development Environment
# Removes development caches and generated build artifacts across the machine:
#   - Xcode DerivedData and Archives
#   - macOS Library Caches and Logs
#   - Android SDK intermediates, build-tools, cmake, NDK, and platforms
#   - Downloads folder entries except /save
#   - Workspace build artifacts in Build files
#   - node_modules, dist/.next, and platform build outputs for SOPHIA, METIS, BFF, CDI, SHINHAN
#   - Local dev caches: CocoaPods, Android, Sonar, ZSH sessions, Gradle, NPM, and NVM
#
# Note: This script does not remove all manual cleanup items. Also delete manually as needed:
#   - Xcode caches, unused iOS simulators, and unused iOS support files
#   - unnecessary Docker images, containers, and volumes

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define paths
XCODE_DIR="$HOME/Library/Developer/Xcode"
LIBRARY_DIR="$HOME/Library"
DOWNLOAD_DIR="$HOME/Downloads"
ANDROID_SDK_DIR="$HOME/Library/Android/sdk"
BUILD_DIR="$HOME/Desktop/WORKSPACE/Build files"
SOPHIA_DIR="$HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/SOPHIA"
METIS_DIR="$HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/METIS"
BFF_DIR="$HOME/Desktop/WORKSPACE/GMO/DEV/tenbin/BFF"
CDI_DIR="$HOME/Desktop/WORKSPACE/GMO/DEV/CDI"
SHINHAN_DIR="$HOME/Desktop/WORKSPACE/GMO/DEV/shinhan"

# Function to print header
print_header() {
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}========================================${NC}\n"
}

# Function to remove a directory (or file) safely
safe_remove() {
    local path="$1"
    local description="$2"

    if [ -e "$path" ]; then
        echo -e "${GREEN}✓${NC} Removing: $description"
        rm -rf "$path"
    else
        echo -e "${YELLOW}⊘${NC} Not found: $description ($path)"
    fi
}

# Function to clear everything INSIDE a directory (keep the directory itself)
# Removes regular and hidden entries. Uses ${dir:?} to guard against
# an empty variable that would otherwise expand to "/*".
clear_contents() {
    local dir="$1"
    local description="$2"

    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} Clearing contents: $description ($dir)"
        rm -rf "${dir:?}"/* "${dir:?}"/.[!.]* "${dir:?}"/..?* 2>/dev/null || true
    else
        echo -e "${YELLOW}⊘${NC} Not found: $description ($dir)"
    fi
}

# Display confirmation
echo -e "${RED}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  DEVELOPMENT ENVIRONMENT CLEANUP SCRIPT                    ║"
echo "║  This will delete cache, build files, and node_modules     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

read -p "Are you sure you want to proceed? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 1
fi

# Start cleanup process
print_header "1. Cleaning Xcode (DerivedData, Archives)"
clear_contents "$XCODE_DIR/DerivedData" "Xcode DerivedData"
clear_contents "$XCODE_DIR/Archives" "Xcode Archives"

print_header "2. Cleaning Library (Caches, Logs)"
clear_contents "$LIBRARY_DIR/Caches" "Library Caches"
clear_contents "$LIBRARY_DIR/Logs" "Library Logs"

print_header "3. Cleaning Android SDK"
clear_contents "$ANDROID_SDK_DIR/.downloadIntermediates" "Android .downloadIntermediates"
clear_contents "$ANDROID_SDK_DIR/build-tools" "Android build-tools"
clear_contents "$ANDROID_SDK_DIR/cmake" "Android cmake"
clear_contents "$ANDROID_SDK_DIR/ndk" "Android ndk"
clear_contents "$ANDROID_SDK_DIR/platforms" "Android platforms"

print_header "4. Cleaning Downloads (keeping /save)"
# Remove all files and folders except the "save" folder
if [ -d "$DOWNLOAD_DIR" ]; then
    find "$DOWNLOAD_DIR" -mindepth 1 -maxdepth 1 ! -name "save" -exec rm -rf {} + 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Cleaned Downloads directory (kept /save folder)"
else
    echo -e "${YELLOW}⊘${NC} Downloads directory not found"
fi

print_header "5. Cleaning Build Files"
clear_contents "$BUILD_DIR" "Build directory contents"

print_header "6. Cleaning SOPHIA"
safe_remove "$SOPHIA_DIR/0_src_sophia-server/node_modules" "SOPHIA server node_modules"
safe_remove "$SOPHIA_DIR/0_src_sophia-server/dist" "SOPHIA server dist"
safe_remove "$SOPHIA_DIR/0_src_sophia-client/node_modules" "SOPHIA client node_modules"
safe_remove "$SOPHIA_DIR/0_src_sophia-client/.next" "SOPHIA client .next"
safe_remove "$SOPHIA_DIR/0_src_sophia-admin-client/node_modules" "SOPHIA admin client node_modules"

print_header "7. Cleaning METIS"
safe_remove "$METIS_DIR/0_src_metis-server/node_modules" "METIS server node_modules"
safe_remove "$METIS_DIR/0_src_metis-server/dist" "METIS server dist"
safe_remove "$METIS_DIR/0_src_metis-client/node_modules" "METIS client node_modules"
safe_remove "$METIS_DIR/0_src_metis-client/.next" "METIS client .next"
safe_remove "$METIS_DIR/0_src_metis-admin-client/node_modules" "METIS admin client node_modules"

print_header "8. Cleaning BFF"
safe_remove "$BFF_DIR/0_src_bff/node_modules" "BFF node_modules"
safe_remove "$BFF_DIR/0_src_bff/dist" "BFF dist"

print_header "9. Cleaning CDI"
safe_remove "$CDI_DIR/taprica-app/0_src_taprica-app/remoconApp/node_modules" "Taprica app node_modules"
safe_remove "$CDI_DIR/taprica-app/0_src_taprica-app/remoconApp/android/app/build" "Taprica app Android build"
safe_remove "$CDI_DIR/taprica-app/0_src_taprica-app/remoconApp/android/.gradle" "Taprica app .gradle"
safe_remove "$CDI_DIR/taprica-app/0_src_taprica-app/remoconApp/ios/Pods" "Taprica app iOS Pods"
safe_remove "$CDI_DIR/taprica-app/0_src_taprica-app/remoconApp/ios/build" "Taprica app iOS build"
safe_remove "$CDI_DIR/taprica-server/0_src_taprica-server/remoconServer/node_modules" "Taprica server node_modules"
safe_remove "$CDI_DIR/cpap/0_src_cpap/node_modules" "CPAP node_modules"
safe_remove "$CDI_DIR/cpap/0_src_cpap/android/app/build" "CPAP Android build"
safe_remove "$CDI_DIR/cpap/0_src_cpap/android/.gradle" "CPAP .gradle"
safe_remove "$CDI_DIR/cpap/0_src_cpap/ios/Pods" "CPAP iOS Pods"
safe_remove "$CDI_DIR/cpap/0_src_cpap/ios/build" "CPAP iOS build"

print_header "10. Cleaning SHINHAN"
safe_remove "$SHINHAN_DIR/0_src_shinhan/node_modules" "SHINHAN node_modules"
safe_remove "$SHINHAN_DIR/0_src_shinhan/android/app/build" "SHINHAN Android build"
safe_remove "$SHINHAN_DIR/0_src_shinhan/android/.gradle" "SHINHAN .gradle"
safe_remove "$SHINHAN_DIR/0_src_shinhan/ios/Pods" "SHINHAN iOS Pods"
safe_remove "$SHINHAN_DIR/0_src_shinhan/ios/build" "SHINHAN iOS build"

print_header "11. Cleaning Home Directory"
safe_remove "$HOME/.cocoapods" "CocoaPods directory"
clear_contents "$HOME/.android/cache" "Android cache"
safe_remove "$HOME/.sonar/cache" "Sonar cache"
clear_contents "$HOME/.zsh_sessions" "ZSH sessions"
safe_remove "$HOME/.gradle" "Gradle directory"
clear_contents "$HOME/.npm/_cacache" "NPM cache"
clear_contents "$HOME/.nvm/.cache" "NVM cache"

print_header "12. Cleaning Docker Builder Cache"
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Running Docker builder prune"
    docker builder prune -a -f
else
    echo -e "${YELLOW}⊘${NC} Docker not installed or not available in PATH"
fi

print_header "Cleanup Completed Successfully!"
echo -e "${GREEN}All cleanup operations have been completed.${NC}\n"
