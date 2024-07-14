#!/bin/bash

# ==== COMMANDS ====
# bash ./reinstall.sh --> to reinstall only deployments
# bash ./reinstall.sh --full --> to delete minikubereinstall everything

# bash ./reinstall.sh --mongodb --> to delete only MongoDB
# bash ./reinstall.sh --gitlab --> to delete only Gitlab

if [ "$1" = "--full" ]; then
     echo "Deleting Minikube and reinstalling everything.."

     minikube delete

     bash ./start.sh
     bash ./install.sh
elif [ "$1" = "--mongodb" ]; then
     echo "Reinstalling only MongoDB.."
     helm -n dev uninstall mongodb-dev
     bash ./mongodb/setup.sh
elif [ "$1" = "--gitlab" ]; then
     echo "Reinstalling only Gitlab.."
     helm -n dev uninstall gitlab-dev
     bash ./gitlab/setup.sh
else
     echo "Reinstalling only Deployments.."
     helm -n dev uninstall mongodb-dev
     helm -n dev uninstall gitlab-dev
     bash ./install.sh
fi