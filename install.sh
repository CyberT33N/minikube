## MongoDB
helm install mongodb-dev ./mongodb/Chart --namespace dev -f ./mongodb/custom-values.yaml

## Gitlab
helm install gitlab-dev ./gitlab/Chart --namespace dev -f ./gitlab/custom-values.yaml