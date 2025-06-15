# vpc resource creation

resource "aws_vpc" "login-vpc" {
  cidr_block       =var.vpc_cidr
  instance_tenancy =var.vpc_tenancy

  tags = {
    Name = var.vpc_name
  }
}
