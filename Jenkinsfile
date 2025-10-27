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
        TEAMS_WEBHOOK = "https://accenture.webhook.office.com/webhookb2/870e2ab9-53bf-43f6-8655-376cbe11bd1c@e0793d39-0939-496d-b129-198edd916feb/IncomingWebhook/f495e4cf395c416e83eae4fb3b9069fd/b08cc148-e951-496b-9f46-3f7e35f79570/V2r0-VttaFGsrZXpm8qS18JcqaHZ26SxRAT51CZvkTR-A1"
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
                    params.each { key, value ->
                        echo "${key}: ${value}"
                    }
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
                    echo " RESUMEN DE CONFIGURACIÓN "
                    echo "================================================"
                    echo "Sistema Operativo Base: ${env.SISTEMA_OPERATIVO_BASE}"
                    echo "Tipo de Procesador: ${params.PROCESSOR_TECH}"
                    echo "Memoria RAM (GB): ${params.VM_MEMORY}"
                    echo "Disco (GB): ${params.DISK_SIZE}"
                    echo "Infraestructura: ${params.INFRAESTRUCTURE_TYPE}"
                }
            }
        }

        /* === BLOQUES TERRAFORM COMENTADOS ===
        stage('Terraform Init & Plan') { ... }
        stage('Terraform Apply') { ... }
        stage('Terraform Destroy') { ... }
        */

        stage('Validación de Parámetros Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))
                        def estadoActual = ""
                        def mensajeTeams = ""

                        echo "==============================================="
                        echo " Validando estado del ticket ${params.TICKET_JIRA}"
                        echo "==============================================="

                        def response = sh(script: """
                            curl -s -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" \
                            -H "Authorization: Basic ${auth}" \
                            -H "Accept: application/json"
                        """, returnStdout: true).trim()

                        def issueData = new groovy.json.JsonSlurper().parseText(response)
                        estadoActual = issueData?.fields?.status?.name ?: "Desconocido"
                        echo "Estado actual del ticket: ${estadoActual}"

                        if (estadoActual.toLowerCase() in ["done", "finalizado", "closed", "cerrado"]) {
                            mensajeTeams = "Error: El ticket ${params.TICKET_JIRA} ya se encuentra en estado '${estadoActual}'. Ejecución detenida."
                            writeFile file: 'teams_error.json', text: groovy.json.JsonOutput.toJson([text: mensajeTeams])
                            sh "curl -H 'Content-Type: application/json' -d @teams_error.json ${TEAMS_WEBHOOK}"
                            error(mensajeTeams)
                        }

                        if (estadoActual.toLowerCase() == "en curso") {
                            echo "El ticket está en curso. Procediendo a cerrarlo automáticamente..."
                            def transitionsResp = sh(script: """
                                curl -s -X GET "${JIRA_TRANSITIONS_URL}" \
                                -H "Authorization: Basic ${auth}" \
                                -H "Accept: application/json"
                            """, returnStdout: true).trim()

                            def transitions = new groovy.json.JsonSlurper().parseText(transitionsResp)
                            def finalizadoTransition = transitions?.transitions?.find {
                                it.name.toLowerCase().contains("finalizado") || it.name.toLowerCase().contains("done")
                            }

                            if (finalizadoTransition) {
                                sh """
                                    curl -s -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \
                                    -H "Authorization: Basic ${auth}" \
                                    -H "Content-Type: application/json" \
                                    -d '{ "transition": { "id": "${finalizadoTransition.id}" } }'
                                """
                                echo "Ticket ${params.TICKET_JIRA} movido a estado 'Finalizado'."
                                mensajeTeams = "Ticket ${params.TICKET_JIRA} pasó automáticamente de 'En curso' a 'Finalizado'."
                                writeFile file: 'teams_message.json', text: groovy.json.JsonOutput.toJson([text: mensajeTeams])
                                sh "curl -H 'Content-Type: application/json' -d @teams_message.json ${TEAMS_WEBHOOK}"
                            } else {
                                error("No se encontró transición válida a 'Finalizado' para el ticket ${params.TICKET_JIRA}.")
                            }
                        } else {
                            mensajeTeams = "El ticket ${params.TICKET_JIRA} tiene estado '${estadoActual}'. Continuando ejecución."
                            writeFile file: 'teams_info.json', text: groovy.json.JsonOutput.toJson([text: mensajeTeams])
                            sh "curl -H 'Content-Type: application/json' -d @teams_info.json ${TEAMS_WEBHOOK}"
                        }
                    }
                }
            }
        }

        stage('Notificación Teams (Jira)') {
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
