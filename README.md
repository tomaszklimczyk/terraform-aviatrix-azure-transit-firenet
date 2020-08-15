# Aviatrix Transit Firenet for Azure

### Description
This module deploys a VNET, Aviatrix transit gateways (HA), and firewall instances.

### Diagram
<img src="https://avtx-tf-modules-images.s3.amazonaws.com/azure-transit-firenet.png"  height="250">

### Compatibility
Module version | Terraform version | Controller version
:--- | :--- | :---
v1.0.2 | 0.12 | 6.1
v1.0.1 | | 
v1.0.0 | | 

### Usage Example

Examples shown below are specific to each vendor.

#### Palo Alto Networks
```
module "transit_firenet_1" {
  source                 = "terraform-aviatrix-modules/azure-transit-firenet/aviatrix"
  version                = "1.0.1"
  cidr                   = "10.1.0.0/20"
  region                 = "East Us"
  azure_account_name     = "TM-Azure"
  firewall_image         = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
  firewall_image_version = "9.1.0"
}
```
#### Check Point
```
module "transit_firenet_1" {
  source                 = "terraform-aviatrix-modules/azure-transit-firenet/aviatrix"
  version                = "1.0.1"
  cidr                   = "10.1.0.0/20"
  region                 = "East Us"
  azure_account_name     = "TM-Azure"
  firewall_image         = "Check Point CloudGuard IaaS Single Gateway R80.40 - Bring Your Own License" 
  firewall_image_version = "8040.900294.0593"
}
```


#### Fortinet
```
module "transit_firenet_1" {
  source                 = "terraform-aviatrix-modules/azure-transit-firenet/aviatrix"
  version                = "1.0.1"
  cidr                   = "10.1.0.0/20"
  region                 = "East Us"
  azure_account_name     = "TM-Azure"
  firewall_image         = "Fortinet FortiGate (BYOL) Next-Generation Firewall"
  firewall_image_version = "6.4.1"
}
```

### Variables
The following variables are required:

key | value
--- | ---
region | Azure region to deploy the transit VNET in
azure_account_name | The Azure access account on the Aviatrix controller, under which the controller will deploy this VNET
cidr | The IP CIDR wo be used to create the VNET
firewall_image | String for the firewall image to use
firewall_image_version | String for the firewall image version to use

Firewall images
```
Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 
Check Point CloudGuard IaaS Single Gateway R80.40 - Bring Your Own License
Fortinet FortiGate (BYOL) Next-Generation Firewall
```

Firewall image versions tested
```
Palo Alto Networks - 9.1.0
Check Point        - 8040.900294.0593
Fortinet           - 6.4.1
```

The following variables are optional:

key | default | value
:--- | :--- | :---
instance_size | Standard_B2ms | Size of the transit gateway instances
fw_instance_size | Standard_D3_v2 | Size of the firewall instances
attached | true | Attach firewall instances to Aviatrix Gateways
is_checkpoint | false | Set to true for Check Point firewalls
checkpoint_password | Aviatrix#1234 | Default initial password for Check Point
ha_gw | true | Set to false to deploy single Aviatrix gateway. When set to false, fw_amount is ignored and only a single NGFW instance is deployed.

### Outputs
This module will return the following objects:

key | description
:--- | :---
vpc | The created VNET as an object with all of it's attributes. This was created using the aviatrix_vpc resource.
transit_gateway | The created Aviatrix transit gateway as an object with all of it's attributes.
aviatrix_firenet | The created Aviatrix firenet object with all of it's attributes.
aviatrix_firewall_instance | A list of the created firewall instances and their attributes.

#### Azure Infrastructure Created

The module automates creation of 44 infrastructure components in Azure.

<img src="https://avtx-tf-modules-images.s3.amazonaws.com/azure-firenet-module-infr.png"  height="350">

