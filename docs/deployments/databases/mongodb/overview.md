## Databases

### 🍃 MongoDB

<br>

#### 🔗 Connection String
- `mongodb://root:test@192.168.49.2.nip.io:30644/`

<br>

## 🍃 MongoDB

<details>
<summary>Click to expand..</summary>

### 🔗 Connection String
- `mongodb://root:test@192.168.49.2.nip.io:30644/`

### 📥 Add Repo
```shell
# Add Bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update Helm repo
helm repo update

# List available Helm Chart versions
helm search repo bitnami/mongodb --versions
```

### 📦 Install Helm Chart
```shell
# This will download the MongoDB Helm chart to the folder ./mongodb/Chart
cd ~/Projects/minikube
mkdir -p ./mongodb/Chart

# 15.6.12 = MongoDB 7
helm pull bitnami/mongodb --version 15.6.12 --untar --untardir ./tmp
cp -r ./tmp/mongodb/* ./mongodb/Chart
rm -rf ./tmp

# Create custom-values.yaml
touch ./mongodb/custom-values.yaml

# /home/t33n/Projects/minikube/mongodb/setup.sh
```

### 🔄 Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade mongodb-dev ./mongodb/Chart --namespace dev -f ./mongodb/custom-values.yaml --atomic
```

### ❌ Delete Deployment
```shell
kubectl config use-context minikube
helm --namespace dev delete mongodb-dev
```

</details>
