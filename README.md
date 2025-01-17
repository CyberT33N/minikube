
# 🛠️ Minikube
This project will create your local cluster development environment with essential Helm charts. Currently included:

- **GitLab**
- **MinIO**

- Databases:
   - **MongoDB**
   - **PostgreSQL**



<br><br>
<br><br>

## Dependencies

<details>
<summary>Click to expand..</summary>

<br>

### 🐶 K9s
<details>
<summary>Click to expand..</summary>

K9s is a terminal-based UI that allows you to interact with your Kubernetes clusters in a more efficient and user-friendly way. It simplifies the management of Kubernetes resources and provides an intuitive interface for developers and operators alike.



## 📥 Install/Update

1. **Download the latest version of K9s:**
   Visit the [K9s Releases page](https://github.com/derailed/k9s/releases) and download the latest version for your operating system.

2. **Verify your architecture:**
   Use the following command to check your CPU architecture:
   ```shell
   lscpu
   ```

   - For `x86_64`, use the `amd64` version.

3. **Install the corresponding version:**
   For example, to install version 0.32.5 for Linux (amd64), use the following command:
   ```shell
   wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb
   sudo dpkg -i k9s_linux_amd64.deb
   ```

<br>

Once the installation is complete, you can start K9s by running the command `k9s` in your terminal.

</details>
</details>












<br><br><br><br>

## 🔒 UFW
- If you want to deny incoming & outgoing traffic while still working with Minikube, refer to:
  - [UFW Cheat Sheet](https://github.com/CyberT33N/ufw-cheat-sheet/blob/main/README.md#deny-forward-incoming--outgoing)

<br>

### 🌐 VPN
- For some reason, it does not work with a double VPN from NordVPN.

























<br><br><br><br>


## ⚡ Start
- This will start Minikube and create the namespace `dev`.
```shell
start.sh
```

<br>

## 📦 Install
- This will install all deployments.
```shell
install.sh
```

<br>

## 🌍 Minikube IP
- Get your Minikube IP:
```shell
minikube ip
```
- Should be `192.168.49.2` or `192.168.49.2.nip.io`


























<br><br><br><br>


# 🔗 Deployment Links

## 🌟 MinIO
- [MinIO Login](http://192.168.49.2.nip.io:30001/login)
- **User:** `test69696969` | **Password:** `test69696969`




<br><br>


## Databases

<br>

### 🍃 MongoDB

<br>

#### 🔗 Connection String
- `mongodb://root:test@192.168.49.2.nip.io:30644/`

<br>

### 🍃 PostgreSQL

<br>

#### 🔗 Connection String
- `postgresql://test:test@192.168.49.2.nip.io:30543/test`








<br><br>


## 🚀 GitLab

### 🌍 UI
- [GitLab UI](https://gitlab.local.com)
- **Credentials:** `root:69aZc996`

### SSH
```shell
ssh://git@gitlab.local.com:32022
```































<br><br><br><br>

# 📜 Helm Charts






<br>

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




























<br><br>
<br><br>

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








































































<br><br>

## 🗄️ MinIO

<details>
<summary>Click to expand..</summary>

### 🔗 Links

#### UI
- [MinIO UI](http://192.168.49.2.nip.io:30001/login)
  - **User:** `test69696969` | **Password:** `test69696969`

#### API
- **Endpoint:** `http://192.168.49.2.nip.io:30000`
  - **Access Key:** `test69696969` | **Secret Key:** `test69696969`

<br><br>

### ❌ Uninstall

#### 🗑️ Full Uninstall
```shell
# Delete the MinIO namespace and all resources within it
kubectl delete namespace minio-dev
```

#### 🔍 Uninstall Steps
```shell
# Delete the Pod
kubectl delete pod minio -n minio-dev

# Delete the Secret
kubectl delete secret minio-secret -n minio-dev

# Delete the PersistentVolumeClaim
kubectl delete pvc minio-pvc -n minio-dev

# Delete the PersistentVolume
kubectl delete pv minio-pv

# Delete the Service
kubectl delete service minio-service -n minio-dev

# Delete the Namespace
kubectl delete namespace minio-dev
```

<br><br>

### ✅ Install
```shell
bash ./minio/setup.sh
```

<br><br>

### 🔄 Re-install
```shell
bash ./reinstall.sh --minio
```

<br><br>

### 🔼 Upgrade
```shell
bash ./minio/setup.sh
```
- In most cases, just re-running this will detect changes. For credential changes, you must delete the pod. In local environments, use the reinstall script for ease.

<br><br>

### 🛠️ MinIO Client

#### 📥 Install
- [MinIO Client Documentation](https://min.io/docs/minio/linux/reference/minio-mc.html)
- Check architecture with `uname -m`:
  - `x86_64` indicates Intel.

#### 📦 Installation for x86_64
```shell
# ==== INSTALL =====
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

# mc --help

# ==== SET ALIAS =====
# If using zsh, run the mc command in the zsh shell
bash +o history
mc alias set minio http://192.168.49.2.nip.io:30000 test69696969 test69696969
bash -o history

# ==== TEST CONNECTION =====
mc admin info minio
```

<br><br>

### 📦 MinIO for GitLab
- [GitLab Object Storage Documentation](https://docs.gitlab.com/charts/advanced/external-object-storage/minio.html)
- Create the buckets below only when fully switching to external object storage. If this instance is for the GitLab runner only, it's not necessary.

```shell
mc mb minio/gitlab-registry-storage
mc mb minio/gitlab-lfs-storage
mc mb minio/gitlab-artifacts-storage
mc mb minio/gitlab-uploads-storage
mc mb minio/gitlab-packages-storage
mc mb minio/gitlab-backup-storage
```

</details>


















































<br><br>

## 🐙 GitLab
<details>
<summary>Click to expand..</summary>

- The GitLab Helm chart, when configured with the Minikube example from the official documentation, will create its own self-signed certificates. Therefore, there's no need to worry about certificate management, although you can create your own certificates if necessary. However, this is not recommended due to the additional workload involved. You essentially only need to include the generated secret in the GitLab Runner configuration:
```yaml
gitlab-runner:
  install: true
  certsSecretName: gitlab-dev-wildcard-tls-chain
```

<br><br>


### 📚 Guides
- [Minikube Development](https://docs.gitlab.com/charts/development/minikube/)




<br><br>

### 🔗 Links
- [GitLab Sign In](https://gitlab.local.com/users/sign_in)

<br>

#### 🌐 UI
- [GitLab Dashboard](https://gitlab.local.com)
- **Credentials:** root:69aZc996

<br>

#### 🔑 Git SSH
```shell
ssh://git@gitlab.local.com:32022
```





<br><br>
<br><br>

### 🏠 Hosts
- Add the following entries to your `/etc/hosts` file. In your `custom-values.yaml`, you can also add `global.hosts.domain=192.168.49.2.nip.io`.
```shell
sudo gedit /etc/hosts

# ==== MINIKUBE ====
192.168.49.2 gitlab.local.com
192.168.49.2 minio.local.com
```

<br><br>
<br><br>

### 🌩️ MinIO
- I was unable to get the included MinIO release running due to the self-signed TLS certificate issue.
    - [Related Issue](https://gitlab.com/gitlab-org/charts/gitlab-runner/-/issues/75#note_211405230)

- Instead, we can deploy our own MinIO instance and use it within our GitLab Runner. Please refer to the MinIO installation section above or run `./minio/setup.sh`.
  - The setup will also create the necessary `runner-cache` bucket for the GitLab Runner.
  - Additionally, it will generate the required secret `minio-dev` within our `dev` namespace.
```yaml
gitlab-runner:
  runners:
    cache:
    ## S3 secret name.
      secretName: minio-dev
```

- To utilize our own MinIO instance with the GitLab Runner, ensure that the correct configuration is set:
```yaml
# Provide GitLab Runner with the secret object containing the self-signed certificate chain
gitlab-runner:
  install: true
  certsSecretName: gitlab-dev-wildcard-tls-chain

  runners:
    cache:
    ## S3 secret name.
      secretName: minio-dev
    ## Use this line for access using gcs-access-id and gcs-private-key
    # secretName: gcsaccess
    ## Use this line for access using a google-application-credentials file
    # secretName: google-application-credentials
    ## Use this line for access using Azure with azure-account-name and azure-account-key
    # secretName: azureaccess

    config: |
      [[runners]]
        image = "ubuntu:22.04"

        {{- if .Values.global.minio.enabled }}
        [runners.cache]
          Type = "s3"
          Path = "gitlab-runner"
          Shared = true
          [runners.cache.s3]
            AccessKey = "test69696969"
            SecretKey = "test69696969"
            ServerAddress = "192.168.49.2.nip.io:30000"
            BucketName = "runner-cache"
            BucketLocation = "us-east-1"
            Insecure = true
        {{ end }}
```
- **Note:** Both the AccessKey and SecretKey must be set; otherwise, you will encounter an error indicating that the URL cannot be found. The values must be valid.
- In our scenario, the MinIO instance is not using HTTPS, so `Insecure` must be set to `true`.
- As mentioned earlier, the bucket must already exist. You can create it using `mc mb minio/runner-cache`.

<br><br><br><br>

### 🔒 Certificates
- This section is not required for the GitLab Helm chart in Minikube due to the automated creation of self-signed certificates. However, it may be useful for others.

<br><br>

#### ✍️ Create Self-Signed Certificate
```shell
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout gitlab.local.com.key -out gitlab.local.com.crt -subj "/C=DE/ST=Some-State/L=City/O=Organization/OU=Department/CN=local.com"
```

<br><br>

### 📥 Download Certificate and Create Secret
```shell
# Create certificate
openssl s_client -showcerts -connect gitlab.local.com:443 -servername gitlab.local.com < /dev/null 2>/dev/null | openssl x509 -outform PEM > ./gitlab/gitlab.local.com.crt

if kubectl get secret -n dev gitlab-cert-self >/dev/null 2>&1; then
    kubectl delete secret -n dev gitlab-cert-self
fi

kubectl create secret generic gitlab-cert-self \
--namespace dev \
--from-file=./gitlab/gitlab.local.com.crt
```





<br><br>
<br><br>

### 🦊 Git (SSH)
- We utilize NodePort for GitLab shell access, allowing us to push to our repositories. Git is available over port 32022. Refer to this guide for instructions on creating and adding SSH keys: [Git Cheat Sheet](https://github.com/CyberT33N/git-cheat-sheet/blob/main/README.md#ssh).
  - After setting up your SSH keys, run:
```shell
git remote add gitlabInternal ssh://git@gitlab.local.com:32022/websites/test.git
```

<br><br>
<br><br>

### ➕ Add Repository
```shell
# Add GitLab repository
helm repo add gitlab https://charts.gitlab.io/

# Update Helm repository
helm repo update

# List available Helm chart versions
helm search repo gitlab --versions
```

<br><br>
<br><br>

### ⚙️ Install Helm Chart
```shell
# This command downloads the GitLab Helm chart to the folder ./gitlab/Chart
cd ~/Projects/minikube
mkdir -p ./gitlab/Chart

helm pull gitlab/gitlab --version 8.1.2 --untar --untardir ./tmp
cp -r ./tmp/gitlab/* ./gitlab/Chart
rm -rf ./tmp

# Create custom-values.yaml
touch ./gitlab/custom-values.yaml
```
- If you encounter the error `download failed after attempts=6: net/http: TLS handshake timeout` during the GitLab Runner deployment, try:
```shell
unset all_proxy
```

<br><br>

### 🔄 Upgrade Helm Chart
```shell
kubectl config use-context minikube
helm upgrade gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml --atomic
```

<br><br>

### ❌ Delete Release
```shell
kubectl config use-context minikube
helm --namespace dev delete gitlab-dev
```

<br><br>

### 📍 Retrieve IP Addresses
```shell
kubectl get ingress -lrelease=gitlab-dev -n dev
```

<br><br>

### 🔑 Change Password

<br><br>

#### 💻 Method #1 - UI
- You can access the GitLab instance by visiting the specified domain. In this example, `https://gitlab.192.168.99.100.nip.io` is used. If you manually created the secret for the initial root password, you can use that to sign in as the root user. If not, GitLab automatically generates a random password for the root user, which can be extracted using the following command (replace `<name>` with the name of the release, which is `gitlab` if you used the command above):
```shell
kubectl get -n dev secret gitlab-dev-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```
- You can change the password by signing in, right-clicking on your avatar, and selecting edit > password.

<br><br>

#### 🛠️ Method #2 - GitLab Rails
- Use GitLab Rails to change the password. The pod `gitlab-dev-toolbox` can perform this operation:
```shell
kubectl create secret generic gitlab-cert-self \
--namespace dev \
--from-file=./gitlab/gitlab.local.com.crt

NAMESPACE="dev"
POD_NAME=$(kubectl get pods -n dev | grep gitlab-dev-toolbox | awk '{print $1}')

# Check if the pod name was found
if [ -z "$POD_NAME" ]; then
  echo "No pod found with the name 'gitlab-dev-toolbox'."
  exit 1
fi

# Execute the command in the pod
kubectl exec -it $POD_NAME -n $NAMESPACE -- bash -c "gitlab-rails runner \"user = User.find_by(username: 'root'); user.password = 'passwordHere'; user.password_confirmation = '

passwordHere'; user.save!\""
```


<br><br>

#### ⚙️ Method 3 - Helm Chart (Not Tested)
You can create a secret and set it in your `custom-values.yaml` as demonstrated in this guide:
```shell
kubectl create secret -n dev generic gitlab-root-password-custom --from-literal='password=test'
```
```yaml
# initialRootPassword:
#   secret: gitlab-root-password-custom
#   key: password
```

























<br><br><br><br>

## 🔧Useful kubectl commands

<br>

### Ingress

### Check Ingress Object
To inspect the ingress object for your GitLab deployment, use the following command:
```shell
kubectl describe ingress gitlab-dev-webservice-default -n dev
```

<br><br>


</details>