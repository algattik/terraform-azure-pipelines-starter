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

