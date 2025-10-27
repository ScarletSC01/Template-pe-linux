pipeline {   
    agent any

    environment {
        PAIS = 'PE'
        SISTEMA_OPERATIVO_BASE = 'Linux'
        SNAPSHOT_ENABLED = 'true'
        JIRA_API_URL = "https://bancoripley1.atlassian.net/rest/api/3/issue/"
        JIRA_API_TOKEN = "" // Debes definirlo si usas autenticación básica
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        string(name: 'PROYECT_ID', defaultValue: '', description: 'ID del proyecto en Google Cloud Platform')
        string(name: 'REGION', defaultValue: 'us-central1', description: 'Región de GCP donde se desplegará la VM')
        string(name: 'ZONE', defaultValue: 'us-central1-a', description: 'Zona de disponibilidad específica')
        choice(name: 'ENVIRONMENT', choices: ['desarrollo-1', 'pre-productivo-2', 'produccion-3'], description: 'Ambiente de despliegue')
        string(name: 'VM_NAME', defaultValue: 'vm-pe-linux', description: 'Nombre único para la máquina virtual')
        choice(name: 'PROCESSOR_TECH', choices: ['n2', 'e2'], description: 'Tecnología de procesador')
        choice(name: 'VM_TYPE', choices: ['n2-standard', 'e2-standard'], description: 'Familia de máquina virtual')
        string(name: 'VM_CORES', defaultValue: '2', description: 'Número de vCPUs')
        string(name: 'VM_MEMORY', defaultValue: '8', description: 'Memoria RAM en GB')
        choice(name: 'OS_TYPE', choices: ['linux-ubuntu-22', 'linux-ubuntu-20', 'linux-debian-12'], description: 'Versión del sistema operativo')
        string(name: 'DISK_SIZE', defaultValue: '100', description: 'Tamaño del disco (GB)')
        choice(name: 'DISK_TYPE', choices: ['pd-ssd', 'pd-balanced', 'pd-standard'], description: 'Tipo de disco')
        choice(name: 'INFRAESTRUCTURE_TYPE', choices: ['On-demand', 'Preemptible'], description: 'Tipo de infraestructura')
        string(name: 'VPC_NETWORK', defaultValue: 'vpc-pe-01', description: 'Nombre de la red VPC')
        string(name: 'SUBNET', defaultValue: 'subnet-pe-01', description: 'Subred')
        string(name: 'NETWORK_SEGMENT', defaultValue: '10.0.1.0/24', description: 'Segmento de red CIDR')
        string(name: 'INTERFACE', defaultValue: 'nic0', description: 'Interfaz de red principal')
        choice(name: 'PRIVATE_IP', choices: ['true', 'false'], description: 'Asignar IP privada')
        choice(name: 'PUBLIC_IP', choices: ['false', 'true'], description: 'Asignar IP pública')
        string(name: 'FIREWALL_RULES', defaultValue: 'allow-ssh', description: 'Reglas de firewall')
        string(name: 'SERVICE_ACCOUNT', defaultValue: 'sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com', description: 'Cuenta de servicio')
        string(name: 'LABEL', defaultValue: '', description: 'Etiquetas personalizadas')
        choice(name: 'ENABLE_STARTUP_SCRIPT', choices: ['false', 'true'], description: 'Script de inicio')
        choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Protección contra eliminación')
        choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Confirmación antes de eliminar')
        choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Eliminar disco al borrar VM')
        string(name: 'TICKET_JIRA', defaultValue: 'AJI-1', description: 'Ticket de Jira')
    }

    stages {
        stage('Validación de Parámetros') {
            steps {
                script {
                    echo "================================================"
                    echo "         VALIDACIÓN DE PARÁMETROS              "
                    echo "================================================"

                    def errores = []
                    if (!params.SUBNET?.trim()) errores.add("El parámetro SUBNET no puede estar vacío")
                    if (!params.NETWORK_SEGMENT?.trim()) errores.add("El parámetro NETWORK_SEGMENT no puede estar vacío")

                    if (errores.size() > 0) {
                        echo "Errores encontrados:"
                        errores.each { echo "  - ${it}" }
                        error("Validación fallida")
                    }
                    echo "Validación completada correctamente"
                }
            }
        }

        stage('Notify Teams') {
            steps {
                script {
                    def teamsWebhookUrl = "https://accenture.webhook.office.com/webhookb2/870e2ab9-53bf-43f6-8655-376cbe11bd1c@e0793d39-0939-496d-b129-198edd916feb/IncomingWebhook/f495e4cf395c416e83eae4fb3b9069fd/b08cc148-e951-496b-9f46-3f7e35f79570/V2r0-VttaFGsrZXpm8qS18JcqaHZ26SxRAT51CZvkTR-A1"

                    // Obtener estado del ticket
                    def jiraState = sh(script: "curl -s -X GET ${JIRA_API_URL}${params.TICKET_JIRA} -H 'Authorization: Basic ${JIRA_API_TOKEN}' -H 'Accept: application/json' | jq -r '.fields.status.name'", returnStdout: true).trim()

                    def ticketMessage = ""
                    if (jiraState == "Finalizada") {
                        ticketMessage = "El ticket ${params.TICKET_JIRA} ya estaba finalizado."
                    } else {
                        sh """
                        curl -s -X POST ${JIRA_API_URL}${params.TICKET_JIRA}/transitions \
                        -H 'Authorization: Basic ${JIRA_API_TOKEN}' \
                        -H 'Content-Type: application/json' \
                        -d '{"transition": {"id": "31"}}'
                        """
                        ticketMessage = "El ticket ${params.TICKET_JIRA} fue cambiado a Finalizado."
                    }

                    def message = """
                    {
                        "title": "Pipeline ejecutado",
                        "text": "Detalles de la Instancia:\\nInstancia VM: ${params.VM_NAME}\\nAmbiente: ${params.ENVIRONMENT}\\nTipo de Servicio: GCP - Cloud SQL\\nConfiguración de Backup:\\nHora de Inicio del Backup: test\\nDías de Retención: test\\nEnlace de la Build: ${env.BUILD_URL}\\n\\n${ticketMessage}"
                    }
                    """

                    sh """
                    curl -H 'Content-Type: application/json' -d '${message}' ${teamsWebhookUrl}
                    """
                }
            }
        }
    }

    post {
        always {
            echo "================================================"
            echo "            FIN DE LA EJECUCIÓN                "
            echo "  Fecha: ${new Date()}"
            echo "================================================"
        }
    }
}
