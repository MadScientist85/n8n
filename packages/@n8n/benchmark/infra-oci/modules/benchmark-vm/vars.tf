variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the compute instance"
  type        = string
}

variable "prefix" {
  description = "Prefix to append to resources"
  type        = string
}

variable "instance_shape" {
  description = "Shape of the compute instance"
  type        = string
}

variable "instance_ocpus" {
  description = "Number of OCPUs for the instance"
  type        = number
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GB for the instance"
  type        = number
}

variable "instance_boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GB"
  type        = number
}

variable "ssh_public_key" {
  description = "SSH Public Key"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources created by this module"
  type        = map(string)
}
