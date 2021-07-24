terraform {
  required_version = "~> 1"

  required_providers {
    oci = {
      source = "hashicorp/oci"
      version = "~> 4"
    }
  }
  
}

locals {
  vcn_id = var.vcn_id
  cidr = var.cidr
  name = var.name
  
  vcn = data.oci_core_vcn.this
  subnet = oci_core_subnet.this
  routing_table = oci_core_route_table.this
}

data "oci_core_vcn" "this" {
  vcn_id = local.vcn_id
}

resource "oci_core_subnet" "this" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id
  prohibit_public_ip_on_vnic = false

  cidr_block = local.cidr
  route_table_id = local.routing_table.id
  display_name = local.name
  dns_label = local.name
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id
  
  display_name = local.name
}

resource "oci_core_route_table" "this" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id

  display_name = local.name
  
  route_rules = [{
    network_entity_id = oci_core_internet_gateway.this.id
    
    description = format("Internet route for %s subnet", local.name)
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }]
}
