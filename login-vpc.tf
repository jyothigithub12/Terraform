# vpc resource creation

resource "aws_vpc" "login-vpc" {
  cidr_block       =var.vpc_cidr
  instance_tenancy =var.vpc_tenancy

  tags = {
    Name = var.vpc_name
  }
}

# public subnet creation
resource "aws_subnet" "login-pub-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  for_each = var.public_subnets_cidrs
  cidr_block = each.value
  map_public_ip_on_launch = "true"
  

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# private subnet creation
resource "aws_subnet" "login-pvt-subnet" {
  vpc_id     = aws_vpc.login-vpc.id
  for_each = var.private_subnets_cidrs
  cidr_block = each.value
  map_public_ip_on_launch = "false"
  

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "login-igw" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

