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
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
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
        choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Protección eliminación')
        choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Confirmación borrado')
        choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Auto delete disk')
        string(name: 'TICKET_JIRA', defaultValue: 'AJI-83', description: 'Ticket Jira')
    }

    stages {

        stage('Validación de Parámetros') {
            steps {
                script {
                    echo "================================================"
                    echo "         VALIDACIÓN DE PARÁMETROS              "
                    echo "================================================"

                    def errores = []
                    if (!params.SUBNET?.trim()) errores.add("SUBNET no puede estar vacío")
                    if (!params.NETWORK_SEGMENT?.trim()) errores.add("NETWORK_SEGMENT no puede estar vacío")

                    if (errores.size() > 0) {
                        errores.each { echo "  - ${it}" }
                        error("Validación fallida")
                    }
                    echo "Validación completada correctamente"
                }
            }
        }

        stage('Mostrar Variables') {
            steps {
                script {
                    echo "================================================"
                    echo "           VARIABLES OCULTAS                    "
                    echo "================================================"
                    echo "PAIS: ${PAIS}"
                    echo "SISTEMA_OPERATIVO_BASE: ${SISTEMA_OPERATIVO_BASE}"
                    echo "SNAPSHOT_ENABLED: ${SNAPSHOT_ENABLED}"
                    echo "SNAPSHOT_VM: ${SNAPSHOT_VM}"
                    echo "SNAPSHOT_SO: ${SNAPSHOT_SO}"
                    echo "SNAPSHOT_DISK: ${SNAPSHOT_DISK}"
                    echo "LABEL: ${LABEL}"
                    echo "ENABLE_STARTUP_SCRIPT: ${ENABLE_STARTUP_SCRIPT}"

                    echo "================================================"
                    echo "        VARIABLES Y PARÁMETROS DEL PIPELINE     "
                    echo "================================================"

                    def paramOrder = [
                        'SERVICE_ACCOUNT','CHECK_DELETE','FIREWALL_RULES','ZONE','DISK_SIZE','NETWORK_SEGMENT',
                        'ENABLE_STARTUP_SCRIPT','ENVIRONMENT','PROYECT_ID','VM_NAME','PROCESSOR_TECH','INTERFACE',
                        'AUTO_DELETE_DISK','LABEL','VM_CORES','PRIVATE_IP','VM_TYPE','ENABLE_DELETION_PROTECTION',
                        'TICKET_JIRA','OS_TYPE','PUBLIC_IP','INFRAESTRUCTURE_TYPE','REGION','SUBNET','VM_MEMORY',
                        'VPC_NETWORK','DISK_TYPE'
                    ]
                    paramOrder.each { p ->
                        echo "${p}: ${params.get(p)}"
                    }
                }
            }
        }

stage('Gestionar Jira y Teams') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {

                // Escribir credenciales sin interpolación insegura
                writeFile file: 'jira_auth.txt', text: JIRA_USER + ':' + JIRA_API_TOKEN

                def issueResponse = sh(script: "curl -s -u \$(cat jira_auth.txt) -X GET ${JIRA_API_URL}${params.TICKET_JIRA} -H 'Accept: application/json'", returnStdout: true).trim()

                // Usar matcher seguro
                def matcher = issueResponse =~ /"name"\s*:\s*"([^"]+)"/
                def status = matcher.find() ? matcher[0][1] : 'Desconocido'
                matcher = null // evitar problemas de serialización

                if (status != 'Finalizada') {
                    echo "Estado actual del ticket ${params.TICKET_JIRA}: ${status}"
                    echo "Cambiando estado a 'Finalizado'..."
                    sh "curl -s -u \$(cat jira_auth.txt) -X POST ${JIRA_API_URL}${params.TICKET_JIRA}/transitions -H 'Content-Type: application/json' -d '{\"transition\": {\"id\": \"31\"}}'"
                    echo "Ticket actualizado a Finalizado."
                } else {
                    echo "El ticket ya está en estado Finalizado."
                }

                def teamsMessage = [
                    title: "Pipeline ejecutado correctamente",
                    text: """Detalles de la VM:
Instancia: ${params.VM_NAME}
Ambiente: ${params.ENVIRONMENT}
Proyecto: ${params.PROYECT_ID}
Región: ${params.REGION}
Fecha: ${new Date()}
Build URL: ${env.BUILD_URL}"""
                ]

                sh "curl -H 'Content-Type: application/json' -d '${groovy.json.JsonOutput.toJson(teamsMessage)}' -X POST https://accenture.webhook.office.com/webhookb2/870e2ab9-53bf-43f6-8655-376cbe11bd1c@e0793d39-0939-496d-b129-198edd916feb/IncomingWebhook/f495e4cf395c416e83eae4fb3b9069fd/b08cc148-e951-496b-9f46-3f7e35f79570/V2r0-VttaFGsrZXpm8qS18JcqaHZ26SxRAT51CZvkTR-A1"
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
