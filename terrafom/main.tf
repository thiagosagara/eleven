terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.16" 
      }
    }

    required_version = ">= 1.1.7"
}

provider "aws" {
    region = var.region
}

# VPC:
#   CIDR: 172.31.0.0/20
#   subnetA_privada: 172.31.0.0/24 (a)
#   subnetB_privada: 172.31.2.0/24 (b)
#   NatGateway

# module "vpc" {
#   source               = "../../"

#   cidr                = "172.31.0.0/20"
#   azs                 = ["${var.region}a", "${var.region}b"]
#   public_subnets      = ["172.31.0.0/24", "172.31.2.0/24"]
#   database_subnets    = ["172.31.4.0/24", "172.31.6.0/24"]
#   elasticache_subnets = ["172.31.8.0/24", "172.31.10.0/24"]

#   enable_dns_hostnames = true
#   context = module.this.context
# }


# module "subnets" {
#   source               = "../../"

#   availability_zones   = var.availability_zones
#   vpc_id               = var.vpc_id
#   igw_id               = [module.vpc.igw_id]
#   ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
#   nat_gateway_enabled  = false
#   nat_instance_enabled = false

# }

# EC2: 
#   instalação no userdata:
#       apt update -y
#       apt install ansible unzip -y
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
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
  subnet_id                   = var.subnet_id_aws_instance[0]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash		
  apt update -y && apt install curl ansible unzip git software-properties-common -y
  add-apt-repository ppa:ondrej/php -y && apt update -y

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
    
  cd /opt && git clone https://github.com/thiagosagara/eleven.git && cd eleven/ansible
  ansible-playbook wordpress.yml

  #necessario alterar os endpoints do ALB e do RDS no wp-config.php
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

resource "aws_security_group" "blog-sagaratec-db" {
  name        = var.name_blog-sagaratec-db
  description = "Permite acesso do EC2 no RDS"
  vpc_id      = var.vpc_id

  ingress {
    security_groups = [aws_security_group.blog-sagaratec-web.id]
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

resource "aws_db_instance" "default" {
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "5.7.38"
  instance_class          = "db.t3.micro"
  db_name                 = "wordpress"
  username                = "wpuser"
  password                = "Wp-13579"
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.blog-sagaratec-db.id]
  multi_az                = true
  availability_zone       = var.availability_zones[0]
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
#       nós: 1
#       
resource "aws_security_group" "blog-sagaratec-sessoes" {
  name        = var.name_blog-sagaratec-sessoes
  description = "Permite acesso do EC2 no ElastiCache"
  vpc_id      = var.vpc_id

  ingress {
    security_groups = [aws_security_group.blog-sagaratec-web.id]
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

resource "aws_elasticache_cluster" "blog-sagaratec-sessoes" {
  cluster_id            = "blog-sagaratec-sessoes"
  engine                = "memcached"
  node_type             = "cache.t4g.micro"
  num_cache_nodes       = 1
  version               = "1.6.6"
  parameter_group_name  = "default.memcached1.4"
  port                  = 11211
  availability_zone     = var.availability_zones[0]
}

# Load Balancer:
#   ALB
#   forward 80 to 443
#   health_check: info.php

resource "aws_acm_certificate" "blog-sagaratec-cert" {
  domain_name       = "sagara.tec.br"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "blog-sagaratec-alb" {
  name        = var.name_blog-sagaratec-alb
  description = "Liberacoes para ALB"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    description   = "ALB"
    protocol      = "HTTP"
    from_port     = 80
    to_port       = 80
  }

  ingress {
    cidr_blocks   = ["0.0.0.0/0"]
    description   = "ALB"
    protocol      = "HTTPS"
    from_port     = 443
    to_port       = 443
  }

  egress {
    cidr_blocks       = [ "0.0.0.0/0" ]
    ipv6_cidr_blocks  = [ "::/0" ]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"   
  }
  
  tags = {
    Name = "blog-sagaratec-alb"
  } 
  
}

resource "aws_lb" "blog-sagaratec-lb" {
  name               = "blog-sagaratec-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.blog-sagaratec-alb.id]
  subnets            = var.availability_zones
}

resource "aws_lb_listener" "blog-sagaratec-lb-listener-http" {
  load_balancer_arn = aws_lb.blog-sagaratec-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "blog-sagaratec-lb-listener-https" {
  load_balancer_arn = aws_lb.blog-sagaratec-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.blog-sagaratec-cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blog-sagaratec-lb-target-group.arn
  }
}

resource "aws_lb_target_group" "blog-sagaratec-lb-target-group" {
  name     = "blog-sagaratec-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

#ASG
resource "aws_ami_from_instance" "blog-sagaratec-ami" {
  name               = "blog-sagaratec-ami"
  source_instance_id = aws_instance.blog-sagaratec-app.id
}

resource "aws_launch_configuration" "blog-sagaratec-launch-config" {
  name          = "blog-sagaratec-launch-config"
  image_id      = aws_ami_from_instance.blog-sagaratec-ami.id
  instance_type = var.type_aws_instance
}

resource "aws_autoscaling_group" "blog-sagaratec-asg" {
  name                 = "blog-sagaratec-asg"
  launch_configuration = aws_launch_configuration.blog-sagaratec-launch-config.name
  min_size             = 1
  max_size             = 2

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "blog-sagaratec-asg-lb" {
  autoscaling_group_name = aws_autoscaling_group.blog-sagaratec-asg.id
  elb                    = aws_lb.blog-sagaratec-lb.id
}

#WAF
resource "aws_wafv2_web_acl" "blog-sagaratec-waf" {
  name  = "blog-sagaratec-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "metric-waf-blog-sagaratec"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "blog-sagaratec-waf-alb" {
  resource_arn = aws_lb.blog-sagaratec-lb.arn
  web_acl_arn  = aws_wafv2_web_acl.blog-sagaratec-waf.arn
}


















