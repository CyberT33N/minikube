kubectl config use-context minikube

helm install mongodb-dev ./mongodb/Chart --namespace dev -f ./mongodb/custom-values.yaml