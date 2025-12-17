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

# 1. Get the latest Ubuntu 22.04 AMI automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Official Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Security Group
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

# 3. The EC2 Instance
resource "aws_instance" "k8s_node" {
  ami           = data.aws_ami.ubuntu.id # Use the auto-found AMI
  instance_type = "t2.micro"             # <--- CHANGED TO T2.MICRO (Classic Free Tier)
  key_name      = "k8s-lab-key"
  
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # User data script to install K3s + Swap
  user_data = file("${path.module}/../scripts/user-data.sh")

  tags = {
    Name = "K3s-ArgoCD-FreeTier"
  }
}

output "public_ip" {
  value = aws_instance.k8s_node.public_ip
}