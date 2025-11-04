terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "mi_servidor" {
  for_each = var.nombres_servicios
  ami           = "ami-0023593d16b53b3e9"
  instance_type = "t3.micro"
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.security-group.security_group_id]
  associate_public_ip_address = true
  tags = {
    Nombre    = "ServidorTerraform-${each.key}"
    Owner     = ""
    Instancia = "EC2: Elastic Compute Cloud"
    AlgunTag = local.tag_name
  }
}

locals {
  tag_name = "un-tag"
}

#data "aws_subnet" "default" {
#  default_for_az = true
#}

resource "aws_cloudwatch_log_group" "grupo_log_ec2" {
  for_each = var.nombres_servicios
  tags = {
    Environment = "prueba"
    Servicio = each.key
  }
  lifecycle {
    create_before_destroy = true
  }
}
