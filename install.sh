#!/usr/bin/env bash
set -e

# ==========================================
# NixOS Universal Installation Script
# ==========================================

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INSTALLER] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# 1. Select Host
HOSTS_DIR="./hosts"
if [ ! -d "$HOSTS_DIR" ]; then
    error "Directory $HOSTS_DIR not found!"
    exit 1
fi

AVAILABLE_HOSTS=($(ls -d $HOSTS_DIR/*/ | xargs -n 1 basename))

if [ ${#AVAILABLE_HOSTS[@]} -eq 0 ]; then
    error "No host configurations found in $HOSTS_DIR."
    exit 1
fi

echo -e "${GREEN}Available Hosts:${NC}"
for i in "${!AVAILABLE_HOSTS[@]}"; do
    echo "$((i+1)). ${AVAILABLE_HOSTS[$i]}"
done

read -p "Select a host to install (enter number): " host_index

# Validate input
if ! [[ "$host_index" =~ ^[0-9]+$ ]] || [ "$host_index" -lt 1 ] || [ "$host_index" -gt ${#AVAILABLE_HOSTS[@]} ]; then
    error "Invalid selection."
    exit 1
fi

FLAKE_HOST="${AVAILABLE_HOSTS[$((host_index-1))]}"
DISK_CONFIG="$HOSTS_DIR/$FLAKE_HOST/disko-config.nix"

if [ ! -f "$DISK_CONFIG" ]; then
    error "Disko config not found at $DISK_CONFIG"
    exit 1
fi

log "Selected Host: $FLAKE_HOST"
log "Disko Config: $DISK_CONFIG"

# 2. Safety Check
warn "This script will WIPE the disk defined in $DISK_CONFIG and install NixOS for host '$FLAKE_HOST'!"
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
if [ "$confirm" != "yes" ]; then
    error "Aborted."
    exit 1
fi

# 3. Partitioning (Disko)
log "Running Disko to partition and mount drives..."
# We use the disko config directly. 
# Note: Ensure you have internet access for 'nix run' if not cached.
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko "$DISK_CONFIG"


# 4. Installation
log "Installing NixOS system..."
nixos-install --flake ".#$FLAKE_HOST"

log "Installation Complete!"
echo "Please check the output above for any errors."
echo "If everything looks good, type 'reboot' to restart into your new system."
echo "IMPORTANT: On first boot, you may need to enroll Secure Boot keys if in Setup Mode."