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
        JIRA_TRANSITIONS_URL = "https://bancoripley1.atlassian.net/rest/api/3/issue/AJI-83/transitions"
        TEAMS_WEBHOOK = "https://accenture.webhook.office.com/webhookb2/8fb63984-6f5f-4c2a-a6d3-b4fce2feb8ee@e0793d39-0939-496d-b129-198edd916feb/IncomingWebhook/334818fae3a84ae484512967d1d3f4f1/b08cc148-e951-496b-9f46-3f7e35f79570/V27mobtZgWmAzxIvjHCY5CMAFKPZptkEnQbT5z7X84QNQ1"
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
        string(name: 'VM_NAME', defaultValue: 'vm-pe-linux', description: 'Nombre VM')
        choice(name: 'PROCESSOR_TECH', choices: ['n2', 'e2'], description: 'Procesador')
        choice(name: 'VM_TYPE', choices: ['n2-standard', 'e2-standard'], description: 'Tipo VM')
        string(name: 'VM_CORES', defaultValue: '2', description: 'vCPUs')
        string(name: 'VM_MEMORY', defaultValue: '8', description: 'RAM GB')
        choice(name: 'OS_TYPE', choices: ['linux-ubuntu-22', 'linux-ubuntu-20', 'linux-debian-12'], description: 'OS')
        string(name: 'DISK_SIZE', defaultValue: '100', description: 'Disco GB')
        choice(name: 'DISK_TYPE', choices: ['pd-ssd', 'pd-balanced', 'pd-standard'], description: 'Tipo disco')
        choice(name: 'INFRAESTRUCTURE_TYPE', choices: ['On-demand', 'Preemptible'], description: 'Infraestructura')
        string(name: 'VPC_NETWORK', defaultValue: 'vpc-pe-01', description: 'VPC')
        string(name: 'SUBNET', defaultValue: 'subnet-pe-01', description: 'Subred')
        string(name: 'NETWORK_SEGMENT', defaultValue: '10.0.1.0/24', description: 'Segmento red')
        string(name: 'INTERFACE', defaultValue: 'nic0', description: 'Interfaz')
        choice(name: 'PRIVATE_IP', choices: ['true', 'false'], description: 'IP Privada')
        choice(name: 'PUBLIC_IP', choices: ['false', 'true'], description: 'IP Pública')
        string(name: 'FIREWALL_RULES', defaultValue: 'allow-ssh', description: 'Firewall')
        string(name: 'SERVICE_ACCOUNT', defaultValue: 'sa-plataforma@jenkins-terraform-demo-472920.iam.gserviceaccount.com', description: 'Cuenta Servicio')
        string(name: 'LABEL', defaultValue: 'app=demo', description: 'Label')
        choice(name: 'ENABLE_STARTUP_SCRIPT', choices: ['false', 'true'], description: 'Startup script')
        choice(name: 'ENABLE_DELETION_PROTECTION', choices: ['false', 'true'], description: 'Protección eliminación')
        choice(name: 'CHECK_DELETE', choices: ['false', 'true'], description: 'Confirmación borrado')
        choice(name: 'AUTO_DELETE_DISK', choices: ['true', 'false'], description: 'Auto delete disk')
        string(name: 'TICKET_JIRA', defaultValue: 'AJI-1', description: 'Ticket Jira')
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
                    params.each { key, value -> echo "${key}: ${value}" }
                }
            }
        }

        stage('Validación de Parámetros') {
            steps {
                script {
                    def errores = []
                    if (!params.SUBNET?.trim()) errores.add("SUBNET no puede estar vacío")
                    if (!params.NETWORK_SEGMENT?.trim()) errores.add("NETWORK_SEGMENT no puede estar vacío")
                    if (errores) {
                        errores.each { echo it }
                        error("Validación de parámetros fallida")
                    }
                }
            }
        }

        stage('Resumen Pre-Despliegue') {
            steps {
                script {
                    echo "================================================"
                    echo "              RESUMEN DE CONFIGURACIÓN          "
                    echo "================================================"
                    echo "Sistema Operativo Base: ${env.SISTEMA_OPERATIVO_BASE}"
                    echo "Tipo de Procesador: ${params.PROCESSOR_TECH}"
                    echo "Memoria RAM (GB): ${params.VM_MEMORY}"
                    echo "Disco (GB): ${params.DISK_SIZE}"
                    echo "Infraestructura: ${params.INFRAESTRUCTURE_TYPE}"
                }
            }
        }

        stage('Validación de Parámetros Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        echo "==============================================="
                        echo " Validando estado del ticket ${params.TICKET_JIRA}"
                        echo "==============================================="

                        def estado = sh(script: """
                            bash -c '
                            curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" -H "Accept: application/json" \
                            | jq -r ".fields.status.name // \\"Desconocido\\""
                            '
                        """, returnStdout: true).trim()

                        echo "Estado actual del ticket: ${estado}"

                        // CASE 1: Ya finalizado o Done
                        if (estado.toLowerCase() in ['done','finalizado','closed','cerrado']) {
                            def mensaje = groovy.json.JsonOutput.toJson([text: "Error: El ticket ${params.TICKET_JIRA} ya se encuentra en estado '${estado}'. Ejecución detenida."])
                            writeFile file: 'teams_error.json', text: mensaje
                            sh "curl -H 'Content-Type: application/json' -d @teams_error.json ${TEAMS_WEBHOOK}"
                            error("El ticket ${params.TICKET_JIRA} ya está '${estado}'")
                        }

                        // CASE 2: En curso → pasar a Finalizado
                        if (estado.toLowerCase() == 'en curso') {
                            echo "El ticket está en curso. Buscando transición a 'Finalizado'..."

                            def transitionId = sh(script: """
                                bash -c '
                                curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" -X GET "${JIRA_TRANSITIONS_URL}" -H "Accept: application/json" \
                                | jq -r ".transitions[] | select((.name|ascii_downcase) | test(\\"finaliz|done|cerrad\\")) | .id" | head -n1
                                '
                            """, returnStdout: true).trim()

                            if (transitionId) {
                                echo "Usando transition id: ${transitionId} para mover ticket a Finalizado..."

                                // Comentario en Jira
                                sh """
                                    bash -c 'curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/comment" \
                                    -H "Content-Type: application/json" \
                                    -d "{\\"body\\": \\"Pipeline Jenkins: Se procede a mover el ticket a estado Finalizado automáticamente.\\"}"
                                    '
                                """

                                // Transición
                                sh """
                                    bash -c 'curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \
                                    -H "Content-Type: application/json" \
                                    -d "{\\"transition\\":{\\"id\\":\\"${transitionId}\\"}}"
                                    '
                                """

                                def okMsg = groovy.json.JsonOutput.toJson([text: "Ticket ${params.TICKET_JIRA} pasó automáticamente de 'En curso' a 'Finalizado' (transition id: ${transitionId})."])
                                writeFile file: 'teams_message.json', text: okMsg
                                sh "curl -H 'Content-Type: application/json' -d @teams_message.json ${TEAMS_WEBHOOK}"
                            } else {
                                def warn = groovy.json.JsonOutput.toJson([text: "No se encontró transición a 'Finalizado' o 'Done' para ${params.TICKET_JIRA}."])
                                writeFile file: 'teams_warn.json', text: warn
                                sh "curl -H 'Content-Type: application/json' -d @teams_warn.json ${TEAMS_WEBHOOK}"
                                error("No se encontró transición válida a 'Finalizado' o 'Done'.")
                            }
                        } else {
                            def info = groovy.json.JsonOutput.toJson([text: "Ticket ${params.TICKET_JIRA} en estado '${estado}'. No se requiere acción."])
                            writeFile file: 'teams_info.json', text: info
                            sh "curl -H 'Content-Type: application/json' -d @teams_info.json ${TEAMS_WEBHOOK}"
                        }
                    }
                }
            }
        }

        stage('Notificación Final Teams') {
            steps {
                script {
                    def msg = groovy.json.JsonOutput.toJson([text: "Pipeline finalizó correctamente. Ticket ${params.TICKET_JIRA} validado y actualizado."])
                    writeFile file: 'teams_final.json', text: msg
                    sh "curl -H 'Content-Type: application/json' -d @teams_final.json ${TEAMS_WEBHOOK}"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline ejecutado exitosamente"
        }
        failure {
            echo "Pipeline falló durante la ejecución"
        }
        always {
            echo "================================================"
            echo " FIN DE LA EJECUCIÓN "
            echo " Fecha: ${new Date()}"
            echo "================================================"
        }
    }
}
