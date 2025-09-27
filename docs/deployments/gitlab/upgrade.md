### 🔄 Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml --atomic
```
