# Default Azure Location
variable "azure_location" {
  type        = "string"
  description = "Azure datacenter to deploy to."
  default     = "westeurope"
}

# Environment
variable "environment" {
  type    = "string"
  default = "prd"
}

# Tenant
variable "department" {
  type    = "string"
  default = "ecom"
}

# Organisation

variable "organisation" {
  type    = "string"
  default = "wf"
}

# Tenant
variable "project" {
  type    = "string"
  default = "2020"
}
