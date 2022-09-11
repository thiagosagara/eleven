terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.16" 
      }
    }
}

provider "aws" {
    region = var.region

}

# VPC:
#   CIDR: 192.168.0.0/20
#   subnetA_privada: 192.168.0.0/24 (1a)
#   subnetB_privada: 192.168.2.0/24 (1b)
#   NatGateway
#resource "aws_vpc" "blog-sagaratec-vpc" {
# 
#}


# EC2: 
#   instalação no userdata:
#       apt update -y
#       apt install ansible unzip -y
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#       wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
#       echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
#       sudo apt update && sudo apt install terraform
#
#   Security-Group:
#       name: blog-sagaratec-web
#       porta: HTTP

resource "aws_security_group" "blog-sagaratec-web" {
  name        = var.name_security_group_web
  description = "Permite acesso HTTP para app"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks       = ["0.0.0.0/0"]
    description       = "HTTP"
    protocol          = "tcp"
    from_port         = 80
    to_port           = 80
  }

  ingress {
    cidr_blocks       = ["0.0.0.0/0"]
    description       = "SSH"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
  }

  egress {
    cidr_blocks       = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks  = [ "::/0" ]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"   
  }
  
  tags = {
    Name = "blog-sagaratec-web"
  } 
  
}


resource "aws_instance" "blog-sagaratec-app" {
  ami                         = var.ami_aws_instance
  instance_type               = var.type_aws_instance
  vpc_security_group_ids      = [aws_security_group.blog-sagaratec-web.id]
  key_name                    = var.key_aws_instance
  monitoring                  = true
  subnet_id                   = var.subnet_id_aws_instance
  associate_public_ip_address = true

  user_data = <<EOF
  #!/bin/bash		
  apt update -y && apt install curl ansible unzip -y

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  
  
  EOF

  tags = {
    Name = "srv-blog-sagaratec-template"
  }
}


# RDS:
#   engine: mysql 5.7
#   user:   wpuser
#   name:   wordpress
#   pass:   Wp@12345
#   type: t2.micro
#   storage: 20Gb
#   AZ: 1a e 1b
#   Security-Group:
#       name: blog-sagaratec-db
#       porta: 3306
#       Allow: blog-sagaratec-web
#
#   Setar multiAZ
#resource "aws_rds_cluster_instance" "blog-sagaratec-db" {
#  
#}
resource "aws_security_group" "blog-sagaratec-db" {
  name        = var.name_blog-sagaratec-db
  description = "Permite acesso do EC2 no RDS"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks       = ["0.0.0.0/0"]
    description       = "Banco"
    protocol          = "tcp"
    from_port         = 3306
    to_port           = 3306
  }

  egress {
    cidr_blocks       = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks  = [ "::/0" ]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"   
  }
  
  tags = {
    Name = "blog-sagaratec-db"
  } 
  
}




# ElastiCache:
#   Security-Group
#       name: blog-sagaratec-sessoes
#       allow: blog-sagaratec-web 
#       porta: 11211
#   Subnet:
#       name: cache-sessoes-blog-sagaratec
#    Cluster MemCached:
#       name: blog-sagaratec-sessoes
#       type: cache.t4g.micro
#       versao: 1.6.6
#       nós: 2
#       AZ: 1a e 1b
#       
#resource "aws_elasticache_cluster" "blog-sagaratec-sessoes" {
#  
#}
resource "aws_security_group" "blog-sagaratec-sessoes" {
  name        = var.name_blog-sagaratec-sessoes
  description = "Permite acesso do EC2 no ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks       = ["0.0.0.0/0"]
    description       = "ElastiCache"
    protocol          = "tcp"
    from_port         = 11211
    to_port           = 11211
  }

  egress {
    cidr_blocks       = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks  = [ "::/0" ]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"   
  }
  
  tags = {
    Name = "blog-sagaratec-sessoes"
  } 
  
}


# Load Balancer:
#   ALB
#   forward 80 to 443
#   health_check: info.php
#resource "aws_alb" "blog-sagaratec-lb" {
#  
#}























