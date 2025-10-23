# ================================================================
# PARÁMETROS DE CONFIGURACIÓN TERRAFORM - PLANTILLA PE LINUX
# ================================================================

PROJECT_ID               = "jenkins-terraform-demo-472920"      # ID del proyecto en Google Cloud Platform
REGION                   = "us-central1"                         # Región de GCP donde se desplegará la VM
ZONE                     = "us-central1-a"                       # Zona de disponibilidad específica
ENVIRONMENT              = "desarrollo-1"                        # Ambiente de despliegue de la infraestructura

VM_NAME                  = "vm-pe-linux"                         # Nombre único para la máquina virtual
PROCESSOR_TECH           = "n2"                                  # Tecnología de procesador
VM_TYPE                  = "n2-standard"                         # Familia de tipo de máquina virtual
VM_CORES                 = 2                                     # Número de vCPUs para la máquina virtual
VM_MEMORY                = 8                                     # Memoria RAM en GB
OS_TYPE                  = "debian-11"                           # Versión del sistema operativo

DISK_SIZE                = 100                                   # Tamaño del disco persistente en GB
DISK_TYPE                = "pd-ssd"                              # Tipo de disco (pd-ssd, pd-balanced, pd-standard)
INFRAESTRUCTURE_TYPE     = "On-demand"                           # Tipo de infraestructura

VPC_NETWORK              = "vpc-pe-01"                           # Nombre de la red VPC
SUBNET                   = "subnet-pe-01"                        # Nombre de la subred
NETWORK_SEGMENT          = "10.0.1.0/24"                         # Segmento de red CIDR
INTERFACE                = "nic0"                                # Nombre de la interfaz de red principal

PRIVATE_IP               = true                                  # Asignar IP privada estática
PUBLIC_IP                = false                                 # Asignar IP pública externa

FIREWALL_RULES           = "allow-rdp,allow-winrm"               # Reglas de firewall separadas por comas

SERVICE_ACCOUNT          = "sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com"  # Cuenta de servicio

LABEL                    = "app=demo"                                    # Etiquetas personalizadas para la VM (ejemplo: "ambiente=dev,pais=pe")

ENABLE_STARTUP_SCRIPT    = false                                 # Habilitar script de inicio personalizado
ENABLE_DELETION_PROTECTION = false                               # Proteger VM contra eliminación accidental
CHECK_DELETE             = false                                 # Solicitar confirmación antes de eliminar recursos
AUTO_DELETE_DISK         = true                                  # Eliminar automáticamente el disco al eliminar la VM
