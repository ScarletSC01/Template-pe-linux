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
        TEAMS_WEBHOOK = "https://accenture.webhook.office.com/webhookb2/..."
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        // VARIABLES VISIBLES
        string(name: 'PROYECT_ID', defaultValue: '', description: 'ID del proyecto en GCP')
        string(name: 'REGION', defaultValue: 'us-central1', description: 'Región')
        string(name: 'ZONE', defaultValue: 'us-central1-a', description: 'Zona')
        choice(name: 'ENVIRONMENT', choices: ['desarrollo-1', 'pre-productivo-2', 'produccion-3'], description: 'Ambiente')
        string(name: 'VM_NAME', defaultValue: 'vm-cl-linux', description: 'Nombre VM')
        choice(name: 'PROCESSOR_TECH', choices: ['n2', 'e2'], description: 'Procesador')
        choice(name: 'VM_TYPE', choices: ['n2-standard', 'e2-standard'], description: 'Tipo VM')
        string(name: 'VM_CORES', defaultValue: '2', description: 'vCPUs')
        string(name: 'VM_MEMORY', defaultValue: '8', description: 'RAM GB')
        choice(name: 'OS_TYPE', choices: ['linux-ubuntu-22', 'linux-ubuntu-20', 'linux-debian-12'], description: 'OS')
        string(name: 'DISK_SIZE', defaultValue: '100', description: 'Tamaño disco GB')
        choice(name: 'DISK_TYPE', choices: ['pd-ssd', 'pd-balanced', 'pd-standard'], description: 'Tipo disco')
        choice(name: 'INFRAESTRUCTURE_TYPE', choices: ['On-demand', 'Preemptible'], description: 'Infraestructura')
        string(name: 'VPC_NETWORK', defaultValue: 'vpc-cl-01', description: 'VPC')
        string(name: 'SUBNET', defaultValue: 'subnet-cl-01', description: 'Subred')
        string(name: 'NETWORK_SEGMENT', defaultValue: '10.0.1.0/24', description: 'Segmento red')
        string(name: 'INTERFACE', defaultValue: 'nic0', description: 'Interfaz')
        choice(name: 'PRIVATE_IP', choices: ['true', 'false'], description: 'IP Privada')
        choice(name: 'PUBLIC_IP', choices: ['false', 'true'], description: 'IP Pública')
        string(name: 'FIREWALL_RULES', defaultValue: 'allow-ssh', description: 'Firewall')
        string(name: 'SERVICE_ACCOUNT', defaultValue: 'sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com', description: 'Cuenta Servicio')
        string(name: 'LABEL', defaultValue: 'app=demo', description: 'Label')
        choice(name: 'ENABLE_STARTUP_SCRIPT', choices: ['false', 'true'], description: 'Habilitar script')
        choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Protección eliminación')
        choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Confirmación borrado')
        choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Auto delete disk')
        string(name: 'TICKET_JIRA', defaultValue: 'AJI-83', description: 'Ticket Jira')
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
                    params.each { k, v -> echo "${k}: ${v}" }
                }
            }
        }

        stage('Post-Jira Status y Transición') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {

                        // Generar auth
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))

                        // Llamada GET ticket
                        def response = sh(
                            script: """curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" -H "Authorization: Basic ${auth}" -H "Accept: application/json" """,
                            returnStdout: true
                        ).trim()

                        // Parse JSON fuera de contexto serializable
                        @NonCPS
                        def parseJson(String jsonText) {
                            return new groovy.json.JsonSlurper().parseText(jsonText)
                        }

                        def ticketJson = parseJson(response)
                        def estado = ticketJson.fields.status.name.toString()
                        echo "Estado actual del ticket ${params.TICKET_JIRA}: ${estado}"

                        // Si está "En curso", ejecutar transición a finalizado
                        if (estado.toLowerCase() == "en curso") {
                            echo "Transición automática a 'Finalizado'..."

                            def transResponse = sh(
                                script: """curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" -H "Authorization: Basic ${auth}" -H "Accept: application/json" """,
                                returnStdout: true
                            ).trim()

                            def transitions = parseJson(transResponse)
                            def transitionId = transitions.transitions.find { it.name.toLowerCase().contains("finalizado") }?.id
                            if (transitionId) {
                                sh """curl -s -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \\
                                    -H "Authorization: Basic ${auth}" \\
                                    -H "Content-Type: application/json" \\
                                    -d '{ "transition": { "id": "${transitionId}" } }'"""
                                echo "Ticket ${params.TICKET_JIRA} finalizado automáticamente."
                            } else {
                                echo "No se encontró transición a 'Finalizado'."
                            }
                        }
                    }
                }
            }
        }

        stage('Notificación Teams') {
            steps {
                script {
                    def mensaje = """{
                        "title": "Pipeline Jira & VM",
                        "text": "Ticket ${params.TICKET_JIRA} revisado. Estado final: ${estado}. Proyecto: ${params.PROYECT_ID}, VM: ${params.VM_NAME}"
                    }"""
                    writeFile file: 'teams_message.json', text: mensaje
                    sh "curl -H 'Content-Type: application/json' -d @teams_message.json ${env.TEAMS_WEBHOOK}"
                    echo "Notificación enviada a Teams"
                }
            }
        }

        /*
        stage('Terraform Init & Plan') { ... }
        stage('Terraform Apply') { ... }
        stage('Terraform Destroy') { ... }
        */
    }

    post {
        success { echo "Pipeline ejecutado exitosamente" }
        failure { echo "Pipeline falló durante la ejecución" }
        always {
            echo "==============================================="
            echo "            FIN DE LA EJECUCIÓN                "
            echo "  Fecha: ${new Date()}"
            echo "==============================================="
        }
    }
}
