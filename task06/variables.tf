variable "client_certificate_path" {
  type        = string
  default = "../terraform/client.pfx"
}

variable "client_certificate_password" {
  type        = string
  default = ""
}

variable "admin_username" {
  description = "The administrator login name for the new SQL Server"
  default     = "sqladmin"
}

variable "admin_password" {
  description = "The password associated with the admin_username user"
  default     = null
}

variable "database_name" {
  description = "The name of the database"
  default     = "db06"
}

variable "sqlserver_name" {
  description = "SQL server Name"
  default     = "sql00task06"
}
