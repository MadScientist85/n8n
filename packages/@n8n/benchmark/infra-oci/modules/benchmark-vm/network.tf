# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
  dns_label      = "${var.prefix}vcn"

  freeform_tags = var.tags
}

# Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.prefix}-igw"
  enabled        = true

  freeform_tags = var.tags
}

# Route Table
resource "oci_core_route_table" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.prefix}-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = var.tags
}

# Security List
resource "oci_core_security_list" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.prefix}-seclist"

  # Egress rule - allow all outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Ingress rule - allow SSH
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Ingress rule - allow ICMP for ping
  ingress_security_rules {
    protocol  = "1" # ICMP
    source    = "0.0.0.0/0"
    stateless = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  freeform_tags = var.tags
}

# Subnet
resource "oci_core_subnet" "main" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.main.id
  cidr_block          = "10.0.0.0/24"
  display_name        = "${var.prefix}-subnet"
  dns_label           = "${var.prefix}subnet"
  route_table_id      = oci_core_route_table.main.id
  security_list_ids   = [oci_core_security_list.main.id]
  dhcp_options_id     = oci_core_vcn.main.default_dhcp_options_id

  freeform_tags = var.tags
}
