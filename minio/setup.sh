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

# Wait for MinIO to be ready (pod Ready + HTTP health) with a 5-minute timeout
wait_for_minio_readiness() {
    local namespace="minio-dev"
    local timeout_seconds=300
    local sleep_seconds=5

    log "Waiting for MinIO pod to be Ready (timeout ${timeout_seconds}s)..."
    if ! kubectl wait --for=condition=Ready pod/minio -n "${namespace}" --timeout="${timeout_seconds}s"; then
        echo "[ERROR] MinIO pod did not become Ready within ${timeout_seconds}s"
        exit 1
    fi

    if command -v minikube >/dev/null 2>&1; then
        local ip
        ip=$(minikube ip 2>/dev/null || true)
        if [ -n "$ip" ]; then
            local url="http://${ip}.nip.io:30000/minio/health/ready"
            log "Waiting for MinIO HTTP readiness at ${url} (timeout ${timeout_seconds}s)..."
            local elapsed=0
            while ! curl -sf --max-time 3 "$url" >/dev/null 2>&1; do
                if [ "$elapsed" -ge "$timeout_seconds" ]; then
                    echo "[ERROR] MinIO HTTP endpoint not ready after ${timeout_seconds}s"
                    exit 1
                fi
                sleep "$sleep_seconds"
                elapsed=$((elapsed + sleep_seconds))
            done
            log "MinIO HTTP endpoint is ready."
        else
            log "Minikube IP not detected; skipping HTTP readiness check."
        fi
    else
        log "minikube CLI not found; skipping HTTP readiness check."
    fi
}

# Ensure MinIO is ready before creating the bucket
wait_for_minio_readiness

# Create a MinIO bucket
execute_command "mc mb minio/runner-cache"
