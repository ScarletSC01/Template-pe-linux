variable "PROJECT_ID" {}
variable "REGION" {}
variable "ZONE" {}
variable "VM_NAME" {}
variable "VM_TYPE" {}
variable "VM_CORES" {}
variable "DISK_SIZE" {}
variable "DISK_TYPE" {}
variable "OS_TYPE" {}
variable "VPC_NETWORK" {}
variable "SUBNET" {}
variable "NETWORK_SEGMENT" {}
variable "SERVICE_ACCOUNT" {}
variable "LABEL" { default = "" }
variable "PUBLIC_IP" { default = "true" }
variable "AUTO_DELETE_DISK" { default = "true" }
variable "ENABLE_STARTUP_SCRIPT" { default = "false" }
variable "ENABLE_DELETION_PROTECTION" { default = "false" }
variable "ENVIRONMENT" {}
