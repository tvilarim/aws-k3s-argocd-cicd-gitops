terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Stores the state in S3 so GitHub Actions doesn't "forget" the server
  backend "s3" {
    bucket = "k8s-lab-state-1765995194" 
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Security Group: Allow SSH (22), ArgoCD UI (30080), K8s API (6443)
resource "aws_security_group" "k8s_sg" {
  name = "k8s-lab-sg"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The EC2 Spot Instance
resource "aws_instance" "k8s_node" {
  ami           = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS (us-east-1)
  instance_type = "t3a.medium"
  key_name      = "k8s-lab-key"
  
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # Spot Request (Lowest Cost)
  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = "0.0150"
    }
  }

  user_data = file("${path.module}/../scripts/user-data.sh")

  tags = {
    Name = "K3s-ArgoCD"
  }
}

output "public_ip" {
  value = aws_instance.k8s_node.public_ip
}