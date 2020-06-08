resource oci_core_vcn virtual_network {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  display_name = "neo4j_vcn"
  dns_label    = "neo4j"
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_internet_gateway" "internet_gateway" {
  display_name   = "internet_gateway"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.virtual_network.id
}

resource "oci_core_route_table" "route_table" {
  display_name   = "route_table"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.virtual_network.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "security_list" {
  display_name   = "security_list"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.virtual_network.id

  egress_security_rules {
    protocol    = "All"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "All"
    source   = "10.0.0.0/24"
  }

  ingress_security_rules {
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "3389"
      min = "3389"

    }
  }
  ingress_security_rules {
    protocol = "6"

    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "22"
      min = "22"

    }
  }

}

resource oci_core_subnet neo4j_subnet_public {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  dhcp_options_id = oci_core_vcn.virtual_network.default_dhcp_options_id
  display_name    = "PubNEO4J"
  dns_label       = "neo4j"

  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_route_table.route_table.id

  security_list_ids = [
    oci_core_security_list.security_list.id,
  ]

  vcn_id = oci_core_vcn.virtual_network.id
}


resource oci_core_subnet neo4j_subnet_private {
  cidr_block     = "10.0.1.0/24"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  dhcp_options_id = oci_core_vcn.virtual_network.default_dhcp_options_id
  display_name    = "PrivNEO4J"
  dns_label       = "neo4jpriv"

  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.route_table_private.id

  security_list_ids = [
    oci_core_security_list.security_list_private.id,
  ]

  vcn_id = oci_core_vcn.virtual_network.id
}

resource oci_core_nat_gateway export_NAT_Gateway {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid
  defined_tags   = {}

  display_name  = "NAT_Gateway"
  freeform_tags = {}

  vcn_id = oci_core_vcn.virtual_network.id
}

resource "oci_core_route_table" "route_table_private" {
  display_name   = "route_table_private"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.virtual_network.id

   route_rules {
     destination       = "0.0.0.0/0"
     destination_type  = "CIDR_BLOCK"
     network_entity_id = oci_core_nat_gateway.export_NAT_Gateway.id
   }
}

resource "oci_core_security_list" "security_list_private" {
  display_name   = "security_list_private"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.virtual_network.id

  egress_security_rules {
    protocol    = "All"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "All"
    source   = "10.0.1.0/24"
  }
  ingress_security_rules {
    protocol = "6"

    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "7474"
      min = "7473"

    }
  }
  ingress_security_rules {
    protocol = "6"

    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"

    tcp_options {
      max = "7687"
      min = "7687"

    }
  }

}

resource oci_core_cpe CPE {
  compartment_id = var.compartment_ocid

  display_name  = "CPE"
  ip_address    = var.CPE_IPAddress
}

resource oci_core_drg_attachment DRGattachmentNeo4J {
  display_name = "DRGattachmentNeo4J"
  drg_id       = oci_core_drg.DRGNeo4J.id
  vcn_id       = oci_core_vcn.virtual_network.id
}

resource oci_core_drg DRGNeo4J {
  compartment_id = var.compartment_ocid
  display_name   = "DRGNeo4J"
}

resource oci_core_ipsec VPNIpSec {
  compartment_id            = var.compartment_ocid
  cpe_id                    = oci_core_cpe.CPE.id
  cpe_local_identifier      = var.CPE_IPAddress
  cpe_local_identifier_type = "IP_ADDRESS"

  display_name  = "VPNIpSec"
  drg_id        = oci_core_drg.DRGNeo4J.id

  static_routes = [
    var.IPSec_StaticRoute,
  ]
}

data "oci_core_ipsec_config" "VPNIpSec_config" {
    #Required
    ipsec_id = oci_core_ipsec.VPNIpSec.id
}

#output "IPSec Tunnels IPs" {
#  value = "${join(",", oci_core_ipsec_config.VPNIpSec_config.tunnels.ip_address)}"
#}

