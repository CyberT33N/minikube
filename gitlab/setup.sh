#!/bin/bash
cd "$(dirname "$0")"; printf "\nCurrent working directory:"; pwd

kubectl config use-context minikube

# ==== INSTALL ====
helm install gitlab-dev ./Chart --namespace dev -f ./custom-values.yaml

# Wait until gitlab UI is ready..
until kubectl get pods --namespace dev | grep gitlab-dev-webservice-default | grep Running | grep 2/2
do
    echo "Wait for healthy gitlab-dev-webservice-default Pods..."
    sleep 10
done
echo "Gitlab UI is ready.."
sleep 10

# ==== CHANGE GITLAB ROOT PASSWORD ====
NAMESPACE="dev"
POD_NAME=$(kubectl get pods -n dev | grep gitlab-dev-toolbox | awk '{print $1}')

# Prüfen, ob der Pod-Name gefunden wurde
if [ -z "$POD_NAME" ]; then
  echo "Kein Pod mit dem Namen 'gitlab-dev-toolbox' gefunden."
  exit 1
fi

# Befehl im Pod ausführen
kubectl exec -it $POD_NAME -n $NAMESPACE -- bash -c "gitlab-rails runner \"user = User.find_by(username: 'root'); user.password = '69aZc996'; user.password_confirmation = '69aZc996'; user.save!\""