variable "region" {
  default =  "us-east-2"
}

#variable "profile" {
#  default = "noprod"
#}

variable "name_security_group_web" {
  default = "blog-sagaratec-web"
}

variable "name_blog-sagaratec-db" {
  default = "blog-sagaratec-db"
}

variable "name_blog-sagaratec-sessoes" {
  default = "blog-sagaratec-sessoes"
}

variable "name_blog-sagaratec-alb" {
  default = "blog-sagaratec-alb"
}

variable "vpc_id" {
  default = "vpc-04b0e6cbb6efbafa3"
}

variable "ami_aws_instance" {
  default = "ami-052efd3df9dad4825"
}

variable "type_aws_instance" {
  default = "t3.micro"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-2a","us-east-2b"]
}

variable "subnet_id_aws_instance" {
  type    = list(string)
  default = ["subnet-06a2288581eb2a944","subnet-0fa9d811cd009de14"]
  #us-east-2a e 2b
}

variable "key_aws_instance" {
  default = "eleven-sagara"
}
