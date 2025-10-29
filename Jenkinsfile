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

        stage('Validación de Parámetros Jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        echo "==============================================="
                        echo " Validando estado del ticket ${params.TICKET_JIRA}"
                        echo "==============================================="

                        def estado = sh(script: """ bash -c '
                            curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                            -X GET "${JIRA_API_URL}${params.TICKET_JIRA}" -H "Accept: application/json" \
                            | jq -r ".fields.status.name // \\"Desconocido\\""
                        ' """, returnStdout: true).trim()

                        echo "Estado actual del ticket: ${estado}"

                        if (estado.toLowerCase() in ['done', 'finalizado', 'cerrado', 'completado']) {
                            def msgError = groovy.json.JsonOutput.toJson([
                                text: "El ticket ${params.TICKET_JIRA} ya se encuentra en estado '${estado}'. No se puede continuar con la ejecución del pipeline."
                            ])
                            sh """ curl -X POST -H 'Content-Type: application/json' \
                            --data-raw '${msgError}' ${TEAMS_WEBHOOK} """
                            error("Ticket ${params.TICKET_JIRA} ya se encuentra en estado ${estado}. Pipeline detenido.")
                        }

                        if (estado.toLowerCase() in ['in progress', 'en curso']) {
                            echo "Transicionando automáticamente el ticket ${params.TICKET_JIRA} al estado 'Done'..."

                            // 🔹 Transicionar a Done
                            sh(script: """ bash -c '
                                curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                                -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/transitions" \
                                -H "Content-Type: application/json" \
                                -d "{\\"transition\\":{\\"name\\":\\"Done\\"}}"
                            ' """, returnStdout: true).trim()

                            // 🔹 Agregar comentario indicando que el ticket se actualizó y está finalizado
                            def comentario = groovy.json.JsonOutput.toJson([
                                body: "El ticket ${params.TICKET_JIRA} fue actualizado automáticamente al estado 'Done' y marcado como finalizado por el pipeline de Jenkins (${env.JOB_NAME}."
                            ])
                            sh """ curl -s -u "$JIRA_USER:$JIRA_API_TOKEN" \
                            -X POST "${JIRA_API_URL}${params.TICKET_JIRA}/comment" \
                            -H "Content-Type: application/json" \
                            --data-raw '${comentario}' """

                            // 🔹 Notificación Teams
                            def msgOk = groovy.json.JsonOutput.toJson([
                                text: "El ticket ${params.TICKET_JIRA} fue actualizado automáticamente al estado 'Done' y se dejó un comentario en Jira indicando que está finalizado."
                            ])
                            sh """ curl -X POST -H 'Content-Type: application/json' \
                            --data-raw '${msgOk}' ${TEAMS_WEBHOOK} """
                        } else {
                            def msgInfo = groovy.json.JsonOutput.toJson([
                                text: "El ticket ${params.TICKET_JIRA} se encuentra en estado '${estado}'. No se realizó ningún cambio."
                            ])
                            sh """ curl -X POST -H 'Content-Type: application/json' \
                            --data-raw '${msgInfo}' ${TEAMS_WEBHOOK} """
                        }
                    }
                }
            }
        }
    }
     // 🔹 BLOQUE 2: COMENTAR EN JIRA 
        stage('Post-Coment-jira') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'JIRA_TOKEN', usernameVariable: 'JIRA_USER', passwordVariable: 'JIRA_API_TOKEN')]) {
                        def auth = java.util.Base64.encoder.encodeToString("${JIRA_USER}:${JIRA_API_TOKEN}".getBytes("UTF-8"))
                        def comentario = "Este ticket fue actualizado correctamente"

                        def response = sh(
                            script: """
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
                                                    {
                                                        "type": "text",
                                                        "text": "${comentario}"
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                }'
                            """,
                            returnStdout: true
                        ).trim()

                        echo "Comentario enviado al ticket ${params.TICKET_JIRA}: ${response}"
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
