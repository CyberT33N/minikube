### 🏠 Hosts
- Add the following entries to your `/etc/hosts` file. In your `custom-values.yaml`, you can also add `global.hosts.domain=192.168.49.2.nip.io`.
```shell
sudo gedit /etc/hosts

# ==== MINIKUBE ====
192.168.49.2 gitlab.local.com
192.168.49.2 minio.local.com
```
