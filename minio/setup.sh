#!/bin/bash

# Function for logging
log() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to execute a command with error handling
execute_command() {
    local command="$1"
    log "Executing: $command"
    eval "$command" || { echo "[ERROR] Command failed: $command"; exit 1; }
}

# Change to the script's directory and print the current working directory
cd "$(dirname "$0")" || { echo "[ERROR] Failed to change directory"; exit 1; }
printf "\nCurrent working directory: "; pwd

# Set the Kubernetes context to Minikube
execute_command "kubectl config use-context minikube"

# Apply the MinIO configuration
execute_command "kubectl apply -f ./minio-dev.yaml"

# Optionally get pods in the minio-dev namespace (commented out)
# execute_command "kubectl get pods -n minio-dev"

# Create a MinIO bucket
execute_command "mc mb minio/runner-cache"
