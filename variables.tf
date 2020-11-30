variable "ami_name_postgresql" {
  default     = "PostgreSQL"
  description = "The AMI name for the PostgreSQL AMI"
  type        = string
}

variable "ami_name_smtp" {
  default     = "SMTP"
  description = "The AMI name for the SMTP AMI"
  type        = string
}

variable "ami_name_nginx" {
  default     = "NGINX"
  description = "The AMI name for the NGINX AMI"
  type        = string
}

variable "ami_name_nginx_controller" {
  default     = "NGINX Controller"
  description = "The AMI name for the NGINX Controller AMI"
  type        = string
}

variable "key_name" {
  description = "The key used to ssh into your AWS instance"
  type        = string
}

variable "key_location" {
  description = "The location of the key used to ssh into your AWS instance"
  type        = string
}

variable "nginx_controller_fqdn" {
  description = "NGINX Controller's FQDN"
  type        = string
}

variable "nginx_controller_license_location" {
  description = "NGINX Controller's FQDN"
  type        = string
}

variable "nginx_controller_tarball_location" {
  description = "Tarball location of NGINX Controller"
  type        = string
}

variable "nginx_plus_certificate" {
  description = "The path to your NGINX Plus certificate"
  type        = string
}

variable "nginx_plus_key" {
  description = "The path to your NGINX Plus key"
  type        = string
}

variable "owner" {
  description = "Owner of resources being created (included as a tag)"
  type        = string
}

variable "region" {
  default     = "us-west-1"
  description = "Your target AWS region"
  type        = string
}

variable "run_packer" {
  default     = true
  description = "Run Packer builds from within Terraform"
  type        = bool
}

variable "run_ansible" {
  default     = true
  description = "Run Ansible playbooks from within Terraform"
  type        = bool
}
