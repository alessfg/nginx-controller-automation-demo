variable "ami_id" {
  description = "The AMI ID for the NGINX Controller instance"
  type        = string
}

variable "nginx_controller_fqdn" {
  description = "The FQDN of NGINX Controller"
  type        = string
}

variable "instance_type" {
  default     = "c5.2xlarge"
  description = "The instance type for your NGINX Controller instance"
  type        = string
}

variable "key_name" {
  default     = null
  description = "The key used to ssh into your instance"
  type        = string
}
variable "name_prefix" {
  default     = ""
  description = "Naming prefix of resources being created"
  type        = string
}
variable "owner" {
  default     = ""
  description = "Owner of resources being created (included as a tag)"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for your NGINX Controller instance"
  type        = string
}
