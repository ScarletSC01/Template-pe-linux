resource "google_compute_network" "vpc_network" {
  name                    = var.VPC_NETWORK
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.SUBNET
  ip_cidr_range = var.NETWORK_SEGMENT
  region        = var.REGION
  network       = google_compute_network.vpc_network.id
}
