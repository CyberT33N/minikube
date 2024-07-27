# Minikube
- For some reason it does not work with double vpn from nordvpn

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


## MinIO
- http://192.168.49.2.nip.io:30001/login
- User:test69696969 | Password:test69696969






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
- root:69aZc996













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


## MinIO

<br><br>
<br><br>

### Links
- http://192.168.49.2.nip.io:30001/login
- User:test69696969 | Password:test69696969

<br><br>
<br><br>


### Uninstall

<br><br>

#### Full
```shell
# Delete the MinIO namespace and all resources within it
kubectl delete namespace minio-dev
```

<br><br>

#### Single steps
```shell
# Lösche den Pod
kubectl delete pod minio -n minio-dev

# Lösche das Secret
kubectl delete secret minio-secret -n minio-dev

# Lösche den PersistentVolumeClaim
kubectl delete pvc minio-pvc -n minio-dev

# Lösche den PersistentVolume
kubectl delete pv minio-pv

# Lösche den Service
kubectl delete service minio-service -n minio-dev

# Lösche den Namespace
kubectl delete namespace minio-dev
```


<br><br>
<br><br>

### Install
```shell
bash ./minio/setup.sh
```

<br><br>
<br><br>

### Re-install
```shell
bash ./reinstall.sh --minio
```

<br><br>
<br><br>

### Ugprade
```shell
bash ./minio/setup.sh
```
- For most cases you can just re-run it and it will detect if there are any changes. But in other cases like e.g. where we want to change credentials you have to delete the pod. However, for local environemnts you can just run the reinstall script above. This will be the easieast way when yua re doing some changes




<br><br>
<br><br>

### MinIO Client

<br><br>

#### Install
- https://min.io/docs/minio/linux/reference/minio-mc.html
- Check architecture `uname -m`
  - x86_64 means intel

### x86_64
```shell
# ==== INSTALL =====
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

# mc --help

# ==== SET ALIAS =====
# When you use zsh then jsut run the mc command on zsh shell
bash +o history
mc alias set minio http://192.168.49.2.nip.io:30000 test69696969 test69696969
bash -o history

# ==== TEST CONNECTION =====
mc admin info minio
```


<br><br>
<br><br>

### MinIO for Gitlab
- https://docs.gitlab.com/charts/advanced/external-object-storage/minio.html

```shell
mc mb gitlab-registry-storage
mc mb gitlab-lfs-storage
mc mb gitlab-artifacts-storage
mc mb gitlab-uploads-storage
mc mb gitlab-packages-storage
mc mb gitlab-backup-storage
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

# /home/t33n/Projects/minikube/mongodb/setup.sh
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

# /home/t33n/Projects/minikube/mongodb/setup.sh

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

### Change password

<br><br>

#### Method #1 - UI
- You can access the GitLab instance by visiting the domain specified, https://gitlab.192.168.99.100.nip.io is used in these examples. If you manually created the secret for initial root password, you can use that to sign in as root user. If not, GitLab automatically created a random password for the root user. This can be extracted by the following command (replace <name> by name of the release - which is gitlab if you used the command above). 
```shell
kubectl get -n dev secret gitlab-dev-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```
- You can change the password by sign in > right click on your avater > edit > password

<br><br>

#### Method #2 - gitlab-rails
- Use gitlab-rails. The pod gitlab-dev-toolbox is able to dit
```shell
kubectl create secret generic gitlab-cert-self \
--namespace dev \
--from-file=./gitlab/gitlab.local.com.crt

NAMESPACE="dev"
POD_NAME=$(kubectl get pods -n dev | grep gitlab-dev-toolbox | awk '{print $1}')

# Prüfen, ob der Pod-Name gefunden wurde
if [ -z "$POD_NAME" ]; then
  echo "Kein Pod mit dem Namen 'gitlab-dev-toolbox' gefunden."
  exit 1
fi

# Befehl im Pod ausführen
kubectl exec -it $POD_NAME -n $NAMESPACE -- bash -c "gitlab-rails runner \"user = User.find_by(username: 'root'); user.password = 'passwordHere'; user.password_confirmation = 'passwordHere'; user.save!\""
```

<br><br>

#### Method 3 - Helm chart (Not tested)
You create a secret and set it to your custom-values.yaml like we did in this guide
```shell
kubectl create secret -n dev generic gitlab-root-password-custom --from-literal='password=test'

```
```yaml
# initialRootPassword:
#   secret: gitlab-root-password-custom
#   key: password

```

<br><br>

### Check ingress object
```shell
kubectl describe ingress gitlab-dev-webservice-default -n dev
```

<br><br>

### Git
- Git is available over port 32022. Check this guide for how to to create and to add SSH Key (https://github.com/CyberT33N/git-cheat-sheet/blob/main/README.md#ssh)
  - Then after this you run `ssh-add ~/.ssh/github/id_ecdsa` and then after this:
```shell
git remote add gitlabInternal ssh://git@gitlab.local.com:32022/websites/anyTest.git

```