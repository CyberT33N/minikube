#!/bin/bash

kubectl config use-context minikube

# if ! kubectl get secret -n dev gitlab-root-password-custom >/dev/null 2>&1; then
#      kubectl create secret -n dev generic gitlab-root-password-custom --from-literal='password=test'
# fi

helm install gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml

# Wait until gitlab UI is ready..
until kubectl get pods --namespace dev | grep gitlab-dev-webservice-default | grep Running | grep 2/2
do
    echo "Wait for healthy gitlab-dev-webservice-default Pods..."
    sleep 10
done
echo "Gitlab UI is ready.."
sleep 10

# Create cert
openssl s_client -showcerts -connect gitlab.local.com:443 -servername gitlab.local.com < /dev/null 2>/dev/null | openssl x509 -outform PEM > ./gitlab/gitlab.local.com.crt

if kubectl get secret -n dev gitlab-cert-self >/dev/null 2>&1; then
    kubectl delete secret -n dev gitlab-cert-self
fi

kubectl create secret generic gitlab-cert-self \
--namespace dev \
--from-file=./gitlab/gitlab.local.com.crt

NAMESPACE="dev"
POD_NAME=$(kubectl get pods -n dev | grep gitlab-dev-toolbox | awk '{print $1}')

# Prüfen, ob der Pod-Name gefunden wurde
if [ -z "$POD_NAME" ]; then
  echo "Kein Pod mit dem Namen 'gitlab-dev-toolbox' gefunden."
  exit 1
fi

# Befehl im Pod ausführen
kubectl exec -it $POD_NAME -n $NAMESPACE -- bash -c "gitlab-rails runner \"user = User.find_by(username: 'root'); user.password = '69aZc996'; user.password_confirmation = '69aZc996'; user.save!\""