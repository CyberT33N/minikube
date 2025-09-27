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
