## MongoDB
helm install mongodb-dev ./mongodb/Chart --namespace dev -f ./mongodb/custom-values.yaml

## Gitlab
helm install gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml

# Wait until gitlab UI is ready..
until kubectl get pods --namespace dev | grep gitlab-dev-webservice-default | grep Running | grep 2/2
do
    echo "Wait for healthy gitlab-dev-webservice-default Pods..."
    sleep 10
done

# Create cert
openssl s_client -showcerts -connect gitlab.local.com:443 -servername gitlab.local.com < /dev/null 2>/dev/null | openssl x509 -outform PEM > ./gitlab/gitlab.local.com.crt

kubectl create secret generic gitlab-cert-self \
  --namespace dev \
  --from-file=./gitlab/gitlab.local.com.crt
