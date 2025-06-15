#variables for login


#AWS access key
variable access_key {
    description = "enter access key "
 
}

#aws secret key
variable secret_key {
    description = "enter secret key"
   
}


# variable for vpc

variable vpc_name {
    description = "enter vpc name"

}

# VPC CIDR
variable vpc_cidr {
  description = "Please Input VPC CIDR"
}

# VPC Tenancy
variable vpc_tenancy {
  default = "default"
}

# VPC Public Subnets
variable public_subnets_cidrs {
  description = "Please Input Subnet Details"
  type = map(string)
  default = {
    frontend = "10.0.0.0/24"
    backend = "10.0.1.0/24"
    loadbalancer = "10.0.2.0/24"
  }
}

# VPC Private Subnets
variable private_subnets_cidrs {
  description = "Please Input Subnet Details"
  type = map(string)
  default = {
    database = "10.0.3.0/24"
    cache = "10.0.4.0/24"
  }
}




