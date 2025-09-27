### 🔒 Certificates
- This section is not required for the GitLab Helm chart in Minikube due to the automated creation of self-signed certificates. However, it may be useful for others.

#### ✍️ Create Self-Signed Certificate
```shell
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout gitlab.local.com.key -out gitlab.local.com.crt -subj "/C=DE/ST=Some-State/L=City/O=Organization/OU=Department/CN=local.com"
```

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
