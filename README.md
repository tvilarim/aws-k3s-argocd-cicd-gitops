# AWS K3s ArgoCD CI/CD GitOps

[![Deploy via AWS CLI](https://github.com/YOUR_USERNAME/aws-k3s-argocd-cicd-gitops/actions/workflows/deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/aws-k3s-argocd-cicd-gitops/actions/workflows/deploy.yml)

**[🇺🇸 Read in English](#-aws-k3s-argocd-cicd-gitops-english)** | **[🇧🇷 Leia em Português](#-aws-k3s-argocd-cicd-gitops-português)**

---

## 🇺🇸 AWS K3s ArgoCD CI/CD GitOps (English)

A lightweight, cost-optimized **GitOps Laboratory** running on AWS. This project provisions a Kubernetes cluster (K3s) and a Continuous Delivery tool (ArgoCD) on a single EC2 instance using a purely scripted **GitHub Actions Pipeline**.

### 🚀 Key Features

* **Low Cost Architecture:** Runs on a single `t3.small` (or `t3.medium`) Spot Instance.
* **Zero-State Deployment:** Uses AWS CLI directly in the pipeline, removing the complexity of Terraform state files.
* **Automated GitOps Setup:** K3s and ArgoCD are installed and configured automatically via `user-data` scripts.
* **Self-Healing:** The pipeline detects if the server exists; if not, it creates it. If the firewall is missing, it adds it.
* **Storage Optimized:** Automatically requests a 20GB gp3 volume to prevent Kubernetes eviction errors.

### 🛠 Tech Stack

* **Cloud:** AWS EC2 (US-East-1)
* **Orchestrator:** K3s (Lightweight Kubernetes)
* **CD Tool:** ArgoCD
* **Pipeline:** GitHub Actions
* **Scripting:** Bash + AWS CLI

### ⚙️ How to Deploy

1.  **Fork/Clone this repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/aws-k3s-argocd-cicd-gitops.git](https://github.com/YOUR_USERNAME/aws-k3s-argocd-cicd-gitops.git)
    ```

2.  **Set GitHub Secrets:**
    Go to `Settings > Secrets and variables > Actions` and add:
    * `AWS_ACCESS_KEY_ID`: Your AWS Key.
    * `AWS_SECRET_ACCESS_KEY`: Your AWS Secret.

3.  **Push to Main:**
    Any push to the `main` branch triggers the deployment.
    ```bash
    git push origin main
    ```

4.  **Access ArgoCD:**
    Check the GitHub Action logs for the "DEPLOYMENT COMPLETE" section to find your IP.
    * **URL:** `https://<EC2_PUBLIC_IP>:30080`
    * **Username:** `admin`
    * **Password:** Run this command locally:
        ```bash
        ssh -i k8s-lab-key.pem ubuntu@<EC2_PUBLIC_IP> 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo'
        ```

---

## 🇧🇷 AWS K3s ArgoCD CI/CD GitOps (Português)

Um laboratório **GitOps** leve e otimizado para baixo custo na AWS. Este projeto provisiona um cluster Kubernetes (K3s) e uma ferramenta de Entrega Contínua (ArgoCD) em uma única instância EC2, usando um pipeline puramente scriptado via **GitHub Actions**.

### 🚀 Principais Funcionalidades

* **Arquitetura de Baixo Custo:** Roda em uma única instância Spot `t3.small` (ou `t3.medium`).
* **Deploy "Zero-State":** Utiliza AWS CLI diretamente no pipeline, eliminando a complexidade de arquivos de estado do Terraform.
* **Setup GitOps Automatizado:** K3s e ArgoCD são instalados e configurados automaticamente via scripts `user-data`.
* **Auto-Recuperação:** O pipeline detecta se o servidor existe; se não, ele o cria. Se o firewall estiver faltando, ele o adiciona.
* **Otimização de Armazenamento:** Solicita automaticamente um volume gp3 de 20GB para evitar erros de "eviction" do Kubernetes.

### 🛠 Stack Tecnológica

* **Cloud:** AWS EC2 (US-East-1)
* **Orquestrador:** K3s (Kubernetes Leve)
* **Ferramenta CD:** ArgoCD
* **Pipeline:** GitHub Actions
* **Scripting:** Bash + AWS CLI

### ⚙️ Como Implantar

1.  **Fork/Clone este repositório:**
    ```bash
    git clone [https://github.com/SEU_USUARIO/aws-k3s-argocd-cicd-gitops.git](https://github.com/SEU_USUARIO/aws-k3s-argocd-cicd-gitops.git)
    ```

2.  **Configure os Segredos no GitHub:**
    Vá em `Settings > Secrets and variables > Actions` e adicione:
    * `AWS_ACCESS_KEY_ID`: Sua chave de acesso AWS.
    * `AWS_SECRET_ACCESS_KEY`: Sua chave secreta AWS.

3.  **Push na Main:**
    Qualquer push na branch `main` aciona o deploy.
    ```bash
    git push origin main
    ```

4.  **Acessar o ArgoCD:**
    Verifique os logs da GitHub Action na seção "DEPLOYMENT COMPLETE" para encontrar seu IP.
    * **URL:** `https://<IP_PUBLICO_EC2>:30080`
    * **Usuário:** `admin`
    * **Senha:** Execute este comando localmente:
        ```bash
        ssh -i k8s-lab-key.pem ubuntu@<IP_PUBLICO_EC2> 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo'
        ```