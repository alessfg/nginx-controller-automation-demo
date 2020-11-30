# Create AWS main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_vpc" : "vpc"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# Create AWS main subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_subnet" : "subnet"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# Create AWS internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name  = var.name_prefix != "" ? "${var.name_prefix}_gateway" : "gateway"
    Owner = var.owner != "" ? var.owner : "Terraform"
  }
}

# Configure AWS network route
resource "aws_route" "main" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
