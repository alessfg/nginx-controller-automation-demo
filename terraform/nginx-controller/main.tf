# Fetch AWS subnet data
data "aws_subnet" "main" {
  id = var.subnet_id
}

# NGINX Controller
resource "aws_instance" "nginx_controller" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.nginx_controller.id,
  ]
  subnet_id = var.subnet_id
  root_block_device {
    volume_size = 130
  }
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_nginx_controller" : "nginx_controller"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# Fetch NGINX Controller's EIP allocation ID
data "dns_a_record_set" "nginx_controller" {
  host = var.nginx_controller_fqdn
}

data "aws_eip" "nginx_controller_public_ip" {
  public_ip = data.dns_a_record_set.nginx_controller.addrs[0]
}

# Associate NGINX Controller's EIP
resource "aws_eip_association" "nginx_controller" {
  instance_id   = aws_instance.nginx_controller.id
  allocation_id = data.aws_eip.nginx_controller_public_ip.id
}

# NGINX Controller security group
resource "aws_security_group" "nginx_controller" {
  name        = var.name_prefix != "" ? "${var.name_prefix}_nginx_controller_sg" : "nginx_controller_sg"
  description = "Security group for NGINX Controller instance"
  vpc_id      = data.aws_subnet.main.vpc_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_nginx_controller_sg" : "nginx_controller_sg"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

resource "aws_security_group_rule" "nginx_controller_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_controller_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_controller_ingress_agent" {
  type              = "ingress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_controller_egress_smtp" {
  type              = "egress"
  from_port         = 25
  to_port           = 25
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    data.aws_subnet.main.cidr_block,
  ]
}

resource "aws_security_group_rule" "nginx_controller_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_controller_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_controller_egress_postgresql" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_controller.id
  cidr_blocks = [
    data.aws_subnet.main.cidr_block,
  ]
}
