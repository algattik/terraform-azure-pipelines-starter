variable "keyvault_rg" {
  type = string
  description = "Resource group name of the Key Vault containing Terraform secrets. Use only lowercase letters and numbers"
  default = "terraform"
}

variable "keyvault_name" {
  type = string
  description = "Name of the Key Vault containing Terraform secrets. Use only lowercase letters and numbers"
  default = "terraformstarter"
}

variable "appname" {
  type = string
  description = "Application name. Use only lowercase letters and numbers"
  default = "starterterraform"
}

variable "environment" {
  type    = string
  description = "Environment name: 'dev' or 'stage'"
  default = "dev"
}

variable "location" {
  type    = string
  default = "North Europe"
}
