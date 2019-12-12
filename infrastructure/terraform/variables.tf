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
  description = "Azure region where to create resources."
  default = "North Europe"
}

variable "department" {
  type    = string
  description = "A sample variable passed from the build pipeline and used to tag resources."
  default = "Engineering"
}
