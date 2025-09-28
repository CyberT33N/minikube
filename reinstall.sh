#!/bin/bash

# ==================== COMMANDS ====================
# 🚀 Reinstall only deployments
# bash ./reinstall.sh 

# 🔄 Reinstall everything (delete Minikube and reinstall)
# bash ./reinstall.sh --full 

# 🗑️ Reinstall only MongoDB
# bash ./reinstall.sh --mongodb 

# 🗑️ Reinstall only GitLab
# bash ./reinstall.sh --gitlab 

# 🗑️ Reinstall only MinIO
# bash ./reinstall.sh --minio 

# ==================== SCRIPT LOGIC ====================
# Check for the first argument to determine the action
if [ "$1" = "--full" ]; then
    echo "🗑️ Deleting Minikube and reinstalling everything.."

    minikube delete --all --purge  # Delete the Minikube cluster

    # Restart the installation process
    bash ./start.sh
    bash ./install.sh

# Check for MongoDB reinstallation
elif [ "$1" = "--mongodb" ]; then
    echo "🔄 Reinstalling only MongoDB.."
    bash ./mongodb/uninstall.sh  # Uninstall MongoDB
    bash ./mongodb/setup.sh      # Setup MongoDB

# Check for MinIO reinstallation
elif [ "$1" = "--minio" ]; then
    echo "🔄 Reinstalling only MinIO.."
    bash ./minio/uninstall.sh     # Uninstall MinIO
    bash ./minio/setup.sh         # Setup MinIO

# Check for GitLab reinstallation
elif [ "$1" = "--gitlab" ]; then
    echo "🔄 Reinstalling only GitLab.."
    bash ./gitlab/uninstall.sh    # Uninstall GitLab
    bash ./gitlab/setup.sh        # Setup GitLab

# If no valid argument is provided, reinstall deployments
else
    echo "🔄 Reinstalling only deployments.."

    # Uninstall all services
    bash ./mongodb/uninstall.sh
    bash ./minio/uninstall.sh
    bash ./gitlab/uninstall.sh
    
    # Install all services again
    bash ./install.sh
fi
