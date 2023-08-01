terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/26"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.0.0/28", "10.0.0.16/28"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.0.32/28", "10.0.0.48/28"]
}

resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "Project VPC IG"
  }
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_subnet_association" {
  count           = length(var.public_subnet_cidrs)
  subnet_id       = aws_subnet.public_subnets[count.index].id
  route_table_id  = aws_route_table.public_route_table.id
}

# Create private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "private_route_table"
  }
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_subnet_association" {
  count           = length(var.private_subnet_cidrs)
  subnet_id       = aws_subnet.private_subnets[count.index].id
  route_table_id  = aws_route_table.private_route_table.id
}

# Create NAT gateway
resource "aws_eip" "nat_eip" {
  vpc      = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
}

# Create default route in private route table pointing to NAT gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}



