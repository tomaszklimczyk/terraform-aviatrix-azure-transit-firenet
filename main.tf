#Transit VPC
resource "aviatrix_vpc" "default" {
  cloud_type           = 8
  name                 = length(var.name) > 0 ? "avx-${var.name}-transit" : replace(lower("avx-${var.region}-transit"), " ", "-")
  region               = var.region
  cidr                 = var.cidr
  account_name         = var.azure_account_name
  aviatrix_firenet_vpc = true
  aviatrix_transit_vpc = false
}

#Transit GW
resource "aviatrix_transit_gateway" "single" {
  count                  = var.ha_gw ? 0 : 1
  enable_active_mesh     = true
  cloud_type             = 8
  vpc_reg                = var.region
  gw_name                = length(var.name) > 0 ? "avx-${var.name}-transit" : replace(lower("avx-${var.region}-transit"), " ", "-")
  gw_size                = var.instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  account_name           = var.azure_account_name
  subnet                 = var.insane_mode ? cidrsubnet(aviatrix_vpc.default.cidr, 3, 6) : aviatrix_vpc.default.subnets[0].cidr
  insane_mode            = var.insane_mode ? true : false
  enable_transit_firenet = true
  connected_transit      = true
}

#HA Transit GW
resource "aviatrix_transit_gateway" "ha" {
  count                  = var.ha_gw ? 1 : 0
  enable_active_mesh     = true
  cloud_type             = 8
  vpc_reg                = var.region
  gw_name                = length(var.name) > 0 ? "avx-${var.name}-transit" : replace(lower("avx-${var.region}-transit"), " ", "-")
  gw_size                = var.insane_mode ? "Standard_D3_v2" : var.instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  account_name           = var.azure_account_name
  subnet                 = var.insane_mode ? cidrsubnet(aviatrix_vpc.default.cidr, 3, 6) : aviatrix_vpc.default.subnets[0].cidr
  ha_subnet              = var.insane_mode ? cidrsubnet(aviatrix_vpc.default.cidr, 3, 7) : aviatrix_vpc.default.subnets[2].cidr
  insane_mode            = var.insane_mode ? true : false
  enable_transit_firenet = true
  ha_gw_size             = var.insane_mode ? "Standard_D3_v2" : var.instance_size
  connected_transit      = true
}

#Single instance
resource "aviatrix_firewall_instance" "firewall_instance" {
  count                  = var.ha_gw ? 0 : 1
  firewall_name          = length(var.name) > 0 ? "avx-${var.name}-fw1" : replace(lower("avx-${var.region}-fw1"), " ", "-")
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[0].cidr
  firenet_gw_name        = aviatrix_transit_gateway.single[0].gw_name
  username               = local.is_checkpoint ? "admin" : var.firewall_username
  password               = local.is_checkpoint ? var.checkpoint_password : ""
  management_subnet      = aviatrix_vpc.default.subnets[2].cidr
}

#Dual instance
resource "aviatrix_firewall_instance" "firewall_instance_1" {
  count                  = var.ha_gw ? 1 : 0
  firewall_name          = length(var.name) > 0 ? "avx-${var.name}-fw1" : replace(lower("avx-${var.region}-fw1"), " ", "-")
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[0].cidr
  firenet_gw_name        = aviatrix_transit_gateway.ha[0].gw_name
  username               = local.is_checkpoint ? "admin" : var.firewall_username
  password               = local.is_checkpoint ? var.checkpoint_password : ""
  management_subnet      = aviatrix_vpc.default.subnets[2].cidr
}

resource "aviatrix_firewall_instance" "firewall_instance_2" {
  count                  = var.ha_gw ? 1 : 0
  firewall_name          = length(var.name) > 0 ? "avx-${var.name}-fw2" : replace(lower("avx-${var.region}-fw2"), " ", "-")
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name        = "${aviatrix_transit_gateway.ha[0].gw_name}-hagw"
  username               = local.is_checkpoint ? "admin" : var.firewall_username
  password               = local.is_checkpoint ? var.checkpoint_password : ""
  management_subnet      = aviatrix_vpc.default.subnets[3].cidr
}

resource "aviatrix_firenet" "firenet_single" {
  count              = var.ha_gw ? 0 : 1
  vpc_id             = aviatrix_vpc.default.vpc_id
  inspection_enabled = true
  egress_enabled     = true
  firewall_instance_association {
    firenet_gw_name      = aviatrix_transit_gateway.single[0].gw_name
    instance_id          = aviatrix_firewall_instance.firewall_instance[0].instance_id
    vendor_type          = "Generic"
    firewall_name        = aviatrix_firewall_instance.firewall_instance[0].firewall_name
    lan_interface        = aviatrix_firewall_instance.firewall_instance[0].lan_interface
    management_interface = null
    egress_interface     = aviatrix_firewall_instance.firewall_instance[0].egress_interface
    attached             = var.attached
  }
}

resource "aviatrix_firenet" "firenet_ha" {
  count              = var.ha_gw ? 1 : 0
  vpc_id             = aviatrix_vpc.default.vpc_id
  inspection_enabled = true
  egress_enabled     = true
  firewall_instance_association {
    firenet_gw_name      = aviatrix_transit_gateway.ha[0].gw_name
    instance_id          = aviatrix_firewall_instance.firewall_instance_1[0].instance_id
    vendor_type          = "Generic"
    firewall_name        = aviatrix_firewall_instance.firewall_instance_1[0].firewall_name
    lan_interface        = aviatrix_firewall_instance.firewall_instance_1[0].lan_interface
    management_interface = null
    egress_interface     = aviatrix_firewall_instance.firewall_instance_1[0].egress_interface
    attached             = var.attached
  }
  firewall_instance_association {
    firenet_gw_name      = "${aviatrix_transit_gateway.ha[0].gw_name}-hagw"
    instance_id          = aviatrix_firewall_instance.firewall_instance_2[0].instance_id
    vendor_type          = "Generic"
    firewall_name        = aviatrix_firewall_instance.firewall_instance_2[0].firewall_name
    lan_interface        = aviatrix_firewall_instance.firewall_instance_2[0].lan_interface
    management_interface = null
    egress_interface     = aviatrix_firewall_instance.firewall_instance_2[0].egress_interface
    attached             = var.attached
  }
}
