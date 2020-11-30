data "aws_subnet" "main" {
  id = var.subnet_id
}

# NGINX Plus agent instance(s)
resource "aws_instance" "nginx_plus_agent" {
  count                       = var.nginx_plus_agent_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.nginx_plus_agent.id,
  ]
  subnet_id = var.subnet_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_nginx_plus_agent" : "nginx_plus_agent"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# Create AWS security group for NGINX Controller agent instances
resource "aws_security_group" "nginx_plus_agent" {
  name        = var.name_prefix != "" ? "${var.name_prefix}_nginx_plus_agent_sg" : "nginx_plus_agent_sg"
  description = "Security group for NGINX Plus agent instance"
  vpc_id      = data.aws_subnet.main.vpc_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_nginx_plus_agent_sg" : "nginx_plus_agent_sg"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

resource "aws_security_group_rule" "nginx_plus_agent_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_plus_agent.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_plus_agent_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_plus_agent.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_plus_agent_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_plus_agent.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_plus_agent_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_plus_agent.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_plus_agent_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_plus_agent.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "nginx_plus_agent_egress_controller" {
  type              = "egress"
  from_port         = 8443
  to_port           = 8443
  protocol          = "tcp"
  security_group_id = aws_security_group.nginx_plus_agent.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
