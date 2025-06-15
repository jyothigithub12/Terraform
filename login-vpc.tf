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

# Public NACL
resource "aws_network_acl" "login-public-nacl" {
  vpc_id = aws_vpc.login-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "${var.vpc_name}-public-nacl"
  }
}

# Public NACL Association
resource "aws_network_acl_association" "login-public-nacl-asc" {
  for_each       = var.public_subnets_cidrs  
  network_acl_id = aws_network_acl.login-public-nacl.id
  subnet_id      = aws_subnet.login-pub-subnet[each.key].id
}


# Private NACL
resource "aws_network_acl" "login-private-nacl" {
  vpc_id = aws_vpc.login-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "${var.vpc_name}-private-nacl"
  }
}

# Private NACL Association
resource "aws_network_acl_association" "login-private-nacl-asc" {
  for_each       = var.private_subnets_cidrs
  network_acl_id = aws_network_acl.login-private-nacl.id
  subnet_id      = aws_subnet.login-pvt-subnet[each.key].id
}

# Frontend Security Group
resource "aws_security_group" "login-fe-sg" {
  name        = "login-frontend"
  description = "Allow Frontend Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-fe-sg"
  }
}

# Frontend Security Group Rules
resource "aws_vpc_security_group_ingress_rule" "login-fe-sg-rules" {
  security_group_id = aws_security_group.login-fe-sg.id
  count             = length(var.login_fe_inbound_ports)
  cidr_ipv4         = var.login_fe_inbound_ports[count.index].cidr
  from_port         = var.login_fe_inbound_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.login_fe_inbound_ports[count.index].port
}

# API Security Group
resource "aws_security_group" "login-api-sg" {
  name        = "login-api"
  description = "Allow API Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-api-sg"
  }
}

# API Security Group Rules
resource "aws_vpc_security_group_ingress_rule" "login-api-sg-rules" {
  security_group_id = aws_security_group.login-api-sg.id
  count             = length(var.login_api_inbound_ports)
  cidr_ipv4         = var.login_api_inbound_ports[count.index].cidr
  from_port         = var.login_api_inbound_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.login_api_inbound_ports[count.index].port
}

# DB Security Group
resource "aws_security_group" "login-db-sg" {
  name        = "login-db"
  description = "Allow DB Traffic"
  vpc_id      = aws_vpc.login-vpc.id

  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}

# DB Security Group Rules
resource "aws_vpc_security_group_ingress_rule" "login-db-sg-rules" {
  security_group_id = aws_security_group.login-db-sg.id
  count             = length(var.login_db_inbound_ports)
  cidr_ipv4         = var.login_db_inbound_ports[count.index].cidr
  from_port         = var.login_db_inbound_ports[count.index].port
  ip_protocol       = "tcp"
  to_port           = var.login_db_inbound_ports[count.index].port
}

# Locals for easier access of egress rules
locals {
  security_groups = {
    fe = aws_security_group.login-fe-sg.id
    api = aws_security_group.login-api-sg.id
    db = aws_security_group.login-db-sg.id
  }
}

# Common Egress Rules - Outbound All 
resource "aws_vpc_security_group_egress_rule" "login-common-outbound" {
  for_each          = local.security_groups
  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}


resource "aws_instance" "login-web-server" {
  ami           = "ami-021a584b49225376d"
  instance_type = "t2.micro"
  key_name      = "terraform-key"

  # Use the subnet key dynamically
  subnet_id = aws_subnet.login-pub-subnet[var.web_instance_subnet_key].id

  # Use the SG key dynamically from locals
  vpc_security_group_ids = [
    local.security_groups[var.web_instance_sg_key]
  ]

  user_data = file("script.sh")

  tags = {
    Name = "login-web-server"
  }
}







