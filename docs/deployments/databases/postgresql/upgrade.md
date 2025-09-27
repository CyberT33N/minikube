### 🔄 Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade postgresql-dev ./postgresql/Chart --namespace dev -f ./postgresql/custom-values.yaml --atomic
```
