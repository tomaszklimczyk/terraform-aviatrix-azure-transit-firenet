output "vnet" {
  description = "The created VNET with all of it's attributes"
  value       = aviatrix_vpc.default
}

output "transit_gateway" {
  description = "The Aviatrix transit gateway object with all of it's attributes"
  value       = var.ha_gw ? aviatrix_transit_gateway.ha[0] : aviatrix_transit_gateway.single[0]
}

output "aviatrix_firenet" {
  description = "The Aviatrix firenet object with all of it's attributes"
  value       = var.ha_gw ? aviatrix_firenet.firenet_ha[0] : aviatrix_firenet.firenet_single[0]
}

output "aviatrix_firewall_instance" {
  description = "A list with the created firewall instances and their attributes"
  value       = var.ha_gw ? [aviatrix_firewall_instance.firewall_instance_1[0], aviatrix_firewall_instance.firewall_instance_2[0]] : [aviatrix_firewall_instance.firewall_instance[0]]
}


output "azure_vnet_name" {
  value = "${split(":", aviatrix_vpc.default.vpc_id)[0]}"
}

output "azure_rg" {
  value = "${split(":", aviatrix_vpc.default.vpc_id)[1]}"
}

output "firewall_instance_1_nic_name" {
  value = join("", regex("([^\\/]+$)", aviatrix_firewall_instance.firewall_instance_1[0].egress_interface))
}

output "firewall_instance_2_nic_name" {
  value = join("", regex("([^\\/]+$)", aviatrix_firewall_instance.firewall_instance_2[0].egress_interface))
}

output "firewall_name" {
  value = [for name in aviatrix_firenet.firenet_ha[0].firewall_instance_association.*.instance_id : join("", regex("^(.*?):", name))]
}
