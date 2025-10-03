
# Random prefix for the resources
resource "random_string" "prefix" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Get the list of availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

# Use the first availability domain if not specified
locals {
  ad_name = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# VM
module "test_vm" {
  source = "./modules/benchmark-vm"

  compartment_ocid              = var.compartment_ocid
  availability_domain           = local.ad_name
  prefix                        = random_string.prefix.result
  instance_shape                = var.instance_shape
  instance_ocpus                = var.instance_ocpus
  instance_memory_in_gbs        = var.instance_memory_in_gbs
  instance_boot_volume_size_in_gbs = var.instance_boot_volume_size_in_gbs
  ssh_public_key                = tls_private_key.ssh_key.public_key_openssh

  tags = local.common_tags
}
