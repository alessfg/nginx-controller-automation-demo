# Fetch AWS subnet data
data "aws_subnet" "main" {
  id = var.subnet_id
}

# PostgreSQL DB instance
resource "aws_instance" "postgresql" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [
    aws_security_group.postgresql.id,
  ]
  subnet_id = var.subnet_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_postgresql" : "postgresql"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# PostgreSQL security group
resource "aws_security_group" "postgresql" {
  name        = var.name_prefix != "" ? "${var.name_prefix}_postgresql_sg" : "postgresql_sg"
  description = "Security group for PostgreSQL DB instance"
  vpc_id      = data.aws_subnet.main.vpc_id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_postgresql_sg" : "postgresql_sg"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

resource "aws_security_group_rule" "postgresql_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.postgresql.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "postgresql_ingress_controller" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.postgresql.id
  cidr_blocks = [
    data.aws_subnet.main.cidr_block,
  ]
}

resource "aws_security_group_rule" "postgresql_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.postgresql.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "postgresql_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.postgresql.id
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
