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
