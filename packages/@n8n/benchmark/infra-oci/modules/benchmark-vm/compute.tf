# Get the latest Ubuntu 22.04 image
data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Compute Instance
resource "oci_core_instance" "main" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "${var.prefix}-vm"
  shape               = var.instance_shape

  # Shape configuration for flexible shapes
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  # Boot volume configuration
  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu.images[0].id
    boot_volume_size_in_gbs = var.instance_boot_volume_size_in_gbs
  }

  # Network configuration
  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.main.id
    display_name     = "${var.prefix}-vnic"
    hostname_label   = "${var.prefix}vm"
  }

  # SSH key
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {
      ssh_public_key = var.ssh_public_key
    }))
  }

  freeform_tags = var.tags
}
