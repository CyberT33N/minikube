#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")"
printf "\nCurrent working directory: "
pwd

# Set the Kubernetes context to Minikube
kubectl config use-context minikube

# ==== INSTALL GITLAB ====
echo "Installing GitLab..."
helm install gitlab-dev ./Chart --namespace dev -f ./custom-values.yaml

# Wait until GitLab UI is ready
echo "Waiting for GitLab UI to be ready..."
until kubectl get pods --namespace dev | grep gitlab-dev-webservice-default | grep Running | grep 2/2; do
    echo "Waiting for healthy gitlab-dev-webservice-default Pods..."
    sleep 10
done

echo "GitLab UI is ready."
sleep 10

# ==== CHANGE GITLAB ROOT PASSWORD ====
NAMESPACE="dev"
POD_NAME=$(kubectl get pods -n "$NAMESPACE" | grep gitlab-dev-toolbox | awk '{print $1}')

# Check if the Pod name was found
if [ -z "$POD_NAME" ]; then
    echo "No pod found with the name 'gitlab-dev-toolbox'."
    exit 1
fi

# Execute command in the Pod to change the GitLab root password
echo "Changing GitLab root password..."
kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- bash -c "gitlab-rails runner \"user = User.find_by(username: 'root'); user.password = '69aZc996'; user.password_confirmation = '69aZc996'; user.save!\""

echo "GitLab root password changed successfully."
