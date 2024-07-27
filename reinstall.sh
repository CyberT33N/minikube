#!/bin/bash

# ==== COMMANDS ====
# bash ./reinstall.sh --> To reinstall only deployments
# bash ./reinstall.sh --full --> **To delete minikube and reinstall everything**

# bash ./reinstall.sh --mongodb --> To delete only MongoDB
# bash ./reinstall.sh --gitlab --> To delete only Gitlab
# bash ./reinstall.sh --minio --> To delete only MinIO

if [ "$1" = "--full" ]; then
     echo "Deleting Minikube and reinstalling everything.."

     minikube delete

     bash ./start.sh
     bash ./install.sh
elif [ "$1" = "--mongodb" ]; then
     echo "Reinstalling only MongoDB.."
     bash ./mongodb/uninstall.sh
     bash ./mongodb/setup.sh
elif [ "$1" = "--minio" ]; then
     echo "Reinstalling only MinIO.."
     bash ./minio/uninstall.sh
     bash ./minio/setup.sh
elif [ "$1" = "--gitlab" ]; then
     echo "Reinstalling only Gitlab.."
     bash ./gitlab/uninstall.sh
     bash ./gitlab/setup.sh
else
     echo "Reinstalling only Deployments.."

     bash ./mongodb/uninstall.sh
     bash ./minio/uninstall.sh
     bash ./gitlab/uninstall.sh
     
     bash ./install.sh
fi