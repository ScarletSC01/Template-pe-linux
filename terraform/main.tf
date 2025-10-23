provider "google" {
  project = var.PROJECT_ID
  region  = var.REGION
  zone    = var.ZONE
}

resource "google_compute_instance" "vm_linux" {
  name         = var.VM_NAME
  machine_type = "${var.VM_TYPE}-${var.VM_CORES}"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/${var.OS_TYPE}"
      size  = var.DISK_SIZE
      type  = var.DISK_TYPE
    }
    auto_delete = var.AUTO_DELETE_DISK == "true" ? true : false
  }

  network_interface {
    network    = var.VPC_NETWORK
    subnetwork = var.SUBNET
    dynamic "access_config" {
      for_each = var.PUBLIC_IP == "true" ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.SERVICE_ACCOUNT
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = var.ENABLE_STARTUP_SCRIPT == "true" ? file("startup.sh") : null

  tags = ["linux", lower(var.ENVIRONMENT)]

  deletion_protection = var.ENABLE_DELETION_PROTECTION == "true" ? true : false

  labels = merge(
    { sistema_operativo = "linux", pais = "pe" },
    length(var.LABEL) > 0 ? { for pair in split(",", var.LABEL) : split("=", pair)[0] => split("=", pair)[1] } : {}
  )
}
