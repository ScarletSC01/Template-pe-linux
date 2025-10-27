pipeline {
    agent any

    environment {
        PAIS = 'PE'
        SISTEMA_OPERATIVO_BASE = 'Linux'
        SNAPSHOT_ENABLED = 'true'
        SNAPSHOT_VM = 'snap_vm_01'
        SNAPSHOT_SO = 'snap_os_01'
        SNAPSHOT_DISK = 'snap_disk_01'
        LABEL = 'vm-template'
        ENABLE_STARTUP_SCRIPT = 'true'
        JIRA_API_URL = "https://bancoripley1.atlassian.net/rest/api/3/issue/"
        TEAMS_WEBHOOK_URL = "https://accenture.webhook.office.com/webhookb2/xxxxxxxxxx" // reemplazar por tu webhook
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        // Variables visibles en orden
        string(name: 'PROYECT_ID', defaultValue: '', description: 'ID del proyecto en Google Cloud Platform')
        string(name: 'REGION', defaultValue: 'us-central1', description: 'Región de GCP donde se desplegará la VM')
        string(name: 'ZONE', defaultValue: 'us-central1-a', description: 'Zona de disponibilidad específica')
        choice(name: 'ENVIRONMENT', choices: ['desarrollo-1', 'pre-productivo-2', 'produccion-3'], description: 'Ambiente de despliegue de la infraestructura')
        string(name: 'VM_NAME', defaultValue: 'vm-cl-linux', description: 'Nombre único para la máquina virtual')
        choice(name: 'PROCESSOR_TECH', choices: ['n2', 'e2'], description: 'Tecnología de procesador')
        choice(name: 'VM_TYPE', choices: ['n2-standard', 'e2-standard'], description: 'Familia de tipo de máquina virtual')
        string(name: 'VM_CORES', defaultValue: '2', description: 'Número de vCPUs para la máquina virtual')
        string(name: 'VM_MEMORY', defaultValue: '8', description: 'Memoria RAM en GB')
        choice(name: 'OS_TYPE', choices: ['linux-ubuntu-22', 'linux-ubuntu-20', 'linux-debian-12'], description: 'Versión del sistema operativo')
        string(name: 'DISK_SIZE', defaultValue: '100', description: 'Tamaño del disco persistente en GB')
        choice(name: 'DISK_TYPE', choices: ['pd-ssd', 'pd-balanced', 'pd-standard'], description: 'Tipo de disco')
        choice(name: 'INFRAESTRUCTURE_TYPE', choices: ['On-demand', 'Preemptible'], description: 'Tipo de infraestructura')
        string(name: 'VPC_NETWORK', defaultValue: 'vpc-cl-01', description: 'Nombre de la red VPC')
        string(name: 'SUBNET', defaultValue: 'subnet-cl-01', description: 'Nombre de la subred')
        string(name: 'NETWORK_SEGMENT', defaultValue: '10.0.1.0/24', description: 'Segmento de red CIDR')
        string(name: 'INTERFACE', defaultValue: 'nic0', description: 'Nombre de la interfaz de red principal')
        choice(name: 'PRIVATE_IP', choices: ['true', 'false'], description: 'Asignar IP privada estática')
        choice(name: 'PUBLIC_IP', choices: ['false', 'true'], description: 'Asignar IP pública externa')
        string(name: 'FIREWALL_RULES', defaultValue: 'allow-ssh', description: 'Reglas de firewall separadas por comas')
        string(name: 'SERVICE_ACCOUNT', defaultValue: 'sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com', description: 'Cuenta de servicio para la VM')
        string(name: 'LABEL', defaultValue: 'app=demo', description: 'Etiquetas personalizadas para la VM')
        choice(name: 'ENABLE_STARTUP_SCRIPT', choices: ['false', 'true'], description: 'Habilitar script de inicio personalizado')
        choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Proteger la VM contra eliminación accidental')
        choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Solicitar confirmación antes de eliminar recursos')
        choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Eliminar automáticamente el disco al eliminar la VM')
        string(name: 'TICKET_JIRA', defaultValue: 'AJI-83', description: 'Ticket de Jira a consultar y comentar')
    }

    stages {
        stage('Mostrar Variables Ocultas y Visibles') {
            steps {
                script {
                    echo "================== Variables Ocultas =================="
                    echo "PAIS: ${env.PAIS}"
                    echo "SISTEMA_OPERATIVO_BASE: ${env.SISTEMA_OPERATIVO_BASE}"
                    echo "SNAPSHOT_ENABLED: ${env.SNAPSHOT_ENABLED}"
                    echo "SNAPSHOT_VM: ${env.SNAPSHOT_VM}"
                    echo "SNAPSHOT_SO: ${env.SNAPSHOT_SO}"
                    echo "SNAPSHOT_DISK: ${env.SNAPSHOT_DISK}"
                    echo "LABEL: ${env.LABEL}"
                    echo "ENABLE_STARTUP_SCRIPT: ${env.ENABLE_STARTUP_SCRIPT}"
                    
                    echo "================== Variables Visibles =================="
                    echo "PROYECT_ID: ${params.PROYECT_ID}"
                    echo "REGION: ${params.REGION}"
                    echo "ZONE: ${params.ZONE}"
                    echo "ENVIRONMENT: ${params.ENVIRONMENT}"
                    echo "VM_NAME: ${params.VM_NAME}"
                    echo "PROCESSOR_TECH: ${params.PROCESSOR_TECH}"
                    echo "VM_TYPE: ${params.VM_TYPE}"
                    echo "VM_CORES: ${params.VM_CORES}"
                    echo "VM_MEMORY: ${params.VM_MEMORY}"
                    echo "OS_TYPE: ${params.OS_TYPE}"
                    echo "DISK_SIZE: ${params.DISK_SIZE}"
                    echo "DISK_TYPE: ${params.DISK_TYPE}"
                    echo "INFRAESTRUCTURE_TYPE: ${params.INFRAESTRUCTURE_TYPE}"
                    echo "VPC_NETWORK: ${params.VPC_NETWORK}"
                    echo "SUBNET: ${params.SUBNET}"
                    echo "NETWORK_SEGMENT: ${params.NETWORK_SEGMENT}"
                    echo "INTERFACE: ${params.INTERFACE}"
                    echo "PRIVATE_IP: ${params.PRIVATE_IP}"
                    echo "PUBLIC_IP: ${params.PUBLIC_IP}"
                    echo "FIREWALL_RULES: ${params.FIREWALL_RULES}"
                    echo "SERVICE_ACCOUNT: ${params.SERVICE_ACCOUNT}"
                    echo "LABEL: ${params.LABEL}"
                    echo "ENABLE_STARTUP_SCRIPT: ${params.ENABLE_STARTUP_SCRIPT}"
                    echo "ENABLE_DELETION_PROTECTION: ${params.ENABLE_DELETION_PROTECTION}"
                    echo "CHECK_DELETE: ${params.CHECK_DELETE}"
                    echo "AUTO_DELETE_DISK: ${params.AUTO_DELETE_DISK}"
                    echo "TICKET_JIRA: ${params.TICKET_JIRA}"
                }
            }
        }

        // --- BLOQUES TERRAFORM COMENTADOS ---
        /*
        stage('Terraform Init & Plan') { steps { echo 'Terraform Init & Plan' } }
        stage('Terraform Apply') { steps { echo 'Terraform Apply' } }
        stage('Terraform Destroy') { steps { echo 'Terraform Destroy' } }
        */

        stage('Post-Jira Status') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))
                        def response = sh(
                            script: """
                                curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" \\
                                -H "Authorization: Basic ${auth}" \\
                                -H "Accept: application/json"
                            """,
                            returnStdout: true
                        ).trim()
                        def json = new groovy.json.JsonSlurper().parseText(response)
                        def estado = json.fields.status.name
                        echo "Estado actual del ticket ${params.TICKET_JIRA}: ${estado}"
                    }
                }
            }
        }

        stage('Post-Coment-jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))
                        def comentario = "Este ticket fue comentado por Scarlet SC"
                        sh """
                            curl -s -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/comment" \\
                            -H "Authorization: Basic ${auth}" \\
                            -H "Content-Type: application/json" \\
                            -d '{
                                "body": {
                                    "type": "doc",
                                    "version": 1,
                                    "content": [
                                        {
                                            "type": "paragraph",
                                            "content": [
                                                { "type": "text", "text": "${comentario}" }
                                            ]
                                        }
                                    ]
                                }
                            }'
                        """
                        echo "Comentario enviado al ticket ${params.TICKET_JIRA}"
                    }
                }
            }
        }

        stage('Validar y Cerrar Ticket Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))

                        // Consultar estado actual
                        def ticketResponse = sh(
                            script: """
                                curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" \\
                                -H "Authorization: Basic ${auth}" \\
                                -H "Accept: application/json"
                            """,
                            returnStdout: true
                        ).trim()
                        def ticketJson = new groovy.json.JsonSlurper().parseText(ticketResponse)
                        def estadoActual = ticketJson.fields.status.name
                        echo "Estado actual del ticket ${params.TICKET_JIRA}: ${estadoActual}"

                        // Consultar transiciones
                        def transitionsResponse = sh(
                            script: """
                                curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \\
                                -H "Authorization: Basic ${auth}" \\
                                -H "Accept: application/json"
                            """,
                            returnStdout: true
                        ).trim()
                        def transitionsJson = new groovy.json.JsonSlurper().parseText(transitionsResponse)

                        // Buscar transición a 'Finalizado'
                        def cerrarTransition = transitionsJson.transitions.find { it.name.toLowerCase().contains('finalizado') || it.name.toLowerCase().contains('done') }

                        if (estadoActual.toLowerCase() == 'en curso' && cerrarTransition != null) {
                            sh """
                                curl -s -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \\
                                -H "Authorization: Basic ${auth}" \\
                                -H "Content-Type: application/json" \\
                                -d '{ "transition": { "id": "${cerrarTransition.id}" } }'
                            """
                            echo "Ticket ${params.TICKET_JIRA} cambiado a estado Finalizado"
                            env.TICKET_FINALIZADO = "true"
                        } else {
                            echo "No se puede finalizar el ticket automáticamente. Estado actual: ${estadoActual}"
                            env.TICKET_FINALIZADO = "false"
                        }

                        // Notificación Teams
                        def mensajeTeams = """
                        {
                            "@type": "MessageCard",
                            "@context": "https://schema.org/extensions",
                            "summary": "Actualización de ticket Jira",
                            "themeColor": "${env.TICKET_FINALIZADO == 'true' ? '00FF00' : 'FF0000'}",
                            "title": "Ticket Jira: ${params.TICKET_JIRA}",
                            "text": "**Estado anterior:** ${estadoActual}\\n**Ticket finalizado automáticamente:** ${env.TICKET_FINALIZADO}"
                        }
                        """
                        writeFile file: 'teams_ticket.json', text: mensajeTeams
                        sh "curl -H 'Content-Type: application/json' -d @teams_ticket.json ${env.TEAMS_WEBHOOK_URL}"
                        echo "Notificación enviada a Teams sobre ticket Jira"
                    }
                }
            }
        }

        stage('Notificación Teams') {
            steps {
                script {
                    def mensaje = """
                    {
                        "@type": "MessageCard",
                        "@context": "https://schema.org/extensions",
                        "summary": "Pipeline ejecutado",
                        "themeColor": "0078D7",
                        "title": "Ejecución Jenkins",
                        "text": "Pipeline completado. Ticket Jira: ${params.TICKET_JIRA}"
                    }
                    """
                    writeFile file: 'teams_message.json', text: mensaje
                    sh "curl -H 'Content-Type: application/json' -d @teams_message.json ${env.TEAMS_WEBHOOK_URL}"
                    echo "Notificación enviada a Teams"
                }
            }
        }
    }

    post {
        success { echo "Pipeline ejecutado exitosamente" }
        failure { echo "Pipeline falló durante la ejecución" }
        always {
            echo "================================================"
            echo "            FIN DE LA EJECUCIÓN                "
            echo "  Fecha: ${new Date()}"
            echo "================================================"
        }
    }
}

