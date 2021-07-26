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
  public = var.public
  acl = var.acl
  
  vcn = data.oci_core_vcn.vcn
  subnet = oci_core_subnet.subnet
  
  protocol_map = {
    all = "all",
    tcp = 6,
    udp = 17,
    icmp = 1,
    icmp6 = 58
  }
}

data "oci_core_vcn" "vcn" {
  vcn_id = local.vcn_id
}

resource "oci_core_subnet" "subnet" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id
  prohibit_public_ip_on_vnic = !local.public

  cidr_block = local.cidr
  display_name = local.name
  dns_label = local.name
}
