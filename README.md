# Minikube


<br><br>
<br><br>

# start
- Will start the minikube and create namespace `dev`
- `start.sh`



<br><br>
<br><br>

# install
- Will install all deployments
- `install.sh`





<br><br>
<br><br>
_____________________________________
_____________________________________
<br><br>
<br><br>

# Links



<br><br>
<br><br>

## MongoDB

<br><br>

### Connection String
- `mongodb://root:test@192.168.49.2.nip.io:30644/`



<br><br>
<br><br>

## Gitlab

<br><br>

### UI
- https://gitlab.local.com













<br><br>
<br><br>
_____________________________________
_____________________________________
<br><br>
<br><br>

## IP
- Get your minikube IP
```shell
minikube ip
```
- Should be 192.168.49.2 or 192.168.49.2.nip.io











<br><br>
<br><br>
_____________________________________
_____________________________________
<br><br>
<br><br>


# Services
- Show all services in namespace dev
```shell
kubectl get svc --namespace=dev
```






<br><br>
<br><br>
<br><br>
<br><br>


# Ingress

## Show all ingress routes
```shell
kubectl get ingress -n dev
```

<br><br>
<br><br>


## Get details about ingress object
```shell
kubectl describe ingress gitlab-dev-webservice-default -n dev
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

## cert-manager

<br><br>
<br><br>

### Install
```shell
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version 1.15.1
```

<br><br>
<br><br>

### Uninstall
```shell
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.crds.yaml
kubectl delete namespace cert-manager
```

















<br><br>
<br><br>
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





















<br><br>
<br><br>
<br><br>
<br><br>

## Gitlab

<br><br>
<br><br>

### Guides
- https://docs.gitlab.com/charts/development/minikube/

### Links
- https://gitlab.local.com/users/sign_in

<br><br>
<br><br>

### Hosts
- Add this to your `/etc/hosts` file. In your custom-values.yaml you can also add global.hosts.domain=192.168.49.2.nip.io
```shell
sudo gedit /etc/hosts

# ==== MINIKUBE ====
192.168.49.2 gitlab.local.com
```

<br><br>
<br><br>


### Add repo
```shell
# Add gitlab repo
helm repo add gitlab https://charts.gitlab.io/

# Update helm repo
helm repo update

# Auflisten der verfügbaren Helm Chart Versionen
helm search repo gitlab --versions
```

<br><br>
<br><br>

### Install Helm Chart
```shell
# This will download the gitlab helm chart to the folder ./gitlab/Chart
cd ~/Projects/minikube
mkdir -p ./gitlab/Chart

helm pull gitlab/gitlab --version 8.1.2  --untar --untardir ./tmp
cp -r ./tmp/gitlab/* ./gitlab/Chart
rm -rf ./tmp

# Create custom-values.yaml
touch ./gitlab/custom-values.yaml

# Change context
kubectl config use-context minikube

# Install
helm install gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml

# - https://docs.gitlab.com/runner/install/kubernetes.html#providing-a-custom-certificate-for-accessing-gitlab
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
```
     - If you get error `download failed after attempts=6: net/http: TLS handshake timeout` in your gitlab-runner deployment try:
     ```shell
     unset all_proxy
     ```

<br><br>

### Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml --atomic
```

<br><br>

### Delete Deployment
```shell
kubectl config use-context minikube
helm --namespace dev delete gitlab-dev
```

<br><br>

### Retrieve IP addresses
```shell
kubectl get ingress -lrelease=gitlab-dev -n dev
```

<br><br>

### Get password
- You can access the GitLab instance by visiting the domain specified, https://gitlab.192.168.99.100.nip.io is used in these examples. If you manually created the secret for initial root password, you can use that to sign in as root user. If not, GitLab automatically created a random password for the root user. This can be extracted by the following command (replace <name> by name of the release - which is gitlab if you used the command above). 
```shell
kubectl get -n dev secret gitlab-dev-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```
- You can change the password by sign in > right click on your avater > edit > password


<br><br>

### Check ingress object
```shell
kubectl describe ingress gitlab-dev-webservice-default -n dev
```