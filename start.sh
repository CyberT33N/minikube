#!/bin/bash
set -e

# Prevent "Exiting due to PROVIDER_DOCKER_NEWGRP - dial unix
# /var/run/docker.sock: connect: permission denied"
# sudo usermod -aG docker $USER && newgrp docker

_directory=$(dirname $0)

minikube start \
   --cpus=8 \
   --memory=18G \
   --driver=docker \
   --addons storage-provisioner 

echo "minikube start done.."

MINIKUBE_IP=$(minikube ip)

echo "Minikube IP: $MINIKUBE_IP"

FROM_IP="${MINIKUBE_IP%.*}.$((${MINIKUBE_IP##*.}+1))"
TO_IP="${MINIKUBE_IP%.*}.$((${MINIKUBE_IP##*.}+10))"

# make sure we are in the correct context
kubectl config use minikube
kubectl create namespace dev

# We have to congiure the loadbalancer IPs manually because of https://github.com/kubernetes/minikube/issues/8283
# We configure the IPs for metallb loadbalancer in minikubes config.json and then start metallb addon. It will read the config and use the IPs for the metallb secret `config`.
# This way we can avoid interactive command `minikube addons configure metallb`, and the ips are persistent.
cat ~/.minikube/profiles/minikube/config.json | jq ".KubernetesConfig.LoadBalancerStartIP=\"$FROM_IP\"" | jq ".KubernetesConfig.LoadBalancerEndIP=\"$TO_IP\"" > ~/.minikube/profiles/minikube/config.json.tmp && mv ~/.minikube/profiles/minikube/config.json.tmp ~/.minikube/profiles/minikube/config.json 

minikube addons enable metallb
minikube addons enable ingress
# minikube addons enable metrics-server

_files=$(find  $_directory  | grep 'values')

# make sure Treafik loadbalancer IP is correct in all configs
for file in $_files
do
    while read -r _line; do
    if [ "$_line" != "" ]; then
      # replace loadbalancer ip's with actual ip's from minikube (traefik should always use the first loadbalancer ip)
      sed -E -i "s/([.]*:\s)'([a-z-]*){0,1}([0-9]{1,3}\.){3}[0-9]{1,3}.nip.io'/\1'\2${FROM_IP}.nip.io'/g" $file
    fi
  done <<< $(cat $file | grep 'loadbalancer-IP')  
done

echo "Minikube Loadbalancer can be accessed with ${FROM_IP}.nip.io"

