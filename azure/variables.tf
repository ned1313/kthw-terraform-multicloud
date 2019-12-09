
#############################################################################
# VARIABLES
#############################################################################

variable naming_prefix {
  type        = string
  description = "Set this variable to the prefix that will be used by all resources, should be four characters of less."
  default     = "k8s"
}

variable "location" {
  type        = string
  description = "Location for the resources"
  default     = "eastus"
}

variable "vnet_cidr_range" {
  type        = string
  description = "IP Address range for the Vnet"
  default     = "10.0.0.0/16"
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "List of subnet prefixes in the Vnet"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "subnet_names" {
  type        = list(string)
  description = "List of subnet names in the Vnet"
  default     = ["kubectl", "other"]
}

variable "username" {
  type        = string
  description = "Username for the virtual machines"
  default     = "kthw"
}

#############################################################################
# VARIABLES
#############################################################################

locals {
  resource_group_name = "${var.naming_prefix}-kthw"

}