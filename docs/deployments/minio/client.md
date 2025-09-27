### 🛠️ MinIO Client

#### 📥 Install
- [MinIO Client Documentation](https://min.io/docs/minio/linux/reference/minio-mc.html)
- Check architecture with `uname - m`:
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
