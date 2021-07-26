

resource "oci_core_security_list" "ingress" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id
  
  display_name = local.name
  
  dynamic "ingress_security_rules" {
    for_each = local.acl.ingress
    
    content {
      description = ingress_security_rules.value.description
      source = ingress_security_rules.value.source
      protocol = local.protocol_map[ingress_security_rules.value.protocol]
      
      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "tcp" ? { "${ingress_security_rules.key}" = ingress_security_rules.value } : {}
        
        content {
          min = tcp_options.value.dst_port_min
          max = tcp_options.value.dst_port_max
          source_port_range {
            min = tcp_options.value.src_port_min
            max = tcp_options.value.src_port_max
          }
        }
      }
      
      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "udp" ? { "${ingress_security_rules.key}" = ingress_security_rules.value } : {}
        
        content {
          min = udp_options.value.dst_min
          max = udp_options.value.dst_max
          source_port_range {
            min = udp_options.value.src_min
            max = udp_options.value.src_max
          }
        }
      }
      
      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.protocol == "icmp" ? { "${ingress_security_rules.key}" = ingress_security_rules.value } : {}
        
        content {
          type = icmp_options.value.type
          code = icmp_options.value.type
        }
      }
    }
  }
}
