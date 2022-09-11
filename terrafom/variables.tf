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

variable "vpc_id" {
  default = "vpc-04b0e6cbb6efbafa3"
}

variable "ami_aws_instance" {
  default = "ami-052efd3df9dad4825"
}

variable "type_aws_instance" {
  default = "t3.micro"
}

variable "subnet_id_aws_instance" {
  default = "subnet-06a2288581eb2a944"
}

variable "key_aws_instance" {
  default = "eleven-sagara"
}
