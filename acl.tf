locals {
  protocol_map = {
    all = "all",
    tcp = 6,
    udp = 17,
    icmp = 1,
    icmp6 = 58
  }
}

resource "oci_core_security_list" "acl" {
  compartment_id = local.vcn.compartment_id
  vcn_id = local.vcn.id
  
  display_name = local.name
  
  dynamic "ingress_security_rules" {
    for_each = try(local.acl.ingress, {})
    
    content {
      description = ingress_security_rules.value.description
      source = ingress_security_rules.value.source
      protocol = local.protocol_map[try(ingress_security_rules.value.protocol, "all")]
      
      dynamic "tcp_options" {
        for_each = try(ingress_security_rules.value.protocol, "all") == "tcp" ? zipmap([ingress_security_rules.key], [ingress_security_rules.value]) : {}
        
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
        for_each = try(ingress_security_rules.value.protocol, "all") == "udp" ? zipmap([ingress_security_rules.key], [ingress_security_rules.value]) : {}
        
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
        for_each = try(ingress_security_rules.value.protocol, "all") == "icmp" ? zipmap([ingress_security_rules.key], [ingress_security_rules.value]) : {}
        
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }
  
  dynamic "egress_security_rules" {
    for_each = try(local.acl.egress, {})
    
    content {
      description = egress_security_rules.value.description
      destination = egress_security_rules.value.destination
      protocol = local.protocol_map[try(egress_security_rules.value.protocol, "all")]
      
      dynamic "tcp_options" {
        for_each = try(egress_security_rules.value.protocol, "all") == "tcp" ? zipmap([egress_security_rules.key], [egress_security_rules.value]) : {}
        
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
        for_each = try(egress_security_rules.value.protocol, "all") == "udp" ? zipmap([egress_security_rules.key], [egress_security_rules.value]) : {}
        
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
        for_each = try(egress_security_rules.value.protocol, "all") == "icmp" ? zipmap([egress_security_rules.key], [egress_security_rules.value]) : {}
        
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }
}
