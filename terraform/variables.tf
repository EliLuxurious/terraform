variable "aws_region" {
  default = "us-east-2"
}

variable "key_name" {
  description = "Nombre de la key pair existente en AWS"
}

variable "repo_url" {
  default = "https://github.com/EliLuxurious/cloud_dev_api.git"
}

variable "elia_public_host" {
  description = "IP pública donde están clima y temblor"
}

variable "instance_type" {
  default = "t3.micro"
}
