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
