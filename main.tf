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
  #for_each = var.nombres_servicios
  count = local.nombre_workspace == "produccion" ? 2 : 1
  ami           = "ami-0023593d16b53b3e9"
  instance_type = "t3.micro"
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.security-group.security_group_id]
  associate_public_ip_address = true
  tags = {
    Nombre    = format("%s-%s",local.nombre_workspace,count.index)  #"ServidorTerraform-${each.key}"
    Owner     = ""
    Instancia = "EC2: Elastic Compute Cloud"
    AlgunTag = local.tag_name
  }
}

locals {
  tag_name = "un-tag"
  nombre_workspace = terraform.workspace
  ruta_private_key = "home/rusok/Documentos/DevOps/ejemploTerraform/clasesdevops.pem"
  nombre_key = "clasesdevops"
  usuario_ssh = "ubuntu"
  # continuar en resources
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
