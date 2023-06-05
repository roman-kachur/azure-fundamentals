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
