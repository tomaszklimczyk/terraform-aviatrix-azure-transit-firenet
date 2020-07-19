#Transit VPC
resource "aviatrix_vpc" "default" {
  cloud_type           = 8
  name                 = replace(lower("vnet-transit-${var.region}"), " ", "-")
  region               = var.region
  cidr                 = var.cidr
  account_name         = var.azure_account_name
  aviatrix_firenet_vpc = true
  aviatrix_transit_vpc = false
}

# HA Transit GW
resource "aviatrix_transit_gateway" "ha" {
  enable_active_mesh     = true
  cloud_type             = 8
  vpc_reg                = var.region
  gw_name                = replace(lower("tg-${var.region}"), " ", "-")
  gw_size                = var.instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  account_name           = var.azure_account_name
  subnet                 = aviatrix_vpc.default.subnets[2].cidr
  ha_subnet              = aviatrix_vpc.default.subnets[3].cidr
  enable_transit_firenet = true
  ha_gw_size             = var.instance_size
  connected_transit      = true

}

resource "aviatrix_firewall_instance" "firewall_instance_1" {
  firewall_name          = replace(lower("fw1-${var.region}"), " ", "-")
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[0].cidr
  firenet_gw_name        = aviatrix_transit_gateway.ha.gw_name
  username               = var.is_checkpoint ? "admin" : "avtx1234"
  password               = var.is_checkpoint ? var.checkpoint_password : ""
  management_subnet      = aviatrix_vpc.default.subnets[2].cidr
}

resource "aviatrix_firewall_instance" "firewall_instance_2" {
  firewall_name          = replace(lower("fw2-${var.region}"), " ", "-")
  firewall_size          = var.fw_instance_size
  vpc_id                 = aviatrix_vpc.default.vpc_id
  firewall_image         = var.firewall_image
  firewall_image_version = var.firewall_image_version
  egress_subnet          = aviatrix_vpc.default.subnets[1].cidr
  firenet_gw_name        = "${aviatrix_transit_gateway.ha.gw_name}-hagw"
  username               = var.is_checkpoint ? "admin" : "avtx1234"
  management_subnet      = aviatrix_vpc.default.subnets[3].cidr
  depends_on             = [aviatrix_firewall_instance.firewall_instance_1]
}

resource "aviatrix_firenet" "firenet_ha" {
  vpc_id             = aviatrix_vpc.default.vpc_id
  inspection_enabled = true
  egress_enabled     = true
  firewall_instance_association {
    firenet_gw_name      = aviatrix_transit_gateway.ha.gw_name
    instance_id          = aviatrix_firewall_instance.firewall_instance_1.instance_id
    vendor_type          = "Generic"
    firewall_name        = aviatrix_firewall_instance.firewall_instance_1.firewall_name
    lan_interface        = aviatrix_firewall_instance.firewall_instance_1.lan_interface
    management_interface = null
    egress_interface     = aviatrix_firewall_instance.firewall_instance_1.egress_interface
    attached             = var.attached
  }
  firewall_instance_association {
    firenet_gw_name      = "${aviatrix_transit_gateway.ha.gw_name}-hagw"
    instance_id          = aviatrix_firewall_instance.firewall_instance_2.instance_id
    vendor_type          = "Generic"
    firewall_name        = aviatrix_firewall_instance.firewall_instance_2.firewall_name
    lan_interface        = aviatrix_firewall_instance.firewall_instance_2.lan_interface
    management_interface = null
    egress_interface     = aviatrix_firewall_instance.firewall_instance_2.egress_interface
    attached             = var.attached
  }
}
