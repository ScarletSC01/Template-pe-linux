output "vm_name" {
  description = "Nombre de la VM creada"
  value       = google_compute_instance.vm_linux.name
}

output "vm_ip" {
  description = "Dirección IP pública (si aplica)"
  value       = try(google_compute_instance.vm_linux.network_interface[0].access_config[0].nat_ip, "")
}
