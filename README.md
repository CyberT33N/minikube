# Minikube





<br><br>
<br><br>
_____________________________________
_____________________________________
<br><br>
<br><br>

## IP
```shell
minikube ip
```
- Should be 192.168.49.2









<br><br>
<br><br>
_____________________________________
_____________________________________
<br><br>
<br><br>


# Services
```shell
kubectl get svc --namespace=dev
```





<br><br>
<br><br>
_____________________________________
_____________________________________
<br><br>
<br><br>

# Helm Charts

<br><br>
<br><br>

## MongoDB

### Connection String
- `mongodb://root:test@192.168.49.2.nip.io:30644/`

<br><br>
<br><br>

### Add repo
```shell
# Add bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update helm repo
helm repo update

# Auflisten der verfügbaren Helm Chart Versionen
helm search repo bitnami/mongodb --versions
```

<br><br>
<br><br>

### Install Helm Chart
```shell
# This will download the mongodb helm chart to the folder ./mongodb/Chart
cd ~/Projects/minikube
mkdir -p ./mongodb/Chart

# 15.6.12 = MongoDB 7
helm pull bitnami/mongodb --version 15.6.12 --untar --untardir ./tmp
cp -r ./tmp/mongodb/* ./mongodb/Chart
rm -rf ./tmp

# Create custom-values.yaml
touch ./mongodb/custom-values.yaml

# Change context
kubectl config use-context minikube

# Install
helm install mongodb-dev ./mongodb/Chart --namespace dev -f ./mongodb/custom-values.yaml
```

<br><br>
<br><br>

### Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade mongodb-dev ./mongodb/Chart --namespace dev -f ./mongodb/custom-values.yaml --atomic
```

### Delete Deployment
```shell
kubectl config use-context minikube
helm --namespace dev delete mongodb-dev
```