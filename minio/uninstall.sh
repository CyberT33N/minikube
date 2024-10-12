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

# Set the Kubernetes context to Minikube
execute_command "kubectl config use-context minikube"

# Delete the MinIO namespace
execute_command "kubectl delete namespace minio-dev"
