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
        choice(name: 'TARGET_STATE', choices: ['','To Do','In Progress','ATRASADO','Done'], description: 'Estado objetivo (déjalo vacío para no cambiar estado)')

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

        stage('Validar Estado Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        echo "Consultando estado actual del ticket ${params.TICKET_JIRA}..."

                        def estadoActual = sh(script: """bash -c '
                            curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                            -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" -H "Accept: application/json" \
                            | jq -r ".fields.status.name // \\"Desconocido\\""
                        '""", returnStdout: true).trim()

                        echo "Estado actual del ticket: ${estadoActual}"
                        env.JIRA_ESTADO = estadoActual

                        if (estadoActual == "Done") {
                            echo "El ticket ya está finalizado. No se realizarán más acciones."

                            def payloadTeams = groovy.json.JsonOutput.toJson([
                                text: "Ticket ${params.TICKET_JIRA} | Estado actual: Finalizado"
                            ])
                            writeFile file: 'teams_done.json', text: payloadTeams
                            sh "curl -X POST -H 'Content-Type: application/json' --data @teams_done.json ${TEAMS_WEBHOOK}"

                            error("El ticket ya está en estado Done, pipeline detenido.")
                        }
                    }
                }
            }
        }

        stage('Cambiar Estado (si se indica)') {
            when {
                expression { params.TARGET_STATE?.trim() }
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {

                        def transiciones = [
                            "To Do": "11",
                            "In Progress": "21",
                            "ATRASADO": "2",
                            "Done": "31"
                        ]

                        def estadoObjetivo = params.TARGET_STATE
                        def transitionId = transiciones[estadoObjetivo]

                        echo "Actualizando ticket ${params.TICKET_JIRA} a '${estadoObjetivo}'..."

                        def payloadTrans = groovy.json.JsonOutput.toJson([transition: [id: transitionId]])
                        writeFile file: 'transicion.json', text: payloadTrans

                        sh """
                            curl -s -u '${JIRA_USER}:${JIRA_API_TOKEN}' \
                            -X POST '${JIRA_API_URL}${params.TICKET_JIRA}/transitions' \
                            -H 'Content-Type: application/json' \
                            --data @transicion.json
                        """

                        env.JIRA_ESTADO = estadoObjetivo
                    }
                }
            }
        }

        stage('Notificar a Teams y Agregar Comentario a Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {

                        def estado = env.JIRA_ESTADO ?: "Desconocido"
                        def mensajeSimple = [
                            "To Do"      : "Tareas por hacer",
                            "In Progress": "En progreso",
                            "ATRASADO"   : "Atrasado",
                            "Done"       : "Finalizado"
                        ]
                        def texto = mensajeSimple.get(estado, "Sin estado asignado")

                        // ===== Notificación a Teams =====
                        def payloadTeams = groovy.json.JsonOutput.toJson([
                            text: "Ticket ${params.TICKET_JIRA} | Estado actual: ${texto}"
                        ])
                        writeFile file: 'teams.json', text: payloadTeams
                        sh "curl -X POST -H 'Content-Type: application/json' --data @teams.json ${TEAMS_WEBHOOK}"

                        // ===== Comentario en Jira =====
                        def comentario = groovy.json.JsonOutput.toJson([
                            body: [
                                type: "doc",
                                version: 1,
                                content: [[
                                    type: "paragraph",
                                    content: [[type: "text", text: "Ticket ${params.TICKET_JIRA} | Estado actual: ${texto}"]]
                                ]]
                            ]
                        ])
                        writeFile file: 'comentario.json', text: comentario

                        sh """
                            curl -s -u '${JIRA_USER}:${JIRA_API_TOKEN}' \
                            -X POST '${JIRA_API_URL}${params.TICKET_JIRA}/comment' \
                            -H 'Content-Type: application/json' \
                            --data @comentario.json
                        """
                    }
                }
            }
        }
    }

    post {
        success { echo "Pipeline ejecutado exitosamente" }
        failure { echo "Pipeline falló durante la ejecución" }
        always {
            echo "================================================"
            echo " FIN DE LA EJECUCIÓN "
            echo " Fecha: ${new Date()}"
            echo "================================================"
        }
    }
}
