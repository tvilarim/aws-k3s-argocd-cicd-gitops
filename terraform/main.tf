terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "k8s-lab-state-1765995194" # <--- YOUR BUCKET NAME HERE
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Security Group
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

# The EC2 Instance
resource "aws_instance" "k8s_node" {
  # Ubuntu 22.04 LTS (HVM) - Standard ID for us-east-1
  ami           = "ami-0c7217cdde317cfec" 
  
  # UPGRADE: t3.medium (2 vCPU, 4GB RAM)
  # Uses your $118 credit effectively.
  instance_type = "t3.medium"
  
  key_name      = "k8s-lab-key"
  
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # User data script (Install K3s)
  user_data = file("${path.module}/../scripts/user-data.sh")

  tags = {
    Name = "K3s-ArgoCD-Paid"
  }
}

output "public_ip" {
  value = aws_instance.k8s_node.public_ip
}