variable "ami_name" {
  default     = "NGINX"
  description = "Name of AMI to be created"
  type        = string
}

variable "instance_type" {
  default     = "t3.medium"
  description = "The instance type for the AMI build"
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
  default     = ""
  description = "Owner of resources being created (included as a tag)"
  type        = string
}

variable "region" {
  default     = "us-west-1"
  description = "Your target AWS region"
  type        = string
}

variable "source_ami" {
  default     = "ami-0a741b782c2c8632d"
  description = "Source AMI ID to base this build on"
  type        = string
}

source "amazon-ebs" "nginx" {
  # AMI configuration
  ami_name              = var.ami_name
  ami_description       = "${var.ami_name} AMI"
  force_deregister      = true
  force_delete_snapshot = true
  ssh_username          = "ubuntu"
  tags = {
    Name  = "${var.ami_name} AMI"
    Owner = var.owner != "" ? var.owner : "Packer"
  }
  # Access configuration
  region        = var.region
  # Run configuration
  instance_type = var.instance_type
  source_ami    = var.source_ami
}

build {
  description = "Install NGINX"
  sources = [
    "source.amazon-ebs.nginx"
  ]
  provisioner "ansible" {
    extra_arguments = [
      "--extra-vars",
      "nginx_plus_certificate=${var.nginx_plus_certificate} nginx_plus_key=${var.nginx_plus_key}",
    ]
    galaxy_file   = "${path.root}/requirements.yml"
    playbook_file = "${path.root}/nginx.yml"
    # Global parameters
    max_retries = 2
    pause_before = "10s"
  }
}
