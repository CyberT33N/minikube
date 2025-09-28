#!/bin/bash

# 📜 Enable strict error handling
set -e

# 🛠️ Prevent permission issues with Docker
# Uncomment the line below to add the current user to the Docker group.
# This allows the user to execute Docker commands without sudo.
# sudo usermod -aG docker $USER && newgrp docker

# 📂 Set the script's directory
_directory=$(dirname "$0")

# 🎮 Detect NVIDIA GPU support for Docker and set GPU flags if available
GPU_FLAGS=""
if command -v nvidia-smi >/dev/null 2>&1; then
  if docker info --format '{{json .Runtimes}}' 2>/dev/null | grep -q '"nvidia"'; then
    echo "🧪 Testing NVIDIA container runtime (ubuntu image)..."
    if sudo -n docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi >/dev/null 2>&1; then
      GPU_FLAGS="--gpus all"
      echo "🎮 NVIDIA GPU runtime works (sudo). Enabling GPU passthrough for Minikube."
    elif docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi >/dev/null 2>&1; then
      GPU_FLAGS="--gpus all"
      echo "🎮 NVIDIA GPU runtime works (no sudo). Enabling GPU passthrough for Minikube."
    else
      echo "🧪 Ubuntu check failed. Trying CUDA base image..."
      if sudo -n docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then
        GPU_FLAGS="--gpus all"
        echo "🎮 NVIDIA CUDA base image test succeeded (sudo). Enabling GPU passthrough."
      elif docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then
        GPU_FLAGS="--gpus all"
        echo "🎮 NVIDIA CUDA base image test succeeded (no sudo). Enabling GPU passthrough."
      else
        echo "⚠️ NVIDIA runtime is present, but container GPU test failed. Continuing without GPU."
      fi
    fi
  else
    echo "⚠️ NVIDIA drivers detected, but Docker lacks GPU runtime. Install nvidia-container-toolkit or continue without GPU."
  fi
else
  echo "ℹ️ No NVIDIA GPU support detected. Starting Minikube without GPU."
fi

# 🚀 Start Minikube with specified resources and enable storage provisioner
MINIKUBE_ARGS="--cpus no-limit --memory no-limit --container-runtime docker --driver docker --addons storage-provisioner"
if [ -n "$GPU_FLAGS" ]; then
  MINIKUBE_ARGS="$MINIKUBE_ARGS $GPU_FLAGS"
fi
minikube start $MINIKUBE_ARGS
  
echo "✅ Minikube started successfully!"

# 🌐 Get the Minikube IP address
MINIKUBE_IP=$(minikube ip)
echo "🌟 Minikube IP: $MINIKUBE_IP"

# 🔧 Configure IP ranges for LoadBalancer
FROM_IP="${MINIKUBE_IP%.*}.$((${MINIKUBE_IP##*.}+1))"  # Starting IP
TO_IP="${MINIKUBE_IP%.*}.$((${MINIKUBE_IP##*.}+10))"   # Ending IP

# 🔑 Ensure we are using the correct Kubernetes context
kubectl config use minikube
kubectl create namespace dev  # Create a development namespace

# ⚙️ Configure LoadBalancer IPs manually due to Minikube issue
# This ensures persistence and avoids interactive configuration.
cat ~/.minikube/profiles/minikube/config.json | jq ".KubernetesConfig.LoadBalancerStartIP=\"$FROM_IP\"" \
| jq ".KubernetesConfig.LoadBalancerEndIP=\"$TO_IP\"" \
> ~/.minikube/profiles/minikube/config.json.tmp && mv ~/.minikube/profiles/minikube/config.json.tmp ~/.minikube/profiles/minikube/config.json 

# 🔌 Enable MetalLB and Ingress add-ons
minikube addons enable metallb
minikube addons enable ingress
# Uncomment the line below to enable the metrics server if needed.
# minikube addons enable metrics-server

# 📁 Locate all 'values' files in the script's directory
_files=$(find "$_directory" -type f | grep 'values')

# 🔄 Update LoadBalancer IPs in configuration files
for file in $_files; do
    while read -r _line; do
        if [ -n "$_line" ]; then  # Check if the line is not empty
            # ✏️ Replace LoadBalancer IPs with actual IPs from Minikube
            sed -E -i "s/([.]*:\s)'([a-z-]*){0,1}([0-9]{1,3}\.){3}[0-9]{1,3}.nip.io'/\1'\2${FROM_IP}.nip.io'/g" "$file"
        fi
    done <<< "$(grep 'loadbalancer-IP' "$file")"  # Read only lines containing 'loadbalancer-IP'
done

# 🌍 Notify user of access to the Minikube LoadBalancer
echo "✅ Minikube LoadBalancer can be accessed with ${FROM_IP}.nip.io"
