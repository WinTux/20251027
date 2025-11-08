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
  ami           = "ami-0ec4ab14b1c5a10f2"
  instance_type = "t3.micro"
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.security-group.security_group_id]
  associate_public_ip_address = true
  key_name = local.nombre_key
  tags = {
    Nombre    = format("%s-%s",local.nombre_workspace,count.index)  #"ServidorTerraform-${each.key}"
    Owner     = ""
    Instancia = "EC2: Elastic Compute Cloud"
    AlgunTag = local.tag_name
  }
  provisioner "remote-exec" {
    inline = ["echo 'Esperando conexión SSH de ${self.public_ip}'"]
    connection {
      type = "ssh"
      user = local.usuario_ssh
      private_key = file(local.ruta_private_key)
      host = self.public_ip
      timeout = "5m"
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, --private-key ${local.ruta_private_key} nginx.yml"
  }
}

locals {
  tag_name = "un-tag"
  nombre_workspace = terraform.workspace
  ruta_private_key = "/home/rusok/Documentos/DevOps/ejemploTerraform/clasesdevops.pem"
  nombre_key = "clasesdevops"
  usuario_ssh = "ubuntu"
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
