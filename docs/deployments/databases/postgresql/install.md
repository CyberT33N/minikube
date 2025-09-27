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
