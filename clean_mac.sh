#!/bin/bash

# ==============================================================================
# Script Name: clean_mac.sh
# Description: Automates the removal of cache, logs, and temporary build files
#              for macOS development environments (Docker, Python, Node, Xcode).
# ==============================================================================

echo "--------------------------------------------------"
echo " Starting macOS System & Dev Environment Cleanup"
echo "--------------------------------------------------"

# 1. System Caches and macOS Aerial Wallpapers
echo "[1/7] Cleaning System Caches and Aerial Wallpaper assets..."
# Cleans general app caches
sudo rm -rf ~/Library/Caches/*
# Cleans the 18GB+ high-definition wallpaper videos found earlier
sudo rm -rf ~/Library/Application\ Support/com.apple.idleassetsd/Customer/*
echo "Done."

# 2. Homebrew Maintenance
if command -v brew &> /dev/null; then
    echo "[2/7] Cleaning Homebrew logs and old formulas..."
    # Cleans the 22GB+ log directory found in /opt/homebrew/var/log
    sudo rm -rf /opt/homebrew/var/log/*
    # Removes old versions of installed packages
    brew cleanup -s
    # Cleans the download cache
    rm -rf $(brew --cache)
    echo "Done."
fi

# 3. Developer Tools (Xcode & Simulator)
echo "[3/7] Cleaning Xcode DerivedData and iOS Simulator images..."
# Removes temporary build artifacts
rm -rf ~/Library/Developer/Xcode/DerivedData/*
# Removes downloaded iOS/watchOS simulator runtime images (7GB+ per file)
rm -rf ~/Library/Developer/CoreSimulator/Images/*
rm -rf ~/Library/Developer/CoreSimulator/Caches/*
echo "Done."

# 4. Containerization (Docker / OrbStack)
if command -v docker &> /dev/null; then
    echo "[4/7] Pruning Docker/OrbStack build cache and unused resources..."
    # Removes the buildkit snapshots (the ones with node_modules you found)
    docker builder prune -a -f
    # Removes all stopped containers, unused networks, and dangling images
    docker system prune -a --volumes -f
    echo "Done. (Note: Run 'Optimize Now' in OrbStack GUI to reclaim physical space)"
fi

# 5. Package Manager Caches (Python & Node.js)
echo "[5/7] Clearing Conda and NPM caches..."
if command -v conda &> /dev/null; then
    # Removes unused packages and tarballs from Miniconda
    conda clean -ay
fi
if command -v npm &> /dev/null; then
    # Clears the 13GB+ npm cache
    npm cache clean --force
fi
echo "Done."

# 6. Specific AI App Data (Claude Desktop)
echo "[6/7] Removing Claude Desktop VM bundles..."
# Cleans the 11GB+ virtual machine images used for code analysis
rm -rf ~/Library/Application\ Support/Claude/vm_bundles/*
echo "Done."

# 7. Final Step: Empty Trash
echo "[7/7] Emptying System Trash..."
rm -rf ~/.Trash/*
echo "Done."

echo "--------------------------------------------------"
echo "✨ Cleanup Completed Successfully!"
echo "Current Disk Usage:"
df -h / | grep /
echo "--------------------------------------------------"
echo "REMINDER: For OrbStack or Parallels, you must manually"
echo "trigger 'Optimize' or 'Reclaim Space' in their respective"
echo "GUI settings to shrink the physical disk image (.dmg/.pvm)."
