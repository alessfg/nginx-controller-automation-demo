variable "name_prefix" {
  default     = ""
  description = "Naming prefix of resources being created"
  type        = string
}

variable "owner" {
  default     = null
  description = "Owner of resources being created (included as a tag)"
  type        = string
}

variable "subnet_cidr" {
  default     = "10.0.0.0/24"
  description = "CIDR of the main subnet"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR of the main VPC"
  type        = string
}
