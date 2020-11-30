variable "ami_id" {
  description = "The AMI ID for the NGINX Plus agent instance"
  type        = string
}
variable "nginx_plus_agent_count" {
  default     = 1
  description = "Number of NGINX Plus agent instances"
  type        = number
}

variable "key_name" {
  description = "The key used to ssh into your AWS instance"
  type        = string
}

variable "instance_type" {
  default     = "c5.xlarge"
  description = "The instance type for your NGINX Plus agent instance"
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
  description = "The subnet ID for your NGINX Plus agent instance"
  type        = string
}
