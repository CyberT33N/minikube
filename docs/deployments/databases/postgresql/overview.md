## Databases

### 🍃 PostgreSQL

<br>

#### 🔗 Connection String
- `postgresql://test:test@192.168.49.2.nip.io:30543/test`



## 🍃 PostgreSQL

<details>
<summary>Click to expand..</summary>

### 🔗 Connection String
- `postgresql://test:test@192.168.49.2.nip.io:30543/test`

### 📥 Add Repo
```shell
# Add Bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update Helm repo
helm repo update

# List available Helm Chart versions
helm search repo bitnami/postgresql --versions
```

### 📦 Install Helm Chart
```shell
# This will download the PostgreSQL Helm chart to the folder ./postgresql/Chart
cd ~/Projects/minikube
mkdir -p ./postgresql/Chart

# 17.2.0
helm pull bitnami/postgresql --version 16.4.3 --untar --untardir ./tmp
cp -r ./tmp/postgresql/* ./postgresql/Chart
rm -rf ./tmp

# Create custom-values.yaml
touch ./postgresql/custom-values.yaml

# /home/t33n/Projects/minikube/postgresql/setup.sh
```

### 🔄 Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade postgresql-dev ./postgresql/Chart --namespace dev -f ./postgresql/custom-values.yaml --atomic
```

### ❌ Delete Deployment
```shell
kubectl config use-context minikube
helm --namespace dev delete postgresql-dev
```

</details>
