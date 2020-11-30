resource "null_resource" "build_nginx_ami" {
  count = var.run_packer ? 1 : 0
  provisioner "local-exec" {
    command = "packer build -var='nginx_plus_certificate=${var.nginx_plus_certificate}' -var='nginx_plus_key=${var.nginx_plus_key}' -var='ami_name=${var.ami_name_nginx}' -var='owner=${var.owner}' packer/nginx/nginx.pkr.hcl"
  }
}

resource "null_resource" "build_nginx_controller_ami" {
  count = var.run_packer ? 1 : 0
  provisioner "local-exec" {
    command = "packer build -var='nginx_controller_tarball_location=${var.nginx_controller_tarball_location}' -var='ami_name=${var.ami_name_nginx_controller}' -var='owner=${var.owner}' packer/nginx-controller/nginx-controller.pkr.hcl"
  }
}

resource "null_resource" "build_postgresql_ami" {
  count = var.run_packer ? 1 : 0
  provisioner "local-exec" {
    command = "packer build -var='ami_name=${var.ami_name_postgresql}' -var='owner=${var.owner}' packer/postgresql/postgresql.pkr.hcl"
  }
}

resource "null_resource" "build_smtp_ami" {
  count = var.run_packer ? 1 : 0
  provisioner "local-exec" {
    command = "packer build -var='ami_name=${var.ami_name_smtp}' -var='owner=${var.owner}' packer/smtp/smtp.pkr.hcl"
  }
}

data "aws_ami" "nginx" {
  owners = [
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.ami_name_nginx,
    ]
  }
  depends_on = [
    null_resource.build_nginx_ami,
  ]
}

data "aws_ami" "nginx_controller" {
  owners = [
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.ami_name_nginx_controller,
    ]
  }
  depends_on = [
    null_resource.build_nginx_controller_ami,
  ]
}

data "aws_ami" "postgresql" {
  owners = [
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.ami_name_postgresql,
    ]
  }
  depends_on = [
    null_resource.build_postgresql_ami,
  ]
}

data "aws_ami" "smtp" {
  owners = [
    "self"
  ]
  filter {
    name = "name"
    values = [
      var.ami_name_smtp,
    ]
  }
  depends_on = [
    null_resource.build_smtp_ami,
  ]
}

module "network" {
  # Module source
  source = "./terraform/network"
  # Module variables
  owner = var.owner
}

module "nginx" {
  # Module source
  source = "./terraform/nginx"
  # Module variables
  ami_id    = data.aws_ami.nginx.id
  key_name  = var.key_name
  subnet_id = module.network.subnet_id
  owner     = var.owner
}

module "nginx_controller" {
  # Module source
  source = "./terraform/nginx-controller"
  # Module variables
  nginx_controller_fqdn = var.nginx_controller_fqdn
  ami_id                = data.aws_ami.nginx_controller.id
  key_name              = var.key_name
  subnet_id             = module.network.subnet_id
  owner                 = var.owner
}

module "postgresql" {
  # Module source
  source = "./terraform/postgresql"
  # Module variables
  ami_id    = data.aws_ami.postgresql.id
  key_name  = var.key_name
  subnet_id = module.network.subnet_id
  owner     = var.owner
}

module "smtp" {
  # Module source
  source = "./terraform/smtp"
  # Module variables
  ami_id    = data.aws_ami.smtp.id
  key_name  = var.key_name
  subnet_id = module.network.subnet_id
  owner     = var.owner
}

resource "null_resource" "install_nginx_controller" {
  count = var.run_ansible ? 1 : 0
  provisioner "remote-exec" {
    inline = [
      "echo 'Instance up and ready'",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_location)
      host        = var.nginx_controller_fqdn
    }
  }
  provisioner "local-exec" {
    command = <<EOT
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook --private-key ${var.key_location} -i ${var.nginx_controller_fqdn}, -u ubuntu ansible/nginx-controller-install.yml \
--extra-vars 'nginx_controller_license_location=${var.nginx_controller_license_location} nginx_controller_tarball_location=${var.nginx_controller_tarball_location} nginx_controller_fqdn=${var.nginx_controller_fqdn} nginx_controller_db_host=${module.postgresql.private_ip} nginx_controller_smtp_host=${module.smtp.private_ip}'
EOT
  }
  depends_on = [
    module.nginx_controller,
  ]
}

resource "null_resource" "install_nginx_controller_agent" {
  count = var.run_ansible ? length(module.nginx.public_ip) : 0
  provisioner "remote-exec" {
    inline = [
      "echo 'Instance up and ready'",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_location)
      host        = module.nginx.public_ip[count.index]
    }
  }
  provisioner "local-exec" {
    command = <<EOT
ansible-galaxy install -r ansible/requirements.yml
ansible-playbook --private-key ${var.key_location} -i ${module.nginx.public_ip[0]}, -u ubuntu ansible/nginx-controller-agent.yml \
--extra-vars 'controller_fqdn=${var.nginx_controller_fqdn}'
EOT
  }
  depends_on = [
    module.nginx,
    null_resource.install_nginx_controller,
  ]
}
