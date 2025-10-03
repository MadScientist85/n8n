output "vm_name" {
  value = oci_core_instance.main.display_name
}

output "ip" {
  value = oci_core_instance.main.public_ip
}

output "ssh_username" {
  value = "benchmark"
}
