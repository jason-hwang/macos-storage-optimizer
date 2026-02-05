#!/bin/bash

################################################################################
# macOS Storage Optimizer
# A concise shell script to reclaim disk space by purging development-related
# caches, logs, and temporary artifacts on macOS.
#
# Usage: ./macos-storage-optimizer.sh [--dry-run]
#   --dry-run: Show what would be cleaned without actually deleting anything
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Flags
DRY_RUN=false
TOTAL_FREED=0

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run]"
            echo "  --dry-run: Show what would be cleaned without actually deleting anything"
            echo "  -h, --help: Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}==>${NC} ${1}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

# Function to print warnings
print_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

# Function to print errors
print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

# Function to get directory size
get_size() {
    if [ -d "$1" ] || [ -f "$1" ]; then
        du -sk "$1" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

# Function to format size in human-readable format
format_size() {
    local size_kb=$1
    if [ "$size_kb" -ge 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.2f GB\", $size_kb/1048576}")"
    elif [ "$size_kb" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.2f MB\", $size_kb/1024}")"
    else
        echo "${size_kb} KB"
    fi
}

# Function to clean a path
clean_path() {
    local path="$1"
    local description="$2"
    
    if [ ! -e "$path" ]; then
        return
    fi
    
    local size=$(get_size "$path")
    local size_formatted=$(format_size "$size")
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "Would clean: $description ($size_formatted)"
    else
        if rm -rf "$path" 2>/dev/null; then
            print_success "Cleaned: $description ($size_formatted)"
            TOTAL_FREED=$((TOTAL_FREED + size))
        else
            print_error "Failed to clean: $description"
        fi
    fi
}

# Print banner
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   macOS Storage Optimizer             ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Running in DRY-RUN mode - no files will be deleted${NC}"
fi

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

# Homebrew Caches
print_header "Cleaning Homebrew caches..."
if command -v brew &> /dev/null; then
    BREW_CACHE=$(brew --cache 2>/dev/null || echo "$HOME/Library/Caches/Homebrew")
    if [ -d "$BREW_CACHE" ]; then
        clean_path "$BREW_CACHE/*" "Homebrew cache"
    fi
    
    # Cleanup old versions
    if [ "$DRY_RUN" = false ]; then
        if brew cleanup -s 2>/dev/null; then
            print_success "Homebrew cleanup completed"
        fi
    else
        print_warning "Would run: brew cleanup -s"
    fi
else
    print_warning "Homebrew not installed, skipping..."
fi

# npm Caches
print_header "Cleaning npm caches..."
if command -v npm &> /dev/null; then
    NPM_CACHE="$HOME/.npm"
    if [ -d "$NPM_CACHE" ]; then
        if [ "$DRY_RUN" = false ]; then
            if npm cache clean --force 2>/dev/null; then
                print_success "npm cache cleaned"
            fi
        else
            size=$(get_size "$NPM_CACHE")
            size_formatted=$(format_size "$size")
            print_warning "Would clean: npm cache ($size_formatted)"
        fi
    fi
else
    print_warning "npm not installed, skipping..."
fi

# Yarn Caches
print_header "Cleaning Yarn caches..."
if command -v yarn &> /dev/null; then
    YARN_CACHE=$(yarn cache dir 2>/dev/null || echo "$HOME/Library/Caches/Yarn")
    if [ -d "$YARN_CACHE" ]; then
        if [ "$DRY_RUN" = false ]; then
            if yarn cache clean 2>/dev/null; then
                print_success "Yarn cache cleaned"
            fi
        else
            size=$(get_size "$YARN_CACHE")
            size_formatted=$(format_size "$size")
            print_warning "Would clean: Yarn cache ($size_formatted)"
        fi
    fi
else
    print_warning "Yarn not installed, skipping..."
fi

# pip Caches
print_header "Cleaning pip caches..."
PIP_CACHE="$HOME/Library/Caches/pip"
clean_path "$PIP_CACHE" "pip cache"

# Python __pycache__ directories (common in development)
print_header "Cleaning Python __pycache__ directories..."
if [ "$DRY_RUN" = false ]; then
    PYCACHE_COUNT=$(find "$HOME" -type d -name "__pycache__" 2>/dev/null | wc -l)
    if [ "$PYCACHE_COUNT" -gt 0 ]; then
        find "$HOME" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        print_success "Removed $PYCACHE_COUNT __pycache__ directories"
    fi
else
    PYCACHE_COUNT=$(find "$HOME" -type d -name "__pycache__" 2>/dev/null | wc -l)
    print_warning "Would remove $PYCACHE_COUNT __pycache__ directories"
fi

# Xcode DerivedData
print_header "Cleaning Xcode caches..."
XCODE_DERIVED="$HOME/Library/Developer/Xcode/DerivedData"
clean_path "$XCODE_DERIVED" "Xcode DerivedData"

XCODE_ARCHIVES="$HOME/Library/Developer/Xcode/Archives"
clean_path "$XCODE_ARCHIVES" "Xcode Archives"

# CocoaPods
print_header "Cleaning CocoaPods caches..."
COCOAPODS_CACHE="$HOME/Library/Caches/CocoaPods"
clean_path "$COCOAPODS_CACHE" "CocoaPods cache"

# Gradle
print_header "Cleaning Gradle caches..."
GRADLE_CACHE="$HOME/.gradle/caches"
clean_path "$GRADLE_CACHE" "Gradle caches"

# Maven
print_header "Cleaning Maven caches..."
MAVEN_REPO="$HOME/.m2/repository"
if [ -d "$MAVEN_REPO" ]; then
    size=$(get_size "$MAVEN_REPO")
    size_formatted=$(format_size "$size")
    print_warning "Maven repository found ($size_formatted) - skipping (manual cleanup recommended)"
fi

# Docker (if installed)
print_header "Cleaning Docker artifacts..."
if command -v docker &> /dev/null; then
    if [ "$DRY_RUN" = false ]; then
        if docker system prune -af --volumes 2>/dev/null; then
            print_success "Docker system pruned"
        fi
    else
        print_warning "Would run: docker system prune -af --volumes"
    fi
else
    print_warning "Docker not installed, skipping..."
fi

# System Logs
print_header "Cleaning system logs..."
SYSTEM_LOGS="$HOME/Library/Logs"
if [ -d "$SYSTEM_LOGS" ]; then
    if [ "$DRY_RUN" = false ]; then
        find "$SYSTEM_LOGS" -type f -name "*.log" -delete 2>/dev/null || true
        find "$SYSTEM_LOGS" -type f -name "*.old" -delete 2>/dev/null || true
        print_success "System logs cleaned"
    else
        LOG_COUNT=$(find "$SYSTEM_LOGS" -type f \( -name "*.log" -o -name "*.old" \) 2>/dev/null | wc -l)
        print_warning "Would remove $LOG_COUNT log files"
    fi
fi

# Application Caches
print_header "Cleaning application caches..."
APP_CACHES="$HOME/Library/Caches"
if [ -d "$APP_CACHES" ]; then
    size=$(get_size "$APP_CACHES")
    size_formatted=$(format_size "$size")
    print_warning "Application caches found ($size_formatted) - skipping for safety (manual cleanup recommended)"
fi

# Trash
print_header "Emptying Trash..."
TRASH="$HOME/.Trash"
clean_path "$TRASH/*" "Trash"

# Download folder old files (optional - commented out for safety)
# print_header "Cleaning old downloads..."
# find "$HOME/Downloads" -type f -mtime +30 -delete 2>/dev/null || true

# Summary
echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Cleanup Summary                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}This was a dry-run. No files were deleted.${NC}"
    echo -e "${YELLOW}Run without --dry-run to perform actual cleanup.${NC}"
else
    TOTAL_FREED_FORMATTED=$(format_size "$TOTAL_FREED")
    echo -e "Total space freed: ${GREEN}$TOTAL_FREED_FORMATTED${NC}"
    echo -e "${GREEN}✓ Cleanup completed successfully!${NC}"
fi

echo ""
