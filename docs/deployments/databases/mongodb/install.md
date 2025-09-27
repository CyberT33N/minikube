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
