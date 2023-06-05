variable "client_certificate_path" {
  type        = string
  default = "../../terraform/client.pfx"
}

variable "client_certificate_password" {
  type        = string
  default = ""
}

variable "location" {
  type        = string
  default = "UK South"
}


#### vnet1 (255) and 3 subnets (14, 30, 10) ####
variable "vnet1_cidr" {
  type        = string
  default = "10.0.0.0/23"
}

variable "vnet1_subnet1_cidr" {
  type        = string
  default = "10.0.0.0/27"
}

variable "vnet1_subnet2_cidr" {
  type        = string
  default = "10.0.0.64/26"
}

variable "vnet1_subnet3_cidr" {
  type        = string
  default = "10.0.0.32/28"
}


#### vnet2 (255) and 2 subnets (expand to full) ####
variable "vnet2_cidr" {
  type        = string
  default = "10.0.2.0/23"
}

variable "vnet2_subnet1_cidr" {
  type        = string
  default = "10.0.2.0/24"
}

variable "vnet2_subnet2_cidr" {
  type        = string
  default = "10.0.3.0/24"
}


#### vnet3 (200): gw subnet /27, two more subnets for 5 ####
variable "vnet3_cidr" {
  type        = string
  default = "10.0.4.0/24"
}

variable "vnet3_subnet1_cidr" {
  type        = string
  default = "10.0.4.0/27"
}

variable "vnet3_subnet2_cidr" {
  type        = string
  default = "10.0.4.32/28"
}

variable "vnet3_subnet3_cidr" {
  type        = string
  default = "10.0.4.48/28"
}
