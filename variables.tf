variable "region" {
  description = "The Azure region to deploy this module in"
  type        = string
}

variable "cidr" {
  description = "The CIDR range to be used for the VNET"
  type        = string
}

variable "azure_account_name" {
  description = "The Azure account name, as known by the Aviatrix controller"
  type        = string
}

variable "instance_size" {
  description = "Azure Instance size for the Aviatrix gateways"
  type        = string
  default     = "Standard_B2ms"
}

variable "fw_instance_size" {
  description = "Azure Instance size for the NGFW's"
  type        = string
  default     = "Standard_D3_v2"
}

/*
variable "is_checkpoint" {
  description = "Boolean to determine if module deploys Check Point"
  type        = bool
  default     = false
}
*/

variable "checkpoint_password" {
  description = "Check Point firewall instance password"
  type        = string
  default     = "#Aviatrix1234"
}

variable "attached" {
  description = "Boolean to determine if the spawned firewall instances will be attached on creation"
  type        = bool
  default     = true
}

variable "name" {
  description = "Custom name for VNETs, gateways, and firewalls"
  type        = string
  default     = ""
}

variable "firewall_image" {
  description = "The firewall image to be used to deploy the NGFW's"
  type        = string
}

variable "firewall_image_version" {
  description = "The firewall image version specific to the NGFW vendor image"
  type        = string
}

variable "firewall_username" {
  description = "The username for the administrator account"
  type        = string
  default     = "fwadmin"
}

variable "ha_gw" {
  description = "Set to false to deploy single Aviatrix gateway. When set to false, fw_amount is ignored and only a single NGFW instance is deployed."
  type        = bool
  default     = true
}

locals {
  is_checkpoint = length(regexall("check", lower(var.firewall_image))) > 0 #Check if fw image contains checkpoint. Needs special handling for the username/password
}

variable "insane_mode" {
  description = "Set to true to enable Aviatrix high performance encryption."
  type        = bool
  default     = false
}


####

variable "controller_ip" {
  type    = string
  default = ""
}

variable "username" {
  type    = string
  default = ""
}

variable "password" {
  type    = string
  default = ""
}