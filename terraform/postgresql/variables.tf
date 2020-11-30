variable "ami_id" {
  description = "The AMI ID for the PostgreSQL instance"
  type        = string
}

variable "instance_type" {
  default     = "c5.xlarge"
  description = "The instance type for your PostgreSQL instance"
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
  default     = null
  description = "Owner of resources being created (included as a tag)"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for your PostgreSQL instance"
  type        = string
}
