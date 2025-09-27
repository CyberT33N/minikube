## 🛡️ cert-manager

<details>
<summary>Click to expand..</summary>

- **This helm chart was not tested yet..**

### 🛠️ Install
```shell
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version 1.15.1
```

### ❌ Uninstall
```shell
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.crds.yaml
kubectl delete namespace cert-manager
```

</details>
