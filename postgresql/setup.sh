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

# Install the postgresql Helm chart
execute_command "helm install postgresql-dev ./postgresql/Chart --namespace dev -f ./postgresql/custom-values.yaml"
