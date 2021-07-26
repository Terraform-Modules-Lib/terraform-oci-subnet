resource "oci_core_security_list" "egress" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id
  
  display_name = local.name
  
  dynamic "egress_security_rules" {
    for_each = local.acl.egress
    
    content {
      description = egress_security_rules.value.description
      destination = egress_security_rules.value.destination
      protocol = local.protocol_map[egress_security_rules.value.protocol]
      
      dynamic "tcp_options" {
        for_each = egress_security_rules.value.protocol == "tcp" ? zipmap([egress_security_rules.key], [egress_security_rules.value]) : {}
        
        content {
          min = try(tcp_options.value.dst_port_min, tcp_options.value.dst_port_max, tcp_options.value.dst_port, 1)
          max = try(tcp_options.value.dst_port_max, tcp_options.value.dst_port_min, tcp_options.value.dst_port, 65535)
          source_port_range {
            min = try(tcp_options.value.src_port_min, tcp_options.value.src_port_max, tcp_options.value.src_port, 1)
            max = try(tcp_options.value.src_port_max, tcp_options.value.src_port_min, tcp_options.value.src_port, 65535)
          }
        }
      }
      
      dynamic "udp_options" {
        for_each = egress_security_rules.value.protocol == "udp" ? zipmap([egress_security_rules.key], [egress_security_rules.value]) : {}
        
        content {
          min = try(udp_options.value.dst_port_min, udp_options.value.dst_port_max, udp_options.value.dst_port, 1)
          max = try(udp_options.value.dst_port_max, udp_options.value.dst_port_min, udp_options.value.dst_port, 65535)
          source_port_range {
            min = try(udp_options.value.src_port_min, udp_options.value.src_port_max, udp_options.value.src_port, 1)
            max = try(udp_options.value.src_port_max, udp_options.value.src_port_min, udp_options.value.src_port, 65535)
          }
        }
      }
      
      dynamic "icmp_options" {
        for_each = egress_security_rules.value.protocol == "icmp" ? zipmap([egress_security_rules.key], [egress_security_rules.value]) : {}
        
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }
}
