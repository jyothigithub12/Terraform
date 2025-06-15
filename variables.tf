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


