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
<<<<<<< HEAD
  value       = var.ha_gw ? [aviatrix_firewall_instance.firewall_instance_1[0], aviatrix_firewall_instance.firewall_instance_2[0]] : [aviatrix_firewall_instance.firewall_instance[0]]
}
=======
  value       = [aviatrix_firewall_instance.firewall_instance_1, aviatrix_firewall_instance.firewall_instance_2]
}




>>>>>>> master
