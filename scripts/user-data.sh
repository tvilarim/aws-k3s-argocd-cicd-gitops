#!/bin/bash

# --- STEP 1: CREATE SWAP (FAKE RAM) ---
# We create a 4GB file on disk to use as extra memory
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# Optimize system to use Swap only when necessary
sysctl -w vm.swappiness=20
echo 'vm.swappiness=20' >> /etc/sysctl.conf

# --- STEP 2: INSTALL UTILITIES ---
apt-get update && apt-get install -y curl

# --- STEP 3: INSTALL K3S (LIGHTWEIGHT K8S) ---
# We disable traefik and metrics-server to save precious RAM
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=metrics-server" sh -

# Wait for K3s to wake up
sleep 30

# --- STEP 4: INSTALL ARGOCD ---
kubectl create namespace argocd --kubeconfig /etc/rancher/k3s/k3s.yaml
# We use the 'core' installation which is lighter
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml

# Patch Service to NodePort so we can access it
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "targetPort": 8080, "nodePort": 30080}]}}' --kubeconfig /etc/rancher/k3s/k3s.yaml

echo "Bootstrap Complete"