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
  default = "10.0.0.0/16"
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

# Variable For Security Group - Frontend

variable "login_fe_inbound_ports" {
  type = list(object({
    port = number
    cidr = string
    
  }))
  default = [
  { port = 22, cidr = "0.0.0.0/0"},
  { port = 80, cidr = "0.0.0.0/0"},
  ]
}

# Variable For Security Group - Backend

variable "login_api_inbound_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
  { port = 22, cidr = "0.0.0.0/0"},
  { port = 8080, cidr = "0.0.0.0/0"},
  ]
}

# Variable For Security Group - Database

variable "login_db_inbound_ports" {
  type = list(object({
    port = number
    cidr = string
  }))
  default = [
  { port = 22, cidr = "0.0.0.0/0"},
  { port = 5432, cidr = "0.0.0.0/0"},
  ]
}


variable "web_instance_subnet_key" {
  description = "Which public subnet key to use for the EC2 instance"
  type        = string
  default     = "frontend" # Can change to "backend", etc.
}

variable "web_instance_sg_key" {
  description = "Which SG to attach to EC2 (fe, api, db)"
  type        = string
  default     = "fe"
}





