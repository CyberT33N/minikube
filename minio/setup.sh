cd "$(dirname "$0")"; printf "\nCurrent working directory:"; pwd

kubectl config use-context minikube

kubectl apply -f ./minio-dev.yaml
# kubectl get pods -n minio-dev