# ... (Security Group stays the same) ...

resource "aws_instance" "k8s_node" {
  ami           = "ami-04b70fa74e45c3917" # Ubuntu 24.04 LTS
  
  # CHANGE 1: Use a Free Tier eligible type
  instance_type = "t3.micro" 
  
  key_name      = "k8s-lab-key"
  
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  # CHANGE 2: REMOVE the "instance_market_options" block entirely.
  # We will run On-Demand (Free if you are in the first 12 months, or very cheap ~0.01/hr)
  
  user_data = file("${path.module}/../scripts/user-data.sh")

  tags = {
    Name = "K3s-ArgoCD-FreeTier"
  }
}

output "public_ip" {
  value = aws_instance.k8s_node.public_ip
}