### 🔑 Change Password

#### 💻 Method #1 - UI
- You can access the GitLab instance by visiting the specified domain. In this example, `https://gitlab.192.168.99.100.nip.io` is used. If you manually created the secret for the initial root password, you can use that to sign in as the root user. If not, GitLab automatically generates a random password for the root user, which can be extracted using the following command (replace `<name>` with the name of the release, which is `gitlab` if you used the command above):
```shell
kubectl get -n dev secret gitlab-dev-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```
- You can change the password by signing in, right-clicking on your avatar, and selecting edit > password.

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
