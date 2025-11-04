variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "aws_region_otro" {
  type    = string
  default = "xxx"
}

variable "nombres_servicios" {
  description = "Nombres de mis instancias EC2 generadas por foreach"
  type = set(string)
}
