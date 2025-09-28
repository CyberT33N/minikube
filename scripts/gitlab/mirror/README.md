# Mirror GitHub to GitLab

```shell
export GITHUB_TOKEN=ghp_xxx
export GITLAB_TOKEN=glpat_xxx
export GITLAB_BASE_URL=http://<gitlab-host-oder-ingress>
export GITLAB_NAMESPACE_PATH=my-root-group   # optional
export INCLUDE_FORKS=false                   # optional
export VISIBILITY=private                    # optional: private|internal|public
export DRY_RUN=true                          # zuerst testen
export CONCURRENCY=4                         # optional

node --experimental-strip-types /home/t33n/Projects/environments/minikube/scripts/gitlab/mirror-github-to-gitlab.ts
```