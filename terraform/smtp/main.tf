# Fetch AWS subnet data
data "aws_subnet" "main" {
  id = var.subnet_id
}

# SMTP instance
resource "aws_instance" "smtp" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.smtp.id,
  ]

  subnet_id = var.subnet_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_smtp" : "smtp"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# SMTP security group
resource "aws_security_group" "smtp" {
  name        = var.name_prefix != "" ? "${var.name_prefix}_smtp_sg" : "smtp_sg"
  description = "Security group for SMTP instance"
  vpc_id      = data.aws_subnet.main.vpc_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_smtp_sg" : "smtp_sg"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

resource "aws_security_group_rule" "smtp_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.smtp.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "smtp_ingress_controller" {
  type              = "ingress"
  from_port         = 25
  to_port           = 25
  protocol          = "tcp"
  security_group_id = aws_security_group.smtp.id
  cidr_blocks = [
    data.aws_subnet.main.cidr_block,
  ]
}

resource "aws_security_group_rule" "smtp_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.smtp.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "smtp_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.smtp.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "smtp_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.smtp.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
