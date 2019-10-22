locals {
  tcp_protocol  = "6"
  all_protocols = "all"
  anywhere      = "0.0.0.0/0"
}

resource "oci_core_security_list" "security_list" {
  display_name   = "security_list"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.virtual_network.id

  egress_security_rules {
    protocol    = local.all_protocols
    destination = local.anywhere
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol = local.all_protocols
    source   = "10.0.0.0/16"
  }

  ingress_security_rules {
    protocol = local.tcp_protocol
    source   = local.anywhere

    tcp_options {
      max = "9042"
      min = "9042"
    }
  }
}

