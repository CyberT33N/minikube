#!/bin/bash

# Function for logging
log() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to execute a script with error handling
execute_script() {
    local script_path="$1"
    log "Starting setup for $script_path..."
    bash "$script_path" || { echo "[ERROR] Failed to execute $script_path."; exit 1; }
    log "$script_path executed successfully."
}

# Main script execution
execute_script "./mongodb/setup.sh"
execute_script "./gitlab/setup.sh"
execute_script "./minio/setup.sh"
