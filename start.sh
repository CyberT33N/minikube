#!/bin/bash

# 📜 Enable strict error handling
set -e

# 🛠️ Prevent permission issues with Docker
# Uncomment the line below to add the current user to the Docker group.
# This allows the user to execute Docker commands without sudo.
# sudo usermod -aG docker $USER && newgrp docker

# 📂 Set the script's directory
_directory=$(dirname "$0")

# 🚀 Start Minikube with specified resources and enable storage provisioner
# Allocate 8 CPUs
# Allocate 18 GB of memory
# Use Docker as the driver
# Enable storage provisioner add-on
minikube start \
  --cpus=8 \
  --memory=18g \
  --driver=docker \
  --addons=storage-provisioner
  
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
