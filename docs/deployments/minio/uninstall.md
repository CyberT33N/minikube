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
