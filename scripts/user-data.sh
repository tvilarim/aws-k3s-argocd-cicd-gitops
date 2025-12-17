#!/bin/bash
# Update system
apt-get update && apt-get install -y curl

# Install K3s (Kubernetes)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -

# Wait for K3s to be ready
sleep 30

# Install ArgoCD
kubectl create namespace argocd --kubeconfig /etc/rancher/k3s/k3s.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --kubeconfig /etc/rancher/k3s/k3s.yaml

# Expose ArgoCD Server on Port 30080 (NodePort)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort", "ports": [{"port": 443, "targetPort": 8080, "nodePort": 30080}]}}' --kubeconfig /etc/rancher/k3s/k3s.yaml