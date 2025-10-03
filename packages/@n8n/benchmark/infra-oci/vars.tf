variable "region" {
  description = "OCI region to deploy resources"
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain for the compute instance"
  type        = string
  default     = ""
}

variable "instance_shape" {
  description = "Shape of the compute instance"
  default     = "VM.Standard.E4.Flex"
}

variable "instance_ocpus" {
  description = "Number of OCPUs for the instance (for flexible shapes)"
  default     = 8
}

variable "instance_memory_in_gbs" {
  description = "Amount of memory in GB for the instance (for flexible shapes)"
  default     = 32
}

variable "instance_boot_volume_size_in_gbs" {
  description = "Size of the boot volume in GB"
  default     = 100
}

variable "ssh_authorized_keys" {
  description = "List of SSH authorized keys"
  type        = list(string)
  default     = []
}

locals {
  common_tags = {
    Id        = "N8nBenchmark"
    Terraform = "true"
    Owner     = "Catalysts"
    CreatedAt = timestamp()
  }
}
