#!/bin/bash
set -e

# 1. OPTIONAL: CREATE SWAP (Safety Net for Stability)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# 2. INSTALL K3S
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=metrics-server" sh -

# 3. FIX PERMISSIONS FOR UBUNTU USER (So you don't need sudo)
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config
chmod 600 /home/ubuntu/.kube/config
echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >> /home/ubuntu/.bashrc

# 4. WAIT FOR K8S TO BE READY (Wait up to 60s)
echo "Waiting for K3s to allow connections..."
for i in {1..30}; do
  if kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml > /dev/null 2>&1; then
    break
  fi
  sleep 2
done

# 5. INSTALL ARGOCD
kubectl create namespace argocd --kubeconfig /etc/rancher/k3s/k3s.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml

# 6. PATCH SERVICE TO NODEPORT (Open Port 30080)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "targetPort": 8080, "nodePort": 30080}]}}' --kubeconfig /etc/rancher/k3s/k3s.yaml

echo "Bootstrap Complete"