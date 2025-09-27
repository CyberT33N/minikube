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






</details>
