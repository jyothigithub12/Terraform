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

# Public Route Table
resource "aws_route_table" "login-pub-rt" {
  vpc_id = aws_vpc.login-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.login-igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Public Route Table - Public SNS ASC
resource "aws_route_table_association" "login-public-asc" {
  for_each       = var.public_subnets_cidrs  
  subnet_id      = aws_subnet.login-pub-subnet[each.key].id
  route_table_id = aws_route_table.login-pub-rt.id
}

# Private Route Table
resource "aws_route_table" "login-pvt-rt" {
  vpc_id = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Private Route Table - Private SNS ASC
resource "aws_route_table_association" "login-private-asc" {
  for_each       = var.private_subnets_cidrs
  subnet_id      = aws_subnet.login-pvt-subnet[each.key].id
  route_table_id = aws_route_table.login-pvt-rt.id
}



