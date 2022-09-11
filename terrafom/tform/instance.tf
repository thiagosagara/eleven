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
    access_key    = "ASIAY5O6NYQ3TQRUFIPM"
    secret_key    = "L6mEdQ84iKyJp+Fnpccf71dioerLi2M89pxRcRMd"
    token         = "IQoJb3JpZ2luX2VjEOP//////////wEaCXVzLWVhc3QtMSJHMEUCIQDCEegC40Nazivi+SMt99KslN+FdipR5MOiGsf5Ixkr8wIgSvxa9yzpgI1XkPEVqiUgACX+XfmpDmkcXxI4Lk56mIgqoQMIexABGgw2MTMwMzYxODA1MzUiDP8FcHc3/zp9YfQprSr+AsQ8ddTaHogEQszjXzR0NJICu7qcnMfYxcagVhaxCqxJ08j/aXMTVL8PHIPhH5jNHLJ6HM5+SRmVJejSrzO06i/Sno8VkssEmTGKFfIFs7u3UWt2FmS2n3ahZSjYsmtWy/6NfQSanFQbmTPugA7hSrcOQV6p6GUbJzr4pD7L5GMFXYiJzdOKFIsgU/UwhhKrln1e/geNhhKHmMSc76sSDwrJ+4tkMAQ787r5+0flg64MnirGb6kEUiWSWkMlIh631yx53bUvhz/e6r2442+oySSa+5Pd3qiNY3NDkP5GZH3kR9jOzsI2njt4qah1byBZtj7BuDEqktjToFQ3DDNKWZE5JG/YLPTn/OIERPaw19s/3wRvMbKAQr2qhffy2qV6a8mTHwF3ZI97nz+9YosTmCeWfXGBYaoHRVmqpAXWA5fFjyNhbnLGesXFC9ZwIalYa0rnezC3gEFfSMpW3Moy9nf3dAy6mc5aoVRQLyVz/tMFKKyXXE/gOUkQrhjmJMEwvMz4mAY6pgE5x4nM3afZKBD7YVyXOJXxr+19pMooBQo9y8Pb2ewkbUSCJ1FwuODCMJzMIpig4tAPwqDsULE79POO4a3TvmSzIklV+DADTg8eJskWLOVsIzMCz/823cajE6toETJIU1w9dOAKGsR2GY9dm2UUD5qYxHeAIzLp1GXQWxY2U1iwuzDNp+26b6v1pyT4zj9ZaEFNSgX/YT412OaEY8JjIFnBc7HE70rF"
}

resource "aws_instance" "blog-sagaratec-app" {
  ami                         = var.ami_aws_instance
  instance_type               = var.type_aws_instance
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